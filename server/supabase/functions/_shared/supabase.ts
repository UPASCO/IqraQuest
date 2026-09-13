// Ce que les fonctions demandent à Supabase : qui appelle, et lire ou
// écrire une ligne avec la clé de service — qui ne sort jamais d'ici.
import { SERVICE_ROLE, SUPABASE_ANON_KEY, SUPABASE_URL } from "./env.ts";

export interface Caller {
  id: string;
  email: string;
}

/// L'utilisateur derrière le jeton `Authorization: Bearer …` de la
/// requête. Null si le jeton est absent, faux ou périmé. C'est GoTrue
/// qui juge, pas nous.
export async function callerOf(request: Request): Promise<Caller | null> {
  const auth = request.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return null;
  const response = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: { apikey: SUPABASE_ANON_KEY, Authorization: auth },
  });
  if (!response.ok) return null;
  const user = await response.json();
  if (!user?.id || !user?.email) return null;
  // Une adresse non confirmée n'a pas de licence (my_licence) : elle ne
  // paie pas non plus.
  if (!user?.email_confirmed_at) return null;
  return { id: String(user.id), email: String(user.email) };
}

const serviceHeaders = {
  apikey: SERVICE_ROLE,
  Authorization: `Bearer ${SERVICE_ROLE}`,
  "Content-Type": "application/json",
};

export async function selectOne<T>(
  table: string,
  filter: string,
  columns = "*",
): Promise<T | null> {
  const response = await fetch(
    `${SUPABASE_URL}/rest/v1/${table}?${filter}&select=${columns}&limit=1`,
    { headers: serviceHeaders },
  );
  if (!response.ok) throw new Error(`${table} read failed: ${response.status}`);
  const rows = await response.json();
  return Array.isArray(rows) && rows.length ? rows[0] as T : null;
}

export async function patch(
  table: string,
  filter: string,
  fields: Record<string, unknown>,
): Promise<number> {
  const response = await fetch(`${SUPABASE_URL}/rest/v1/${table}?${filter}`, {
    method: "PATCH",
    headers: { ...serviceHeaders, Prefer: "return=representation" },
    body: JSON.stringify(fields),
  });
  if (!response.ok) throw new Error(`${table} patch failed: ${response.status}`);
  const rows = await response.json();
  return Array.isArray(rows) ? rows.length : 0;
}

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      // La console vit sur son propre sous-domaine ; les fonctions sur
      // celui de Supabase. Le navigateur demande la permission.
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "authorization, apikey, content-type",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
    },
  });
}

export function preflight(request: Request): Response | null {
  if (request.method === "OPTIONS") return json({}, 204);
  return null;
}
