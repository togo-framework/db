-- Enable the togo-postgres extension set on first init.
-- Each is guarded so a missing optional extension doesn't abort startup.
-- NOTE: pg_duckdb and pg_search require shared_preload_libraries — see compose.
DO $$
DECLARE ext text;
BEGIN
  FOREACH ext IN ARRAY ARRAY['vector','pg_search','pg_duckdb','pg_cron','pg_partman'] LOOP
    BEGIN
      EXECUTE format('CREATE EXTENSION IF NOT EXISTS %I', ext);
      RAISE NOTICE 'togo-postgres: enabled %', ext;
    EXCEPTION WHEN OTHERS THEN
      RAISE WARNING 'togo-postgres: skipped % (%).', ext, SQLERRM;
    END;
  END LOOP;
END $$;
