// IqraQuest — mode École : ce que les fonctions lisent de leur
// environnement, et rien d'autre.
//
// Deux clés Stripe distinctes selon le mode, jamais mélangées :
//
//   STRIPE_MODE                 test | live
//   STRIPE_SECRET_KEY           sk_test_… ou sk_live_… (selon STRIPE_MODE)
//   STRIPE_SCHOOL_PRICE_TEST    price_… à 1 €/an, en mode test uniquement
//   STRIPE_SCHOOL_PRICE_LIVE    price_… à 89 €/an
//
// Le tarif de test à 1 € sert à jouer le parcours complet — paiement,
// webhook, activation, portail, résiliation — sans dépenser 89 €. Il ne
// doit JAMAIS devenir le tarif en production : `priceIdFor()` refuse un
// prix de test avec une clé live, et `create-school-checkout` vérifie en
// plus le montant réel du prix avant d'ouvrir la caisse.

export const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
export const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
export const SERVICE_ROLE = Deno.env.get("IQRAQUEST_SERVICE_KEY") ??
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

export const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY") ?? "";
export const STRIPE_MODE = (Deno.env.get("STRIPE_MODE") ?? "test").toLowerCase();

/// L'adresse de la console — là où Stripe ramène après paiement, et où
/// le portail renvoie. Jamais localhost en production.
export const CONSOLE_URL = Deno.env.get("TEACHER_CONSOLE_URL") ??
  "https://school.iqraquest.org";

export function isLive(): boolean {
  return STRIPE_MODE === "live";
}

/// Le Price ID du palier École pour ce mode. Refuse la combinaison qui
/// mettrait le tarif de test en production.
export function priceIdFor(): string {
  const test = Deno.env.get("STRIPE_SCHOOL_PRICE_TEST") ?? "";
  const live = Deno.env.get("STRIPE_SCHOOL_PRICE_LIVE") ?? "";
  if (isLive()) {
    if (!STRIPE_SECRET_KEY.startsWith("sk_live_")) {
      throw new Error("STRIPE_MODE=live mais la clé n'est pas une clé live");
    }
    if (!live) throw new Error("STRIPE_SCHOOL_PRICE_LIVE manquant");
    if (live === test) {
      throw new Error("le Price ID live est identique au Price ID de test");
    }
    return live;
  }
  if (STRIPE_SECRET_KEY.startsWith("sk_live_")) {
    throw new Error("STRIPE_MODE=test mais la clé est une clé live");
  }
  if (!test) throw new Error("STRIPE_SCHOOL_PRICE_TEST manquant");
  return test;
}

/// En production, un prix École sous ce montant est une erreur de
/// configuration, pas une promotion : c'est le garde-fou contre « 1 €
/// en live ». En centimes.
export const LIVE_MINIMUM_AMOUNT_CENTS = 5000;
