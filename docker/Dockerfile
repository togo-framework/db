# togo-postgres — the batteries-included Postgres for togo.
#
# Base: ParadeDB (ships pg_search / BM25 full-text, pgvector for RAG, and
# pg_analytics / DuckDB). On top we add pg_cron (scheduled jobs) and pg_partman
# (partition management). GoTrue (auth) and Storage run as separate services in
# the compose — this image is the database.
#
# Published as a public package: ghcr.io/togo-framework/db
FROM paradedb/paradedb:latest

USER root

# pg_cron + pg_partman from the PostgreSQL APT repo, matched to the base's PG major.
RUN set -eux; \
    apt-get update; \
    PG_MAJOR="$(ls /usr/lib/postgresql | head -1)"; \
    apt-get install -y --no-install-recommends \
        "postgresql-${PG_MAJOR}-cron" \
        "postgresql-${PG_MAJOR}-partman" \
        ca-certificates; \
    rm -rf /var/lib/apt/lists/*

# Extension bootstrap (runs on first init). pg_cron must also be preloaded via
# shared_preload_libraries — set that in the compose `command:` or your own conf.
COPY initdb/ /docker-entrypoint-initdb.d/

USER postgres

LABEL org.opencontainers.image.source="https://github.com/togo-framework/db" \
      org.opencontainers.image.description="togo-postgres — ParadeDB (pg_search, pgvector, pg_analytics) + pg_cron + pg_partman" \
      org.opencontainers.image.licenses="MIT"
