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
│  │  │  (Angular)   │              │  (Angular)  │           │   │
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
User → Frontend → Chat Service (WebSocket) → Redis (Session Validation)
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
- **Session Management**: Redis-backed sessions
- **OTP Verification**: Email-based OTP for login
- **Chat Authentication**: Validates JWT from SpringMate backend

### Authorization
- **Role-Based Access Control (RBAC)**: ADMIN, USER roles
- **Method-Level Security**: `@PreAuthorize` annotations
- **Resource-Level Security**: User can only modify own resources

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

---

## Notes

- This architecture supports horizontal scaling
- Redis is used for caching, session storage, and chat session management
- Database connections are pooled (HikariCP)
- All external service calls are wrapped with Resilience4j (circuit breakers, retries)
- Rate limiting is applied at the filter level
- Chat service authenticates via SpringMate backend JWT validation
- **Database Separation**: Two separate databases (`marketmate` for backend, `mm_chat` for chat service) for better isolation and scalability
- **Monitoring**: Prometheus scrapes metrics from Spring Boot Actuator endpoints, and Grafana provides pre-configured dashboards
- **Infrastructure as Code**: All infrastructure configurations (PostgreSQL init scripts, Redis config, Prometheus, Grafana) are version-controlled and production-ready

---

## Future Enhancements

1. **Microservices Migration**: Further split services if needed
2. **Message Queue**: Add Kafka/RabbitMQ for async processing
3. **Search Service**: Dedicated Elasticsearch for full-text search
4. **CDN Integration**: CloudFront for static assets
5. **API Gateway**: Centralized routing and rate limiting
