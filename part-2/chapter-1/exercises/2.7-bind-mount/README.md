# Exercise 2.7 - Bind Mount (Mandatory)

## Objective

Replace Docker managed volume with a bind mount to store PostgreSQL data in a local directory (`./database`).

## What Changed from 2.6

Exercise 2.6 used:
```yaml
volumes:
  database:

services:
  db:
    volumes:
      - database:/var/lib/postgresql/data
```

This creates a Docker managed volume with an opaque name. Exercise 2.7 uses:
```yaml
services:
  db:
    volumes:
      - ./database:/var/lib/postgresql/data
```

## Bind Mount vs Docker Managed Volume

### Docker Managed Volume (2.6)
- **Location:** `/var/lib/docker/volumes/PROJECT_database/_data`
- **Management:** Docker handles everything
- **Inspection:** Need to use Docker commands
- **Backup:** Slightly more complex

### Bind Mount (2.7)
- **Location:** `./database` (relative to docker-compose.yml)
- **Management:** You control the directory
- **Inspection:** Direct filesystem access
- **Backup:** Simple copy/paste

## Bind Mount Syntax

```yaml
volumes:
  - ./database:/var/lib/postgresql/data
```

This maps:
- **Host:** `./database` (local directory)
- **Container:** `/var/lib/postgresql/data` (PostgreSQL data directory)

The `./` prefix indicates a relative path from the docker-compose.yml location.

## Key Advantages

1. **Visibility** - Can see database files directly on host
2. **Backup** - Easy to backup by copying the folder
3. **Debugging** - Can inspect files without Docker commands
4. **Version Control** - Can track changes if desired
5. **Portability** - Directory travels with docker-compose.yml

## Important Permissions

PostgreSQL runs as UID 999 inside container, so on host:
- Directory appears owned by different user
- Need `sudo` to access directly
- This is normal and secure

## Testing the Bind Mount

### Step 1: Start services
```bash
docker compose up -d
```

### Step 2: Check directory exists
```bash
ls -la database/
```
Shows permission denied (normal for PostgreSQL)

Or with elevated privileges:
```bash
sudo ls -la database/
```
Shows PostgreSQL files

### Step 3: Save messages
Use frontend at http://localhost:5000 or:
```bash
curl -X POST http://localhost:8080/messages \
  -H "Content-Type: application/json" \
  -d '{"message":"test"}'
```

### Step 4: Verify persistence
```bash
docker compose down
docker compose up -d
```
Messages should still be there.

### Step 5: Delete and verify
```bash
docker compose down
sudo rm -rf database
docker compose up -d
```
Messages should be gone (fresh database).

## File Structure

```
2.7-bind-mount/
├── docker-compose.yaml
├── README.md
├── ANSWER.txt
└── database/              (created by docker compose up)
    ├── PG_VERSION
    ├── base/
    ├── pg_commit_ts/
    ├── global/
    └── ... (PostgreSQL data files)
```

## Real-World Use Cases

### Development
```yaml
volumes:
  - ./data/postgres:/var/lib/postgresql/data
```
Easy to backup between development sessions.

### Staging
```yaml
volumes:
  - /mnt/storage/db:/var/lib/postgresql/data
```
Uses dedicated storage mount.

### Production
Better to use cloud database or Docker volumes.

## Cleanup

If testing multiple times:

```bash
# Stop containers
docker compose down

# Remove the bind mount directory
sudo rm -rf database

# Recreate from scratch
docker compose up -d
```

## Advantages Over Anonymous Volumes

1. **Named location** - You know where data is
2. **Easy access** - No cryptic volume IDs
3. **Backup** - Simple directory copy
4. **Inspection** - Direct file inspection possible
5. **Portability** - Moves with the code

## Important Notes

- Bind mount directory is created automatically on first run
- PostgreSQL creates all necessary subdirectories
- Owner/permissions are set by PostgreSQL container
- Use `sudo` to inspect directory contents
- Not recommended for use in git (add to .gitignore)

## Comparison Table

| Feature | Bind Mount | Managed Volume |
|---------|-----------|-----------------|
| Location | ./database | /var/lib/docker/volumes/... |
| Host Access | Direct | Docker commands needed |
| Visibility | Clear directory | Opaque ID |
| Backup | Easy copy | Need docker commands |
| Learning Curve | Low | Medium |
| Production Use | Medium | Better |

## PostgreSQL Permissions

The `database/` directory:
- Owned by UID 999 (PostgreSQL user inside container)
- Readable as root only
- This is secure and expected
- Don't change permissions manually

## Integration with Other Services

Backend, Frontend, and Redis all work unchanged. Only PostgreSQL storage method changed:
- Backend still connects to postgres:5432
- Frontend still sends to backend:8080
- Redis still caches data
- Database persistence is now file-based

## Using with docker-compose exec

Interact with database:
```bash
docker compose exec db_postgres psql -U postgres
```

List tables:
```sql
\dt
SELECT * FROM messages;
```

## Next Steps

Once familiar with bind mounts, you could:
- Create multiple volumes for different purposes
- Set up backup scripts
- Use environment-specific directories
- Implement container networking patterns

## Success Criteria

✓ `docker compose up` creates ./database directory
✓ Messages persist after `docker compose down/up`
✓ Messages disappear after deleting ./database directory
✓ All services communicate normally
✓ Button turns green in frontend
