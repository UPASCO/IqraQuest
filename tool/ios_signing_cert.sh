#!/usr/bin/env bash
#
# Build the ONE iOS distribution identity the CI reuses, so Xcode stops
# asking Apple for a new certificate on every run.
#
# Why this exists: a GitHub runner starts with an empty keychain. With
# automatic signing, Xcode then asks Apple for a brand-new certificate
# each build — and Apple caps how many a team may hold. Once the cap is
# reached every iOS build dies on:
#
#     error: Choose a certificate to revoke. Your account has reached
#            the maximum number of certificates.
#
# Worse, each of those certificates is useless: its private key died
# with the runner that made it. The cure is to create one identity whose
# private key YOU keep, and hand it to the CI as a secret.
#
# This script does every step that does not need an Apple login. It runs
# anywhere with openssl — a Mac is not required.
#
#   ./tool/ios_signing_cert.sh csr you@example.com
#       → makes the private key and the signing request to upload.
#
#   ./tool/ios_signing_cert.sh p12 ~/Downloads/distribution.cer
#       → folds Apple's certificate back together with that private key
#         and prints the two values to paste as GitHub secrets.
#
# Everything is written to ~/iqraquest-signing, deliberately outside the
# repository: a distribution private key must never be committed.
set -euo pipefail

DIR="${IQRAQUEST_SIGNING_DIR:-$HOME/iqraquest-signing}"
KEY="$DIR/ios_dist.key"
CSR="$DIR/ios_dist.csr"
P12="$DIR/ios_dist.p12"
B64="$DIR/ios_dist.p12.b64"

die() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }
step() { printf '\n\033[1m%s\033[0m\n' "$*"; }

command -v openssl >/dev/null || die "openssl is not installed."

case "${1:-}" in
csr)
  email="${2:-}"
  [ -n "$email" ] || die "Usage: $0 csr <your-apple-id-email>"

  mkdir -p "$DIR"
  chmod 700 "$DIR"
  # Never silently replace a key: the certificate Apple already issued
  # against it would become unusable, which is the exact mess this
  # script exists to clean up.
  [ -e "$KEY" ] && die "$KEY already exists. Move it aside first if you
really mean to start over — the certificate Apple issued for it will
stop working."

  step "1/2  Generating the private key and the signing request…"
  openssl genrsa -out "$KEY" 2048 2>/dev/null
  chmod 600 "$KEY"
  openssl req -new -key "$KEY" -out "$CSR" \
    -subj "/emailAddress=$email/CN=IqraQuest Distribution/C=FR"

  step "2/2  Your turn, on Apple's site (about two minutes):"
  cat <<EOF

  a. Open  https://developer.apple.com/account/resources/certificates/list

  b. Revoke the certificates the CI piled up. They are all unusable —
     their private keys died with the runners that made them — and
     revoking a distribution certificate removes NOTHING that is
     already on the App Store.

  c. Click  +  →  "Apple Distribution"  →  Continue
     Upload this file:

         $CSR

     →  Continue  →  Download. You get a file called distribution.cer.

  d. Come back here and run:

         $0 p12 ~/Downloads/distribution.cer

  The private key stays in $KEY and never leaves this machine.
EOF
  ;;

p12)
  cer="${2:-}"
  [ -n "$cer" ] || die "Usage: $0 p12 <path to the .cer downloaded from Apple>"
  [ -f "$cer" ] || die "No such file: $cer"
  [ -f "$KEY" ] || die "$KEY is missing — run '$0 csr <email>' first."

  step "1/3  Reading Apple's certificate…"
  pem="$DIR/ios_dist.pem"
  # Apple hands out DER; a browser or a mail client may have turned it
  # into PEM on the way. Accept either rather than fail on a detail.
  if openssl x509 -inform DER -in "$cer" -out "$pem" 2>/dev/null; then
    printf '     read as DER (Apple'"'"'s usual format)\n'
  elif openssl x509 -inform PEM -in "$cer" -out "$pem" 2>/dev/null; then
    printf '     read as PEM\n'
  else
    die "$cer is not a certificate. Download it again from the Apple
portal — the file must be the certificate itself, not a page saved
from the browser."
  fi
  printf '     %s\n' "$(openssl x509 -in "$pem" -noout -subject | sed 's/^subject=//')"
  printf '     expires %s\n' "$(openssl x509 -in "$pem" -noout -enddate | sed 's/^notAfter=//')"

  step "2/3  Checking the certificate matches the private key…"
  # The single most common way this goes wrong is downloading a
  # certificate issued for a DIFFERENT request. Caught here, it costs a
  # re-download; caught in CI, it costs a failed build and a support
  # hunt.
  a=$(openssl x509 -in "$pem" -noout -modulus | openssl md5)
  b=$(openssl rsa -in "$KEY" -noout -modulus 2>/dev/null | openssl md5)
  [ "$a" = "$b" ] || die "This certificate was NOT issued for the key in
$KEY. On the Apple portal, download the certificate created from
$CSR — or start over with '$0 csr <email>'."
  printf '     they match\n'

  password=$(openssl rand -base64 24 | tr -d '/+=' | cut -c1-24)

  step "3/3  Packing the identity…"
  # -legacy (RC2/3DES) rather than OpenSSL 3's AES default: the CI runs
  # `security import` on macOS, and that reads the legacy container
  # everywhere, while the modern one is refused on some macOS versions.
  if ! openssl pkcs12 -export -legacy -inkey "$KEY" -in "$pem" \
       -name "Apple Distribution" -out "$P12" \
       -passout "pass:$password" 2>/dev/null; then
    openssl pkcs12 -export -inkey "$KEY" -in "$pem" \
      -name "Apple Distribution" -out "$P12" -passout "pass:$password"
  fi
  chmod 600 "$P12"

  if base64 --help 2>&1 | grep -q -- '-w'; then
    base64 -w0 "$P12" > "$B64"          # GNU
  else
    base64 -i "$P12" | tr -d '\n' > "$B64"   # BSD / macOS
  fi

  cat <<EOF

  Done. Two secrets to add, at:

      https://github.com/UPASCO/IqraQuest/settings/secrets/actions

  ── IOS_DIST_CERT_PASSWORD ─────────────────────────────────────────
  $password

  ── IOS_DIST_CERT_P12 ──────────────────────────────────────────────
  The single line in this file (copy all of it, no line breaks):

      $B64

  On macOS:  pbcopy < $B64
  On Linux:  xclip -sel clip < $B64

  Then tell me, and I relaunch the iOS build. From that point every
  build imports this identity and Apple is never asked for another
  certificate.

  Keep $KEY and $P12 somewhere safe and out of the repository — with
  them you never have to do any of this again.
EOF
  ;;

*)
  cat <<EOF
Build the one iOS signing identity the CI reuses.

  $0 csr <your-apple-id-email>     make the key and the request
  $0 p12 <distribution.cer>        fold Apple's answer back in

Files live in $DIR (override with IQRAQUEST_SIGNING_DIR).
Full background: store/apple/TESTFLIGHT_SETUP.md, section 4bis.
EOF
  exit 1
  ;;
esac
