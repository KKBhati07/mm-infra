# MarketMate Infrastructure

Infrastructure repository for MarketMate application stack. Contains configuration files, initialization scripts, and monitoring setup that are used across both local development and production environments.

**Note**: `docker-compose.yml` is provided for local development convenience only. Production deployments will use different orchestration (Kubernetes, ECS, etc.), but the same infrastructure configurations, init scripts, and monitoring setups defined here.

## 📋 Prerequisites

**For Local Development:**
- Docker and Docker Compose installed
- All application repositories in the parent directory:
  - `MM/` - Frontend applications
  - `mm-chat-service/` - Chat engine service
  - `SpringMate/SpringMate/` - Spring Boot backend

**For Production:**
- Infrastructure configurations and init scripts in this repo are production-ready
- Adapt deployment method based on your production environment (Kubernetes, ECS, etc.)

## 🚀 Quick Start (Local Development)

```bash
# Navigate to the infra directory
cd mm-infra

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Stop and remove volumes (fresh start)
docker-compose down -v
```

## 🏗️ Services

### Application Services

| Service | Container Name | Port | Description |
|---------|---------------|------|-------------|
| Frontend | `mm-frontend` | 4200 | Main MarketMate frontend application |
| Admin Portal | `mm-admin` | 4300 | Admin portal frontend |
| Chat Engine | `chat-engine` | 3100 | NestJS chat service |
| Backend | `local-backend` | 8080 | Spring Boot backend API |

### Infrastructure Services

| Service | Container Name | Port | Description |
|---------|---------------|------|-------------|
| PostgreSQL | `local-postgres` | 5432 | Database server |
| Redis | `local-redis` | 6379 | Cache and session store |
| Prometheus | `local-prometheus` | 9090 | Metrics collection |
| Grafana | `local-grafana` | 3005 | Metrics visualization |

## 🗄️ Database Setup

### Automatic Database Initialization

PostgreSQL automatically initializes databases on first container startup using the init script at `postgres/init-databases.sh`.

**Databases created:**
- `marketmate` - Main database for Spring Boot backend
- `mm_chat` - Database for chat engine service

### How It Works

1. **First time setup**: When you run `docker-compose up` for the first time, the init script runs automatically and creates both databases.

2. **Subsequent runs**: If the container already has data, init scripts won't run again (PostgreSQL behavior). The databases will already exist.

3. **Fresh start**: To re-run initialization:
   ```bash
   docker-compose down -v  # Removes all volumes
   docker-compose up        # Fresh start, init scripts run again
   ```

### Manual Database Creation

If you need to create a missing database on an existing container:

```bash
# Option 1: Run the init script manually
docker cp postgres/init-databases.sh local-postgres:/tmp/
docker exec local-postgres bash /tmp/init-databases.sh

# Option 2: Create database directly
docker exec -it local-postgres psql -U postgres -c "CREATE DATABASE mm_chat;"
```

### Database Credentials (Local Development)

- **Host**: `localhost` (or `local-postgres` from other containers)
- **Port**: `5432`
- **User**: `postgres`
- **Password**: `password`
- **Databases**: `marketmate`, `mm_chat`

⚠️ **Note**: These credentials are for local development only. Production deployments should use proper secrets management.

## 📁 Directory Structure

```
mm-infra/
├── docker-compose.yml          # Local development only - Docker Compose setup
├── postgres/
│   └── init-databases.sh       # Database initialization script (production-ready)
├── redis/
│   └── redis.conf             # Redis configuration (production-ready)
├── prometheus/
│   └── prometheus.yml          # Prometheus configuration (production-ready)
└── grafana/
    ├── provisioning/          # Grafana datasources and dashboards (production-ready)
    └── dashboards/            # Grafana dashboard definitions (production-ready)
```

**Production-Ready Components:**
- `postgres/init-databases.sh` - Use in production PostgreSQL initialization
- `redis/redis.conf` - Redis configuration for production
- `prometheus/prometheus.yml` - Metrics collection configuration
- `grafana/` - Monitoring dashboards and provisioning

**Local Development Only:**
- `docker-compose.yml` - Convenience setup for local development

## 🔧 Configuration

### Environment Files (Local Development)

Each service uses its own environment file:
- Frontend/Admin: Environment variables in `docker-compose.yml`
- Chat Engine: `../mm-chat-service/src/env/.env`
- Backend: `../SpringMate/SpringMate/src/main/java/com/example/SpringMate/env/.env`

**Production**: Use proper secrets management (AWS Secrets Manager, HashiCorp Vault, etc.)

### Volumes (Local Development Only)

Data persistence is handled through Docker volumes:
- `pgdata` - PostgreSQL data
- `redis_data` - Redis data
- `grafana_data` - Grafana dashboards and settings
- `mm_node_modules` - Frontend dependencies
- `mm_admin_node_modules` - Admin portal dependencies
- `chat_engine_node_modules` - Chat service dependencies

**Production**: Use managed services or persistent volumes configured in your orchestration platform

## 🔍 Monitoring

### Prometheus
- **Local**: Access at http://localhost:9090
- **Production**: Deploy using `prometheus/prometheus.yml` configuration
- Scrapes metrics from the backend service

### Grafana
- **Local**: Access at http://localhost:3005 (default credentials: `admin` / `admin`)
- **Production**: Use configurations in `grafana/` directory
- Pre-configured with Prometheus datasource and dashboards

## 🛠️ Common Commands (Local Development)

```bash
# Start specific service
docker-compose up -d postgres

# View logs for specific service
docker-compose logs -f chat-engine

# Restart a service
docker-compose restart backend

# Execute command in container
docker exec -it local-postgres psql -U postgres

# Connect to Redis CLI
docker exec -it local-redis redis-cli

# Check service status
docker-compose ps

# Rebuild services after code changes
docker-compose up -d --build
```

## 🐛 Troubleshooting

### Database Connection Issues

1. **Check if PostgreSQL is running**:
   ```bash
   docker-compose ps postgres
   ```

2. **Check database exists**:
   ```bash
   docker exec -it local-postgres psql -U postgres -l
   ```

3. **Re-run database initialization**:
   ```bash
   docker-compose down -v
   docker-compose up -d postgres
   ```

### Port Conflicts

If a port is already in use, either:
- Stop the conflicting service
- Change the port mapping in `docker-compose.yml`

### Volume Issues

To completely reset all data:
```bash
docker-compose down -v
docker volume prune  # Remove unused volumes
docker-compose up -d
```

## 📝 Notes

**Local Development:**
- `docker-compose.yml` provides a convenient local development environment
- Database initialization scripts run automatically on first container startup
- All services are configured for hot-reload during development
- Data persists between container restarts via Docker volumes

**Production:**
- Infrastructure configurations (init scripts, Redis config, Prometheus, Grafana) are production-ready
- Adapt deployment method based on your production environment
- Use the same `init-databases.sh` script for database initialization consistency
- All configurations can be reused in production with appropriate secrets and networking

## 🔐 Production Deployment

This infrastructure repository is designed to be used in production with the following considerations:

1. **Database Initialization**: Use `postgres/init-databases.sh` in your production PostgreSQL setup (Kubernetes init containers, ECS task definitions, etc.)

2. **Secrets Management**: 
   - Replace hardcoded credentials with proper secrets management
   - Use environment-specific configuration files
   - Never commit production credentials

3. **Monitoring**: 
   - Deploy Prometheus and Grafana using configurations in this repo
   - Configure appropriate retention policies and alerting rules
   - Set up proper authentication for Grafana

4. **Configuration Management**:
   - Redis configuration (`redis/redis.conf`) is production-ready
   - Prometheus configuration (`prometheus/prometheus.yml`) can be used as-is or adapted
   - Grafana provisioning and dashboards are production-ready

5. **Backup & Recovery**:
   - Set up automated database backups
   - Configure Redis persistence appropriately
   - Document recovery procedures

6. **Network Security**:
   - Configure proper network policies and security groups
   - Use private networking where possible
   - Implement proper access controls

**Migration Path**: As you move to production, you'll adapt the orchestration method (Kubernetes, ECS, etc.) but reuse the same infrastructure configurations, init scripts, and monitoring setups defined here.
