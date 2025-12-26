# Exercise 2.9 - Fixup

## Objective

Fix broken buttons and ensure all exercise buttons work correctly in the application behind the reverse proxy.

## Problems Identified

### 1. CORS Headers
The reverse proxy (Nginx) was not passing important headers needed for proper proxying:
- `X-Real-IP` - Real client IP
- `X-Forwarded-For` - Original client IP
- `X-Forwarded-Proto` - Original protocol (HTTP/HTTPS)

### 2. Request Routing Consistency
The backend's CORS configuration expects `REQUEST_ORIGIN` to match the actual origin from which requests come. With the reverse proxy, we needed to ensure Nginx passes the correct Host header.

## Solution

### Updated nginx.conf

Added additional proxy headers to properly forward client information:

```nginx
location /api/ {
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_pass http://backend:8080/;
  proxy_redirect off;
}
```

**New headers added:**
- `X-Real-IP` - Preserves original client IP address
- `X-Forwarded-For` - Adds client IP to forwarding chain
- `X-Forwarded-Proto` - Preserves original protocol (http/https)
- `proxy_redirect off` - Prevents Nginx from rewriting redirects

### Key Configuration Changes

1. **Preserved Host Header**
   ```nginx
   proxy_set_header Host $host;
   ```
   This ensures the backend sees `localhost` as the host, matching the `REQUEST_ORIGIN=http://localhost` configuration.

2. **Forwarded Headers**
   ```nginx
   proxy_set_header X-Real-IP $remote_addr;
   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
   proxy_set_header X-Forwarded-Proto $scheme;
   ```
   These help the backend understand the real request origin.

3. **Redirect Handling**
   ```nginx
   proxy_redirect off;
   ```
   Prevents Nginx from rewriting Location headers in redirects.

## How It Works

### Request Flow with Fixed Headers

1. Browser makes request to `http://localhost/api/ping`
2. Nginx receives request
3. Nginx adds headers:
   - `Host: localhost` (from `$host`)
   - `X-Real-IP: <browser-ip>` (from `$remote_addr`)
   - `X-Forwarded-For: <browser-ip>` (from `$proxy_add_x_forwarded_for`)
   - `X-Forwarded-Proto: http` (from `$scheme`)
4. Nginx forwards to backend:8080
5. Backend sees Host header is `localhost`
6. CORS check passes because origin matches `REQUEST_ORIGIN=http://localhost`
7. Backend processes request correctly

## CORS Configuration

The backend uses:
```yaml
environment:
  - REQUEST_ORIGIN=http://localhost
```

With the fixed Nginx configuration, the Host header matches this, so CORS validation passes.

## Testing

All endpoints work correctly:
```bash
# Root path
curl http://localhost/

# API endpoint
curl http://localhost/api/ping
# Returns: pong

# Create message
curl -X POST http://localhost/api/messages \
  -H "Content-Type: application/json" \
  -d '{"body":"test message"}'

# Get all messages
curl http://localhost/api/messages
```

## Files Modified

### nginx.conf
- Added `X-Real-IP` header
- Added `X-Forwarded-For` header
- Added `X-Forwarded-Proto` header
- Added `proxy_redirect off` directive

### docker-compose.yaml
No changes needed - configuration from 2.8 is sufficient.

## Why These Headers Matter

1. **X-Real-IP** - Helps backend log real client IP instead of Nginx IP
2. **X-Forwarded-For** - Standard header for tracking client IP through proxies
3. **X-Forwarded-Proto** - Tells backend the original protocol (important for HTTPS later)
4. **proxy_redirect off** - Prevents breaking redirects in API responses

## Common Issues Fixed

### "CORS Error" Messages
Fixed by ensuring Host header matches REQUEST_ORIGIN.

### Buttons Not Working
Fixed by properly forwarding headers so backend can validate requests correctly.

### Inconsistent Behavior
Nginx and backend configurations now work together properly.

## Production Considerations

For production deployments, these headers become even more important:
- Real client IP tracking for logging/security
- HTTPS protocol detection
- Load balancer compatibility

## Verification Checklist

✓ All endpoints accessible through http://localhost
✓ `/api/ping` returns `pong`
✓ `/api/messages` GET/POST work correctly
✓ Frontend accessible at root path
✓ No CORS errors in browser console
✓ All buttons work in the application
✓ Messages persist correctly

## Integration with Backend CORS

The backend's Gin CORS middleware:
```go
config.AllowOrigins = []string{allowedOrigin}
```

With `REQUEST_ORIGIN=http://localhost`, requests from `http://localhost` are allowed.
The fixed Nginx ensures the request appears to come from `http://localhost`, not from an internal IP.

## Next Steps

The application is now fully functional through a single entry point (port 80) with proper reverse proxy configuration.
