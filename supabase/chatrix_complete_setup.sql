-- ============================================================
-- CHATRIX — COMPLETE DATABASE SETUP
-- Run this ONCE in Supabase SQL Editor on a fresh project
-- ============================================================


-- Functions in this script are created before their tables.
-- This setting tells Postgres to skip validating function bodies
-- at creation time, so the order does not matter.
SET check_function_bodies = false;


-- ============================================================
-- EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";


-- ============================================================
-- FUNCTIONS
-- ============================================================

CREATE OR REPLACE FUNCTION "public"."create_direct_conversation"("other_user_id" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  a uuid;
  b uuid;
  existing_id uuid;
  new_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  if other_user_id = auth.uid() then
    raise exception 'Cannot create conversation with yourself';
  end if;

  a := least(auth.uid(), other_user_id);
  b := greatest(auth.uid(), other_user_id);

  select dc.conversation_id into existing_id
  from public.direct_conversations dc
  where dc.user_low = a and dc.user_high = b;

  if existing_id is not null then
    return existing_id;
  end if;

  insert into public.conversations default values
  returning id into new_id;

  begin
    insert into public.direct_conversations (user_low, user_high, conversation_id)
    values (a, b, new_id);
  exception when unique_violation then
    select dc.conversation_id into existing_id
    from public.direct_conversations dc
    where dc.user_low = a and dc.user_high = b;

    delete from public.conversations where id = new_id;
    return existing_id;
  end;

  insert into public.conversation_members (conversation_id, user_id)
  values
    (new_id, auth.uid()),
    (new_id, other_user_id)
  on conflict do nothing;

  return new_id;
end;
$$;

ALTER FUNCTION "public"."create_direct_conversation"("other_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_message_statuses"("p_conversation_id" "uuid")
RETURNS TABLE("message_id" "uuid", "delivered_at" timestamp with time zone, "read_at" timestamp with time zone)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT
    ms.message_id,
    ms.delivered_at,
    ms.read_at
  FROM public.message_status ms
  JOIN public.messages m ON m.id = ms.message_id
  WHERE m.conversation_id = p_conversation_id
    AND m.sender_id = auth.uid()
  ORDER BY m.created_at ASC;
$$;

ALTER FUNCTION "public"."get_message_statuses"("p_conversation_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_messages_paginated"(
  "p_conversation_id" "uuid",
  "p_limit" integer DEFAULT 50,
  "p_before_timestamp" timestamp with time zone DEFAULT NULL::timestamp with time zone
)
RETURNS TABLE(
  "id" "uuid",
  "conversation_id" "uuid",
  "sender_id" "uuid",
  "type" "text",
  "content" "text",
  "created_at" timestamp with time zone,
  "delivered_at" timestamp with time zone,
  "read_at" timestamp with time zone
)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT
    m.id,
    m.conversation_id,
    m.sender_id,
    m.type,
    m.content,
    m.created_at,
    ms.delivered_at,
    ms.read_at
  FROM public.messages m
  JOIN public.conversation_members cm
    ON cm.conversation_id = m.conversation_id
   AND cm.user_id = auth.uid()
  LEFT JOIN public.message_status ms
    ON ms.message_id = m.id
   AND ms.user_id != auth.uid()
  WHERE m.conversation_id = p_conversation_id
    AND (
      p_before_timestamp IS NULL
      OR m.created_at < p_before_timestamp
    )
  ORDER BY m.created_at DESC
  LIMIT p_limit;
$$;

ALTER FUNCTION "public"."get_messages_paginated"("p_conversation_id" "uuid", "p_limit" integer, "p_before_timestamp" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_conversations"()
RETURNS TABLE(
  "id" "uuid",
  "updated_at" timestamp with time zone,
  "last_message_id" "uuid",
  "last_message_preview" "text",
  "last_message_sender_id" "uuid",
  "last_message_at" timestamp with time zone,
  "other_user_id" "uuid",
  "other_user_name" "text",
  "other_user_avatar_url" "text",
  "unread_count" bigint
)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT
    c.id,
    c.updated_at,
    c.last_message_id,
    c.last_message_preview,
    c.last_message_sender_id,
    c.last_message_at,
    p.id                              AS other_user_id,
    COALESCE(p.full_name, 'Unknown')  AS other_user_name,
    p.avatar_url                      AS other_user_avatar_url,
    (
      SELECT COUNT(*)
      FROM public.messages m
      WHERE m.conversation_id = c.id
        AND m.sender_id       != auth.uid()
        AND m.created_at       > COALESCE(cr.last_read_at, '1970-01-01 00:00:00+00')
    ) AS unread_count
  FROM conversation_members  me
    JOIN conversations        c    ON c.id   = me.conversation_id
    JOIN conversation_members them ON them.conversation_id = me.conversation_id
                                   AND them.user_id <> me.user_id
    JOIN profiles             p    ON p.id   = them.user_id
    LEFT JOIN conversation_reads cr ON cr.conversation_id = me.conversation_id
                                    AND cr.user_id        = auth.uid()
  WHERE me.user_id = auth.uid()
  ORDER BY COALESCE(c.last_message_at, c.updated_at) DESC;
$$;

ALTER FUNCTION "public"."get_my_conversations"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_last_seen"("p_user_id" "uuid")
RETURNS timestamp with time zone
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_last_seen timestamptz;
BEGIN
  SELECT last_seen_at INTO v_last_seen
  FROM public.profiles
  WHERE id = p_user_id;
  RETURN v_last_seen;
END;
$$;

ALTER FUNCTION "public"."get_user_last_seen"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_message_insert_update_conversation"()
RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  update public.conversations
  set
    updated_at = new.created_at,
    last_message_id = new.id,
    last_message_sender_id = new.sender_id,
    last_message_at = new.created_at,
    last_message_preview =
      case
        when new.type = 'text' then left(coalesce(new.content, ''), 120)
        else '[' || coalesce(new.type, 'message') || ']'
      end
  where id = new.conversation_id;
  if not found then
    raise exception 'Conversation % not found for message %', new.conversation_id, new.id;
  end if;
  return new;
end;
$$;

ALTER FUNCTION "public"."handle_message_insert_update_conversation"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"()
RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  insert into public.profiles (id, full_name, avatar_url, updated_at)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'full_name',
      new.raw_user_meta_data->>'name',
      'User'
    ),
    new.raw_user_meta_data->>'avatar_url',
    now()
  )
  on conflict (id) do update
    set full_name = coalesce(excluded.full_name, profiles.full_name),
        avatar_url = coalesce(excluded.avatar_url, profiles.avatar_url),
        updated_at = now();
  return new;
end;
$$;

ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_conversation_read"("p_conversation_id" "uuid")
RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if not exists (
    select 1 from public.conversation_members
    where conversation_id = p_conversation_id
      and user_id         = auth.uid()
  ) then
    raise exception 'Not a member of this conversation';
  end if;

  insert into public.conversation_reads (conversation_id, user_id, last_read_at)
  values (p_conversation_id, auth.uid(), now())
  on conflict (conversation_id, user_id)
  do update set last_read_at = now();
end;
$$;

ALTER FUNCTION "public"."mark_conversation_read"("p_conversation_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_messages_delivered"("p_conversation_id" "uuid")
RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  INSERT INTO public.message_status (message_id, user_id, conversation_id, delivered_at)
  SELECT
    m.id,
    auth.uid(),
    p_conversation_id,
    now()
  FROM public.messages m
  WHERE m.conversation_id = p_conversation_id
    AND m.sender_id != auth.uid()
    AND NOT EXISTS (
      SELECT 1 FROM public.message_status ms
      WHERE ms.message_id = m.id
        AND ms.user_id = auth.uid()
        AND ms.delivered_at IS NOT NULL
    )
  ON CONFLICT (message_id, user_id)
  DO UPDATE SET
    conversation_id = EXCLUDED.conversation_id,
    delivered_at    = COALESCE(message_status.delivered_at, now());
END;
$$;

ALTER FUNCTION "public"."mark_messages_delivered"("p_conversation_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_messages_read"("p_conversation_id" "uuid")
RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  INSERT INTO public.message_status (message_id, user_id, conversation_id, delivered_at, read_at)
  SELECT
    m.id,
    auth.uid(),
    p_conversation_id,
    now(),
    now()
  FROM public.messages m
  WHERE m.conversation_id = p_conversation_id
    AND m.sender_id != auth.uid()
    AND NOT EXISTS (
      SELECT 1 FROM public.message_status ms
      WHERE ms.message_id = m.id
        AND ms.user_id = auth.uid()
        AND ms.read_at IS NOT NULL
    )
  ON CONFLICT (message_id, user_id)
  DO UPDATE SET
    conversation_id = EXCLUDED.conversation_id,
    delivered_at    = COALESCE(message_status.delivered_at, now()),
    read_at         = COALESCE(message_status.read_at, now());
END;
$$;

ALTER FUNCTION "public"."mark_messages_read"("p_conversation_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_last_seen"()
RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  UPDATE public.profiles
  SET last_seen_at = now()
  WHERE id = auth.uid();
END;
$$;

ALTER FUNCTION "public"."update_last_seen"() OWNER TO "postgres";


-- ============================================================
-- TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS "public"."conversations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "last_message_id" "uuid",
    "last_message_preview" "text",
    "last_message_sender_id" "uuid",
    "last_message_at" timestamp with time zone,
    CONSTRAINT "conversations_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "public"."conversations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "full_name" "text" NOT NULL,
    "avatar_url" "text",
    "last_seen_at" timestamp with time zone,
    "show_last_seen" boolean DEFAULT true NOT NULL,
    "send_read_receipts" boolean DEFAULT true NOT NULL,
    CONSTRAINT "profiles_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."conversation_members" (
    "conversation_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "conversation_members_unique" UNIQUE ("conversation_id", "user_id")
);

ALTER TABLE "public"."conversation_members" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."conversation_reads" (
    "conversation_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "last_read_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "conversation_reads_pkey" PRIMARY KEY ("conversation_id", "user_id"),
    CONSTRAINT "conversation_reads_unique" UNIQUE ("conversation_id", "user_id")
);

ALTER TABLE "public"."conversation_reads" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."direct_conversations" (
    "user_low" "uuid" NOT NULL,
    "user_high" "uuid" NOT NULL,
    "conversation_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "direct_conversations_pkey" PRIMARY KEY ("user_low", "user_high"),
    CONSTRAINT "direct_conversations_pair_unique" UNIQUE ("user_low", "user_high"),
    CONSTRAINT "direct_conversations_conversation_id_key" UNIQUE ("conversation_id")
);

ALTER TABLE "public"."direct_conversations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "conversation_id" "uuid" NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "content" "text",
    CONSTRAINT "messages_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "public"."messages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."message_status" (
    "message_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "delivered_at" timestamp with time zone,
    "read_at" timestamp with time zone,
    "conversation_id" "uuid" NOT NULL,
    CONSTRAINT "message_status_pkey" PRIMARY KEY ("message_id", "user_id")
);

ALTER TABLE "public"."message_status" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."fcm_tokens" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "token" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "device_id" "text" DEFAULT ''::"text" NOT NULL,
    CONSTRAINT "fcm_tokens_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "fcm_tokens_token_key" UNIQUE ("token"),
    CONSTRAINT "fcm_tokens_user_id_device_id_key" UNIQUE ("user_id", "device_id")
);

ALTER TABLE "public"."fcm_tokens" OWNER TO "postgres";


-- ============================================================
-- FOREIGN KEYS
-- ============================================================

ALTER TABLE ONLY "public"."conversation_members"
    ADD CONSTRAINT "conversation_members_conversation_id_fkey"
    FOREIGN KEY ("conversation_id") REFERENCES "public"."conversations"("id");

ALTER TABLE ONLY "public"."conversation_reads"
    ADD CONSTRAINT "conversation_reads_conversation_id_fkey"
    FOREIGN KEY ("conversation_id") REFERENCES "public"."conversations"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."direct_conversations"
    ADD CONSTRAINT "direct_conversations_conversation_fk"
    FOREIGN KEY ("conversation_id") REFERENCES "public"."conversations"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_conversation_id_fkey"
    FOREIGN KEY ("conversation_id") REFERENCES "public"."conversations"("id");

ALTER TABLE ONLY "public"."message_status"
    ADD CONSTRAINT "message_status_message_id_fkey"
    FOREIGN KEY ("message_id") REFERENCES "public"."messages"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."message_status"
    ADD CONSTRAINT "message_status_user_id_fkey"
    FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."message_status"
    ADD CONSTRAINT "message_status_conversation_id_fkey"
    FOREIGN KEY ("conversation_id") REFERENCES "public"."conversations"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."fcm_tokens"
    ADD CONSTRAINT "fcm_tokens_user_id_fkey"
    FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS "conversation_members_user_id_conversation_id_idx"
    ON "public"."conversation_members" USING "btree" ("user_id", "conversation_id");

CREATE INDEX IF NOT EXISTS "conversation_reads_user_id_conversation_id_idx"
    ON "public"."conversation_reads" USING "btree" ("user_id", "conversation_id");

CREATE INDEX IF NOT EXISTS "conversations_updated_at_idx"
    ON "public"."conversations" USING "btree" ("updated_at" DESC);

CREATE INDEX IF NOT EXISTS "fcm_tokens_user_id_idx"
    ON "public"."fcm_tokens" USING "btree" ("user_id");

CREATE INDEX IF NOT EXISTS "message_status_conversation_id_idx"
    ON "public"."message_status" USING "btree" ("conversation_id");

CREATE INDEX IF NOT EXISTS "message_status_conversation_user_idx"
    ON "public"."message_status" USING "btree" ("conversation_id", "user_id");

CREATE INDEX IF NOT EXISTS "message_status_message_id_idx"
    ON "public"."message_status" USING "btree" ("message_id");

CREATE INDEX IF NOT EXISTS "message_status_user_id_idx"
    ON "public"."message_status" USING "btree" ("user_id");

CREATE INDEX IF NOT EXISTS "messages_conversation_id_created_at_idx"
    ON "public"."messages" USING "btree" ("conversation_id", "created_at");

CREATE INDEX IF NOT EXISTS "profiles_last_seen_at_idx"
    ON "public"."profiles" USING "btree" ("last_seen_at" DESC);


-- ============================================================
-- TRIGGERS
-- ============================================================

-- Auto-update conversation preview when message inserted
CREATE OR REPLACE TRIGGER "on_message_created_update_conversation"
    AFTER INSERT ON "public"."messages"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."handle_message_insert_update_conversation"();

-- Auto-create profile when new user signs up
CREATE OR REPLACE TRIGGER "on_auth_user_created"
    AFTER INSERT ON "auth"."users"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."handle_new_user"();

-- ⚠️ IMPORTANT: Replace YOUR_PROJECT_URL and YOUR_SERVICE_ROLE_KEY below
-- YOUR_PROJECT_URL → Supabase Dashboard → Settings → General → Reference ID
--   Format: https://YOUR_REF.supabase.co
-- YOUR_SERVICE_ROLE_KEY → Supabase Dashboard → Supabase Settings → API Keys → Legacy anon Tab → anon public
CREATE OR REPLACE TRIGGER "on_new_message_notify"
    AFTER INSERT ON "public"."messages"
    FOR EACH ROW
    EXECUTE FUNCTION "supabase_functions"."http_request"(
        'https://YOUR_PROJECT_URL.supabase.co/functions/v1/send-chat-notification',
        'POST',
        '{"Content-type":"application/json","Authorization":"Bearer YOUR_SERVICE_ROLE_KEY"}',
        '{}',
        '5000'
    );


-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE "public"."conversation_members" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."conversation_reads" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."conversations" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."direct_conversations" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."fcm_tokens" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."message_status" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


-- ============================================================
-- RLS POLICIES
-- ============================================================

-- Profiles
CREATE POLICY "Authenticated can read" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);
CREATE POLICY "Create Own Profile Only" ON "public"."profiles" FOR INSERT TO "authenticated" WITH CHECK (("id" = "auth"."uid"()));
CREATE POLICY "Update Own Profile Only" ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("id" = "auth"."uid"())) WITH CHECK (("id" = "auth"."uid"()));

-- Conversations
CREATE POLICY "Allow creating conversations" ON "public"."conversations" FOR INSERT TO "authenticated" WITH CHECK (true);
CREATE POLICY "Read only conversations where I'm a member" ON "public"."conversations" FOR SELECT TO "authenticated"
    USING ((EXISTS ( SELECT 1 FROM "public"."conversation_members" "cm" WHERE (("cm"."conversation_id" = "conversations"."id") AND ("cm"."user_id" = "auth"."uid"())))));

-- Conversation Members
CREATE POLICY "Conversation owners can insert message" ON "public"."conversation_members" FOR INSERT TO "authenticated"
    WITH CHECK (("user_id" = "auth"."uid"()));
CREATE POLICY "Read My Membership Only" ON "public"."conversation_members" FOR SELECT TO "authenticated"
    USING (("user_id" = "auth"."uid"()));

-- Conversation Reads
CREATE POLICY "Insert own comversation_reads" ON "public"."conversation_reads" FOR INSERT TO "authenticated"
    WITH CHECK ((("user_id" = "auth"."uid"()) AND (EXISTS ( SELECT 1 FROM "public"."conversation_members" "cm" WHERE (("cm"."conversation_id" = "conversation_reads"."conversation_id") AND ("cm"."user_id" = "auth"."uid"()))))));
CREATE POLICY "Read own conversation reads only" ON "public"."conversation_reads" FOR SELECT TO "authenticated"
    USING (("user_id" = "auth"."uid"()));
CREATE POLICY "Update own conversation reads only" ON "public"."conversation_reads" FOR UPDATE TO "authenticated"
    USING ((("user_id" = "auth"."uid"()) AND (EXISTS ( SELECT 1 FROM "public"."conversation_members" "cm" WHERE (("cm"."conversation_id" = "conversation_reads"."conversation_id") AND ("cm"."user_id" = "auth"."uid"()))))))
    WITH CHECK (("user_id" = "auth"."uid"()));

-- Direct Conversations
CREATE POLICY "Read own direct conversations" ON "public"."direct_conversations" FOR SELECT TO "authenticated"
    USING ((("user_low" = "auth"."uid"()) OR ("user_high" = "auth"."uid"())));

-- Messages
CREATE POLICY "Insert message if I'm a member" ON "public"."messages" FOR INSERT TO "authenticated"
    WITH CHECK ((("sender_id" = "auth"."uid"()) AND (EXISTS ( SELECT 1 FROM "public"."conversation_members" "cm" WHERE (("cm"."conversation_id" = "messages"."conversation_id") AND ("cm"."user_id" = "auth"."uid"()))))));
CREATE POLICY "Read messages only if I'm a member of that conversation" ON "public"."messages" FOR SELECT TO "authenticated"
    USING ((EXISTS ( SELECT 1 FROM "public"."conversation_members" "cm" WHERE (("cm"."conversation_id" = "messages"."conversation_id") AND ("cm"."user_id" = "auth"."uid"())))));
CREATE POLICY "Update Own Message Only" ON "public"."messages" FOR UPDATE TO "authenticated"
    USING ((("sender_id" = "auth"."uid"()) AND (EXISTS ( SELECT 1 FROM "public"."conversation_members" "cm" WHERE (("cm"."conversation_id" = "messages"."conversation_id") AND ("cm"."user_id" = "auth"."uid"()))))))
    WITH CHECK (("sender_id" = "auth"."uid"()));
CREATE POLICY "Delete Own Message Only" ON "public"."messages" FOR DELETE TO "authenticated"
    USING ((("sender_id" = "auth"."uid"()) AND (EXISTS ( SELECT 1 FROM "public"."conversation_members" "cm" WHERE (("cm"."conversation_id" = "messages"."conversation_id") AND ("auth"."uid"() = "cm"."user_id"))))));

-- Message Status
CREATE POLICY "Users manage their own message status" ON "public"."message_status"
    USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));
CREATE POLICY "Senders can read status of their messages" ON "public"."message_status" FOR SELECT
    USING ((EXISTS ( SELECT 1 FROM "public"."messages" "m" WHERE (("m"."id" = "message_status"."message_id") AND ("m"."sender_id" = "auth"."uid"())))));

-- FCM Tokens
CREATE POLICY "Users manage their own FCM tokens" ON "public"."fcm_tokens" TO "authenticated"
    USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));


-- ============================================================
-- REALTIME
-- ============================================================

ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."conversations";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."messages";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."conversation_reads";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."message_status";


-- ============================================================
-- STORAGE BUCKETS
-- ============================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'chat-images',
    'chat-images',
    false,
    10485760,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;


-- ============================================================
-- STORAGE POLICIES
-- ============================================================

CREATE POLICY "Avatars are publicly readable"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload avatars"
    ON storage.objects FOR INSERT TO authenticated
    WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "Users can update avatars"
    ON storage.objects FOR UPDATE TO authenticated
    USING (bucket_id = 'avatars');

CREATE POLICY "Authenticated can upload chat images"
    ON storage.objects FOR INSERT TO authenticated
    WITH CHECK (bucket_id = 'chat-images');

CREATE POLICY "Authenticated can read chat images"
    ON storage.objects FOR SELECT TO authenticated
    USING (bucket_id = 'chat-images');


-- ============================================================
-- GRANTS
-- ============================================================

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."create_direct_conversation"("other_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."create_direct_conversation"("other_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_direct_conversation"("other_user_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_message_statuses"("p_conversation_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_message_statuses"("p_conversation_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_message_statuses"("p_conversation_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_messages_paginated"("p_conversation_id" "uuid", "p_limit" integer, "p_before_timestamp" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."get_messages_paginated"("p_conversation_id" "uuid", "p_limit" integer, "p_before_timestamp" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_messages_paginated"("p_conversation_id" "uuid", "p_limit" integer, "p_before_timestamp" timestamp with time zone) TO "service_role";

GRANT ALL ON FUNCTION "public"."get_my_conversations"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_conversations"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_conversations"() TO "service_role";

GRANT ALL ON FUNCTION "public"."get_user_last_seen"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_last_seen"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_last_seen"("p_user_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_message_insert_update_conversation"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_message_insert_update_conversation"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_message_insert_update_conversation"() TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";

GRANT ALL ON FUNCTION "public"."mark_conversation_read"("p_conversation_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."mark_conversation_read"("p_conversation_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."mark_conversation_read"("p_conversation_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."mark_messages_delivered"("p_conversation_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."mark_messages_delivered"("p_conversation_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."mark_messages_delivered"("p_conversation_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."mark_messages_read"("p_conversation_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."mark_messages_read"("p_conversation_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."mark_messages_read"("p_conversation_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."update_last_seen"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_last_seen"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_last_seen"() TO "service_role";

GRANT ALL ON TABLE "public"."conversation_members" TO "anon";
GRANT ALL ON TABLE "public"."conversation_members" TO "authenticated";
GRANT ALL ON TABLE "public"."conversation_members" TO "service_role";

GRANT ALL ON TABLE "public"."conversation_reads" TO "anon";
GRANT ALL ON TABLE "public"."conversation_reads" TO "authenticated";
GRANT ALL ON TABLE "public"."conversation_reads" TO "service_role";

GRANT ALL ON TABLE "public"."conversations" TO "anon";
GRANT ALL ON TABLE "public"."conversations" TO "authenticated";
GRANT ALL ON TABLE "public"."conversations" TO "service_role";

GRANT ALL ON TABLE "public"."direct_conversations" TO "anon";
GRANT ALL ON TABLE "public"."direct_conversations" TO "authenticated";
GRANT ALL ON TABLE "public"."direct_conversations" TO "service_role";

GRANT ALL ON TABLE "public"."fcm_tokens" TO "anon";
GRANT ALL ON TABLE "public"."fcm_tokens" TO "authenticated";
GRANT ALL ON TABLE "public"."fcm_tokens" TO "service_role";

GRANT ALL ON TABLE "public"."message_status" TO "anon";
GRANT ALL ON TABLE "public"."message_status" TO "authenticated";
GRANT ALL ON TABLE "public"."message_status" TO "service_role";

GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";

GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";

-- ============================================================
-- DONE
-- Remember to:
-- 1. Replace YOUR_PROJECT_URL in the notification trigger above
-- 2. Replace YOUR_SERVICE_ROLE_KEY in the notification trigger above
-- 3. Deploy the edge function: supabase functions deploy send-chat-notification
-- ============================================================
