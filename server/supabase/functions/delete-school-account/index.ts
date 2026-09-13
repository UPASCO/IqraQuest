// IqraQuest — mode École : supprimer son compte, abonnement compris.
//
// La suppression en base (`delete_my_account`) refuse tant qu'un
// abonnement Stripe est encore facturé : sinon l'école paierait pour un
// compte qui n'existe plus. Cette fonction fait les choses dans l'ordre :
//   1. résilier l'abonnement chez Stripe, tout de suite, sans facture ;
//   2. marquer la licence `canceled` ;
//   3. appeler `delete_my_account` avec le jeton de l'enseignant — c'est
//      lui qui supprime, pas la clé de service.
// Le client Stripe et ses factures restent chez Stripe : obligation
// légale de conservation, et IqraQuest n'en garde pas de copie.
//
//   supabase functions deploy delete-school-account
import { SUPABASE_ANON_KEY, SUPABASE_URL } from "../_shared/env.ts";
import { stripe } from "../_shared/stripe.ts";
import { callerOf, json, patch, preflight, selectOne } from "../_shared/supabase.ts";

const LIVE_STATUSES = ["active", "trialing", "past_due", "unpaid", "incomplete"];

Deno.serve(async (request) => {
  const pre = preflight(request);
  if (pre) return pre;
  if (request.method !== "POST") return json({ error: "method" }, 405);

  const caller = await callerOf(request);
  if (!caller) return json({ error: "not_signed_in" }, 401);

  try {
    const licence = await selectOne<{
      id: string;
      stripe_subscription_id: string | null;
      status: string;
    }>(
      "licences",
      `owner_id=eq.${caller.id}&stripe_subscription_id=not.is.null`,
      "id,stripe_subscription_id,status",
    );
    if (licence?.stripe_subscription_id && LIVE_STATUSES.includes(licence.status)) {
      try {
        await stripe(
          `/subscriptions/${licence.stripe_subscription_id}`,
          { invoice_now: false, prorate: false },
          "DELETE",
        );
      } catch (e) {
        // Déjà résilié chez Stripe : on continue. Toute autre erreur
        // arrête tout — on ne supprime pas un compte encore facturé.
        if (!/No such subscription|canceled/i.test((e as Error).message)) throw e;
      }
      await patch("licences", `id=eq.${licence.id}`, {
        status: "canceled",
        cancel_at_period_end: false,
      });
      console.log("abonnement résilié avant suppression", { user: caller.id });
    }

    // La suppression elle-même, au nom de l'enseignant.
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/delete_my_account`, {
      method: "POST",
      headers: {
        apikey: SUPABASE_ANON_KEY,
        Authorization: request.headers.get("Authorization") ?? "",
        "Content-Type": "application/json",
      },
      body: "{}",
    });
    if (!response.ok) throw new Error(`delete_my_account: ${response.status}`);
    const result = await response.json();
    if (result?.error) return json({ error: String(result.error) }, 409);
    console.log("compte supprimé", { user: caller.id });
    return json({ deleted: true });
  } catch (e) {
    console.error("delete:", (e as Error).message);
    return json({ error: "server" }, 502);
  }
});
