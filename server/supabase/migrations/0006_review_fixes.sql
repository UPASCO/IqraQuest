-- IqraQuest — mode Classe : correctifs de revue.
--
-- Cinq défauts trouvés en relisant le socle avec l'œil d'un attaquant et
-- celui d'une classe. Aucun n'était visible depuis l'application : tous
-- se seraient manifestés en production, deux d'entre eux en silence.

-- ---------------------------------------------------------------------
-- 1. Une politique d'écriture qui contournait toutes les vérifications
-- ---------------------------------------------------------------------
--
-- `sessions_own` était `for all` : avec les droits de table que Supabase
-- accorde par défaut au rôle `authenticated`, un enseignant connecté
-- pouvait insérer une séance directement dans la table, sans passer par
-- `open_session` — donc sans contrôle de l'échéance de sa licence ni du
-- nombre de salles payées. Toute la logique commerciale était
-- contournable avec une requête.
--
-- Les tables ne sont plus qu'en lecture pour l'enseignant. Écrire passe
-- par les fonctions, et par elles seules.
drop policy if exists sessions_own on public.sessions;

create policy sessions_own on public.sessions
  for select using (
    licence_id in (select id from public.licences where owner_id = auth.uid())
  );

-- Ceinture et bretelles : même si une politique redevenait permissive un
-- jour, le rôle n'a plus le droit d'écrire dans ces tables.
revoke insert, update, delete on public.sessions from authenticated, anon;
revoke insert, update, delete on public.participants from authenticated, anon;
revoke insert, update, delete on public.answers from authenticated, anon;
revoke insert, update, delete on public.licences from authenticated, anon;
revoke insert, update, delete on public.reports from authenticated, anon;

-- ---------------------------------------------------------------------
-- 2. Fermer une séance la faisait disparaître sous les élèves
-- ---------------------------------------------------------------------
--
-- `close_session` supprimait la ligne. Les appareils des élèves, qui
-- interrogent la salle, recevaient alors « code inconnu » — traduit à
-- l'écran par « aucune classe joignable ». Au lieu de voir la fin de la
-- séance et leur score, les enfants voyaient une erreur réseau.
--
-- La séance reste donc, marquée close et en phase `over` ; ce sont les
-- participants qui partent tout de suite, avec leurs réponses. La
-- promesse d'oubli est intacte — c'est même la seule chose qui contenait
-- des prénoms — et la classe voit sa dernière image.
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
  if s.closed_at is not null then
    return jsonb_build_object('closed', true, 'participants', 0);
  end if;

  select count(*) into head_count from public.participants where session_id = s.id;

  -- L'index est un entier : le trier comme du texte donnait 0, 1, 10, 2…
  -- et un rapport dont les questions ne sont pas dans l'ordre de la
  -- leçon ne sert à personne.
  select coalesce(jsonb_agg(row order by (row->>'index')::int), '[]'::jsonb)
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

  -- Les enfants partent maintenant ; la séance, elle, reste le temps que
  -- les écrans voient qu'elle est finie. `purge_old_sessions` l'emporte
  -- au plus tard deux jours après.
  delete from public.participants where session_id = s.id;
  update public.sessions
     set phase = 'over', closed_at = now()
   where id = s.id;

  return jsonb_build_object('closed', true, 'participants', head_count);
end;
$$;

-- ---------------------------------------------------------------------
-- 3. Le tableau doit pouvoir montrer une séance close
-- ---------------------------------------------------------------------
--
-- `board_state` ignorait les séances closes : après la correction
-- ci-dessus, elles seraient devenues invisibles au lieu d'afficher leur
-- fin. Rejoindre et répondre restent impossibles — `join_session` refuse
-- la phase `over`, `submit_answer` exige la phase `asking`.
create or replace function public.board_state(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  s public.sessions;
begin
  select * into s from public.sessions
    where code = upper(btrim(p_code));
  if not found then
    return jsonb_build_object('error', 'unknown_code');
  end if;

  return jsonb_build_object(
    'sessionId', s.id,
    'code', s.code,
    'lessonId', s.lesson_id,
    'boardLanguage', s.board_language,
    'teamCount', s.team_count,
    'questionIds', to_jsonb(s.question_ids),
    'phase', s.phase,
    'currentIndex', s.current_index,
    'askedAt', s.asked_at,
    'secondsPerQuestion', s.seconds_per_question,
    'participants', coalesce((
      select jsonb_agg(jsonb_build_object('nickname', pp.nickname, 'team', pp.team)
                       order by pp.joined_at)
      from public.participants pp where pp.session_id = s.id
    ), '[]'::jsonb),
    'squaresByTeam', coalesce((
      select jsonb_object_agg(t.team::text, coalesce(t.squares, 0))
      from (
        select pp.team, count(a.*) filter (where a.correct) as squares
        from public.participants pp
        left join public.answers a
          on a.participant_id = pp.id and a.session_id = s.id
        where pp.session_id = s.id
        group by pp.team
      ) t
    ), '{}'::jsonb),
    'answeredCurrent', (
      select count(*) from public.answers a
      where a.session_id = s.id and a.question_index = s.current_index
    ),
    'scoring', s.scoring_mode,
    'pupilScores', case when s.scoring_mode = 'individual' then coalesce((
      select jsonb_agg(jsonb_build_object(
               'nickname', x.nickname,
               'team', x.team,
               'correct', x.correct
             ) order by x.correct desc, x.joined_at)
      from (
        select pp.nickname, pp.team, pp.joined_at,
               count(a.*) filter (where a.correct) as correct
        from public.participants pp
        left join public.answers a on a.participant_id = pp.id
        where pp.session_id = s.id
        group by pp.id, pp.nickname, pp.team, pp.joined_at
      ) x
    ), '[]'::jsonb) else '[]'::jsonb end,
    'answersByQuestion', coalesce((
      select jsonb_object_agg(q.question_index::text, q.n)
      from (
        select a.question_index, count(*) as n
        from public.answers a
        where a.session_id = s.id
        group by a.question_index
      ) q
    ), '{}'::jsonb),
    'correctByQuestion', coalesce((
      select jsonb_object_agg(q.question_index::text, q.n)
      from (
        select a.question_index, count(*) filter (where a.correct) as n
        from public.answers a
        where a.session_id = s.id
        group by a.question_index
      ) q
    ), '{}'::jsonb)
  );
end;
$$;

grant execute on function public.board_state(text) to anon, authenticated;

-- ---------------------------------------------------------------------
-- 4. Une adresse non confirmée héritait de la licence d'une école
-- ---------------------------------------------------------------------
--
-- `my_licence()` rattachait une licence à l'adresse d'un compte sans
-- vérifier que cette adresse avait été confirmée. Le lien magique
-- confirme de lui-même, mais rien n'interdit de créer un compte
-- autrement : quelqu'un s'inscrivant en `nimporte.qui@ecole-annour.fr`
-- sans jamais recevoir de courrier aurait hérité de la licence de
-- l'école. La confirmation devient obligatoire.
create or replace function public.my_licence()
returns public.licences
language plpgsql
security definer
set search_path = public
as $$
declare
  l public.licences;
  claimed_email citext;
  claimed_domain citext;
begin
  if auth.uid() is null then
    return null;
  end if;

  select * into l from public.licences where owner_id = auth.uid();
  if found then
    return l;
  end if;

  select email into claimed_email from auth.users
    where id = auth.uid() and email_confirmed_at is not null;
  if claimed_email is null then
    return null;
  end if;

  update public.licences
    set owner_id = auth.uid()
    where email = claimed_email and owner_id is null
    returning * into l;
  if found then
    return l;
  end if;

  claimed_domain := split_part(claimed_email::text, '@', 2);
  select * into l from public.licences
    where domain is not null and domain = claimed_domain;

  return l;
end;
$$;

grant execute on function public.my_licence() to authenticated;
revoke all on function public.my_licence() from anon;

-- ---------------------------------------------------------------------
-- 5. Ce que la correction d'une réponse prouve, et ce qu'elle ne prouve pas
-- ---------------------------------------------------------------------
--
-- La migration 0001 affirmait que « le serveur ne croit pas l'élève sur
-- la justesse ». C'est faux, et il vaut mieux l'écrire que le laisser
-- croire : `submit_answer` reçoit un numéro et déclare juste le numéro
-- zéro. Un appareil modifié peut donc envoyer zéro à chaque question.
--
-- Stocker la clé de correction dans la séance n'y changerait presque
-- rien : la banque entière, réponses comprises, est embarquée dans
-- l'application — un élève déterminé connaît déjà la bonne réponse avant
-- de tricher. Ce mode est un outil de classe, sous le regard d'un
-- enseignant, pas un examen ; le mélange des réponses par appareil
-- empêche de copier sur le voisin, ce qui est le seul risque réel dans
-- une salle.
comment on function public.submit_answer(text, uuid, int, int) is
  'Enregistre une réponse. La justesse est déduite du numéro envoyé '
  '(zéro = la bonne réponse dans la banque figée) : ce n''est pas une '
  'protection contre un appareil modifié, et ça n''a pas à en être une — '
  'la banque et ses réponses sont de toute façon embarquées dans '
  'l''application. Ce qui est protégé, c''est la copie sur le voisin, '
  'par le mélange des réponses propre à chaque appareil.';
