// IqraQuest — mode École : gérer son abonnement.
//
// Le portail client de Stripe fait tout ce qu'une école attend —
// consulter, changer de carte, télécharger les factures, arrêter le
// renouvellement — et le fait mieux qu'une page maison. Cette fonction
// ne fait qu'ouvrir la porte, pour le client Stripe du compte qui
// appelle et personne d'autre.
//
//   supabase functions deploy create-customer-portal
import { CONSOLE_URL } from "../_shared/env.ts";
import { stripe } from "../_shared/stripe.ts";
import { callerOf, json, preflight, selectOne } from "../_shared/supabase.ts";

Deno.serve(async (request) => {
  const pre = preflight(request);
  if (pre) return pre;
  if (request.method !== "POST") return json({ error: "method" }, 405);

  const caller = await callerOf(request);
  if (!caller) return json({ error: "not_signed_in" }, 401);

  try {
    const licence = await selectOne<{ stripe_customer_id: string | null }>(
      "licences",
      `owner_id=eq.${caller.id}`,
      "stripe_customer_id",
    );
    if (!licence?.stripe_customer_id) return json({ error: "no_customer" }, 404);

    const portal = await stripe("/billing_portal/sessions", {
      customer: licence.stripe_customer_id,
      return_url: `${CONSOLE_URL}/?portal=back#/teacher`,
    });
    console.log("portail ouvert", { user: caller.id });
    return json({ url: portal.url });
  } catch (e) {
    console.error("portal:", (e as Error).message);
    return json({ error: "stripe" }, 502);
  }
});
