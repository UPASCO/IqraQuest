-- IqraQuest — mode Classe : le socle.
--
-- Un enseignant achète une licence sur le web (Stripe), ouvre une séance
-- et projette le plateau ; ses élèves rejoignent depuis l'app avec un
-- code, sans compte, sans e-mail, sans identifiant qui les suive.
--
-- Deux principes gouvernent tout ce fichier :
--
-- 1. UN ÉLÈVE N'EST JAMAIS UNE LIGNE QU'ON PEUT LIRE DE L'EXTÉRIEUR.
--    Le rôle anonyme n'a AUCUN droit de lecture ni d'écriture directe
--    sur ces tables. Tout passe par les fonctions `security definer`
--    plus bas, qui exigent le code de la séance et, pour écrire, le
--    jeton de l'élève. Un code qui fuite ouvre une séance de quinze
--    minutes, jamais une base de données.
--
-- 2. CE QUI RESTE APRÈS LA SÉANCE EST AGRÉGÉ.
--    Le rapport que l'enseignant garde compte les réussites par
--    question, pas par enfant, sauf si l'enseignant le demande
--    explicitement à l'ouverture de la séance. Les lignes nominatives
--    s'effacent avec la séance.

create extension if not exists "pgcrypto";
create extension if not exists "citext";

-- ---------------------------------------------------------------------
-- Licences — qui a payé, et jusqu'à quand
-- ---------------------------------------------------------------------
--
-- L'enseignant est la seule identité du système, et elle est réduite au
-- minimum : une adresse e-mail, celle qui a payé, sur laquelle arrive le
-- lien de connexion. Pas de mot de passe, pas de profil, pas de nom.
create table public.licences (
  id uuid primary key default gen_random_uuid(),
  -- Rattachée au compte Supabase créé par le lien magique. Nulle tant
  -- que l'acheteur ne s'est pas connecté une première fois : Stripe
  -- crée la licence, la connexion la réclame.
  owner_id uuid references auth.users on delete set null,
  email citext not null unique,
  plan text not null check (plan in ('essai', 'classe', 'ecole')),
  -- Combien de séances peuvent tourner en même temps. Une classe en a
  -- une ; une école en a autant que de salles.
  concurrent_sessions int not null default 1 check (concurrent_sessions between 1 and 100),
  expires_at timestamptz not null,
  stripe_customer_id text,
  stripe_subscription_id text,
  created_at timestamptz not null default now()
);

create index licences_owner_idx on public.licences (owner_id);

comment on table public.licences is
  'Une licence par école ou par enseignant. Écrite par la fonction Edge '
  'qui reçoit le webhook Stripe, jamais par un client.';

-- ---------------------------------------------------------------------
-- Séances
-- ---------------------------------------------------------------------
--
-- Les questions sont choisies à l'ouverture et figées dans la séance :
-- tous les appareils voient la même carte au même moment, et chacun
-- l'affiche dans sa propre langue puisque la banque est embarquée dans
-- l'app. Une élève arabophone et sa voisine francophone répondent à la
-- même question, chacune dans sa langue.
create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  licence_id uuid not null references public.licences on delete cascade,
  lesson_id text not null,
  -- La langue du tableau projeté. Celle de l'élève est celle de son app.
  board_language text not null default 'fr',
  team_count int not null default 3 check (team_count between 2 and 4),
  question_ids text[] not null check (cardinality(question_ids) between 1 and 30),
  phase text not null default 'lobby'
    check (phase in ('lobby', 'asking', 'revealing', 'over')),
  current_index int not null default 0,
  -- Ouverte à l'appui sur « Question suivante » : l'élève ne peut
  -- répondre qu'à la question en cours, et le temps se compte de là.
  asked_at timestamptz,
  -- Zéro = pas de chrono. L'enseignant peut toujours révéler à la main.
  seconds_per_question int not null default 0 check (seconds_per_question between 0 and 180),
  -- Faux par défaut : le rapport ne garde alors que des agrégats.
  keep_individual_scores bool not null default false,
  opened_at timestamptz not null default now(),
  closed_at timestamptz
);

create index sessions_licence_idx on public.sessions (licence_id);
create index sessions_open_idx on public.sessions (opened_at) where closed_at is null;

-- ---------------------------------------------------------------------
-- Participants — anonymes par construction
-- ---------------------------------------------------------------------
--
-- Un prénom, une équipe, un jeton. Le jeton n'existe que pour cette
-- séance : il permet à un élève dont le wifi a lâché de revenir avec son
-- score, et ne le relie à rien d'autre, jamais. Aucun identifiant
-- d'appareil, aucune adresse, aucun compte.
create table public.participants (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions on delete cascade,
  nickname text not null check (length(btrim(nickname)) between 1 and 24),
  team int not null check (team between 0 and 3),
  token uuid not null default gen_random_uuid(),
  joined_at timestamptz not null default now()
);

create unique index participants_token_idx on public.participants (session_id, token);
create index participants_session_idx on public.participants (session_id);

-- ---------------------------------------------------------------------
-- Réponses
-- ---------------------------------------------------------------------
--
-- Une réponse par élève et par question, définitive : la clé primaire
-- interdit de se raviser, et un `on conflict do nothing` fait qu'un
-- envoi renvoyé deux fois par un réseau capricieux ne compte qu'une.
create table public.answers (
  session_id uuid not null references public.sessions on delete cascade,
  participant_id uuid not null references public.participants on delete cascade,
  question_index int not null check (question_index >= 0),
  choice int not null check (choice between 0 and 3),
  correct bool not null,
  answered_at timestamptz not null default now(),
  primary key (session_id, participant_id, question_index)
);

create index answers_session_question_idx on public.answers (session_id, question_index);

-- ---------------------------------------------------------------------
-- Rapports — ce que l'enseignant garde
-- ---------------------------------------------------------------------
create table public.reports (
  id uuid primary key default gen_random_uuid(),
  licence_id uuid not null references public.licences on delete cascade,
  session_code text not null,
  lesson_id text not null,
  played_at timestamptz not null,
  participant_count int not null,
  -- [{index, questionId, correct, total}] — combien d'élèves ont
  -- réussi chaque question. C'est ce qui se ré-enseigne la semaine
  -- suivante, et ça ne nomme personne.
  per_question jsonb not null,
  -- [{nickname, score}] uniquement si l'enseignant l'a demandé.
  per_pupil jsonb,
  created_at timestamptz not null default now()
);

create index reports_licence_idx on public.reports (licence_id, played_at desc);

-- ---------------------------------------------------------------------
-- Le verrou : rien n'est accessible directement
-- ---------------------------------------------------------------------
alter table public.licences enable row level security;
alter table public.sessions enable row level security;
alter table public.participants enable row level security;
alter table public.answers enable row level security;
alter table public.reports enable row level security;

-- Le rôle anonyme (celui de l'app des élèves) ne reçoit AUCUNE politique
-- de lecture ou d'écriture : sans politique, RLS refuse tout. Il ne peut
-- appeler que les fonctions publiées à la fin de ce fichier.

-- L'enseignant connecté ne voit que ce qui dépend de sa licence.
create policy licences_own on public.licences
  for select using (owner_id = auth.uid());

create policy sessions_own on public.sessions
  for all using (
    licence_id in (select id from public.licences where owner_id = auth.uid())
  ) with check (
    licence_id in (select id from public.licences where owner_id = auth.uid())
  );

create policy participants_own on public.participants
  for select using (
    session_id in (
      select s.id from public.sessions s
      join public.licences l on l.id = s.licence_id
      where l.owner_id = auth.uid()
    )
  );

create policy answers_own on public.answers
  for select using (
    session_id in (
      select s.id from public.sessions s
      join public.licences l on l.id = s.licence_id
      where l.owner_id = auth.uid()
    )
  );

create policy reports_own on public.reports
  for select using (
    licence_id in (select id from public.licences where owner_id = auth.uid())
  );

-- ---------------------------------------------------------------------
-- Le code de séance
-- ---------------------------------------------------------------------
--
-- Six caractères lus de loin sur un tableau et recopiés sans faute par
-- un enfant de huit ans : ni O ni 0, ni I ni 1 ni L, ni U ni V. Ce qui
-- reste tient encore 24^6, soit 191 millions de combinaisons — de quoi
-- rendre une devinette inutile pendant les quinze minutes où le code
-- vit.
create or replace function public.new_session_code()
returns text
language plpgsql
as $$
declare
  alphabet constant text := 'ABCDEFGHJKMNPQRSTWXYZ2345678';
  candidate text;
  i int;
begin
  loop
    candidate := '';
    for i in 1..6 loop
      candidate := candidate || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
    end loop;
    exit when not exists (select 1 from public.sessions where code = candidate);
  end loop;
  return candidate;
end;
$$;

-- ---------------------------------------------------------------------
-- Ce que l'élève peut faire : trois gestes, pas un de plus
-- ---------------------------------------------------------------------

-- Rejoindre. Retourne le jeton et l'état courant. L'élève est réparti
-- dans l'équipe la moins nombreuse, pour que les chevaux partent à
-- égalité — un enseignant qui veut ses propres équipes les changera
-- depuis sa console.
create or replace function public.join_session(p_code text, p_nickname text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  s public.sessions;
  chosen_team int;
  p public.participants;
begin
  select * into s from public.sessions
    where code = upper(btrim(p_code)) and closed_at is null;
  if not found then
    return jsonb_build_object('error', 'unknown_code');
  end if;
  if s.phase = 'over' then
    return jsonb_build_object('error', 'session_over');
  end if;
  if length(btrim(p_nickname)) = 0 then
    return jsonb_build_object('error', 'empty_nickname');
  end if;
  -- Une classe entière, pas un stade : la borne protège la séance d'un
  -- code recopié hors de la salle.
  if (select count(*) from public.participants where session_id = s.id) >= 60 then
    return jsonb_build_object('error', 'session_full');
  end if;

  select t.team into chosen_team
    from generate_series(0, s.team_count - 1) as t(team)
    left join public.participants pp
      on pp.session_id = s.id and pp.team = t.team
    group by t.team
    order by count(pp.id), t.team
    limit 1;

  insert into public.participants (session_id, nickname, team)
    values (s.id, btrim(p_nickname), chosen_team)
    returning * into p;

  return jsonb_build_object(
    'sessionId', s.id,
    'participantId', p.id,
    'token', p.token,
    'team', p.team,
    'teamCount', s.team_count,
    'lessonId', s.lesson_id,
    'phase', s.phase,
    'currentIndex', s.current_index,
    'questionCount', cardinality(s.question_ids)
  );
end;
$$;

-- Répondre. Le serveur ne croit pas l'élève sur la justesse : il ne
-- reçoit qu'un numéro de case, et c'est la banque figée dans la séance
-- qui dit si c'est juste. La bonne réponse est à l'index 0 dans la
-- banque, mais l'app mélange l'ordre à l'affichage — l'élève renvoie
-- donc l'index d'origine de la réponse qu'il a touchée.
create or replace function public.submit_answer(
  p_code text,
  p_token uuid,
  p_question_index int,
  p_choice int
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  s public.sessions;
  p public.participants;
  is_correct bool;
begin
  select * into s from public.sessions
    where code = upper(btrim(p_code)) and closed_at is null;
  if not found then
    return jsonb_build_object('error', 'unknown_code');
  end if;
  select * into p from public.participants
    where session_id = s.id and token = p_token;
  if not found then
    return jsonb_build_object('error', 'unknown_participant');
  end if;
  -- On ne répond qu'à la question ouverte, et seulement tant qu'elle
  -- l'est : une réponse qui arrive après la révélation ne compte pas.
  if s.phase <> 'asking' or p_question_index <> s.current_index then
    return jsonb_build_object('error', 'not_open');
  end if;
  if s.seconds_per_question > 0
     and s.asked_at is not null
     -- Deux secondes de grâce pour un réseau d'école qui traîne.
     and now() > s.asked_at + make_interval(secs => s.seconds_per_question + 2) then
    return jsonb_build_object('error', 'too_late');
  end if;

  is_correct := (p_choice = 0);

  insert into public.answers (session_id, participant_id, question_index, choice, correct)
    values (s.id, p.id, p_question_index, p_choice, is_correct)
    on conflict do nothing;

  return jsonb_build_object('recorded', true, 'correct', is_correct);
end;
$$;

-- Regarder. Le même appel sert à l'élève qui revient après une coupure
-- et au tableau projeté : l'état de la séance, les scores par équipe, et
-- combien d'élèves ont répondu — jamais qui, jamais quoi.
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
    where code = upper(btrim(p_code)) and closed_at is null;
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
    -- Une case par bonne réponse : c'est la règle du mode classe, et
    -- elle rend visible la contribution de chaque enfant sur le
    -- projecteur.
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
    -- De quoi fermer la séance sur les cartes que la classe a manquées,
    -- sans jamais nommer personne : deux compteurs par question, l'un
    -- des réponses reçues, l'autre des bonnes.
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

-- ---------------------------------------------------------------------
-- Qui a le droit d'appeler quoi
-- ---------------------------------------------------------------------
revoke all on function public.new_session_code() from anon, authenticated;

grant execute on function public.join_session(text, text) to anon, authenticated;
grant execute on function public.submit_answer(text, uuid, int, int) to anon, authenticated;
grant execute on function public.board_state(text) to anon, authenticated;

-- ---------------------------------------------------------------------
-- L'oubli
-- ---------------------------------------------------------------------
--
-- Une séance passée n'a plus de raison d'exister : le rapport de
-- l'enseignant, lui, est déjà écrit. Effacer la séance emporte ses
-- participants et leurs réponses (on delete cascade), donc les prénoms
-- des enfants disparaissent d'eux-mêmes. Appelé par pg_cron une fois par
-- jour ; la migration 0002 pose la planification, car elle demande une
-- extension que tous les paliers n'ont pas.
create or replace function public.purge_old_sessions(p_days int default 2)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  removed int;
begin
  delete from public.sessions
    where opened_at < now() - make_interval(days => p_days)
    returning 1 into removed;
  get diagnostics removed = row_count;
  return removed;
end;
$$;

revoke all on function public.purge_old_sessions(int) from anon, authenticated;
