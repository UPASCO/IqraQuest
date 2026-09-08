// IqraQuest — mode Classe : la licence, écrite par Stripe.
//
// Stripe encaisse, cette fonction inscrit la licence sur l'adresse qui a
// payé. L'enseignant n'a donc rien à créer au moment de l'achat : il se
// connecte plus tard par lien magique, et `my_licence()` rattache la
// ligne à son compte (migration 0002).
//
// Deux règles gouvernent ce fichier :
//
// 1. RIEN N'EST CRU SANS SIGNATURE. Le corps de la requête n'est lu
//    qu'après vérification de l'en-tête `Stripe-Signature` avec le
//    secret du webhook. Sans cela, n'importe qui pourrait s'offrir une
//    licence en appelant cette URL.
// 2. LA CLÉ `service_role` NE SORT PAS D'ICI. Elle vit dans les
//    variables d'environnement de la fonction, jamais dans le dépôt,
//    jamais dans l'app. C'est la seule clé qui peut écrire dans
//    `licences`.
//
// Déploiement :
//
//   supabase functions deploy stripe-webhook --no-verify-jwt
//   supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_...
//   supabase secrets set SUPABASE_SERVICE_ROLE_KEY=...
//
// Puis, côté Stripe, un webhook vers l'URL de la fonction, abonné à
// `checkout.session.completed`, `customer.subscription.updated` et
// `customer.subscription.deleted`.
//
// `--no-verify-jwt` est indispensable : c'est Stripe qui appelle, et il
// ne porte pas de JWT Supabase. La signature ci-dessous est ce qui
// remplace ce contrôle.

const WEBHOOK_SECRET = Deno.env.get("STRIPE_WEBHOOK_SECRET") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

// Cinq minutes : au-delà, un appel rejoué n'est plus un appel en retard.
const TOLERANCE_SECONDS = 300;

/// Vérifie l'en-tête `Stripe-Signature`.
///
/// Le schéma est documenté par Stripe : `t=<horodatage>,v1=<hmac>`, le
/// HMAC portant sur `<horodatage>.<corps brut>`. On compare en temps
/// constant, et on refuse ce qui est trop vieux.
async function signatureIsValid(
  payload: string,
  header: string | null,
): Promise<boolean> {
  if (!header || !WEBHOOK_SECRET) return false;

  let timestamp = "";
  const signatures: string[] = [];
  for (const part of header.split(",")) {
    const [key, value] = part.split("=");
    if (key === "t") timestamp = value;
    if (key === "v1") signatures.push(value);
  }
  if (!timestamp || signatures.length === 0) return false;

  const age = Math.abs(Math.floor(Date.now() / 1000) - Number(timestamp));
  if (!Number.isFinite(age) || age > TOLERANCE_SECONDS) return false;

  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(WEBHOOK_SECRET),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const mac = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(`${timestamp}.${payload}`),
  );
  const expected = [...new Uint8Array(mac)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");

  return signatures.some((candidate) => constantTimeEquals(candidate, expected));
}

function constantTimeEquals(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) {
    diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return diff === 0;
}

/// Ce que l'offre achetée donne droit à faire.
///
/// Les métadonnées sont posées sur le produit dans Stripe — c'est là que
/// vivent les prix et les paliers, jamais dans ce dépôt. Sans
/// métadonnée, on retombe sur la licence la plus modeste : une salle.
function entitlementOf(metadata: Record<string, string> | undefined) {
  const plan = metadata?.iqraquest_plan ?? "classe";
  const rooms = Number(metadata?.iqraquest_rooms ?? "1");
  return {
    plan: ["essai", "classe", "ecole"].includes(plan) ? plan : "classe",
    concurrent_sessions: Number.isFinite(rooms)
      ? Math.min(100, Math.max(1, Math.trunc(rooms)))
      : 1,
  };
}

async function upsertLicence(row: Record<string, unknown>) {
  const response = await fetch(
    `${SUPABASE_URL}/rest/v1/licences?on_conflict=email`,
    {
      method: "POST",
      headers: {
        "apikey": SERVICE_ROLE,
        "Authorization": `Bearer ${SERVICE_ROLE}`,
        "Content-Type": "application/json",
        // Une adresse, une licence : un renouvellement met à jour la
        // ligne existante plutôt que d'en empiler une seconde.
        "Prefer": "resolution=merge-duplicates,return=minimal",
      },
      body: JSON.stringify(row),
    },
  );
  if (!response.ok) {
    throw new Error(`licence write failed: ${response.status}`);
  }
}

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return new Response("method not allowed", { status: 405 });
  }

  const payload = await request.text();
  if (!await signatureIsValid(payload, request.headers.get("Stripe-Signature"))) {
    // Volontairement muet : un appelant non signé n'apprend rien d'ici.
    return new Response("bad signature", { status: 400 });
  }

  const event = JSON.parse(payload);
  const object = event?.data?.object ?? {};

  try {
    switch (event?.type) {
      case "checkout.session.completed": {
        const email = object?.customer_details?.email ?? object?.customer_email;
        if (!email) break;
        const rights = entitlementOf(object?.metadata);
        // Un abonnement porte sa propre échéance ; un paiement unique
        // vaut l'année scolaire, renouvelée à chaque achat.
        const expires = object?.expires_at
          ? new Date(object.expires_at * 1000)
          : new Date(Date.now() + 365 * 24 * 3600 * 1000);
        await upsertLicence({
          email,
          plan: rights.plan,
          concurrent_sessions: rights.concurrent_sessions,
          expires_at: expires.toISOString(),
          stripe_customer_id: object?.customer ?? null,
          stripe_subscription_id: object?.subscription ?? null,
        });
        break;
      }

      case "customer.subscription.updated":
      case "customer.subscription.created": {
        const email = object?.metadata?.iqraquest_email;
        if (!email) break;
        const rights = entitlementOf(object?.metadata);
        await upsertLicence({
          email,
          plan: rights.plan,
          concurrent_sessions: rights.concurrent_sessions,
          expires_at: new Date(
            (object?.current_period_end ?? 0) * 1000,
          ).toISOString(),
          stripe_customer_id: object?.customer ?? null,
          stripe_subscription_id: object?.id ?? null,
        });
        break;
      }

      case "customer.subscription.deleted": {
        const email = object?.metadata?.iqraquest_email;
        if (!email) break;
        // On ne supprime pas la licence : on l'arrête. L'école qui
        // revient l'année suivante retrouve la même ligne, et ses
        // rapports avec.
        await upsertLicence({
          email,
          plan: "classe",
          concurrent_sessions: 1,
          expires_at: new Date().toISOString(),
        });
        break;
      }
    }
  } catch (error) {
    // Stripe réessaie sur un 500 : c'est ce qu'on veut si l'écriture a
    // échoué, plutôt qu'une licence payée et jamais inscrite.
    console.error(error);
    return new Response("write failed", { status: 500 });
  }

  return new Response(JSON.stringify({ received: true }), {
    headers: { "Content-Type": "application/json" },
  });
});
