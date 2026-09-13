// IqraQuest — mode École : ouvrir la caisse.
//
// L'école clique « S'abonner » dans sa console ; cette fonction fabrique
// la page de paiement Stripe et rend son adresse. Le prix est chez
// Stripe, la clé secrète est ici, et ni l'un ni l'autre ne passent par
// un navigateur.
//
// Ce que la fonction garantit :
//   - l'appelant est un compte confirmé (jeton vérifié par GoTrue) ;
//   - un seul client Stripe par compte : retrouvé s'il existe, créé
//     sinon, et inscrit sur la licence avant d'ouvrir la caisse ;
//   - la métadonnée du palier est posée sur l'abonnement — c'est elle
//     que le webhook lit pour savoir ce qu'il ouvre ;
//   - en mode live, un prix sous 50 € est refusé : le tarif de test à 1 €
//     ne peut pas finir en production par une variable mal posée.
//
// Déploiement :
//   supabase functions deploy create-school-checkout
//   supabase secrets set STRIPE_SECRET_KEY=sk_test_… STRIPE_MODE=test \
//     STRIPE_SCHOOL_PRICE_TEST=price_… STRIPE_SCHOOL_PRICE_LIVE=price_…
import {
  CONSOLE_URL,
  isLive,
  LIVE_MINIMUM_AMOUNT_CENTS,
  priceIdFor,
} from "../_shared/env.ts";
import { stripe } from "../_shared/stripe.ts";
import { callerOf, json, patch, preflight, selectOne } from "../_shared/supabase.ts";

interface LicenceRow {
  id: string;
  email: string;
  plan: string;
  stripe_customer_id: string | null;
  stripe_subscription_id: string | null;
  status: string;
}

Deno.serve(async (request) => {
  const pre = preflight(request);
  if (pre) return pre;
  if (request.method !== "POST") return json({ error: "method" }, 405);

  const caller = await callerOf(request);
  if (!caller) return json({ error: "not_signed_in" }, 401);

  let priceId: string;
  try {
    priceId = priceIdFor();
  } catch (e) {
    console.error("checkout: configuration", (e as Error).message);
    return json({ error: "not_configured" }, 503);
  }

  try {
    // La licence du compte : c'est sur elle que le client Stripe
    // s'inscrit. Sans licence, my_licence() n'a rien rattaché : le
    // déclencheur d'inscription n'a pas tourné, ce qui ne devrait pas
    // arriver — on le dit plutôt que de créer une ligne à l'aveugle.
    const licence = await selectOne<LicenceRow>(
      "licences",
      `owner_id=eq.${caller.id}`,
      "id,email,plan,stripe_customer_id,stripe_subscription_id,status",
    );
    if (!licence) return json({ error: "no_licence" }, 409);

    // Une licence déjà abonnée n'a rien à acheter : c'est le portail
    // qu'il lui faut. Le dire évite un second abonnement par erreur.
    if (licence.stripe_subscription_id && ["active", "trialing", "past_due"].includes(licence.status)) {
      return json({ error: "already_subscribed" }, 409);
    }

    // Le garde-fou du montant : en live, un prix École sous 50 € est
    // une variable mal posée, pas une promotion.
    const price = await stripe(`/prices/${priceId}`);
    if (isLive() && Number(price?.unit_amount ?? 0) < LIVE_MINIMUM_AMOUNT_CENTS) {
      console.error("checkout: prix live trop bas", priceId, price?.unit_amount);
      return json({ error: "not_configured" }, 503);
    }
    if (price?.recurring?.interval !== "year") {
      console.error("checkout: le prix n'est pas annuel", priceId);
      return json({ error: "not_configured" }, 503);
    }

    // Un client par compte, jamais un par tentative.
    let customerId = licence.stripe_customer_id;
    if (!customerId) {
      const customer = await stripe("/customers", {
        email: caller.email,
        metadata: { iqraquest_user_id: caller.id, iqraquest_licence_id: licence.id },
      });
      customerId = String(customer.id);
      await patch("licences", `id=eq.${licence.id}`, { stripe_customer_id: customerId });
    }

    const session = await stripe("/checkout/sessions", {
      mode: "subscription",
      customer: customerId,
      client_reference_id: caller.id,
      line_items: [{ price: priceId, quantity: 1 }],
      // Le retour ne prouve rien : c'est le webhook qui active. Le
      // paramètre dit seulement à la console de redemander son compte.
      success_url: `${CONSOLE_URL}/?checkout=success#/teacher`,
      cancel_url: `${CONSOLE_URL}/?checkout=cancel#/teacher`,
      allow_promotion_codes: false,
      locale: "auto",
      metadata: { iqraquest_plan: "ecole", iqraquest_email: caller.email },
      subscription_data: {
        metadata: { iqraquest_plan: "ecole", iqraquest_email: caller.email },
      },
    });

    console.log("checkout créé", { user: caller.id, session: session.id, live: isLive() });
    return json({ url: session.url });
  } catch (e) {
    console.error("checkout:", (e as Error).message);
    return json({ error: "stripe" }, 502);
  }
});
