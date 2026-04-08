---
tags: [reference, api, auth]
---

# Authentication

## OAuth 2.0 Flow

```
Client -> Authorization Server -> Token -> API Calls
```

### Endpoints

- Auth URL: `https://auth.example.com/oauth/authorize`
- Token URL: `https://auth.example.com/oauth/token`
- Refresh: `https://auth.example.com/oauth/refresh`

### Scopes

| Scope | Description |
|-------|-------------|
| `read` | Read-only access |
| `write` | Create/update |
| `admin` | Full access |

## Implementation

See [[Reference/API/Authentication]] for code example.

## Related

- [[Reference/External Services]]
- [[Projects/ObsidianDatasource/API Integration]]
