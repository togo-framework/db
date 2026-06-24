# togo-postgres — batteries-included Postgres for togo, Supabase-stack compatible.
#
# Base:  pgduckdb/pgduckdb:17-v1.1.1  (Debian 12 bookworm, PostgreSQL 17)
#        — ships pg_duckdb v1.1.1 + libduckdb v1.4.3.
# Adds:  pgvector, pg_search (ParadeDB BM25), pg_cron, pg_partman via apt/deb.
# Compat: Supabase roles (supabase_admin, authenticator, anon, authenticated,
#         service_role, supabase_auth_admin, supabase_storage_admin) are created
#         by initdb/02-supabase-roles.sql so GoTrue, Storage, and Realtime can
#         connect without a supabase/postgres base image.
#
# Published as: ghcr.io/togo-framework/db
FROM pgduckdb/pgduckdb:17-v1.1.1

USER root

ARG TARGETARCH
ARG PG_SEARCH_VERSION=0.24.1
ARG PG_MAJOR=17

# Add PostgreSQL apt repo (PGDG) — already present in the base image but
# we need apt updated to resolve pg_cron / pgvector / pg_partman.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        "postgresql-${PG_MAJOR}-pgvector" \
        "postgresql-${PG_MAJOR}-cron" \
        "postgresql-${PG_MAJOR}-partman" \
        curl \
        ca-certificates; \
    rm -rf /var/lib/apt/lists/*

# pg_search — ParadeDB BM25 full-text search (requires shared_preload_libraries).
# ParadeDB publishes arch-specific debs; we map Docker's TARGETARCH to their naming.
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
        amd64) DEB_ARCH=amd64 ;; \
        arm64) DEB_ARCH=arm64 ;; \
        *) echo "Unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    DEB_URL="https://github.com/paradedb/paradedb/releases/download/v${PG_SEARCH_VERSION}/postgresql-${PG_MAJOR}-pg-search_${PG_SEARCH_VERSION}-1PARADEDB-bookworm_${DEB_ARCH}.deb"; \
    curl -fsSL -o /tmp/pg_search.deb "${DEB_URL}"; \
    dpkg -i /tmp/pg_search.deb; \
    rm -f /tmp/pg_search.deb

# Extension bootstrap — runs on first `initdb`.
COPY initdb/ /docker-entrypoint-initdb.d/

USER postgres

LABEL org.opencontainers.image.source="https://github.com/togo-framework/db" \
      org.opencontainers.image.description="togo-postgres — pg_duckdb, pg_search (BM25), pgvector, pg_cron, pg_partman + Supabase-role compat" \
      org.opencontainers.image.licenses="MIT"
