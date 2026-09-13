-- IqraQuest — mode École : ce qu'une relecture du parcours compte a
-- trouvé, et corrige.
--
--   1. `my_licence()` prenait « une » licence du compte, sans dire
--      laquelle. Un compte qui en possède deux (sa découverte, puis une
--      École écrite sous une autre adresse) pouvait tomber sur la
--      découverte et lire « cinq parties utilisées » après avoir payé.
--   2. Un abonnement en défaut de paiement (`past_due`) ouvrait encore
--      des séances. La règle est : la séance en cours finit, la suivante
--      attend la régularisation.
--   3. L'inscription ne portait pas le nom de l'établissement : il
--      arrive maintenant par les métadonnées du compte, et va dans le
--      profil et sur la licence.
--   4. Supprimer un compte laissait son abonnement Stripe courir. La
--      fonction refuse tant qu'un abonnement est actif ; la fonction
--      Edge `delete-school-account` le résilie d'abord.

-- ---------------------------------------------------------------------
-- 1. Quelle licence est la mienne — la payée avant la découverte
-- ---------------------------------------------------------------------
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

  -- Parmi les licences du compte : la payée d'abord, puis la plus
  -- longue. Jamais « la première venue ».
  select * into mine from public.licences
    where owner_id = auth.uid()
    order by (plan = 'decouverte') asc, expires_at desc
    limit 1;
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
      and plan <> 'decouverte'
    order by expires_at desc
    limit 1;
  if found then
    return other;
  end if;

  return mine;
end;
$$;

-- ---------------------------------------------------------------------
-- 2. Un impayé bloque la prochaine séance
-- ---------------------------------------------------------------------
--
-- Les statuts qui ferment la porte, à un seul endroit : `open_session`
-- et `my_account` doivent rendre le même verdict.
create or replace function public.licence_blocked_by_status(p_status text)
returns bool
language sql
immutable
as $$
  select p_status in ('past_due', 'unpaid', 'incomplete', 'incomplete_expired', 'paused')
$$;

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

  select * into l from public.licences where id = l.id for update;
  select * into p from public.plans where id = l.plan;

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
  -- Défaut de paiement, abonnement impayé ou jamais finalisé : la
  -- séance en cours va au bout, la suivante attend. `canceled` avec une
  -- échéance future reste ouvert jusqu'à cette échéance.
  if public.licence_blocked_by_status(l.status) then
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

  if l.expires_at < now() or public.licence_blocked_by_status(l.status) then
    blocker := 'expired';
  elsif p.free_games is not null and l.free_games_used >= p.free_games then
    blocker := 'quota';
  elsif running >= l.concurrent_sessions then
    blocker := 'sessions';
  end if;

  -- L'état que la console affiche suit le verdict : un impayé se lit
  -- comme un abonnement arrêté, avec la raison (`status`) à côté.
  st := case
    when blocker = 'expired' then 'expired'
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

-- ---------------------------------------------------------------------
-- 3. L'inscription porte le nom de l'établissement
-- ---------------------------------------------------------------------
--
-- La console envoie `data: {organization_name, first_name, last_name}`
-- à l'inscription ; GoTrue les range dans `raw_user_meta_data`. Le
-- déclencheur les recopie : profil, et nom de l'école sur la licence
-- découverte, pour que la console dise « École An-Nour » dès la
-- première connexion.
create or replace function public.handle_new_school_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  meta jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  org text := nullif(left(trim(meta->>'organization_name'), 120), '');
begin
  insert into public.profiles (id, first_name, last_name, organization_name)
  values (
    new.id,
    nullif(left(trim(meta->>'first_name'), 80), ''),
    nullif(left(trim(meta->>'last_name'), 80), ''),
    org
  )
  on conflict (id) do nothing;

  if new.email is not null then
    insert into public.licences
      (email, owner_id, plan, concurrent_sessions, expires_at, status, school_name)
    select new.email, new.id, p.id, p.rooms, now() + p.duration, 'none', org
      from public.plans p where p.id = 'decouverte'
    on conflict (email) do nothing;
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------
-- 4. Supprimer un compte ne laisse pas un abonnement courir
-- ---------------------------------------------------------------------
create or replace function public.delete_my_account()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  live int;
begin
  if uid is null then
    return jsonb_build_object('error', 'not_signed_in');
  end if;

  -- Un abonnement encore facturé doit être résilié chez Stripe avant :
  -- c'est la fonction Edge `delete-school-account` qui le fait, puis
  -- passe le statut à `canceled`. Sans elle, on refuse plutôt que de
  -- laisser une école payer pour un compte qui n'existe plus.
  select count(*) into live from public.licences
    where owner_id = uid
      and stripe_subscription_id is not null
      and status in ('active', 'trialing', 'past_due', 'unpaid', 'incomplete');
  if live > 0 then
    return jsonb_build_object('error', 'subscription_active');
  end if;

  delete from public.licences where owner_id = uid and domain is null;
  update public.licences set owner_id = null where owner_id = uid;
  delete from public.profiles where id = uid;
  delete from auth.users where id = uid;
  return jsonb_build_object('deleted', true);
end;
$$;

grant execute on function public.delete_my_account() to authenticated;
revoke all on function public.delete_my_account() from anon;
