# Exercise 2.6 - Postgres (Mandatory)

## Objective

Add a PostgreSQL database to the backend from Exercise 2.4 to save messages persistently.

## What Changed from 2.4

Exercise 2.4 had:
- Backend (Go application)
- Frontend (React application)
- Redis (in-memory cache)

Exercise 2.6 adds:
- **PostgreSQL** (persistent message database)

## Architecture

```
Frontend (port 5000)
  ↓
Backend (port 8080)
  ↓
├── Redis (internal) - In-memory cache
└── PostgreSQL (internal) - Persistent storage
```

## Key Configuration

### PostgreSQL Service

The Postgres service is defined in docker-compose.yaml:

```yaml
db:
  image: postgres:17
  restart: unless-stopped
  environment:
    POSTGRES_PASSWORD: postgres
    POSTGRES_USER: postgres
    POSTGRES_DB: postgres
  container_name: db_postgres
  volumes:
    - database:/var/lib/postgresql/data
```

**Key points:**
- Uses PostgreSQL 17 official image
- `restart: unless-stopped` - Restarts on failure but not after explicit stop
- Environment variables configure database credentials
- Docker managed volume `database` persists data
- Default port: 5432 (internal only, not exposed)

### Backend Environment Variables

The backend needs these PostgreSQL variables:

```yaml
environment:
  - POSTGRES_HOST=db
  - POSTGRES_USER=postgres
  - POSTGRES_PASSWORD=postgres
  - POSTGRES_DATABASE=postgres
```

- `POSTGRES_HOST=db` - Uses Docker DNS to reach postgres container
- `POSTGRES_USER` - Database user (matches Postgres POSTGRES_USER)
- `POSTGRES_PASSWORD` - Password (matches Postgres POSTGRES_PASSWORD)
- `POSTGRES_DATABASE` - Database name (matches Postgres POSTGRES_DB)

### Dependencies

```yaml
depends_on:
  - redis
  - db
```

Ensures PostgreSQL starts before backend.

## Docker Managed Volume

Unlike Exercise 2.1-2.2 which used bind mounts (host directory), this uses a Docker managed volume:

```yaml
volumes:
  database:
```

**Benefits:**
- Managed by Docker (no host directory management)
- Persists data between container restarts
- Named volume: `26-postgres_database`
- Automatic backup capabilities

## Running the Exercise

```bash
docker compose up
```

Services will start in order:
1. PostgreSQL database
2. Redis cache
3. Backend (waits for both)
4. Frontend (waits for backend)

Access the application at http://localhost:5000

## Testing PostgreSQL Connection

The backend logs show connection progress:

```
[Ex 2.6+] Connection to postgres failed! Retrying...
[Ex 2.6+] Connection to postgres initialized, ready to ping pong.
```

After successful connection, the backend creates tables and is ready.

## Form/Button Functionality

The frontend now includes a form to:
- Submit messages
- View all messages

Messages are stored in PostgreSQL and persist across container restarts.

## Cleaning Up Volumes

If you need to reset the database:

```bash
docker compose down
docker volume prune
```

Then run `docker compose up` again to recreate empty database.

## Why PostgreSQL Matters

- **Persistence** - Data survives container restarts
- **Reliability** - ACID compliance ensures data integrity
- **Scalability** - Better than Redis for large datasets
- **Queries** - SQL allows complex data operations
- **Transactions** - Can group multiple operations

## Integration with Redis

Both are used:
- **Redis** - Cache for fast response times
- **PostgreSQL** - Persistent storage for messages

Backend reads from cache first, falls back to database if needed.

## Port Mapping Summary

| Service | Port | Accessible From Host |
|---------|------|----------------------|
| Frontend | 5000 | Yes (http://localhost:5000) |
| Backend | 8080 | Yes (http://localhost:8080) |
| Redis | 6379 | No (Docker network only) |
| PostgreSQL | 5432 | No (Docker network only) |

## Postgres Container Interaction

Interact with PostgreSQL directly:

```bash
docker compose exec db_postgres psql -U postgres
```

Then run SQL commands:
```sql
\dt                 -- List tables
SELECT * FROM messages;  -- View messages
```

Backup database:
```bash
docker compose exec db_postgres pg_dump -U postgres > backup.sql
```

## Troubleshooting

**Connection failed errors:**
- Normal initially - PostgreSQL takes time to initialize
- `restart: unless-stopped` makes it retry automatically

**Need fresh database:**
```bash
docker volume rm 26-postgres_database
docker compose down
docker compose up
```

**Check volume:**
```bash
docker volume ls | grep database
```

## Key Learning Points

1. **Docker Managed Volumes** - Simpler than bind mounts for databases
2. **Service Dependencies** - `depends_on` controls startup order
3. **Environment Variables** - Configures service connections
4. **Docker Networking** - Service names work as DNS
5. **Multi-Database Architecture** - Redis + PostgreSQL for different purposes
6. **Container Interaction** - `docker compose exec` for direct access
