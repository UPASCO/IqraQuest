-- IqraQuest — mode Classe : une licence pour un établissement, pas pour
-- une boîte aux lettres.
--
-- Jusqu'ici, une licence appartenait à une adresse. Une école de dix
-- enseignants n'avait donc qu'un seul moyen de s'en servir : partager
-- une boîte, et le mot de passe qui va avec. C'est mauvais pour eux
-- (une adresse commune que tout le monde consulte), mauvais pour nous
-- (cette même adresse se transmet aussi bien à l'école d'à côté), et
-- inutile : ce qui est vendu n'a jamais été un compte, c'est un nombre
-- de salles simultanées.
--
-- Une licence peut désormais porter un domaine. Toute adresse de ce
-- domaine ouvre alors des séances sur la même licence — et sur le même
-- plafond de salles. Dix enseignants de la même école travaillent
-- chacun avec sa propre adresse, et l'école d'à côté, qui n'est pas dans
-- ce domaine, n'entre pas.
--
-- Le champ reste nul pour une licence individuelle : rien ne change pour
-- l'enseignant seul qui achète pour sa classe.

alter table public.licences
  add column if not exists domain citext;

-- Un domaine, pas une adresse : ni arobase, ni espace, et au moins un
-- point. La contrainte est là pour attraper la faute de frappe qui
-- ouvrirait la licence à tout le monde.
alter table public.licences
  drop constraint if exists licences_domain_shape;
alter table public.licences
  add constraint licences_domain_shape check (
    domain is null or (
      domain !~ '[@[:space:]]' and domain ~ '^[a-z0-9.-]+\.[a-z]{2,}$'
    )
  );

create unique index if not exists licences_domain_idx
  on public.licences (domain) where domain is not null;

comment on column public.licences.domain is
  'Domaine de l''établissement (ex. ecole-annour.fr). Quand il est '
  'renseigné, toute adresse de ce domaine partage cette licence et son '
  'plafond de salles simultanées. Nul pour une licence individuelle.';

-- ---------------------------------------------------------------------
-- La licence de l'appelant, avec le domaine
-- ---------------------------------------------------------------------
--
-- Trois chemins, dans cet ordre :
--
--   1. la licence déjà rattachée à ce compte ;
--   2. celle qui porte exactement cette adresse — on la réclame, comme
--      avant : c'est le raccord après un achat Stripe ;
--   3. celle qui porte le domaine de cette adresse — sans la réclamer,
--      justement parce qu'elle sert à plusieurs enseignants à la fois.
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

  select email into claimed_email from auth.users where id = auth.uid();
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

  -- Licence d'établissement : partagée, donc jamais réclamée par un
  -- compte en particulier. Le plafond de salles vaut pour toute l'école,
  -- ce qui est exactement ce qu'elle a payé.
  claimed_domain := split_part(claimed_email::text, '@', 2);
  select * into l from public.licences
    where domain is not null and domain = claimed_domain;

  return l;
end;
$$;

grant execute on function public.my_licence() to authenticated;
revoke all on function public.my_licence() from anon;
