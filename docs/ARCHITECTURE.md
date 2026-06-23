# MarketMate System Architecture Documentation (C4 Model)

This document provides architecture diagrams using the C4 model to visualize the MarketMate platform at different levels of abstraction, including all services (Backend, Frontend, Chat Service).

---

## Table of Contents

1. [System Context (Level 1)](#system-context-level-1)
2. [Container Diagram (Level 2)](#container-diagram-level-2)
3. [Repository Structure](#repository-structure)
4. [Local Development Prerequisites](#local-development-prerequisites)
5. [Local HTTPS Architecture](#local-https-architecture)
6. [Local Development (Docker Compose)](#local-development-docker-compose)
7. [Service Matrix](#service-matrix)
8. [Docker Networking](#docker-networking)
9. [Inter-Service Communication](#inter-service-communication)
10. [Chat Service Authentication Flow](#chat-service-authentication-flow)
11. [Chat Database Initialization](#chat-database-initialization)
12. [Service-Specific Architecture](#service-specific-architecture)
13. [Technology Stack](#technology-stack)
14. [Data Flow Examples](#data-flow-examples)
15. [Security Architecture](#security-architecture)
16. [Performance Optimizations](#performance-optimizations)

> **Note**: For detailed component and code-level architecture of each service, see the architecture documentation in each service repository:
> - **SpringMate Backend**: `SpringMate/SpringMate/docs/ARCHITECTURE.md`
> - **Frontend Applications**: `MM/docs/ARCHITECTURE.md`
> - **Chat Service**: `mm-chat-service/docs/ARCHITECTURE.md` (to be created)

---

## System Context (Level 1)

### Overview
The System Context diagram shows the MarketMate platform in relation to its users and external systems.

```
┌─────────────────────────────────────────────────────────────────┐
│                      MarketMate Platform                        │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │   Public     │  │    Admin     │  │   Chat       │           │
│  │   Frontend   │  │    Portal    │  │   Service    │           │
│  │  (Angular)   │  │  (Angular)   │  │  (NestJS)    │           │ 
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│         │                 │                 │                   │
│         └─────────────────┼─────────────────┘                   │
│                           │                                     │
│                  ┌─────────▼──────────┐                         │
│                  │  SpringMate        │                         │
│                  │  Backend API       │                         │
│                  │  (Spring Boot)     │                         │
│                  └─────────┬──────────┘                         │
└─────────────────────────── ┼ ───────────────────────────────────┘
                             │
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Public     │    │    Admin     │    │   External   │
│   Users      │    │    Users     │    │   Services   │
│              │    │              │    │              │
│ - Browse     │    │ - Manage     │    │ - AWS S3     │
│   Listings   │    │   Listings   │    │ - AWS SES    │
│ - Create     │    │ - Manage     │    │              │
│   Listings   │    │   Users      │    │ - Location   │
│ - Chat       │    │ - View       │    │   API        │
│   with       │    │   Reports    │    │              │
│   Sellers    │    │              │    │              │
└──────────────┘    └──────────────┘    └──────────────┘
```

### Actors
- **Public Users**: End users browsing, creating listings, and chatting with sellers
- **Admin Users**: Administrators managing the platform
- **External Services**: AWS S3, AWS SES, Location API

### External Systems
- **AWS S3**: File storage for listing images and user profiles
- **AWS SES (SDK v2)**: Transactional email delivery for OTP and user notifications
- **Location API**: Provides country/state/city data for seeding

---

## Container Diagram (Level 2)

### Overview
The Container diagram shows the high-level technical building blocks of the MarketMate platform.

```
┌─────────────────────────────────────────────────────────────────┐
│                      MarketMate Platform                        │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              Frontend Applications                       │   │
│  │  ┌──────────────┐              ┌──────────────┐          │   │
│  │  │   Public     │              │    Admin     │          │   │
│  │  │   Frontend   │              │    Portal    │          │   │
│  │  │  (Angular)   │              │  (Angular)   │          │   │
│  │  └──────────────┘              └──────────────┘          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              Backend Services                            │   │
│  │  ┌──────────────┐              ┌──────────────┐          │   │
│  │  │  SpringMate  │              │   Chat       │          │   │
│  │  │  Backend API │              │   Service    │          │   │
│  │  │ (Spring Boot)│              │  (NestJS)    │          │   │
│  │  └──────────────┘              └──────────────┘          │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
        │                    │                    │
        ▼                    ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  PostgreSQL  │    │    Redis     │    │    AWS S3    │
│  Database    │    │    Cache     │    │   Storage    │
│              │    │              │    │              │
│ - marketmate │    │ - Session    │    │ - Images     │
│   (Backend)  │    │   Cache      │    │ - Profiles   │
│ - mm_chat    │    │ - Query      │    │              │
│   (Chat)     │    │   Cache      │    │              │
│              │    │ - Chat       │    │              │
│              │    │   Sessions   │    │              │
└──────────────┘    └──────────────┘    └──────────────┘
        │                    │
        ▼                    ▼
┌──────────────┐    ┌──────────────┐
│  Prometheus  │    │   Grafana    │
│  Monitoring  │    │  Dashboards  │
│              │    │              │
│ - Metrics    │    │ - Visualize  │
│   Collection │    │   Metrics    │
│              │    │              │
└──────────────┘    └──────────────┘
```

### Containers

#### Frontend Applications
1. **Public Frontend (Angular)**: Customer-facing marketplace UI
2. **Admin Portal (Angular)**: Internal admin application

#### Backend Services
3. **SpringMate Backend (Spring Boot)**: RESTful API for authentication, listings, users
4. **Chat Service (NestJS)**: Real-time messaging service using WebSockets

#### Infrastructure
5. **PostgreSQL**: Primary database for persistent data
   - `marketmate` database: Spring Boot backend data (users, listings, categories, locations)
   - `mm_chat` database: Chat service data (conversations, messages)
6. **Redis**: Auth-session cache, query cache, and chat session validation cache (PostgreSQL is the session source of truth)
7. **AWS S3**: File storage for images
8. **Prometheus**: Metrics collection and monitoring
9. **Grafana**: Metrics visualization and dashboards

---

## Repository Structure

Local development requires all application repositories as **siblings** of `mm-infra`. Docker Compose resolves build contexts and volume mounts using relative paths such as `../MM` and `../SpringMate/SpringMate`.

```
MarketMate/                         # parent directory (name is arbitrary)
├── MM/                             # Angular Nx workspace (public + admin apps)
│   └── certs/                      # mkcert PEM files for frontends
├── SpringMate/
│   └── SpringMate/                 # Spring Boot project root (Compose build context)
│       └── src/main/resources/     # marketmate-local.p12 keystore (local only, not committed)
├── mm-chat-service/                # NestJS chat service
│   └── certs/                      # mkcert PEM files for chat HTTPS
└── mm-infra/                       # run all Compose commands from here
    ├── docker-compose.yml
    ├── postgres/
    ├── redis/
    ├── prometheus/
    └── grafana/
```

### Why this layout is required

`docker-compose.yml` lives inside `mm-infra/` and references sibling directories:

| Compose reference | Resolves to |
|-------------------|-------------|
| `../MM` | Frontend build context and bind mount |
| `../MM/certs` | Frontend TLS certificate mount (`/certs` in container) |
| `../SpringMate/SpringMate` | Backend build context and bind mount |
| `../mm-chat-service` | Chat service build context and bind mount |
| `../mm-chat-service/certs` | Chat TLS certificate mount (`/certs` in container) |

If repositories are not laid out this way, `docker compose up` will fail at build or startup because contexts and volume paths will not resolve.

---

## Local Development Prerequisites

Complete these steps **before** running `docker compose up` from `mm-infra/`.

### Required repository layout

Clone or place all four repositories under a shared parent directory as shown in [Repository Structure](#repository-structure). Each service also needs its environment file:

| Service | Environment file |
|---------|------------------|
| Backend | `SpringMate/SpringMate/src/main/java/com/example/SpringMate/env/.env` |
| Chat service | `mm-chat-service/src/env/.env` |
| Frontends | Variables set inline in `docker-compose.yml` |

Copy from `.env.example` files where available and fill in required secrets before first run.

### Required hosts file entries

Map local domains to `127.0.0.1`. Browsers must reach apps via these hostnames (not `localhost`) so shared cookies work across the public app, admin portal, and API.

**Windows** — edit as Administrator: `C:\Windows\System32\drivers\etc\hosts`

**Linux / macOS** — edit: `/etc/hosts`

```
127.0.0.1 marketmate.local
127.0.0.1 admin.marketmate.local
127.0.0.1 api.marketmate.local
```

### Certificate generation process

Local HTTPS uses [mkcert](https://github.com/FiloSottile/mkcert) to create a trusted local certificate authority and domain certificates.

1. **Install mkcert** on the host machine and add it to your `PATH`.
2. **Install the local CA** (once per machine):
   ```bash
   mkcert -install
   ```
3. **Generate wildcard certificates** with explicit filenames (required by Dockerfiles and NestJS bootstrap):
   ```bash
   mkcert -cert-file wildcard.marketmate.local.pem \
          -key-file wildcard.marketmate.local-key.pem \
          marketmate.local "*.marketmate.local" admin.marketmate.local api.marketmate.local
   ```
4. **Place PEM files** in both certificate directories:
   - `MM/certs/wildcard.marketmate.local.pem`
   - `MM/certs/wildcard.marketmate.local-key.pem`
   - `mm-chat-service/certs/wildcard.marketmate.local.pem`
   - `mm-chat-service/certs/wildcard.marketmate.local-key.pem`
5. **Generate the backend PKCS12 keystore** (Spring Boot does not use PEM files directly):
   ```bash
   openssl pkcs12 -export \
     -in wildcard.marketmate.local.pem \
     -inkey wildcard.marketmate.local-key.pem \
     -out marketmate-local.p12 \
     -name marketmate \
     -password pass:changeit
   ```
   Copy the keystore to:
   ```
   SpringMate/SpringMate/src/main/resources/marketmate-local.p12
   ```

Certificate and keystore files contain private keys and are git-ignored. Each developer generates their own copies locally.

### Trusting certificates locally

Running `mkcert -install` registers mkcert's local CA with the system trust store. After that:

- Browsers trust `https://marketmate.local`, `https://admin.marketmate.local`, and `https://api.marketmate.local` without warnings.
- Restart the browser after `mkcert -install` if certificates still appear untrusted.
- Always open apps via the `.local` hostnames — using `localhost` will break cookie sharing and CORS.

### Service URLs

Use these URLs from the host machine after `docker compose up`:

| Service | URL | Notes |
|---------|-----|-------|
| Public frontend | `https://marketmate.local:4200` | Primary entry point; do not use `localhost:4200` for auth |
| Admin portal | `https://admin.marketmate.local:4300` | Shares SSO cookie with public app |
| SpringMate API | `https://api.marketmate.local:8080` | Frontends call `https://api.marketmate.local:8080/api/` |
| Chat service | `https://localhost:4400` | Host port maps to container port 3000 |
| PostgreSQL | `localhost:5432` | User `postgres`, password `password` |
| Redis | `localhost:6379` | No password in local config |
| Prometheus | `http://localhost:9090` | HTTP only in local stack |
| Grafana | `http://localhost:3005` | Default login `admin` / `admin` |

---

## Local HTTPS Architecture

Local development mirrors production cookie and TLS behavior using fake domains, HTTPS, and a shared cookie domain. This is required because browsers reject cross-site `SameSite=None` cookies without HTTPS and a common parent domain.

### Domain map

| Domain | Service | Host port |
|--------|---------|-----------|
| `marketmate.local` | Public Angular app (`marketmate`) | 4200 |
| `admin.marketmate.local` | Admin Angular app (`mm-admin-portal`) | 4300 |
| `api.marketmate.local` | SpringMate backend | 8080 |

### Certificate locations

| Component | Certificate type | Path on host | Path in container |
|-----------|------------------|--------------|-------------------|
| Public frontend | mkcert PEM | `MM/certs/wildcard.marketmate.local.pem` (+ key) | `/certs/` (read-only mount) |
| Admin portal | mkcert PEM | `MM/certs/` (shared with public app) | `/certs/` (read-only mount) |
| Chat service | mkcert PEM | `mm-chat-service/certs/wildcard.marketmate.local.pem` (+ key) | `/certs/` (read-only mount) |
| SpringMate backend | PKCS12 keystore | `SpringMate/SpringMate/src/main/resources/marketmate-local.p12` | `/app/src/main/resources/` (bind mount) |

### Frontend SSL setup

Both frontend containers use `MM/DOCKERFILE.local`, which starts the Nx dev server with SSL enabled:

```dockerfile
npx nx serve $APP_NAME \
  --host 0.0.0.0 \
  --port $PORT \
  --ssl true \
  --ssl-cert /certs/wildcard.marketmate.local.pem \
  --ssl-key /certs/wildcard.marketmate.local-key.pem
```

Compose mounts `../MM/certs:/certs:ro` into both `frontend` and `admin` services. The admin container listens on port `4201` internally and is published as host port `4300`.

### Backend PKCS12 keystore setup

The `local` Spring profile enables TLS in `application-local.yml`:

```yaml
server:
  ssl:
    enabled: true
    key-store: classpath:marketmate-local.p12
    key-store-password: ${SSL_KEYSTORE_PASSWORD:changeit}
    key-store-type: PKCS12
    key-alias: marketmate
```

Docker Compose sets `SPRING_PROFILES_ACTIVE=local` and bind-mounts the entire `SpringMate/SpringMate` project, so the keystore in `src/main/resources/` is available at runtime without Dockerfile changes. Override the keystore password via `SSL_KEYSTORE_PASSWORD` in the backend `.env` file if needed.

### Chat service certificate usage

`mm-chat-service/src/main.ts` creates the NestJS app with HTTPS using the same wildcard PEM files:

```typescript
const httpsOptions = {
  key: fs.readFileSync('/certs/wildcard.marketmate.local-key.pem'),
  cert: fs.readFileSync('/certs/wildcard.marketmate.local.pem'),
};
```

Compose sets `PORT=3000` inside the container (published as host port `4400`). CORS allows `https://marketmate.local:4200` and `https://admin.marketmate.local:4300`.

When calling the SpringMate backend over HTTPS from inside Docker, the chat service sets `NODE_TLS_REJECT_UNAUTHORIZED=0` in its `.env` file to accept the backend's self-signed/mkcert certificate on the internal Docker network (`https://backend:8080`). This is local-development only.

### Cookie domain behavior

SpringMate's `local` profile sets the auth cookie domain to `.marketmate.local` with `secure: true`:

```yaml
app:
  cookie:
    domain: .marketmate.local
    secure: true
```

The leading dot makes the `auth_token` httpOnly cookie available to all subdomains (`marketmate.local`, `admin.marketmate.local`, `api.marketmate.local`). Frontends must call the API at `https://api.marketmate.local:8080/api/` with `withCredentials: true` so the cookie is sent on cross-origin requests.

**Verification:** Log in at `https://marketmate.local:4200`, open DevTools → Application → Cookies, and confirm `auth_token` has domain `.marketmate.local`, `Secure` enabled, and `SameSite=None`. Navigating to the admin portal should reuse the same session.

---

## Local Development (Docker Compose)

The `mm-infra/docker-compose.yml` stack runs the platform locally with separate containers for each service. Run all commands from the `mm-infra/` directory:

```bash
cd mm-infra
docker compose up -d
```

See [Service Matrix](#service-matrix) for the full service reference and [Docker Networking](#docker-networking) for how containers reach each other.

### Infrastructure notes

- **PostgreSQL 15** initializes `marketmate` and `mm_chat` databases via `postgres/init-databases.sh` on first container start.
- **Redis 7** uses the custom config at `redis/redis.conf` (AOF persistence, 256 MB memory cap).
- **Prometheus** scrapes `https://backend:8080/actuator/prometheus` over HTTPS with basic auth (see `prometheus/prometheus.yml`).
- **Grafana** is pre-provisioned with a Prometheus datasource and the SpringMate overview dashboard.
- **`depends_on`** orders startup only (`backend` → `postgres`/`redis`; `prometheus` → `backend`; `grafana` → `prometheus`). It does not wait for readiness.

---

## Service Matrix

All eight services defined in `docker-compose.yml`. Host URLs are accessed from the developer machine or browser. Internal Docker URLs are used for container-to-container traffic on the Compose network.

| Service | Container Name | Host URL | Internal Docker URL | Purpose |
|---------|----------------|----------|---------------------|---------|
| `frontend` | `mm-frontend` | `https://marketmate.local:4200` | — | Public Angular marketplace UI (Nx app `marketmate`); browser-only, not called by other containers |
| `admin` | `mm-admin` | `https://admin.marketmate.local:4300` | — | Admin Angular portal (Nx app `mm-admin-portal`); browser-only, not called by other containers |
| `backend` | `local-backend` | `https://api.marketmate.local:8080` | `https://backend:8080` | Spring Boot REST API (SpringMate); `SPRING_PROFILES_ACTIVE=local` |
| `chat-engine` | `chat-engine` | `https://localhost:4400` | `https://chat-engine:3000` | NestJS chat service (WebSocket/HTTP); container listens on port `3000`, published as host port `4400` |
| `postgres` | `local-postgres` | `localhost:5432` | `postgres:5432` | PostgreSQL 15; databases `marketmate` (backend) and `mm_chat` (chat) |
| `redis` | `local-redis` | `localhost:6379` | `redis:6379` | Redis 7 cache; auth-session cache, query cache, chat session validation |
| `prometheus` | `local-prometheus` | `http://localhost:9090` | `http://prometheus:9090` | Metrics collection; scrapes SpringMate `/actuator/prometheus` |
| `grafana` | `local-grafana` | `http://localhost:3005` | `http://grafana:3000` | Metrics dashboards; queries Prometheus via internal URL |

**Port mapping notes:**

- `admin` maps host `4300` → container `4201` (Nx dev server port set by `PORT=4201`).
- `chat-engine` maps host `4400` → container `3000` (NestJS `PORT=3000` in Compose).
- `grafana` maps host `3005` → container `3000` (Grafana default listen port).

---

## Docker Networking

### Default Docker network behavior

`docker-compose.yml` does not declare a custom `networks:` block. Compose creates a default bridge network for the project (typically named `<project>_default`, e.g. `mm-infra_default` when run from `mm-infra/`). All eight services join this single network and can reach each other by service name.

Published `ports:` entries additionally expose container ports on the host (`127.0.0.1` by default), which is how the browser and host-side tools (psql, redis-cli) connect.

### Service discovery by service name

Docker Compose registers an embedded DNS server on the project network. Each **Compose service name** resolves to the container's IP address. Application configuration uses these names:

| Service name | Used by | Evidence |
|--------------|---------|----------|
| `postgres` | Backend, chat-engine | `DB_URL=jdbc:postgresql://postgres:5432/marketmate`, `DB_HOST=postgres` |
| `redis` | Backend, chat-engine | `application-local.yml` (`host: redis`), `REDIS_HOST=redis` |
| `backend` | chat-engine, prometheus | `AUTH_RESOLVE_URL=https://backend:8080/...`, `prometheus.yml` target `backend:8080` |
| `prometheus` | grafana | `grafana/provisioning/datasources/prometheus.yml` → `http://prometheus:9090` |

### Service name vs container name

| Concept | Defined in | Used for |
|---------|-----------|----------|
| **Service name** (e.g. `backend`) | `services:` key in `docker-compose.yml` | Inter-container DNS, `depends_on` references, Prometheus scrape targets |
| **Container name** (e.g. `local-backend`) | `container_name:` field | `docker exec`, `docker logs`, `docker ps` output |

These are often different. For example, the SpringMate API service is named `backend` in Compose but its container is named `local-backend`. Application code and infrastructure config always use the **service name** (`backend`), not the container name.

The one exception where both match is `chat-engine` (service name and `container_name` are identical).

`container_name` is **not** what application code should use for service discovery — always use the Compose service name.

### Internal URLs used between services

| Internal URL | Protocol | Consumer | Provider |
|--------------|----------|----------|----------|
| `postgres:5432` | TCP (PostgreSQL) | `backend`, `chat-engine` | `postgres` |
| `redis:6379` | TCP (Redis) | `backend`, `chat-engine` | `redis` |
| `backend:8080` | HTTPS | `chat-engine`, `prometheus` | `backend` |
| `prometheus:9090` | HTTP | `grafana` | `prometheus` |

Frontends (`frontend`, `admin`) are not addressed by other containers. The browser reaches them via host-mapped ports and `.local` domains, and they reach the backend via `https://api.marketmate.local:8080` (host port mapping), not `https://backend:8080`.

---

## Inter-Service Communication

### Frontend → Backend

Frontends run in the **browser**, not inside Docker. API calls go from the browser to the host-mapped backend port using the fake domain configured in Angular environments:

```
Browser → https://api.marketmate.local:8080/api/ → host :8080 → backend container :8080
```

| Detail | Value | Evidence |
|--------|-------|----------|
| API base URL | `https://api.marketmate.local:8080/api/` | `MM/apps/marketmate/src/environments/environment.ts` |
| Credentials | `withCredentials: true` (httpOnly `auth_token` cookie) | Shared Angular auth services |
| CORS allowed origins | `https://marketmate.local:4200`, `https://admin.marketmate.local:4300` | `SpringMate/.../application-local.yml` |

The frontend containers themselves do not call `backend:8080`. Only the user's browser does, via the hosts file and published port `8080:8080`.

### Chat → SpringMate

The chat service validates sessions by calling SpringMate's internal auth endpoint over the Docker network:

```
chat-engine → https://backend:8080/internal/v1/auth/resolve_session
```

| Detail | Value | Evidence |
|--------|-------|----------|
| Resolve URL | `https://backend:8080/internal/v1/auth/resolve_session` | `mm-chat-service/src/env/.env` |
| Auth header | `X-SERVICE-KEY` (internal service key) | `mm-chat-service/src/auth/services/auth.service.ts` |
| TLS verification | Disabled (`NODE_TLS_REJECT_UNAUTHORIZED=0`) | `mm-chat-service/src/env/.env` |
| Fast path | Redis `auth:session:{sessionId}` before Spring fallback | `auth.service.ts`, `mm-chat-service/src/env/.env` (`REDIS_HOST`), `redis.provider.ts` |

See [Chat Service Authentication Flow](#chat-service-authentication-flow) for the full WebSocket auth sequence.

### Chat → PostgreSQL and Redis

| Target | Connection | Database / usage | Evidence |
|--------|------------|------------------|----------|
| `postgres:5432` | `DB_HOST=postgres`, `DB_NAME=mm_chat` | Chat messages, conversations (TypeORM) | `mm-chat-service/src/env/.env`, `database.config.ts` |
| `redis:6379` | `REDIS_HOST=redis` | Session validation cache (`auth:session:*` keys) | `mm-chat-service/src/env/.env`, `redis.provider.ts` |

Schema is managed by TypeORM migrations (`synchronize: false`). See [Chat Database Initialization](#chat-database-initialization).

### Backend → PostgreSQL

```
backend → jdbc:postgresql://postgres:5432/marketmate
```

| Detail | Value | Evidence |
|--------|-------|----------|
| JDBC URL | `jdbc:postgresql://postgres:5432/marketmate` | `SpringMate/.../env/.env` (`DB_URL`) |
| Credentials | `postgres` / `password` | `docker-compose.yml`, backend `.env` |
| Schema management | `ddl-auto: update` (local profile) | `application-local.yml` |

### Backend → Redis

```
backend → redis:6379 (database 0)
```

| Detail | Value | Evidence |
|--------|-------|----------|
| Host | `redis` | `application-local.yml` (`spring.data.redis.host`) |
| Port | `6379` | `application-local.yml` |
| Usage | Auth session cache (`auth:session:*`), category/location/query caches | `AuthCacheService.java` (auth sessions); `CategoryService.java`, `LocationService.java` (@Cacheable) |
| Startup dependency | `depends_on: redis` | `docker-compose.yml` |

### Prometheus → Backend

Prometheus scrapes SpringMate metrics over HTTPS on the internal Docker network:

```
prometheus → https://backend:8080/actuator/prometheus
```

| Detail | Value | Evidence |
|--------|-------|----------|
| Scrape target | `backend:8080` | `prometheus/prometheus.yml` |
| Path | `/actuator/prometheus` | `prometheus/prometheus.yml` |
| Scheme | HTTPS (`tls_config.insecure_skip_verify: true`) | `prometheus/prometheus.yml` |
| Authentication | Basic auth (`prometheus@system.infra`; password hardcoded in scrape config) | `prometheus/prometheus.yml` (hardcoded `basic_auth`), `SpringMate/.../UserSeeder.java` (`PROMETHEUS_PASS` seeds user) |
| Startup dependency | `depends_on: backend` | `docker-compose.yml` |

### Grafana → Prometheus

Grafana queries Prometheus server-side from its own container (not via the host):

```
grafana → http://prometheus:9090
```

| Detail | Value | Evidence |
|--------|-------|----------|
| Datasource URL | `http://prometheus:9090` | `grafana/provisioning/datasources/prometheus.yml` |
| Access mode | `proxy` (Grafana backend proxies queries) | `grafana/provisioning/datasources/prometheus.yml` |
| Startup dependency | `depends_on: prometheus` | `docker-compose.yml` |

---

## Chat Service Authentication Flow

The chat service (`chat-engine`) authenticates WebSocket connections using the same `auth_token` JWT that SpringMate issues as an httpOnly cookie. It does **not** read tokens from URL query parameters.

### Overview

```
Browser (logged in via SpringMate)
  → Socket.IO handshake to https://localhost:4400
  → Cookie: auth_token=<JWT> sent in handshake headers
  → ChatGateway middleware / WsJwtGuard
  → verifyJwt(JWT_SECRET) → sessionId
  → resolveUserUuid(sessionId)
       ├─ Redis GET auth:session:{sessionId}  (fast path)
       └─ POST https://backend:8080/internal/v1/auth/resolve_session  (fallback)
            Header: X-SERVICE-KEY
  → socket.data.userUuid attached → join rooms → send/receive messages
```

### JWT handling

| Detail | Implementation | Evidence |
|--------|----------------|----------|
| Token source | `auth_token` httpOnly cookie from WebSocket handshake | `chat.gateway.ts`, `ws-jwt.auth.guard.ts` |
| Token extraction | `getCookieValue(cookieHeader, 'auth_token')` | `cookie.util.ts` |
| Verification | `@nestjs/jwt` `JwtService.verify(token)` | `auth.module.ts`, `auth.service.ts` |
| Shared secret | `JWT_SECRET` env var (must match SpringMate) | `mm-chat-service/src/env/.env`, `SpringMate/.../env/.env` |
| Payload fields | `sub` (SpringMate); `sessionId` claim fallback in chat | `auth.service.ts` `verifyJwt()`, `JwtTokenProvider.java` |

SpringMate embeds the session ID in the JWT when the user logs in. The chat service never issues its own tokens — it only verifies tokens created by SpringMate.

### Cookie vs Authorization header

WebSocket authentication reads the JWT from the **`Cookie` header**, not the `Authorization` header:

```typescript
const cookieHeader = client.handshake.headers.cookie;
const token = getCookieValue(cookieHeader, 'auth_token');
```

This requires the browser to connect with `credentials: true` so the `.marketmate.local` cookie is included in the Socket.IO handshake. The `Authorization: Bearer` pattern is **not used** in the current WebSocket implementation.

Authentication runs in two places for defense in depth:

1. **Socket.IO middleware** (`ChatGateway.afterInit`) — validates on initial handshake before the connection is accepted.
2. **`WsJwtGuard`** — re-validates on guarded WebSocket message handlers; skips re-auth if `socket.data.sessionId` and `socket.data.userUuid` are already set by middleware.

On failure, the socket is disconnected and an `auth_error` event is emitted.

### Session validation

After JWT verification extracts `sessionId`, `AuthService.resolveUserUuid()` maps the session to a `userUuid`:

```
sessionId → userUuid (required for room joins and message authorization)
```

The resolved `userUuid` is stored on `socket.data` and used by `ChatGateway` to join personal rooms (`user:{userUuid}`) and authorize conversation access.

### Redis cache lookup (fast path)

Both SpringMate and the chat service share the same Redis instance and key namespace:

| Detail | Value | Evidence |
|--------|-------|----------|
| Key pattern | `auth:session:{sessionId}` | `AuthCacheService.java`, `auth.service.ts` |
| Written by | SpringMate on login / session validation | `AuthCacheService.cacheAuthenticatedUser()` |
| Serializer | JSON via `GenericJackson2JsonRedisSerializer` | `RedisConfig.java` |
| Read by chat | `redis.exists(key)` then `redis.get(key)` → parse JSON for `userUuid` | `auth.service.ts` |

If the key exists and the cached JSON contains `userUuid`, the chat service resolves the user without calling SpringMate.

### SpringMate fallback

When Redis has no entry, an empty value, unparseable JSON, or missing `userUuid`, the chat service calls SpringMate's internal endpoint:

```
POST https://backend:8080/internal/v1/auth/resolve_session
Content-Type: application/json
X-SERVICE-KEY: <service-key>

{ "sessionId": "<sessionId>" }
```

| Detail | Value | Evidence |
|--------|-------|----------|
| URL config | `AUTH_RESOLVE_URL` (or `SPRING_BASE_URL` in code) | `mm-chat-service/src/env/.env` (`AUTH_RESOLVE_URL`), `auth.service.ts` (`SPRING_BASE_URL`) |
| SpringMate handler | `InternalAuthController.resolve()` | `InternalAuthController.java` |
| SpringMate validation | `SessionValidationService.validate(sessionId)` — checks PostgreSQL session table | `SessionValidationService.java` |
| Response | `{ "data": { "userUuid": "..." } }` | `auth.service.ts` |
| Timeout | 10 seconds (`AbortController`) | `auth.service.ts` |
| TLS | `NODE_TLS_REJECT_UNAUTHORIZED=0` for self-signed backend cert | `mm-chat-service/src/env/.env` |

### X-SERVICE-KEY usage

The internal endpoint is protected by a shared service key, not user credentials:

| Side | Configuration | Evidence |
|------|---------------|----------|
| Chat service (client) | `SPRING_INTERNAL_SERVICE_KEY` or `INTERNAL_SERVICE_KEY`; defaults to `6911aa62-3705-42ef-8484-db35b62cf9ba` if unset | `auth.service.ts` |
| SpringMate (server) | `app.internal.service.key` from `SERVICE_KEY` env; same default | `application.yml`, `InternalAuthController.java` |

SpringMate rejects requests with a mismatched key (`403 Forbidden`). Configure the same key in both services for local and production environments.

---

## Chat Database Initialization

The chat service uses a dedicated PostgreSQL database (`mm_chat`) with schema managed exclusively by TypeORM migrations. Unlike SpringMate (which uses `ddl-auto: update` locally), the chat service has **`synchronize: false`** and will not auto-create tables.

### mm_chat database creation

The empty `mm_chat` database is created automatically on first PostgreSQL container startup:

| Step | What happens | Evidence |
|------|--------------|----------|
| 1 | `POSTGRES_DB: marketmate` creates the default database | `docker-compose.yml` |
| 2 | `postgres/init-databases.sh` runs via `/docker-entrypoint-initdb.d/` | `docker-compose.yml`, `init-databases.sh` |
| 3 | Script creates `marketmate` and `mm_chat` if they do not exist | `init-databases.sh` |

The init script creates **databases only** — no tables, extensions, or seed data. If the `pgdata` volume already exists from a prior run, init scripts do not re-execute.

### TypeORM configuration

| Setting | Value | Evidence |
|---------|-------|----------|
| Database | `mm_chat` | `DB_NAME=mm_chat` in `.env` |
| Host (Docker) | `postgres:5432` | `DB_HOST=postgres` in `.env` |
| `synchronize` | `false` | `database.config.ts` |
| `autoLoadEntities` | `true` | `database.config.ts` |
| Migrations table | `typeorm_migrations` | `database.config.ts` |
| Entities | `conversations`, `messages` | `conversation.entity.ts`, `message.entity.ts` |

### Migration requirements

Migrations are defined in `mm-chat-service/src/migrations/` and run via the TypeORM CLI:

| Migration | Purpose |
|-----------|---------|
| `1766773317623-InitChatSchema` | Creates `conversations` and `messages` tables with indexes and foreign keys |
| `1766775567110-InitChatSchema` | Renames `messages.sender_uuid` → `messages.sender_id` |

```bash
# Run inside the chat container after first startup
docker exec chat-engine npm run migration:run
```

`docker-compose.yml` does **not** run migrations automatically. The chat service container starts without applying schema changes.

The first migration uses `uuid_generate_v4()`, which requires the `uuid-ossp` PostgreSQL extension. If migrations fail with `function uuid_generate_v4() does not exist`, enable the extension:

```bash
docker exec -it local-postgres psql -U postgres -d mm_chat -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
```

Then re-run migrations.

### First-time startup procedure

Complete these steps in order for a fresh local environment:

1. **Start infrastructure and services:**
   ```bash
   cd mm-infra
   docker compose up -d
   ```
2. **Wait for PostgreSQL** to finish initialization (first run creates `mm_chat`).
3. **Run chat migrations** (required before any chat operation):
   ```bash
   docker exec chat-engine npm run migration:run
   ```
4. **Log in via SpringMate** at `https://marketmate.local:4200` so the browser receives the `auth_token` cookie and SpringMate populates the Redis session cache.
5. **Connect to chat** via WebSocket at `https://localhost:4400` with credentials enabled.

### Failure scenarios when migrations are not executed

| Symptom | Cause |
|---------|-------|
| `relation "conversations" does not exist` on `join_conversation` | Tables not created; migrations not run |
| `relation "messages" does not exist` on `send_message` | Same — schema missing |
| Chat service starts without error but all DB operations fail | NestJS boots without running migrations; TypeORM connects to an empty database |
| `function uuid_generate_v4() does not exist` during migration | `uuid-ossp` extension not enabled in `mm_chat` |
| WebSocket auth succeeds but message save fails | Auth uses Redis/SpringMate (no DB); persistence requires migrated tables |

To recover: run `docker exec chat-engine npm run migration:run`. If the database is corrupted or partially migrated, reset with `docker compose down -v` and repeat the first-time procedure.

---

## Service-Specific Architecture

For detailed component and code-level architecture of each service, refer to the architecture documentation in each service repository:

- **SpringMate Backend**: See `SpringMate/SpringMate/docs/ARCHITECTURE.md` for:
  - Component Diagram (Level 3) - Controllers, Services, Repositories
  - Code Diagram (Level 4) - Detailed service implementations

- **Frontend Applications**: See `MM/docs/ARCHITECTURE.md` for:
  - Component Diagram (Level 3) - Angular modules, components, services
  - Code Diagram (Level 4) - Component structure and data flow
  - Shared Library (mm-shared) architecture

- **Chat Service**: See `mm-chat-service/docs/ARCHITECTURE.md` (to be created) for:
  - Component Diagram (Level 3) - WebSocket gateways, services, repositories
  - Code Diagram (Level 4) - Real-time messaging implementation

---

## Technology Stack

### Frontend
- **Public App**: Angular (Nx workspace)
- **Admin Portal**: Angular (Nx workspace)
- **Shared Library**: Angular components and services

### Backend
- **SpringMate API**: Spring Boot 3.x, Java 17+
- **Chat Service**: NestJS, Node.js 22, Socket.IO

### Infrastructure
- **Database**: PostgreSQL 15 (two databases: `marketmate`, `mm_chat`)
- **Cache**: Redis 7
- **Storage**: AWS S3
- **Email Delivery**: AWS SES (SDK v2)
- **Monitoring**: Prometheus (metrics collection) + Grafana (visualization)
- **Containerization**: Docker / Docker Compose

---

## Data Flow Examples

### 1. User Authentication Flow
```
User → Frontend → SpringMate Backend → UserRepository → PostgreSQL
                                    ↓
                              SessionRepository → PostgreSQL
                                    ↓
                              Redis (Session Cache)
```

### 2. Listing Creation Flow
```
User → Frontend → SpringMate Backend → ListingService → ListingRepository → PostgreSQL
                                    ↓
                              StorageService → AWS S3
                                    ↓
                              LocationService → LocationRepository → PostgreSQL
```

### 3. Real-time Chat Flow
```
User (browser, auth_token cookie from SpringMate login)
  → WebSocket handshake → Chat Service (https://localhost:4400)
  → verifyJwt(JWT_SECRET) → sessionId
  → Redis auth:session:{sessionId} → userUuid          [fast path]
  → OR POST backend/internal/v1/auth/resolve_session   [fallback, X-SERVICE-KEY]
  → join_conversation / send_message
  → PostgreSQL mm_chat (conversations, messages via TypeORM)
  → Socket.IO broadcast to conversation room + receiver personal room
```

### 4. Monitoring Data Flow
```
SpringMate Backend → Prometheus (Metrics Scraping)
                            ↓
                    Grafana (Visualization)
                            ↓
                    Dashboards (SpringMate Overview)
```

---

## Security Architecture

### Authentication
- **JWT Tokens**: Stored in httpOnly cookies (`auth_token`) issued by SpringMate
- **Session Management**: Sessions stored in PostgreSQL with Redis used as a session-validation cache
- **OTP Verification**: Email-based OTP for login
- **Chat Authentication**: WebSocket connections authenticate via the `auth_token` cookie in the Socket.IO handshake (not URL params or `Authorization` header). Session is resolved via Redis cache (`auth:session:{sessionId}`) with SpringMate internal API fallback (`X-SERVICE-KEY`)

### Authorization
- **Role-Based Access Control (RBAC)**: ADMIN, USER roles
- **Method-Level Security**: `@PreAuthorize` annotations
- **Resource-Level Security**: User can only modify own resources

### Request/Edge Protections (implemented)
- **Rate limiting**: request throttling filter applied before controllers
- **Request correlation**: request-id filter for tracing logs/requests across services
- **Cookie security**: `auth_token` issued as an httpOnly cookie (with domain/path/secure controlled by app config)

### Security Headers
- HSTS (HTTP Strict Transport Security)
- X-Frame-Options
- X-Content-Type-Options
- X-XSS-Protection
- Content-Security-Policy
- Referrer-Policy

---

## Performance Optimizations

### Caching Strategy
- **Categories**: Cached in Redis (rarely changes)
- **Locations**: Cached by country/state (frequently accessed)
- **Query Results**: Cached for expensive queries
- **Chat session validation**: Reads shared Redis `auth:session:*` cache written by SpringMate; falls back to internal API

### Database Optimization
- **Indexes**: Strategic indexes on frequently queried columns
- **EntityGraph**: Prevents N+1 query problems
- **Batch Operations**: JDBC batch size configured

### Pagination
- **Offset-based**: For most endpoints
- **Cursor-based**: For large datasets (recommended for future)
