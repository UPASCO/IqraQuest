-- IqraQuest — mode Classe : les paliers, et l'espace de l'école.
--
-- Jusqu'ici une licence portait un plan choisi dans une liste écrite en
-- dur (« essai », « classe », « ecole ») et un nombre de salles envoyé
-- par Stripe dans une métadonnée. Deux endroits savaient la même chose,
-- et l'un des deux était un champ de saisie libre dans un tableau de
-- bord : une faute de frappe sur `iqraquest_rooms` donnait cent salles
-- pour quatre-vingt-neuf euros, en silence.
--
-- Les paliers deviennent donc des lignes, ici. Stripe ne transmet plus
-- qu'un nom de palier ; ce qu'il ouvre — combien de salles, pour combien
-- de temps — se lit dans cette table. Les prix, eux, restent chez Stripe
-- et ne sont écrits nulle part dans ce dépôt.

-- ---------------------------------------------------------------------
-- 1. Les paliers
-- ---------------------------------------------------------------------
create table if not exists public.plans (
  id text primary key,

  -- Combien de séances tournent en même temps. C'est la seule chose
  -- qu'une école compare d'un palier à l'autre : trois salles, cinq,
  -- dix.
  rooms int not null check (rooms between 1 and 100),

  -- Ce que l'achat ouvre comme durée. Un an pour les abonnements, quatre-
  -- vingt-dix jours pour un essai, un jour pour le palier de test — celui
  -- qui sert à voir de ses yeux ce que fait l'application le lendemain
  -- d'une échéance.
  -- Strictement positive : une durée nulle écrirait une licence déjà
  -- expirée à l'instant du paiement, et l'école découvrirait son achat
  -- verrouillé.
  duration interval not null check (duration > interval '0'),

  -- L'échéance se cale-t-elle sur l'année scolaire ? Une licence annuelle
  -- achetée en juin expirerait en juin, en pleine préparation de
  -- rentrée : on repousse alors au 31 août. Un essai d'un jour, non —
  -- sinon un test de vingt-quatre heures durerait jusqu'à la rentrée.
  school_year bool not null default false,

  -- Ce que l'école lit dans sa console. Le prix n'y est pas : il vit
  -- chez Stripe, où il peut changer sans toucher à ce dépôt.
  label text not null,

  -- Un palier retiré de la vente reste ici tant qu'une licence le porte.
  sellable bool not null default true
);

comment on table public.plans is
  'Les paliers de l''offre. Stripe transmet un identifiant de palier ; '
  'ce qu''il ouvre se lit ici, jamais dans la métadonnée du paiement. '
  'Les prix vivent chez Stripe.';

insert into public.plans (id, rooms, duration, school_year, label, sellable)
values
  ('essai',   1,  interval '90 days', false, 'Essai',              false),
  ('classe',  1,  interval '1 year',  true,  'Une classe',         false),
  ('ecole',   3,  interval '1 year',  true,  'École',              false),
  ('ecole3',  3,  interval '1 year',  true,  'École — 3 salles',   true),
  ('ecole5',  5,  interval '1 year',  true,  'École — 5 salles',   true),
  ('ecole10', 10, interval '1 year',  true,  'École — 10 salles',  true),
  -- Le palier d'observation : un euro, vingt-quatre heures. Il existe
  -- pour qu'on puisse regarder, le lendemain, ce que voit une école dont
  -- l'abonnement vient de finir — sans attendre un an pour le savoir.
  ('test1j',  1,  interval '1 day',   false, 'Test — 1 jour',      true)
on conflict (id) do update
  set rooms       = excluded.rooms,
      duration    = excluded.duration,
      school_year = excluded.school_year,
      label       = excluded.label,
      sellable    = excluded.sellable;

alter table public.plans enable row level security;
-- Aucune politique : la table ne se lit que par les fonctions
-- ci-dessous, qui sont `security definer`.

-- ---------------------------------------------------------------------
-- 2. Une licence porte un palier qui existe
-- ---------------------------------------------------------------------
--
-- La contrainte était une liste en dur dans un `check`. Elle devient une
-- clé étrangère : ajouter un palier ne demande plus de modifier la
-- table des licences, et un palier inventé par une métadonnée mal saisie
-- ne rentre plus.
alter table public.licences drop constraint if exists licences_plan_check;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'licences_plan_fkey'
  ) then
    alter table public.licences
      add constraint licences_plan_fkey
      foreign key (plan) references public.plans(id);
  end if;
end;
$$;

-- ---------------------------------------------------------------------
-- 3. Ce que l'école voit de son abonnement
-- ---------------------------------------------------------------------
--
-- La console n'avait que la licence brute : une adresse, un nombre, une
-- date. Elle ne pouvait donc ni nommer le palier, ni dire combien de
-- jours restent, ni distinguer « expiré » de « pas encore acheté » —
-- deux situations qui demandent des écrans opposés (renouveler, ou
-- acheter).
--
-- Tout ce que l'espace client affiche tient dans cette réponse, et rien
-- de ce qu'il affiche n'est calculé côté navigateur : l'échéance qui
-- verrouille est celle du serveur, pas celle de l'horloge du portable.
create or replace function public.my_account()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  l public.licences;
  p public.plans;
  running int;
begin
  l := public.my_licence();
  if l.id is null then
    return jsonb_build_object('state', 'no_licence');
  end if;

  select * into p from public.plans where id = l.plan;

  select count(*) into running from public.sessions
    where licence_id = l.id
      and closed_at is null
      and opened_at > now() - interval '4 hours';

  return jsonb_build_object(
    'state', case when l.expires_at < now() then 'expired' else 'active' end,
    'email', l.email,
    'schoolName', l.school_name,
    'plan', l.plan,
    'planLabel', coalesce(p.label, l.plan),
    'rooms', l.concurrent_sessions,
    'roomsInUse', running,
    'expiresAt', l.expires_at,
    -- Arrondi vers le haut : une licence qui finit ce soir a « un jour »,
    -- pas zéro. Zéro est réservé à ce qui est fini.
    'daysLeft', greatest(0, ceil(extract(epoch from (l.expires_at - now())) / 86400))::int,
    'subscribed', l.stripe_subscription_id is not null,
    'since', l.created_at
  );
end;
$$;

grant execute on function public.my_account() to authenticated;
revoke all on function public.my_account() from anon;

-- ---------------------------------------------------------------------
-- 4. L'historique des séances
-- ---------------------------------------------------------------------
--
-- Les rapports existaient déjà — ils sont écrits à la fermeture de
-- chaque séance — mais rien ne permettait de les relire. Un enseignant
-- qui voulait reporter les scores sur son cahier devait le faire avant
-- de fermer la séance, sur le tableau projeté, devant la classe.
--
-- Les prénoms disparaissent des rapports au bout de quatre-vingt-dix
-- jours (migration 0003) : au-delà, cette liste rend le bilan par
-- question, sans personne dedans. C'est voulu, et c'est ce que la
-- politique de confidentialité promet.
create or replace function public.my_reports(p_limit int default 50)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  l public.licences;
  -- `rows` est un mot-clé de PL/pgSQL (ROWS d'une déclaration de
  -- fonction) : une variable de ce nom se lit mal et se compile parfois
  -- moins bien encore.
  out_rows jsonb;
begin
  l := public.my_licence();
  if l.id is null then
    return jsonb_build_object('error', 'no_licence');
  end if;

  -- `r` est une colonne jsonb, pas un enregistrement : trier sur
  -- `r.played_at` demanderait un champ d'un type composite qui n'en est
  -- pas un. C'est la date de la sous-requête qui ordonne.
  select coalesce(jsonb_agg(t.r order by t.played_at desc), '[]'::jsonb)
    into out_rows
    from (
      select jsonb_build_object(
        'id', id,
        'code', session_code,
        'lessonId', lesson_id,
        'playedAt', played_at,
        'pupils', participant_count,
        'perQuestion', per_question,
        'perPupil', per_pupil
      ) as r, played_at
      from public.reports
      where licence_id = l.id
      order by played_at desc
      limit greatest(1, least(200, p_limit))
    ) t;

  return jsonb_build_object('reports', out_rows);
end;
$$;

grant execute on function public.my_reports(int) to authenticated;
revoke all on function public.my_reports(int) from anon;

-- ---------------------------------------------------------------------
-- 5. Ouvrir une séance reste refusé après l'échéance
-- ---------------------------------------------------------------------
--
-- `open_session` refusait déjà une licence expirée (migration 0002) :
-- rien à changer, et c'est le point important. Le verrouillage n'est pas
-- un écran, c'est un refus du serveur ; l'écran ne fait que l'expliquer.
-- Ce commentaire est là pour que la prochaine lecture ne cherche pas
-- ailleurs.
comment on function public.open_session(text, text[], int, text, int, bool, text) is
  'Ouvre une séance. Refuse une licence expirée (`licence_expired`) et '
  'une école qui fait déjà tourner autant de salles qu''elle en a '
  'payées (`too_many_sessions`). C''est ici que l''abonnement se fait '
  'respecter — la console ne fait qu''afficher le refus.';
