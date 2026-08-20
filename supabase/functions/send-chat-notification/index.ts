

import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID")!;
const FIREBASE_SERVICE_ACCOUNT = Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!;

Deno.serve(async (req) => {
  try {
    const payload = await req.json();
    const record = payload.record;
    if (!record) return new Response("No record", { status: 400 });

    const { id: messageId, conversation_id, sender_id, content, type } = record;

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Get sender profile
    const { data: sender } = await supabase
      .from("profiles")
      .select("full_name")
      .eq("id", sender_id)
      .single();

    // Get recipients
    const { data: members } = await supabase
      .from("conversation_members")
      .select("user_id")
      .eq("conversation_id", conversation_id)
      .neq("user_id", sender_id);

    if (!members || members.length === 0) {
      return new Response("No recipients", { status: 200 });
    }

    const recipientIds = members.map((m: any) => m.user_id);

    // Get FCM tokens
    const { data: tokens } = await supabase
      .from("fcm_tokens")
      .select("token, user_id")
      .in("user_id", recipientIds);

    if (!tokens || tokens.length === 0) {
      return new Response("No FCM tokens", { status: 200 });
    }

    // Get FCM access token
    const accessToken = await getAccessToken();

    const senderName = sender?.full_name ?? "Someone";
    const notificationBody = type === "image" ? "📷 Photo" : content;

    // Send to each token
    const results = await Promise.allSettled(
      tokens.map((t: any) =>
        sendNotification({
          token: t.token,
          title: senderName,
          body: notificationBody,
          accessToken,
          data: {
            conversation_id,
            other_user_id: sender_id,
            message_id: messageId,
          },
        })
      )
    );

    console.log("Results:", JSON.stringify(results));

    return new Response(JSON.stringify({ success: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});

// Get FCM OAuth2 access token
// Uses Deno's native crypto.subtle for RSA-SHA256 JWT signing
async function getAccessToken(): Promise<string> {
  const serviceAccount = JSON.parse(FIREBASE_SERVICE_ACCOUNT);

  const now = Math.floor(Date.now() / 1000);

  // Build JWT header + payload
  const header = { alg: "RS256", typ: "JWT" };
  const jwtPayload = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  // Base64url encode (NOT regular base64)
  const encodeBase64Url = (str: string): string => {
    return btoa(str)
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=+$/, "");
  };

  const encodedHeader = encodeBase64Url(JSON.stringify(header));
  const encodedPayload = encodeBase64Url(JSON.stringify(jwtPayload));
  const signingInput = `${encodedHeader}.${encodedPayload}`;

  // Import private key
  const privateKey = await importPKCS8(serviceAccount.private_key);

  // Sign
  const encoder = new TextEncoder();
  const signatureBuffer = await crypto.subtle.sign(
    { name: "RSASSA-PKCS1-v1_5" },
    privateKey,
    encoder.encode(signingInput)
  );

  // Base64url encode signature
  const signatureArray = new Uint8Array(signatureBuffer);
  const signatureBase64 = btoa(String.fromCharCode(...signatureArray))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");

  const jwt = `${signingInput}.${signatureBase64}`;

  // Exchange JWT for access token
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const tokenData = await tokenResponse.json();

  if (!tokenData.access_token) {
    console.error("Token exchange failed:", JSON.stringify(tokenData));
    throw new Error(`Failed to get access token: ${JSON.stringify(tokenData)}`);
  }

  return tokenData.access_token;
}


// Import PKCS8 PEM private key
async function importPKCS8(pem: string): Promise<CryptoKey> {
  // Remove PEM headers and decode base64
  const pemContents = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\n/g, "")
    .trim();

  const binaryDer = Uint8Array.from(
    atob(pemContents),
    (char) => char.charCodeAt(0)
  );

  return await crypto.subtle.importKey(
    "pkcs8",
    binaryDer.buffer,
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: { name: "SHA-256" },
    },
    false,
    ["sign"]
  );
}

// Send FCM notification via HTTP v1 API
async function sendNotification({
  token,
  title,
  body,
  accessToken,
  data,
}: {
  token: string;
  title: string;
  body: string;
  accessToken: string;
  data: Record<string, string>;
}) {
  const url = `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`;

  const message = {
    message: {
      token,
      data: {
          ...Object.fromEntries(
                     Object.entries(data).map(([k, v]) => [k, String(v)])
                   ),
               title,
               body
          },
      android: {
        priority: "high",
      },
    },
  };

  const response = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(message),
  });

  if (!response.ok) {
    const error = await response.text();
    console.error(`FCM error for token ${token}:`, error);
    throw new Error(`FCM error: ${error}`);
  }

  const result = await response.json();
  console.log("FCM success:", JSON.stringify(result));
  return result;
}