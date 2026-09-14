-- Ce que Supabase fournit d'office et qu'un Postgres nu n'a pas : les
-- rôles, le schéma `auth`, et `auth.uid()`. Assez pour jouer les
-- migrations et les tests hors de Supabase — jamais à jouer sur un vrai
-- projet.
do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then
    create role service_role nologin bypassrls;
  end if;
end;
$$;

grant usage on schema public to anon, authenticated, service_role;
grant anon, authenticated, service_role to current_user;

create schema if not exists auth;
create table if not exists auth.users (
  id uuid primary key default gen_random_uuid(),
  email text unique,
  encrypted_password text,
  email_confirmed_at timestamptz,
  raw_user_meta_data jsonb,
  created_at timestamptz not null default now()
);

-- Supabase lit l'identifiant de l'appelant dans le JWT ; ici, dans un
-- réglage de session que le test pose lui-même.
create or replace function auth.uid()
returns uuid
language sql
stable
as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;
