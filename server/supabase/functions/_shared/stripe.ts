// Parler à Stripe sans SDK : l'API est du formulaire encodé, et deux
// appels suffisent ici. Pas de dépendance, rien à mettre à jour.
import { STRIPE_SECRET_KEY } from "./env.ts";

/// Encode un objet imbriqué à la manière de Stripe :
/// `{ line_items: [{ price: "x" }] }` → `line_items[0][price]=x`.
export function form(
  data: Record<string, unknown>,
  prefix = "",
  out: string[] = [],
): string {
  for (const [key, value] of Object.entries(data)) {
    if (value === undefined || value === null) continue;
    const name = prefix ? `${prefix}[${key}]` : key;
    if (Array.isArray(value)) {
      value.forEach((item, i) => {
        if (typeof item === "object" && item !== null) {
          form(item as Record<string, unknown>, `${name}[${i}]`, out);
        } else {
          out.push(`${encodeURIComponent(`${name}[${i}]`)}=${encodeURIComponent(String(item))}`);
        }
      });
    } else if (typeof value === "object") {
      form(value as Record<string, unknown>, name, out);
    } else {
      out.push(`${encodeURIComponent(name)}=${encodeURIComponent(String(value))}`);
    }
  }
  return out.join("&");
}

export async function stripe(
  path: string,
  data?: Record<string, unknown>,
  method: "POST" | "GET" | "DELETE" = data ? "POST" : "GET",
  // deno-lint-ignore no-explicit-any
): Promise<any> {
  if (!STRIPE_SECRET_KEY) throw new Error("STRIPE_SECRET_KEY manquant");
  const response = await fetch(`https://api.stripe.com/v1${path}`, {
    method,
    headers: {
      Authorization: `Bearer ${STRIPE_SECRET_KEY}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: method !== "GET" && data ? form(data) : undefined,
  });
  const body = await response.json();
  if (!response.ok) {
    // Le message de Stripe, jamais la clé : elle n'est pas dans la
    // réponse, et ce log est le seul endroit où l'erreur se lit.
    throw new Error(`stripe ${path}: ${body?.error?.message ?? response.status}`);
  }
  return body;
}
