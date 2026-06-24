<p align="center"><img src=".github/assets/togo-mark.svg" width="96" alt="togo"></p>
<h1 align="center">togo-framework/db</h1>
<p align="center">The <strong>togo-postgres</strong> database stack — Postgres with batteries included.</p>
<p align="center"><sub>part of the <a href="https://github.com/togo-framework">togo-framework</a></sub></p>

---

`togo new --db togo-postgres` provisions this stack. It is **ParadeDB** (pg_search /
BM25 full-text, **pgvector** for RAG, **pg_analytics** / DuckDB) plus **pg_cron**
(scheduled jobs) and **pg_partman** (partitioning) — published as a public image:

```
ghcr.io/togo-framework/db:latest
```

NATS JetStream provides the message queue; GoTrue (auth) and Storage are optional
Supabase services in the compose.

## Use it

```bash
docker compose up -d            # togo-postgres + NATS
# DATABASE_URL=postgres://postgres:postgres@localhost:5432/togo
```

Or just the image:

```bash
docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=postgres \
  ghcr.io/togo-framework/db:latest \
  postgres -c shared_preload_libraries=pg_cron
```

Extensions are enabled on first init (`docker/initdb/01-extensions.sql`): `vector`,
`pg_search`, `pg_analytics`, `pg_cron`, `pg_partman`.

---

## 💎 Premium sponsors

togo is proudly sponsored by **ID8 Media** and **One Studio**.

<p align="center">
  <a href="https://id8media.com"><img src=".github/assets/id8media.svg" height="44" alt="ID8 Media" /></a>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <a href="https://one-studio.co"><img src=".github/assets/one-studio.jpeg" height="44" alt="One Studio" /></a>
</p>
