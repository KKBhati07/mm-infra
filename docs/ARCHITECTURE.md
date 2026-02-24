# MarketMate System Architecture Documentation (C4 Model)

This document provides architecture diagrams using the C4 model to visualize the MarketMate platform at different levels of abstraction, including all services (Backend, Frontend, Chat Service).

---

## Table of Contents

1. [System Context (Level 1)](#system-context-level-1)
2. [Container Diagram (Level 2)](#container-diagram-level-2)
3. [Service-Specific Architecture](#service-specific-architecture)

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
│   Listings   │    │   Listings   │    │ - Email      │
│ - Create     │    │ - Manage     │    │   Service    │
│   Listings   │    │   Users      │    │ - Location   │
│ - Chat       │    │ - View       │    │   API        │
│   with       │    │   Reports    │    │              │
│   Sellers    │    │              │    │              │
└──────────────┘    └──────────────┘    └──────────────┘
```

### Actors
- **Public Users**: End users browsing, creating listings, and chatting with sellers
- **Admin Users**: Administrators managing the platform
- **External Services**: AWS S3, Email service, Location API

### External Systems
- **AWS S3**: File storage for listing images and user profiles
- **Email Service (SMTP)**: Sends OTP and notification emails
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
│   (Backend)  │    │   Storage    │    │ - Profiles   │
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
6. **Redis**: Caching, session storage, and chat session management
7. **AWS S3**: File storage for images
8. **Prometheus**: Metrics collection and monitoring
9. **Grafana**: Metrics visualization and dashboards

---

## Local Development (Docker Compose)

The `mm-infra/docker-compose.yml` stack runs the platform locally with separate containers for each service.

### Services (current)
- **Public frontend**: `mm-frontend` (Angular) on `https://marketmate.local:4200`
- **Admin portal**: `mm-admin` (Angular) on `https://admin.marketmate.local:4300`
- **SpringMate backend**: `local-backend` (Spring Boot) on `https://localhost:8080` (local TLS/self-signed)
- **Chat service**: `chat-engine` (NestJS) on `https://localhost:4400`
- **PostgreSQL 15**: `local-postgres` on `localhost:5432` (initializes `marketmate` + `mm_chat`)
- **Redis 7**: `local-redis` on `localhost:6379`
- **Prometheus**: `local-prometheus` on `localhost:9090` (scrapes SpringMate `/actuator/prometheus` over HTTPS with basic auth)
- **Grafana**: `local-grafana` on `localhost:3005` (pre-provisioned Prometheus datasource + dashboards)

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

- **Chat Service**: See `mm-chat-service/docs/ARCHITECTURE.md` for:
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
User → Frontend → Chat Service (WebSocket) → SpringMate (internal session resolve) → Redis/PostgreSQL (session validation)
                                    ↓
                              PostgreSQL (mm_chat DB - Message Storage)
                                    ↓
                              Broadcast to Other User
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
- **JWT Tokens**: Stored in httpOnly cookies
- **Session Management**: Sessions stored in PostgreSQL with Redis used as a session-validation cache
- **OTP Verification**: Email-based OTP for login
- **Chat Authentication**: Validates sessions by calling SpringMate’s internal session resolve API (no tokens passed via URL params)

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
- **Chat Sessions**: Cached in Redis for fast validation

### Database Optimization
- **Indexes**: Strategic indexes on frequently queried columns
- **EntityGraph**: Prevents N+1 query problems
- **Batch Operations**: JDBC batch size configured

### Pagination
- **Offset-based**: For most endpoints
- **Cursor-based**: For large datasets (recommended for future)
