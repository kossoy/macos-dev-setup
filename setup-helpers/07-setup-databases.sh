#!/bin/bash
# =============================================================================
# Database Setup Script
# =============================================================================
# Sets up Docker-based databases with context awareness
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Print functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

print_header "🗄️  Database Setup"
print_header "================="
echo ""

# Check for Docker
if ! command -v docker &>/dev/null; then
    print_error "Docker is not installed"
    print_status "Install with: ./setup-helpers/04-install-docker.sh"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &>/dev/null; then
    print_error "Docker daemon is not running"
    print_status "Start Docker Desktop and try again"
    exit 1
fi

print_success "Docker is running"
echo ""

# Create databases directory
DATABASES_DIR="$HOME/work/databases"
mkdir -p "$DATABASES_DIR"

print_status "Database configurations will be created in: $DATABASES_DIR"
echo ""

# ============================================================================
# Shared Databases (Always Available)
# ============================================================================

print_header "📦 Creating Shared Database Configuration"
echo ""

cat > "$DATABASES_DIR/shared-compose.yml" << 'EOF'
version: '3.8'

services:
  # PostgreSQL (shared development)
  postgres-shared:
    image: postgres:15-alpine
    container_name: postgres-shared
    environment:
      POSTGRES_PASSWORD: devpassword
      POSTGRES_USER: devuser
      POSTGRES_DB: devdb
    ports:
      - "5433:5432"
    volumes:
      - postgres-shared-data:/var/lib/postgresql/data
    restart: unless-stopped

  # Redis (shared cache)
  redis-shared:
    image: redis:7-alpine
    container_name: redis-shared
    ports:
      - "6380:6379"
    volumes:
      - redis-shared-data:/data
    restart: unless-stopped

volumes:
  postgres-shared-data:
  redis-shared-data:
EOF

print_success "Shared databases configuration created"
echo "  - PostgreSQL on port 5433"
echo "  - Redis on port 6380"
echo ""

# ============================================================================
# Work Context Databases
# ============================================================================

print_header "💼 Creating Work Database Configuration"
echo ""

cat > "$DATABASES_DIR/work-compose.yml" << 'EOF'
version: '3.8'

services:
  # PostgreSQL (work)
  postgres-work:
    image: postgres:15-alpine
    container_name: postgres-work
    environment:
      POSTGRES_PASSWORD: workpass
      POSTGRES_USER: workuser
      POSTGRES_DB: workdb
    ports:
      - "5432:5432"
    volumes:
      - postgres-work-data:/var/lib/postgresql/data
    restart: unless-stopped

  # MySQL (work)
  mysql-work:
    image: mysql:8
    container_name: mysql-work
    environment:
      MYSQL_ROOT_PASSWORD: workpass
      MYSQL_DATABASE: workdb
      MYSQL_USER: workuser
      MYSQL_PASSWORD: workpass
    ports:
      - "3306:3306"
    volumes:
      - mysql-work-data:/var/lib/mysql
    restart: unless-stopped

  # MongoDB (work)
  mongodb-work:
    image: mongo:7
    container_name: mongodb-work
    environment:
      MONGO_INITDB_ROOT_USERNAME: workuser
      MONGO_INITDB_ROOT_PASSWORD: workpass
    ports:
      - "27017:27017"
    volumes:
      - mongodb-work-data:/data/db
    restart: unless-stopped

  # Redis (work)
  redis-work:
    image: redis:7-alpine
    container_name: redis-work
    ports:
      - "6379:6379"
    volumes:
      - redis-work-data:/data
    restart: unless-stopped

volumes:
  postgres-work-data:
  mysql-work-data:
  mongodb-work-data:
  redis-work-data:
EOF

print_success "Work databases configuration created"
echo "  - PostgreSQL on port 5432"
echo "  - MySQL on port 3306"
echo "  - MongoDB on port 27017"
echo "  - Redis on port 6379"
echo ""

# ============================================================================
# Personal Context Databases
# ============================================================================

print_header "🏠 Creating Personal Database Configuration"
echo ""

cat > "$DATABASES_DIR/personal-compose.yml" << 'EOF'
version: '3.8'

services:
  # PostgreSQL (personal)
  postgres-personal:
    image: postgres:15-alpine
    container_name: postgres-personal
    environment:
      POSTGRES_PASSWORD: personalpass
      POSTGRES_USER: personaluser
      POSTGRES_DB: personaldb
    ports:
      - "5434:5432"
    volumes:
      - postgres-personal-data:/var/lib/postgresql/data
    restart: unless-stopped

  # MySQL (personal)
  mysql-personal:
    image: mysql:8
    container_name: mysql-personal
    environment:
      MYSQL_ROOT_PASSWORD: personalpass
      MYSQL_DATABASE: personaldb
      MYSQL_USER: personaluser
      MYSQL_PASSWORD: personalpass
    ports:
      - "3307:3306"
    volumes:
      - mysql-personal-data:/var/lib/mysql
    restart: unless-stopped

  # MongoDB (personal)
  mongodb-personal:
    image: mongo:7
    container_name: mongodb-personal
    environment:
      MONGO_INITDB_ROOT_USERNAME: personaluser
      MONGO_INITDB_ROOT_PASSWORD: personalpass
    ports:
      - "27018:27017"
    volumes:
      - mongodb-personal-data:/data/db
    restart: unless-stopped

volumes:
  postgres-personal-data:
  mysql-personal-data:
  mongodb-personal-data:
EOF

print_success "Personal databases configuration created"
echo "  - PostgreSQL on port 5434"
echo "  - MySQL on port 3307"
echo "  - MongoDB on port 27018"
echo ""

# ============================================================================
# Management Scripts
# ============================================================================

print_status "Creating database management scripts..."
echo ""

# Script to start shared databases
cat > "$DATABASES_DIR/start-shared.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
docker compose -f shared-compose.yml up -d
echo "✅ Shared databases started"
EOF
chmod +x "$DATABASES_DIR/start-shared.sh"

# Script to start work databases
cat > "$DATABASES_DIR/start-work.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
docker compose -f work-compose.yml up -d
echo "✅ Work databases started"
EOF
chmod +x "$DATABASES_DIR/start-work.sh"

# Script to start personal databases
cat > "$DATABASES_DIR/start-personal.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
docker compose -f personal-compose.yml up -d
echo "✅ Personal databases started"
EOF
chmod +x "$DATABASES_DIR/start-personal.sh"

# Script to stop all databases
cat > "$DATABASES_DIR/stop-all.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
docker compose -f shared-compose.yml down
docker compose -f work-compose.yml down
docker compose -f personal-compose.yml down
echo "✅ All databases stopped"
EOF
chmod +x "$DATABASES_DIR/stop-all.sh"

# Script to show database status
cat > "$DATABASES_DIR/status.sh" << 'EOF'
#!/bin/bash
echo "Database Containers Status:"
echo "============================"
docker ps --filter "name=postgres-" --filter "name=mysql-" --filter "name=mongodb-" --filter "name=redis-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
EOF
chmod +x "$DATABASES_DIR/status.sh"

print_success "Management scripts created"
echo ""

# ============================================================================
# README
# ============================================================================

cat > "$DATABASES_DIR/README.md" << 'EOF'
# Database Configurations

This directory contains Docker Compose configurations for context-aware database management.

## Port Assignments

### Shared Databases (Always available)
- PostgreSQL: `localhost:5433`
- Redis: `localhost:6380`

### Work Context
- PostgreSQL: `localhost:5432`
- MySQL: `localhost:3306`
- MongoDB: `localhost:27017`
- Redis: `localhost:6379`

### Personal Context
- PostgreSQL: `localhost:5434`
- MySQL: `localhost:3307`
- MongoDB: `localhost:27018`

## Management Scripts

### Start Databases
```bash
./start-shared.sh       # Start shared databases
./start-work.sh         # Start work databases
./start-personal.sh     # Start personal databases
```

### Stop Databases
```bash
./stop-all.sh           # Stop all databases
```

### Check Status
```bash
./status.sh             # Show running database containers
```

## Connection Strings

### PostgreSQL
```bash
# Shared
psql postgresql://devuser:devpassword@localhost:5433/devdb

# Work
psql postgresql://workuser:workpass@localhost:5432/workdb

# Personal
psql postgresql://personaluser:personalpass@localhost:5434/personaldb
```

### MySQL
```bash
# Work
mysql -h localhost -P 3306 -u workuser -pworkpass workdb

# Personal
mysql -h localhost -P 3307 -u personaluser -ppersonalpass personaldb
```

### MongoDB
```bash
# Work
mongosh mongodb://workuser:workpass@localhost:27017/

# Personal
mongosh mongodb://personaluser:personalpass@localhost:27018/
```

### Redis
```bash
# Shared
redis-cli -p 6380

# Work
redis-cli -p 6379
```

## Docker Compose Commands

### Manual Control
```bash
# Start specific service
docker compose -f work-compose.yml up -d postgres-work

# View logs
docker compose -f work-compose.yml logs -f postgres-work

# Stop specific service
docker compose -f work-compose.yml stop postgres-work

# Remove containers and volumes
docker compose -f work-compose.yml down -v
```

## Data Persistence

All databases use named volumes for data persistence. Data persists even after containers are stopped.

To completely remove database data:
```bash
docker compose -f work-compose.yml down -v
```

## Security Note

⚠️ **These configurations use default passwords for development only.**

For production use:
1. Change all passwords
2. Use environment variables or secrets management
3. Configure proper network isolation
4. Enable SSL/TLS for connections
5. Set up proper backup strategies
EOF

print_success "README.md created"
echo ""

# ============================================================================
# Test Database Connections
# ============================================================================

print_header "🧪 Testing Database Setup"
echo ""

read -p "Start shared databases now to test? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Starting shared databases..."
    cd "$DATABASES_DIR"
    docker compose -f shared-compose.yml up -d

    print_status "Waiting for databases to be ready..."
    sleep 5

    print_status "Checking container status..."
    docker ps --filter "name=postgres-shared" --filter "name=redis-shared"

    echo ""
    print_success "Shared databases are running"
    print_status "Check status anytime with: $DATABASES_DIR/status.sh"
else
    print_status "Skipped database startup"
fi

echo ""

# ============================================================================
# Summary
# ============================================================================

print_header "✅ Database Setup Complete!"
print_header "==========================="
echo ""

print_success "Created configurations for:"
echo "  ✅ Shared databases (PostgreSQL, Redis)"
echo "  ✅ Work databases (PostgreSQL, MySQL, MongoDB, Redis)"
echo "  ✅ Personal databases (PostgreSQL, MySQL, MongoDB)"
echo ""

print_success "Management scripts created in: $DATABASES_DIR"
echo "  ./start-shared.sh"
echo "  ./start-work.sh"
echo "  ./start-personal.sh"
echo "  ./stop-all.sh"
echo "  ./status.sh"
echo ""

print_status "Quick Start:"
echo "  cd $DATABASES_DIR"
echo "  ./start-shared.sh        # Start shared databases"
echo "  ./start-work.sh          # Start work databases"
echo "  ./status.sh              # Check status"
echo ""

print_status "Connection details:"
echo "  See: $DATABASES_DIR/README.md"
echo ""

print_status "Next steps:"
echo "  1. Start the databases you need"
echo "  2. Connect using the credentials in README.md"
echo "  3. Configure your applications"
echo ""

print_warning "Remember: These are development databases with default passwords"
print_status "Change passwords for production use!"
