-- IqraQuest — mode École : le parcours compte, joué sur une vraie base.
--
-- À jouer après les migrations (voir run_local.sh). Chaque bloc pose un
-- appelant (`request.jwt.claim.sub`, ce que Supabase lit dans le JWT)
-- et vérifie ce que les fonctions rendent. Un `assert` qui casse arrête
-- tout avec la raison.
\set ON_ERROR_STOP on
set client_min_messages = notice;

create or replace function pg_temp.as_user(p_uid uuid) returns void
language sql as $$ select set_config('request.jwt.claim.sub', p_uid::text, true) $$;

create or replace function pg_temp.open(p_req uuid default gen_random_uuid())
returns jsonb language sql as $$
  select public.open_session('lesson_test', array['q1','q2','q3'], 3, 'fr', 0, false, 'teams', p_req, 'device-1')
$$;

begin;

-- 1. L'inscription : profil, licence découverte, nom de l'établissement.
insert into auth.users (id, email, email_confirmed_at, raw_user_meta_data)
values ('00000000-0000-0000-0000-000000000001', 'a@ecole.test', now(),
        '{"organization_name": "  École An-Nour "}');
do $$
declare l public.licences; p public.profiles;
begin
  select * into p from public.profiles where id = '00000000-0000-0000-0000-000000000001';
  assert p.organization_name = 'École An-Nour', 'profil : nom d''établissement';
  select * into l from public.licences where owner_id = '00000000-0000-0000-0000-000000000001';
  assert l.plan = 'decouverte' and l.status = 'none' and l.concurrent_sessions = 2, 'licence découverte';
  assert l.school_name = 'École An-Nour', 'licence : nom d''établissement';
  raise notice 'ok 1 inscription';
end $$;

-- 2. Non confirmé : aucune licence, aucun compte visible.
insert into auth.users (id, email) values ('00000000-0000-0000-0000-000000000002', 'b@ecole.test');
do $$
begin
  perform pg_temp.as_user('00000000-0000-0000-0000-000000000002');
  assert public.my_licence() is null, 'non confirmé : my_licence null';
  assert public.my_account()->>'state' = 'no_licence', 'non confirmé : no_licence';
  raise notice 'ok 2 non confirmé';
end $$;

-- 3. Cinq parties, puis la sixième refusée ; le rejeu ne coûte rien.
do $$
declare r jsonb; first uuid := gen_random_uuid(); i int;
begin
  perform pg_temp.as_user('00000000-0000-0000-0000-000000000001');
  assert public.my_account()->>'state' = 'active', 'découverte active';
  assert (public.my_account()->>'free')::bool, 'découverte : free';
  for i in 1..5 loop
    r := pg_temp.open(case when i = 1 then first else gen_random_uuid() end);
    assert r->>'error' is null, 'partie ' || i || ' : ' || r::text;
    assert (r->>'freeGamesUsed')::int = i, 'compteur ' || i;
    perform public.close_session((r->>'sessionId')::uuid);
  end loop;
  r := pg_temp.open();
  assert r->>'error' = 'quota_exhausted', 'sixième : ' || r::text;
  assert public.my_account()->>'state' = 'quota_exhausted', 'état quota';
  assert (public.my_account()->>'freeGamesUsed')::int = 5, 'cinq utilisées';
  r := pg_temp.open(first);
  assert (r->>'replayed')::bool, 'rejeu : même séance rendue';
  assert (select free_games_used from public.licences where owner_id = '00000000-0000-0000-0000-000000000001') = 5, 'rejeu : aucun crédit consommé';
  raise notice 'ok 3 cinq parties';
end $$;

-- 4. L'offre École : deux appareils, le bail de cinq minutes, le battement.
update public.licences
   set plan = 'ecole', concurrent_sessions = 2, status = 'active',
       stripe_customer_id = 'cus_test', stripe_subscription_id = 'sub_test',
       expires_at = now() + interval '1 year'
 where owner_id = '00000000-0000-0000-0000-000000000001';
do $$
declare a jsonb; b jsonb; c jsonb;
begin
  perform pg_temp.as_user('00000000-0000-0000-0000-000000000001');
  assert public.my_account()->>'state' = 'active' and not (public.my_account()->>'free')::bool, 'École active';
  a := pg_temp.open(); b := pg_temp.open();
  assert a->>'error' is null and b->>'error' is null, 'deux appareils';
  c := pg_temp.open();
  assert c->>'error' = 'too_many_sessions', 'troisième refusé : ' || c::text;
  assert public.my_account()->>'blocker' = 'sessions', 'blocker sessions';
  update public.sessions set last_seen_at = now() - interval '6 minutes' where id = (a->>'sessionId')::uuid;
  c := pg_temp.open();
  assert c->>'error' is null, 'bail expiré : place libre';
  assert (public.heartbeat_session((b->>'sessionId')::uuid)->>'ok')::bool, 'battement';
  assert jsonb_array_length(public.my_sessions()->'sessions') = 3, 'trois séances listées';
  perform public.close_session((a->>'sessionId')::uuid);
  perform public.close_session((b->>'sessionId')::uuid);
  perform public.close_session((c->>'sessionId')::uuid);
  assert (public.my_account()->>'roomsInUse')::int = 0, 'tout fermé';
  raise notice 'ok 4 appareils';
end $$;

-- 5. Un impayé : la prochaine séance attend.
update public.licences set status = 'past_due' where owner_id = '00000000-0000-0000-0000-000000000001';
do $$
declare r jsonb;
begin
  perform pg_temp.as_user('00000000-0000-0000-0000-000000000001');
  r := pg_temp.open();
  assert r->>'error' = 'licence_expired', 'impayé : refus';
  assert public.my_account()->>'state' = 'expired' and public.my_account()->>'status' = 'past_due', 'impayé : état';
  raise notice 'ok 5 impayé';
end $$;

-- 6. Renouvellement annulé : ouvert jusqu'à l'échéance.
update public.licences set status = 'canceled', cancel_at_period_end = true where owner_id = '00000000-0000-0000-0000-000000000001';
do $$
declare r jsonb;
begin
  perform pg_temp.as_user('00000000-0000-0000-0000-000000000001');
  r := pg_temp.open();
  assert r->>'error' is null, 'annulé mais pas échu : ouvert';
  perform public.close_session((r->>'sessionId')::uuid);
  update public.licences set status = 'active' where owner_id = '00000000-0000-0000-0000-000000000001';
  raise notice 'ok 6 résiliation à l''échéance';
end $$;

-- 7. Deux licences sur un compte : la payée d'abord.
insert into public.licences (email, owner_id, plan, concurrent_sessions, expires_at, status)
values ('ancienne@ecole.test', '00000000-0000-0000-0000-000000000001', 'decouverte', 2, now() + interval '100 years', 'none');
do $$
begin
  perform pg_temp.as_user('00000000-0000-0000-0000-000000000001');
  assert (public.my_licence()).plan = 'ecole', 'la payée d''abord';
  raise notice 'ok 7 préférence';
end $$;

-- 8. Supprimer : refusé tant que l'abonnement court, puis tout part.
do $$
declare r jsonb;
begin
  perform pg_temp.as_user('00000000-0000-0000-0000-000000000001');
  r := public.delete_my_account();
  assert r->>'error' = 'subscription_active', 'suppression refusée : ' || r::text;
  update public.licences set status = 'canceled' where owner_id = '00000000-0000-0000-0000-000000000001';
  r := public.delete_my_account();
  assert (r->>'deleted')::bool, 'supprimé';
  assert not exists (select 1 from auth.users where id = '00000000-0000-0000-0000-000000000001'), 'compte parti';
  assert not exists (select 1 from public.licences where owner_id = '00000000-0000-0000-0000-000000000001'), 'licences parties';
  assert not exists (select 1 from public.profiles where id = '00000000-0000-0000-0000-000000000001'), 'profil parti';
  raise notice 'ok 8 suppression';
end $$;

-- 9. La clé publique ne lit rien et n'appelle pas les fonctions du compte.
do $$
declare n int; blocked bool := false;
begin
  perform set_config('request.jwt.claim.sub', '', true);
  execute 'set local role anon';
  begin
    execute 'select count(*) from public.licences' into n;
    assert n = 0, 'anon lit des licences';
  exception when insufficient_privilege then null;
  end;
  begin
    perform public.my_account();
  exception when insufficient_privilege then blocked := true;
  end;
  assert blocked, 'anon appelle my_account';
  execute 'reset role';
  raise notice 'ok 9 anon';
end $$;

rollback;
