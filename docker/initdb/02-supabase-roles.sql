-- Supabase service roles — required by GoTrue, Storage, and Realtime.
-- This replicates the role setup from supabase/postgres so those services
-- can connect without needing the supabase/postgres base image.

-- supabase_admin: owns the supabase_* schemas, superuser for migrations.
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'supabase_admin') THEN
    CREATE ROLE supabase_admin LOGIN SUPERUSER CREATEROLE CREATEDB REPLICATION BYPASSRLS;
  END IF;
END $$;

-- authenticator: the role Supabase API (PostgREST) connects as; it switches to
-- anon / authenticated / service_role via SET LOCAL ROLE.
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'authenticator') THEN
    CREATE ROLE authenticator LOGIN NOINHERIT NOCREATEROLE NOCREATEDB NOSUPERUSER;
  END IF;
END $$;

-- anon: unauthenticated API requests.
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon NOLOGIN NOINHERIT;
  END IF;
END $$;

-- authenticated: logged-in users.
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'authenticated') THEN
    CREATE ROLE authenticated NOLOGIN NOINHERIT;
  END IF;
END $$;

-- service_role: bypasses RLS; used by server-side operations.
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'service_role') THEN
    CREATE ROLE service_role NOLOGIN NOINHERIT BYPASSRLS;
  END IF;
END $$;

-- supabase_auth_admin: GoTrue migration user; owns auth schema.
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'supabase_auth_admin') THEN
    CREATE ROLE supabase_auth_admin LOGIN NOINHERIT CREATEROLE NOCREATEDB NOSUPERUSER;
  END IF;
END $$;

-- supabase_storage_admin: Storage service user; owns storage schema.
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'supabase_storage_admin') THEN
    CREATE ROLE supabase_storage_admin LOGIN NOINHERIT CREATEROLE NOCREATEDB NOSUPERUSER;
  END IF;
END $$;

-- Grant authenticator the ability to switch to the functional roles.
GRANT anon        TO authenticator;
GRANT authenticated TO authenticator;
GRANT service_role  TO authenticator;

-- Grant supabase_admin authority to manage all supabase service roles.
GRANT supabase_auth_admin    TO supabase_admin;
GRANT supabase_storage_admin TO supabase_admin;
GRANT anon        TO supabase_admin;
GRANT authenticated TO supabase_admin;
GRANT service_role  TO supabase_admin;

-- auth schema: GoTrue creates its own tables here; we just ensure the schema exists
-- and ownership is correct.
CREATE SCHEMA IF NOT EXISTS auth AUTHORIZATION supabase_auth_admin;
GRANT ALL PRIVILEGES ON SCHEMA auth TO supabase_auth_admin;

-- storage schema: Supabase Storage creates its own tables here.
CREATE SCHEMA IF NOT EXISTS storage AUTHORIZATION supabase_storage_admin;
GRANT ALL PRIVILEGES ON SCHEMA storage TO supabase_storage_admin;

-- Grant postgres (the superuser default) membership in these roles so it can
-- manage them during development.
GRANT anon, authenticated, service_role TO postgres;
