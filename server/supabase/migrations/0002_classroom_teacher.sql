-- IqraQuest — mode Classe : la console de l'enseignant.
--
-- L'enseignant est connecté (lien magique envoyé à l'adresse qui a payé)
-- et pilote la séance depuis le web. Comme pour les élèves, il ne touche
-- pas aux tables : il appelle les fonctions ci-dessous, qui vérifient
-- d'abord que la licence est la sienne, valide, et pas déjà occupée
-- ailleurs.
--
-- Le serveur ne sait rien du contenu. C'est la console — qui embarque la
-- même banque de questions que l'app — qui choisit les questions de la
-- leçon et les passe ici. Cette base ne stocke que des identifiants de
-- cartes ; elle ne pourrait pas dire ce qu'une seule d'entre elles
-- demande.

-- ---------------------------------------------------------------------
-- La licence de l'appelant
-- ---------------------------------------------------------------------
--
-- Stripe crée la licence sur une adresse e-mail, avant que l'acheteur ne
-- se soit jamais connecté. À la première connexion par lien magique, le
-- compte réclame la licence portant son adresse. C'est ce raccord qui
-- évite d'avoir à créer un compte au moment du paiement.
create or replace function public.my_licence()
returns public.licences
language plpgsql
security definer
set search_path = public
as $$
declare
  l public.licences;
  claimed_email citext;
begin
  if auth.uid() is null then
    return null;
  end if;

  select * into l from public.licences where owner_id = auth.uid();
  if found then
    return l;
  end if;

  select email into claimed_email from auth.users where id = auth.uid();
  if claimed_email is null then
    return null;
  end if;

  update public.licences
    set owner_id = auth.uid()
    where email = claimed_email and owner_id is null
    returning * into l;

  return l;
end;
$$;

-- ---------------------------------------------------------------------
-- Ouvrir une séance
-- ---------------------------------------------------------------------
create or replace function public.open_session(
  p_lesson_id text,
  p_question_ids text[],
  p_team_count int default 3,
  p_board_language text default 'fr',
  p_seconds_per_question int default 0,
  p_keep_individual_scores bool default false,
  p_scoring_mode text default 'teams'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  l public.licences;
  running int;
  s public.sessions;
begin
  l := public.my_licence();
  if l.id is null then
    return jsonb_build_object('error', 'no_licence');
  end if;
  if l.expires_at < now() then
    return jsonb_build_object('error', 'licence_expired');
  end if;

  -- Une licence « classe » fait tourner une salle à la fois ; une
  -- licence « école » en fait tourner autant qu'elle en a payé. Les
  -- séances oubliées ouvertes ne bloquent pas indéfiniment : au-delà de
  -- quatre heures, une séance n'est plus une séance.
  select count(*) into running from public.sessions
    where licence_id = l.id
      and closed_at is null
      and opened_at > now() - interval '4 hours';
  if running >= l.concurrent_sessions then
    return jsonb_build_object('error', 'too_many_sessions',
                              'limit', l.concurrent_sessions);
  end if;

  if cardinality(p_question_ids) = 0 then
    return jsonb_build_object('error', 'no_questions');
  end if;

  insert into public.sessions (
    code, licence_id, lesson_id, board_language, team_count,
    question_ids, seconds_per_question, keep_individual_scores, scoring_mode
  ) values (
    public.new_session_code(), l.id, p_lesson_id, p_board_language,
    greatest(2, least(4, p_team_count)), p_question_ids,
    greatest(0, least(180, p_seconds_per_question)), p_keep_individual_scores,
    case when p_scoring_mode = 'individual' then 'individual' else 'teams' end
  ) returning * into s;

  return jsonb_build_object('sessionId', s.id, 'code', s.code);
end;
$$;

-- ---------------------------------------------------------------------
-- Mener la séance
-- ---------------------------------------------------------------------
--
-- Trois gestes : poser la question suivante, montrer la réponse, fermer.
-- L'enseignant garde la main sur le rythme — il peut révéler avant la
-- fin du temps parce que tout le monde a répondu, ou passer à la suite
-- alors que deux élèves n'ont pas fini. C'est une salle de classe, pas
-- un tournoi.
create or replace function public.advance_session(p_session_id uuid, p_action text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  l public.licences;
  s public.sessions;
begin
  l := public.my_licence();
  if l.id is null then
    return jsonb_build_object('error', 'no_licence');
  end if;
  select * into s from public.sessions
    where id = p_session_id and licence_id = l.id;
  if not found then
    return jsonb_build_object('error', 'unknown_session');
  end if;

  if p_action = 'ask' then
    -- Depuis le salon, la première question ; après une révélation, la
    -- suivante. La dernière révélée termine la séance.
    if s.phase = 'revealing' then
      if s.current_index + 1 >= cardinality(s.question_ids) then
        update public.sessions set phase = 'over' where id = s.id returning * into s;
        return jsonb_build_object('phase', s.phase);
      end if;
      update public.sessions
        set current_index = s.current_index + 1, phase = 'asking', asked_at = now()
        where id = s.id returning * into s;
    elsif s.phase = 'lobby' then
      update public.sessions
        set phase = 'asking', current_index = 0, asked_at = now()
        where id = s.id returning * into s;
    else
      return jsonb_build_object('error', 'not_now');
    end if;

  elsif p_action = 'reveal' then
    if s.phase <> 'asking' then
      return jsonb_build_object('error', 'not_now');
    end if;
    update public.sessions set phase = 'revealing' where id = s.id returning * into s;

  elsif p_action = 'close' then
    perform public.close_session(s.id);
    return jsonb_build_object('phase', 'over', 'closed', true);

  else
    return jsonb_build_object('error', 'unknown_action');
  end if;

  return jsonb_build_object('phase', s.phase, 'currentIndex', s.current_index);
end;
$$;

-- ---------------------------------------------------------------------
-- Fermer : écrire le rapport, puis effacer les enfants
-- ---------------------------------------------------------------------
--
-- C'est ici que la promesse d'anonymat se tient vraiment. Le rapport
-- compte les réussites par question — ce que l'enseignant ré-enseignera
-- la semaine suivante — et ne nomme personne. Les prénoms ne sont gardés
-- que si l'enseignant l'a demandé à l'ouverture ; sinon la séance part
-- avec ses participants et leurs réponses, tout de suite.
create or replace function public.close_session(p_session_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  l public.licences;
  s public.sessions;
  per_question jsonb;
  per_pupil jsonb;
  head_count int;
begin
  l := public.my_licence();
  if l.id is null then
    return jsonb_build_object('error', 'no_licence');
  end if;
  select * into s from public.sessions
    where id = p_session_id and licence_id = l.id;
  if not found then
    return jsonb_build_object('error', 'unknown_session');
  end if;

  select count(*) into head_count from public.participants where session_id = s.id;

  select coalesce(jsonb_agg(row order by row->>'index'), '[]'::jsonb)
    into per_question
    from (
      select jsonb_build_object(
        'index', q.i,
        'questionId', s.question_ids[q.i + 1],
        'correct', count(a.*) filter (where a.correct),
        'answered', count(a.*)
      ) as row
      from generate_series(0, cardinality(s.question_ids) - 1) as q(i)
      left join public.answers a
        on a.session_id = s.id and a.question_index = q.i
      group by q.i
    ) rows;

  if s.keep_individual_scores then
    select coalesce(jsonb_agg(jsonb_build_object(
             'nickname', pp.nickname,
             'team', pp.team,
             'correct', count(a.*) filter (where a.correct)
           ) order by count(a.*) filter (where a.correct) desc), '[]'::jsonb)
      into per_pupil
      from public.participants pp
      left join public.answers a on a.participant_id = pp.id
      where pp.session_id = s.id
      group by pp.id, pp.nickname, pp.team;
  end if;

  insert into public.reports (
    licence_id, session_code, lesson_id, played_at,
    participant_count, per_question, per_pupil
  ) values (
    l.id, s.code, s.lesson_id, s.opened_at, head_count, per_question, per_pupil
  );

  -- Le rapport est écrit : la séance n'a plus rien à porter.
  delete from public.sessions where id = s.id;

  return jsonb_build_object('closed', true, 'participants', head_count);
end;
$$;

grant execute on function public.my_licence() to authenticated;
grant execute on function public.open_session(text, text[], int, text, int, bool, text) to authenticated;
grant execute on function public.advance_session(uuid, text) to authenticated;
grant execute on function public.close_session(uuid) to authenticated;

revoke all on function public.my_licence() from anon;
revoke all on function public.open_session(text, text[], int, text, int, bool, text) from anon;
revoke all on function public.advance_session(uuid, text) from anon;
revoke all on function public.close_session(uuid) from anon;

-- ---------------------------------------------------------------------
-- Le ménage, tous les jours
-- ---------------------------------------------------------------------
--
-- Une séance qu'on a oublié de fermer — la sonnerie a sonné, l'ordinateur
-- s'est éteint — ne doit pas garder des prénoms d'enfants pour
-- l'éternité. Deux jours, puis elle part. Si pg_cron n'est pas
-- disponible sur le palier choisi, la même fonction s'appelle depuis une
-- fonction Edge planifiée : voir server/README.md.
do $$
begin
  if exists (select 1 from pg_available_extensions where name = 'pg_cron') then
    create extension if not exists pg_cron;
    perform cron.schedule(
      'iqraquest-purge-sessions',
      '17 3 * * *',
      $cron$ select public.purge_old_sessions(2); $cron$
    );
  else
    raise notice 'pg_cron indisponible : planifier purge_old_sessions autrement (voir server/README.md)';
  end if;
end;
$$;
