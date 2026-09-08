-- IqraQuest — mode Classe : l'établissement porte un nom.
--
-- Une licence savait jusqu'ici à quelle adresse elle appartenait, et
-- rien de plus. C'est assez pour ouvrir une séance, et insuffisant pour
-- tout le reste : la console dit « bonjour » à une adresse e-mail, la
-- facture ne porte pas de destinataire, et un réseau de plusieurs écoles
-- ne se relit pas.
--
-- Un nom, donc. Saisi une fois à l'achat, affiché ensuite partout où
-- l'école se reconnaît. Ce n'est pas une donnée personnelle : c'est le
-- nom d'une personne morale, et il reste tant que la licence existe.

alter table public.licences
  add column if not exists school_name text;

alter table public.licences
  drop constraint if exists licences_school_name_length;
alter table public.licences
  add constraint licences_school_name_length check (
    school_name is null or length(btrim(school_name)) between 2 and 120
  );

comment on column public.licences.school_name is
  'Nom de l''établissement, tel qu''il s''appelle lui-même (ex. « École '
  'An-Nour »). Nom d''une personne morale, pas une donnée personnelle. '
  'Affiché dans la console et repris sur la facture.';
