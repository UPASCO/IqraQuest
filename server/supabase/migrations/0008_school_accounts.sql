-- IqraQuest — mode École : le compte, les cinq parties offertes, le bail
-- des appareils, et ce que Stripe doit savoir.
--
-- Ce que cette migration change, et pourquoi chaque chose :
--
--   1. Un compte se crée seul, et il est gratuit. Créer un compte donne
--      cinq parties ; la sixième demande une licence. Le compteur vit
--      ici, jamais dans un téléphone : désinstaller l'application ne
--      redonne rien.
--   2. Une offre à vendre : « IqraQuest École », deux salles à la fois,
--      un an. Les paliers 3/5/10 restent en base, retirés de la vente —
--      une licence qui les porte continue de marcher.
--   3. Les appareils tiennent un bail. Une séance compte tant qu'elle
--      donne signe de vie ; sans battement pendant cinq minutes, elle ne
--      compte plus. Une tablette qui a planté ne bloque personne.
--   4. Ouvrir une séance est atomique et rejouable : le quota, la limite
--      d'appareils et la création se font sous verrou, et la même
--      demande rejouée rend la même séance sans consommer un second
--      crédit.
--   5. Un événement Stripe reçu deux fois ne s'applique qu'une fois.
--   6. Un compte se supprime, et ce qui doit rester pour la facturation
--      reste chez Stripe, pas ici.

-- ---------------------------------------------------------------------
-- 1. Les paliers : une offre à vendre, une offre découverte
-- ---------------------------------------------------------------------
alter table public.plans
  add column if not exists free_games int
    check (free_games is null or free_games between 1 and 100);

comment on column public.plans.free_games is
  'Nombre de parties offertes avant qu''une licence payante soit exigée. '
  'Null = illimité (palier payé).';

insert into public.plans (id, rooms, duration, school_year, label, sellable, free_games)
values
  -- Le compte gratuit : deux salles comme l'offre payante, cinq parties,
  -- et une échéance qui n'arrive jamais — c'est le compteur qui ferme.
  ('decouverte', 2, interval '100 years', false, 'Offre découverte', false, 5),
  -- L'offre : 89 €/an chez Stripe, deux séances en même temps.
  ('ecole',      2, interval '1 year',    true,  'IqraQuest École',  true,  null)
on conflict (id) do update
  set rooms       = excluded.rooms,
      duration    = excluded.duration,
      school_year = excluded.school_year,
      label       = excluded.label,
      sellable    = excluded.sellable,
      free_games  = excluded.free_games;

-- Les paliers par salles quittent la vente sans disparaître.
update public.plans set sellable = false
 where id in ('ecole3', 'ecole5', 'ecole10', 'test1j', 'essai', 'classe');

-- ---------------------------------------------------------------------
-- 2. Ce qu'une licence sait de son abonnement
-- ---------------------------------------------------------------------
alter table public.licences
  add column if not exists free_games_used int not null default 0
    check (free_games_used >= 0),
  add column if not exists status text not null default 'active'
    check (status in ('active', 'trialing', 'past_due', 'unpaid', 'canceled',
                      'incomplete', 'incomplete_expired', 'paused', 'none')),
  add column if not exists current_period_start timestamptz,
  add column if not exists cancel_at_period_end bool not null default false,
  add column if not exists stripe_price_id text;

comment on column public.licences.free_games_used is
  'Parties ouvertes sur le quota gratuit. Incrémenté par open_session '
  'sous verrou, jamais par un client.';
comment on column public.licences.status is
  'Statut Stripe de l''abonnement, tel que le webhook l''a vu en dernier. '
  '''none'' pour une licence sans abonnement (découverte, ou posée à la main).';

-- ---------------------------------------------------------------------
-- 3. Le profil
-- ---------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  first_name text check (first_name is null or length(first_name) <= 80),
  last_name text check (last_name is null or length(last_name) <= 80),
  organization_name text check (organization_name is null or length(organization_name) <= 120),
  account_type text not null default 'school' check (account_type in ('school')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Lire et modifier son propre profil, rien d'autre. C'est la seule table
-- où une politique existe : tout le reste passe par des fonctions.
drop policy if exists profiles_own_read on public.profiles;
create policy profiles_own_read on public.profiles
  for select using (id = auth.uid());
drop policy if exists profiles_own_update on public.profiles;
create policy profiles_own_update on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());
revoke insert, delete on public.profiles from authenticated, anon;
grant select, update (first_name, last_name, organization_name, updated_at)
  on public.profiles to authenticated;

-- ---------------------------------------------------------------------
-- 4. Un compte neuf reçoit son profil et ses cinq parties
-- ---------------------------------------------------------------------
--
-- Déclenché par Supabase Auth à la création de l'utilisateur. Si une
-- licence existe déjà à cette adresse — l'école a payé avant de se
-- connecter —, on ne la double pas : `my_licence()` la rattachera.
create or replace function public.handle_new_school_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id) values (new.id)
  on conflict (id) do nothing;

  if new.email is not null then
    insert into public.licences
      (email, owner_id, plan, concurrent_sessions, expires_at, status)
    select new.email, new.id, p.id, p.rooms, now() + p.duration, 'none'
      from public.plans p where p.id = 'decouverte'
    on conflict (email) do nothing;
  end if;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_school on auth.users;
create trigger on_auth_user_created_school
  after insert on auth.users
  for each row execute function public.handle_new_school_user();

-- ---------------------------------------------------------------------
-- 5. Quelle licence est la mienne
-- ---------------------------------------------------------------------
--
-- Une école qui a acheté avant que ses enseignants s'inscrivent, ou
-- après : dans les deux cas un enseignant du domaine doit tomber sur la
-- licence de l'école, pas sur ses cinq parties personnelles. L'ordre :
--   1. ma licence, si elle n'est pas la découverte ;
--   2. la licence dont l'adresse est la mienne (rattachement) ;
--   3. la licence du domaine de mon adresse, si elle est payée ;
--   4. ma découverte.
create or replace function public.my_licence()
returns public.licences
language plpgsql
security definer
set search_path = public
as $$
declare
  mine public.licences;
  other public.licences;
  claimed_email citext;
  claimed_domain citext;
begin
  if auth.uid() is null then
    return null;
  end if;

  select email into claimed_email from auth.users
    where id = auth.uid() and email_confirmed_at is not null;
  if claimed_email is null then
    return null;
  end if;

  select * into mine from public.licences where owner_id = auth.uid();
  if found and mine.plan <> 'decouverte' then
    return mine;
  end if;

  update public.licences
    set owner_id = auth.uid()
    where email = claimed_email and owner_id is null
    returning * into other;
  if found and other.plan <> 'decouverte' then
    return other;
  end if;
  if found and mine.id is null then
    mine := other;
  end if;

  claimed_domain := split_part(claimed_email::text, '@', 2);
  select * into other from public.licences
    where domain is not null and domain = claimed_domain
      and plan <> 'decouverte';
  if found then
    return other;
  end if;

  return mine;
end;
$$;

grant execute on function public.my_licence() to authenticated;
revoke all on function public.my_licence() from anon;

-- ---------------------------------------------------------------------
-- 6. Le bail des appareils
-- ---------------------------------------------------------------------
alter table public.sessions
  add column if not exists last_seen_at timestamptz not null default now(),
  add column if not exists device_id text
    check (device_id is null or length(device_id) <= 120),
  add column if not exists start_request_id uuid;

-- La même demande rejouée retrouve sa séance : unique par licence.
create unique index if not exists sessions_start_request_idx
  on public.sessions (licence_id, start_request_id)
  where start_request_id is not null;

create index if not exists sessions_lease_idx
  on public.sessions (licence_id, last_seen_at) where closed_at is null;

-- Une séance vit tant qu'elle bat. Cinq minutes sans signe, elle ne
-- compte plus dans la limite d'appareils — une tablette qui a planté ne
-- retient pas sa place.
create or replace function public.session_lease()
returns interval
language sql
immutable
as $$ select interval '5 minutes' $$;

-- Le battement : la console l'envoie toutes les soixante secondes tant
-- que la séance est ouverte.
create or replace function public.heartbeat_session(p_session_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  l public.licences;
  touched int;
begin
  l := public.my_licence();
  if l.id is null then
    return jsonb_build_object('error', 'no_licence');
  end if;
  update public.sessions
     set last_seen_at = now()
   where id = p_session_id and licence_id = l.id and closed_at is null;
  get diagnostics touched = row_count;
  if touched = 0 then
    return jsonb_build_object('error', 'unknown_session');
  end if;
  return jsonb_build_object('ok', true, 'lease', extract(epoch from public.session_lease())::int);
end;
$$;

grant execute on function public.heartbeat_session(uuid) to authenticated;
revoke all on function public.heartbeat_session(uuid) from anon;

-- ---------------------------------------------------------------------
-- 7. Ouvrir une séance : atomique, rejouable, sous quota
-- ---------------------------------------------------------------------
create or replace function public.open_session(
  p_lesson_id text,
  p_question_ids text[],
  p_team_count int default 3,
  p_board_language text default 'fr',
  p_seconds_per_question int default 0,
  p_keep_individual_scores bool default false,
  p_scoring_mode text default 'teams',
  p_request_id uuid default null,
  p_device_id text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  l public.licences;
  p public.plans;
  running int;
  s public.sessions;
begin
  l := public.my_licence();
  if l.id is null then
    return jsonb_build_object('error', 'no_licence');
  end if;

  -- Verrou sur la licence : deux appareils qui appuient en même temps
  -- passent ici l'un après l'autre, et le second voit ce que le premier
  -- a consommé. C'est ce qui rend le quota et la limite incontournables.
  select * into l from public.licences where id = l.id for update;
  select * into p from public.plans where id = l.plan;

  -- Rejouer la même demande rend la même séance, sans rien consommer.
  if p_request_id is not null then
    select * into s from public.sessions
      where licence_id = l.id and start_request_id = p_request_id;
    if found then
      return jsonb_build_object('sessionId', s.id, 'code', s.code, 'replayed', true);
    end if;
  end if;

  if l.expires_at < now() then
    return jsonb_build_object('error', 'licence_expired');
  end if;
  -- Un abonnement en défaut de paiement n'ouvre plus de séance ; celles
  -- qui tournent finissent. `canceled` avec une échéance future reste
  -- actif jusqu'à cette échéance — c'est la règle du renouvellement
  -- annulé.
  if l.status in ('unpaid', 'incomplete_expired') then
    return jsonb_build_object('error', 'licence_expired');
  end if;

  if p.free_games is not null and l.free_games_used >= p.free_games then
    return jsonb_build_object('error', 'quota_exhausted',
                              'used', l.free_games_used, 'limit', p.free_games);
  end if;

  select count(*) into running from public.sessions
    where licence_id = l.id
      and closed_at is null
      and last_seen_at > now() - public.session_lease();
  if running >= l.concurrent_sessions then
    return jsonb_build_object('error', 'too_many_sessions',
                              'limit', l.concurrent_sessions);
  end if;

  if cardinality(p_question_ids) = 0 then
    return jsonb_build_object('error', 'no_questions');
  end if;

  insert into public.sessions (
    code, licence_id, lesson_id, board_language, team_count,
    question_ids, seconds_per_question, keep_individual_scores, scoring_mode,
    start_request_id, device_id, last_seen_at
  ) values (
    public.new_session_code(), l.id, p_lesson_id, p_board_language,
    greatest(2, least(4, p_team_count)), p_question_ids,
    greatest(0, least(180, p_seconds_per_question)), p_keep_individual_scores,
    case when p_scoring_mode = 'individual' then 'individual' else 'teams' end,
    p_request_id, p_device_id, now()
  ) returning * into s;

  if p.free_games is not null then
    update public.licences
       set free_games_used = free_games_used + 1
     where id = l.id;
  end if;

  return jsonb_build_object('sessionId', s.id, 'code', s.code,
                            'freeGamesUsed', case when p.free_games is null then null
                                                  else l.free_games_used + 1 end,
                            'freeGames', p.free_games);
end;
$$;

-- L'ancienne signature disparaît : deux fonctions du même nom avec des
-- paramètres par défaut rendraient chaque appel ambigu.
drop function if exists public.open_session(text, text[], int, text, int, bool, text);
grant execute on function public.open_session(text, text[], int, text, int, bool, text, uuid, text)
  to authenticated;
revoke all on function public.open_session(text, text[], int, text, int, bool, text, uuid, text)
  from anon;

-- ---------------------------------------------------------------------
-- 8. Fermer : par l'enseignant, ou par le temps
-- ---------------------------------------------------------------------
--
-- La fermeture écrit le bilan puis fait partir les élèves. Une séance
-- abandonnée — tablette éteinte, enseignant parti — doit connaître le
-- même sort, sinon son bilan n'existe jamais. La logique est donc dans
-- une fonction interne que les deux chemins appellent.
create or replace function public._close_session_row(s public.sessions)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  per_question jsonb;
  per_pupil jsonb;
  head_count int;
begin
  select count(*) into head_count from public.participants where session_id = s.id;

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

  if s.keep_individual_scores or s.scoring_mode = 'individual' then
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
    s.licence_id, s.code, s.lesson_id, s.opened_at, head_count, per_question, per_pupil
  );

  delete from public.participants where session_id = s.id;
  update public.sessions
     set phase = 'over', closed_at = now()
   where id = s.id;

  return head_count;
end;
$$;

revoke all on function public._close_session_row(public.sessions) from anon, authenticated;

create or replace function public.close_session(p_session_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  l public.licences;
  s public.sessions;
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
  head_count := public._close_session_row(s);
  return jsonb_build_object('closed', true, 'participants', head_count);
end;
$$;

-- Les séances sans battement depuis trente minutes sont closes par le
-- ménage : leur bilan est écrit, leur place déjà libre depuis cinq.
create or replace function public.close_stale_sessions(p_minutes int default 30)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  s public.sessions;
  n int := 0;
begin
  for s in
    select * from public.sessions
     where closed_at is null
       and last_seen_at < now() - make_interval(mins => p_minutes)
  loop
    perform public._close_session_row(s);
    n := n + 1;
  end loop;
  return n;
end;
$$;

revoke all on function public.close_stale_sessions(int) from anon, authenticated;

do $$
begin
  if exists (select 1 from pg_available_extensions where name = 'pg_cron') then
    create extension if not exists pg_cron;
    perform cron.schedule(
      'iqraquest-close-stale-sessions',
      '*/10 * * * *',
      $cron$ select public.close_stale_sessions(30); $cron$
    );
  else
    raise notice 'pg_cron indisponible : planifier close_stale_sessions autrement';
  end if;
end;
$$;

-- ---------------------------------------------------------------------
-- 9. Mes appareils
-- ---------------------------------------------------------------------
create or replace function public.my_sessions()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  l public.licences;
  out_rows jsonb;
begin
  l := public.my_licence();
  if l.id is null then
    return jsonb_build_object('error', 'no_licence');
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
           'sessionId', s.id,
           'code', s.code,
           'lessonId', s.lesson_id,
           'deviceId', s.device_id,
           'openedAt', s.opened_at,
           'lastSeenAt', s.last_seen_at,
           'alive', s.last_seen_at > now() - public.session_lease()
         ) order by s.opened_at desc), '[]'::jsonb)
    into out_rows
    from public.sessions s
   where s.licence_id = l.id and s.closed_at is null;
  return jsonb_build_object('sessions', out_rows, 'limit', l.concurrent_sessions);
end;
$$;

grant execute on function public.my_sessions() to authenticated;
revoke all on function public.my_sessions() from anon;

-- ---------------------------------------------------------------------
-- 10. Mon compte, avec le quota et ce qui bloque
-- ---------------------------------------------------------------------
create or replace function public.my_account()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  l public.licences;
  p public.plans;
  pr public.profiles;
  running int;
  blocker text := null;
  st text;
begin
  l := public.my_licence();
  if l.id is null then
    return jsonb_build_object('state', 'no_licence');
  end if;
  select * into p from public.plans where id = l.plan;
  select * into pr from public.profiles where id = auth.uid();

  select count(*) into running from public.sessions
    where licence_id = l.id
      and closed_at is null
      and last_seen_at > now() - public.session_lease();

  -- Le même jugement que open_session, sans effet : ce que le bouton
  -- « Lancer une partie » a le droit de promettre.
  if l.expires_at < now() or l.status in ('unpaid', 'incomplete_expired') then
    blocker := 'expired';
  elsif p.free_games is not null and l.free_games_used >= p.free_games then
    blocker := 'quota';
  elsif running >= l.concurrent_sessions then
    blocker := 'sessions';
  end if;

  st := case
    when l.expires_at < now() then 'expired'
    when blocker = 'quota' then 'quota_exhausted'
    else 'active'
  end;

  return jsonb_build_object(
    'state', st,
    'canStart', blocker is null,
    'blocker', blocker,
    'email', l.email,
    'schoolName', coalesce(l.school_name, pr.organization_name),
    'firstName', pr.first_name,
    'lastName', pr.last_name,
    'plan', l.plan,
    'planLabel', coalesce(p.label, l.plan),
    'free', p.free_games is not null,
    'freeGames', p.free_games,
    'freeGamesUsed', l.free_games_used,
    'rooms', l.concurrent_sessions,
    'roomsInUse', running,
    'expiresAt', l.expires_at,
    'daysLeft', greatest(0, ceil(extract(epoch from (l.expires_at - now())) / 86400))::int,
    'subscribed', l.stripe_subscription_id is not null,
    'status', l.status,
    'cancelAtPeriodEnd', l.cancel_at_period_end,
    'currentPeriodStart', l.current_period_start,
    'hasCustomer', l.stripe_customer_id is not null,
    'since', l.created_at
  );
end;
$$;

grant execute on function public.my_account() to authenticated;
revoke all on function public.my_account() from anon;

-- ---------------------------------------------------------------------
-- 11. Les événements Stripe ne s'appliquent qu'une fois
-- ---------------------------------------------------------------------
create table if not exists public.stripe_events (
  stripe_event_id text primary key,
  event_type text not null,
  processed_at timestamptz not null default now()
);

alter table public.stripe_events enable row level security;
revoke all on public.stripe_events from anon, authenticated;

-- ---------------------------------------------------------------------
-- 12. Supprimer mon compte
-- ---------------------------------------------------------------------
--
-- Ce qui part : le profil, la licence, les séances et leurs bilans, le
-- compte d'authentification. Ce qui reste : les factures et le client
-- chez Stripe — ils y sont déjà, ils y ont une obligation légale de
-- conservation, et IqraQuest n'en garde pas de copie.
create or replace function public.delete_my_account()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    return jsonb_build_object('error', 'not_signed_in');
  end if;
  -- La licence emporte séances, participants, réponses et bilans par
  -- cascade. Une licence de domaine partagée par plusieurs comptes n'est
  -- pas celle du compte : elle reste, seul le rattachement part.
  delete from public.licences where owner_id = uid and domain is null;
  update public.licences set owner_id = null where owner_id = uid;
  delete from public.profiles where id = uid;
  delete from auth.users where id = uid;
  return jsonb_build_object('deleted', true);
end;
$$;

grant execute on function public.delete_my_account() to authenticated;
revoke all on function public.delete_my_account() from anon;

-- ---------------------------------------------------------------------
-- 13. Les tables restent fermées au rôle public
-- ---------------------------------------------------------------------
revoke insert, update, delete on public.licences from authenticated, anon;
revoke insert, update, delete on public.sessions from authenticated, anon;
