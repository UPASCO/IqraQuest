#!/usr/bin/env bash
# Joue les migrations et le parcours compte sur un PostgreSQL 16 local,
# sans Supabase. Deux usages :
#   bash server/supabase/tests/run_local.sh            # démarre un cluster jetable
#   PGURL=postgres://... bash server/supabase/tests/run_local.sh   # une base à vous
set -euo pipefail
cd "$(dirname "$0")/../../.."

if [ -z "${PGURL:-}" ]; then
  D=${IQRA_PG_DIR:-/tmp/iqpg}
  BIN=$(ls -d /usr/lib/postgresql/*/bin | tail -1)
  if [ ! -d "$D/data" ]; then
    mkdir -p "$D" && chown postgres:postgres "$D" 2>/dev/null || true
    su postgres -s /bin/bash -c "$BIN/initdb -D $D/data -U postgres --auth=trust >/dev/null" \
      || "$BIN/initdb" -D "$D/data" -U postgres --auth=trust >/dev/null
  fi
  if ! "$BIN/pg_isready" -h /tmp -p 5499 -q; then
    su postgres -s /bin/bash -c "$BIN/pg_ctl -D $D/data -o '-p 5499 -k /tmp' -l $D/pg.log start >/dev/null" 2>/dev/null \
      || "$BIN/pg_ctl" -D "$D/data" -o '-p 5499 -k /tmp' -l "$D/pg.log" start >/dev/null
    sleep 1
  fi
  PGURL="postgres://postgres@/iqra?host=/tmp&port=5499"
  psql "postgres://postgres@/postgres?host=/tmp&port=5499" -Atqc "drop database if exists iqra;"
  psql "postgres://postgres@/postgres?host=/tmp&port=5499" -Atqc "create database iqra;"
fi

run() { psql "$PGURL" -v ON_ERROR_STOP=1 -q -f "$1" > /tmp/iqra-sql.log 2>&1 || { echo "ÉCHEC $1"; grep -v NOTICE /tmp/iqra-sql.log | tail -8; exit 1; }; }

run server/supabase/tests/supabase_stub.sql
# Deux fois : la seconde passe prouve que chaque migration est rejouable.
for pass in 1 2; do
  for f in server/supabase/migrations/000*.sql; do run "$f"; done
  echo "migrations : passe $pass ok"
done
psql "$PGURL" -v ON_ERROR_STOP=1 -q -f server/supabase/tests/account_flow.sql > /tmp/iqra-flow.log 2>&1 || { echo "ÉCHEC parcours compte"; grep -v "^NOTICE" /tmp/iqra-flow.log | tail -6; exit 1; }
grep -o "ok [0-9]* [^\"]*" /tmp/iqra-flow.log | sed 's/^/  /'
echo "parcours compte : ok"

# La course : deux consoles ouvrent en même temps sur le dernier crédit.
# La seconde attend le verrou de la première, puis voit le compteur à
# jour — une seule des deux passe.
psql "$PGURL" -v ON_ERROR_STOP=1 -q <<'SQL'
insert into auth.users (id, email, email_confirmed_at)
values ('00000000-0000-0000-0000-00000000000a', 'race@ecole.test', now())
on conflict (id) do nothing;
update public.licences set free_games_used = 4 where owner_id = '00000000-0000-0000-0000-00000000000a';
SQL
race() {
  psql "$PGURL" -Atq <<SQL
select set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000000a', false);
begin;
select coalesce(public.open_session('lesson_test', array['q1'], 3, 'fr', 0, false, 'teams', gen_random_uuid(), 'd$1')->>'error', 'opened');
select pg_sleep($2);
commit;
SQL
}
# Lire TOUT ce que psql rend : couper le tuyau à la première ligne
# tuerait la console pendant son pg_sleep, et sa transaction avec —
# ce qui ferait passer la seconde console à tort.
verdict() { { grep -E "opened|quota_exhausted|too_many_sessions|licence_expired" || echo "(rien)"; } | tail -1; }
a=$(race 1 1.5 | verdict) & pid=$!
sleep 0.4
b=$(race 2 0 | verdict)
wait $pid
used=$(psql "$PGURL" -Atqc "select free_games_used from public.licences where owner_id = '00000000-0000-0000-0000-00000000000a'")
[ "$used" = "5" ] || { echo "ÉCHEC course : compteur $used (attendu 5)"; exit 1; }
[ "$b" = "quota_exhausted" ] || { echo "ÉCHEC course : la seconde console a obtenu « $b »"; exit 1; }
echo "course sur le dernier crédit : une seule séance ouverte, compteur 5"
psql "$PGURL" -Atqc "delete from auth.users where email = 'race@ecole.test';" >/dev/null
echo "TOUT EST VERT"
