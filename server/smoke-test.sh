#!/usr/bin/env bash
#
# IqraQuest — mode Classe : vérifier le socle depuis l'extérieur.
#
# Ce script n'utilise que la clé anon, celle qui est embarquée dans
# l'application et destinée à être publique. Il ne peut donc rien casser,
# et c'est justement ce qu'il démontre : avec cette clé, la seule chose
# joignable est la poignée de fonctions de séance.
#
# Il se lance depuis n'importe quelle machine ayant accès à Internet —
# la vôtre. Les valeurs viennent de Settings → API du tableau de bord :
#
#   SUPABASE_URL=https://xxxx.supabase.co \
#   SUPABASE_ANON_KEY=eyJ... \
#   bash server/smoke-test.sh
#
# Cinq vérifications, dans l'ordre où elles comptent. Un échec de la 1 ou
# de la 2 est grave : il veut dire que des données d'élèves seraient
# lisibles par n'importe qui possédant la clé publique de l'app.

set -uo pipefail

URL="${SUPABASE_URL:-}"
KEY="${SUPABASE_ANON_KEY:-}"

if [[ -z "$URL" || -z "$KEY" ]]; then
  echo "Il manque SUPABASE_URL ou SUPABASE_ANON_KEY." >&2
  echo "Voir server/RUNBOOK.md, étape 1." >&2
  exit 2
fi

URL="${URL%/}"
pass=0
fail=0

ok()   { printf '  \033[32mOK\033[0m    %s\n' "$1"; pass=$((pass + 1)); }
ko()   { printf '  \033[31mÉCHEC\033[0m %s\n' "$1"; fail=$((fail + 1)); }
note() { printf '        %s\n' "$1"; }

get() {
  curl -sS --max-time 20 \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
    "$URL/rest/v1/$1"
}

rpc() {
  curl -sS --max-time 20 -X POST \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    -d "$2" "$URL/rest/v1/rpc/$1"
}

echo
echo "Socle du mode Classe — $URL"
echo

# 1. Les tables ne se lisent pas -------------------------------------
# RLS est actif et aucune politique n'existe pour le rôle anonyme : la
# réponse attendue est une liste vide, pas une erreur. C'est la
# différence entre « il n'y a rien » et « je n'ai pas le droit », et
# c'est la seconde qui est vraie ici.
for table in participants sessions answers licences reports; do
  body="$(get "$table?select=*&limit=1")"
  if [[ "$body" == "[]" ]]; then
    ok "la table $table ne rend rien à la clé publique"
  elif grep -qi 'permission denied\|not exist\|schema must be' <<<"$body"; then
    ok "la table $table est refusée à la clé publique"
  else
    ko "la table $table a répondu quelque chose"
    note "$(head -c 200 <<<"$body")"
  fi
done

# 2. Un code inconnu ne raconte rien ----------------------------------
body="$(rpc board_state '{"p_code":"ZZZZZZ"}')"
if grep -q 'unknown_code' <<<"$body"; then
  ok "board_state répond unknown_code sur un code qui n'existe pas"
else
  ko "board_state n'a pas répondu unknown_code"
  note "$(head -c 200 <<<"$body")"
fi

# 3. On ne rejoint pas une séance qui n'existe pas ---------------------
body="$(rpc join_session '{"p_code":"ZZZZZZ","p_nickname":"Test"}')"
if grep -q 'unknown_code' <<<"$body"; then
  ok "join_session refuse un code inconnu"
else
  ko "join_session n'a pas refusé un code inconnu"
  note "$(head -c 200 <<<"$body")"
fi

# 4. Les fonctions de l'enseignant sont hors de portée -----------------
# my_licence, open_session, advance_session et close_session sont
# réservées aux comptes connectés. Avec la clé anonyme, la réponse doit
# être un refus — jamais une licence.
for fn in my_licence open_session advance_session close_session; do
  body="$(rpc "$fn" '{}')"
  if grep -qi 'permission denied\|not find\|does not exist\|PGRST' <<<"$body"; then
    ok "la fonction $fn est refusée à la clé publique"
  else
    ko "la fonction $fn a répondu à la clé publique"
    note "$(head -c 200 <<<"$body")"
  fi
done

# 5. Le ménage est planifié -------------------------------------------
# Rien de tout cela ne se voit de l'extérieur : à vérifier dans le SQL
# Editor, une fois.
echo
echo "À vérifier une fois dans le SQL Editor (rien de ceci ne se voit d'ici) :"
cat <<'SQL'

  -- Les trois nettoyages sont-ils planifiés ?
  select jobname, schedule from cron.job where jobname like 'iqraquest-%';

  -- RLS est-il bien actif partout, et sans aucune politique ?
  select relname, relrowsecurity,
         (select count(*) from pg_policies p where p.tablename = c.relname) as policies
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public' and c.relkind = 'r'
   order by relname;

SQL

echo
if [[ $fail -eq 0 ]]; then
  printf '\033[32m%d vérifications passées.\033[0m Le socle tient.\n\n' "$pass"
  exit 0
fi
printf '\033[31m%d échec(s)\033[0m sur %d vérifications.\n\n' "$fail" "$((pass + fail))"
exit 1
