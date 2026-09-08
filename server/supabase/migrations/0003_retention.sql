-- IqraQuest — mode Classe : les durées de conservation.
--
-- La séance s'efface d'elle-même au bout de deux jours (migration 0001).
-- Le rapport que garde l'enseignant, lui, ne s'effaçait pas — et quand
-- l'enseignant avait demandé le classement individuel, il contenait des
-- prénoms d'élèves. Une promesse d'anonymat qui tient « sauf si on coche
-- une case, et alors pour toujours » n'est pas une promesse.
--
-- Deux durées, pour deux natures de données :
--
--   90 jours   les prénoms dans un rapport. Un classement nominatif a
--              une valeur pédagogique le temps d'un trimestre ; au-delà,
--              il ne sert plus qu'à être conservé.
--   24 mois    le rapport lui-même. Une fois les prénoms retirés, il ne
--              reste que des compteurs par question — utiles pour
--              comparer deux années, sans rapport avec un enfant.
--
-- Les deux fonctions sont idempotentes : les rejouer ne fait rien de
-- plus. C'est ce qui permet de les planifier sans surveiller.

-- ---------------------------------------------------------------------
-- Retirer les prénoms des vieux rapports
-- ---------------------------------------------------------------------
create or replace function public.strip_old_report_names(p_days int default 90)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  stripped int;
begin
  update public.reports
     set per_pupil = null
   where per_pupil is not null
     and played_at < now() - make_interval(days => p_days);
  get diagnostics stripped = row_count;
  return stripped;
end;
$$;

comment on function public.strip_old_report_names(int) is
  'Retire les prénoms des rapports de plus de N jours. Le bilan par '
  'question reste : il ne nomme personne.';

-- ---------------------------------------------------------------------
-- Effacer les rapports devenus inutiles
-- ---------------------------------------------------------------------
create or replace function public.purge_old_reports(p_months int default 24)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  removed int;
begin
  delete from public.reports
   where played_at < now() - make_interval(months => p_months);
  get diagnostics removed = row_count;
  return removed;
end;
$$;

revoke all on function public.strip_old_report_names(int) from anon, authenticated;
revoke all on function public.purge_old_reports(int) from anon, authenticated;

-- ---------------------------------------------------------------------
-- Le ménage, tous les jours
-- ---------------------------------------------------------------------
--
-- Même remarque que pour la migration 0002 : si pg_cron n'existe pas sur
-- le palier choisi, appeler ces deux fonctions depuis une fonction Edge
-- planifiée. Ce n'est pas une commodité — c'est ce qui fait que la durée
-- de conservation annoncée aux écoles est vraie.
do $$
begin
  if exists (select 1 from pg_available_extensions where name = 'pg_cron') then
    create extension if not exists pg_cron;
    perform cron.schedule(
      'iqraquest-strip-report-names',
      '23 3 * * *',
      $cron$ select public.strip_old_report_names(90); $cron$
    );
    perform cron.schedule(
      'iqraquest-purge-reports',
      '29 3 * * *',
      $cron$ select public.purge_old_reports(24); $cron$
    );
  else
    raise notice 'pg_cron indisponible : planifier strip_old_report_names et purge_old_reports autrement (voir server/README.md)';
  end if;
end;
$$;
