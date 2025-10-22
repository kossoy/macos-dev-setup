# API Development & Testing

Complete setup for API development, testing, and performance analysis tools.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- Homebrew installed

## 1. Postman (API Client)

Postman is the industry-standard API testing tool.

```bash
# Install Postman
brew install --cask postman

# Launch Postman
open -a Postman
```

### Postman Features

- API request builder
- Collections for organizing requests
- Environment variables
- Automated testing
- API documentation generation
- Team collaboration
- Mock servers
- API monitoring

### Quick Start

1. Create a new request
2. Set HTTP method (GET, POST, PUT, DELETE)
3. Enter URL
4. Add headers, body, auth as needed
5. Click Send
6. View response

## 2. Insomnia (Alternative API Client)

Insomnia is a lightweight alternative to Postman.

```bash
# Install Insomnia
brew install --cask insomnia

# Launch Insomnia
open -a Insomnia
```

### Insomnia Features

- Simple, clean interface
- GraphQL support
- gRPC support
- Environment variables
- Code generation
- Plugin system

## 3. HTTPie (Command-Line HTTP Client)

HTTPie is a user-friendly command-line HTTP client.

```bash
# Install HTTPie
brew install httpie

# Verify installation
http --version
```

### HTTPie Usage

```bash
# GET request
http https://api.example.com/users

# GET with query params
http GET https://api.example.com/users search==john

# POST JSON
http POST https://api.example.com/users name=John email=john@example.com

# POST with file
http POST https://api.example.com/upload < file.json

# Custom headers
http GET https://api.example.com/users Authorization:"Bearer token123"

# Download file
http --download https://example.com/file.pdf

# Follow redirects
http --follow https://example.com

# Pretty print
http --pretty=all https://api.example.com/users
```

## 4. cURL (Built-in HTTP Client)

cURL comes pre-installed on macOS.

```bash
# Basic GET
curl https://api.example.com/users

# GET with headers
curl -H "Authorization: Bearer token" https://api.example.com/users

# POST JSON
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com"}'

# POST from file
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d @data.json

# PUT request
curl -X PUT https://api.example.com/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane"}'

# DELETE request
curl -X DELETE https://api.example.com/users/1

# Save response to file
curl https://api.example.com/users -o users.json

# Follow redirects
curl -L https://example.com

# Show headers
curl -I https://api.example.com
curl -i https://api.example.com  # With body

# Verbose output
curl -v https://api.example.com
```

## 5. Apache JMeter (Performance Testing)

Apache JMeter is for load testing and performance measurement.

### Installation

JMeter is already included if you ran the integration script!

```bash
# Launch JMeter GUI
jmeter

# Check version
jmeter --version

# JMeter location
ls ~/work/Mac\ OS\ install/bin/apache-jmeter-5.6.2/
```

### CLI Usage

```bash
# Run test in non-GUI mode (recommended for load testing)
jmeter -n -t test-plan.jmx -l results.jtl -e -o ./reports/

# Options:
# -n : non-GUI mode
# -t : test plan file
# -l : results file
# -e : generate report dashboard
# -o : output folder for report

# Run with specific properties
jmeter -n -t test.jmx -Jusers=100 -Jduration=60

# Distributed testing (server mode)
jmeter-server

# Connect to remote servers
jmeter -n -t test.jmx -R server1,server2,server3
```

### Creating Test Plans

1. Open JMeter GUI
2. Add Thread Group (simulate users)
3. Add HTTP Request Sampler
4. Add listeners (View Results Tree, Summary Report)
5. Configure:
   - Number of threads (users)
   - Ramp-up period
   - Loop count
6. Save test plan (.jmx file)
7. Run in CLI mode for actual load testing

### Example Test Plan Structure

```
Test Plan
├── Thread Group (100 users, 10s ramp-up)
│   ├── HTTP Request Defaults (host, port)
│   ├── HTTP Header Manager (headers)
│   ├── HTTP Request - GET /api/users
│   ├── HTTP Request - POST /api/users
│   └── HTTP Request - GET /api/users/{id}
└── Listeners
    ├── Summary Report
    ├── Graph Results
    └── View Results Tree
```

## 6. REST Client Extensions

### VS Code / Cursor REST Client

```bash
# In Cursor/VS Code, install REST Client extension
# Create .http or .rest file

# Example API calls:
cat > api-tests.http << 'EOF'
### Get all users
GET https://api.example.com/users

### Get user by ID
GET https://api.example.com/users/1

### Create user
POST https://api.example.com/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com"
}

### Update user
PUT https://api.example.com/users/1
Content-Type: application/json

{
  "name": "Jane Doe"
}

### Delete user
DELETE https://api.example.com/users/1

### With authentication
GET https://api.example.com/protected
Authorization: Bearer eyJhbGci...

### With variables
@baseUrl = https://api.example.com
@userId = 1

GET {{baseUrl}}/users/{{userId}}
EOF
```

### IntelliJ HTTP Client

IntelliJ IDEA, PyCharm, and WebStorm have built-in HTTP client:

1. Create `.http` file
2. Write requests using same format
3. Click green arrow to run
4. View responses in tool window

## 7. GraphQL Tools

### Altair GraphQL Client

```bash
# Install Altair
brew install --cask altair-graphql-client

# Launch
open -a "Altair GraphQL Client"
```

### GraphQL Playground (Web)

Visit: `https://www.graphqlplayground.com/`

### Command-Line GraphQL

```bash
# Using curl
curl -X POST https://api.example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ users { id name email } }"}'

# Using httpie
http POST https://api.example.com/graphql \
  query='{ users { id name email } }'
```

## 8. API Documentation Tools

### Swagger/OpenAPI

```bash
# Install Swagger UI
npm install -g swagger-ui

# Or use online editor
open https://editor.swagger.io/
```

### Redoc

```bash
# Install Redoc CLI
npm install -g redoc-cli

# Generate HTML from OpenAPI spec
redoc-cli bundle openapi.yaml -o docs.html
```

## 9. Mock Servers

### JSON Server

```bash
# Install JSON Server
npm install -g json-server

# Create db.json
cat > db.json << 'EOF'
{
  "users": [
    { "id": 1, "name": "John", "email": "john@example.com" },
    { "id": 2, "name": "Jane", "email": "jane@example.com" }
  ],
  "posts": [
    { "id": 1, "title": "Hello", "userId": 1 }
  ]
}
EOF

# Start server
json-server --watch db.json --port 3000

# Endpoints automatically created:
# GET    /users
# GET    /users/1
# POST   /users
# PUT    /users/1
# PATCH  /users/1
# DELETE /users/1
```

### Mockoon

```bash
# Install Mockoon
brew install --cask mockoon

# Launch
open -a Mockoon
```

## 10. Performance Monitoring

### K6 (Load Testing)

```bash
# Install k6
brew install k6

# Create test script
cat > load-test.js << 'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 10,
  duration: '30s',
};

export default function() {
  let response = http.get('https://api.example.com/users');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
EOF

# Run test
k6 run load-test.js

# Run with more virtual users
k6 run --vus 100 --duration 1m load-test.js
```

## 11. API Testing in CI/CD

### Newman (Postman CLI)

```bash
# Install Newman
npm install -g newman

# Export collection from Postman
# Run collection
newman run collection.json

# Run with environment
newman run collection.json -e environment.json

# Generate report
newman run collection.json -r html,cli
```

## 12. Best Practices

### 1. Use Environment Variables

Don't hardcode URLs, tokens:
```bash
# In Postman/Insomnia, create environments:
# - Development: https://api-dev.example.com
# - Staging: https://api-staging.example.com
# - Production: https://api.example.com
```

### 2. Organize Collections

Group related requests:
```
Collections/
├── Authentication/
│   ├── Login
│   ├── Logout
│   └── Refresh Token
├── Users/
│   ├── List Users
│   ├── Get User
│   ├── Create User
│   └── Update User
└── Posts/
    ├── List Posts
    ├── Create Post
    └── Delete Post
```

### 3. Write Tests

```javascript
// Postman test example
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response time is less than 200ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(200);
});

pm.test("User has email", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.email).to.exist;
});
```

### 4. Document APIs

- Use OpenAPI/Swagger specifications
- Include examples
- Document error responses
- Keep documentation updated

## Next Steps

Continue with:
- **[AI/ML Tools](12-ai-ml-tools.md)** - Machine learning development
- **[Docker & Kubernetes](05-docker-kubernetes.md)** - Containerized APIs

---

**Estimated Time**: 15 minutes  
**Difficulty**: Beginner  
**Last Updated**: October 5, 2025
