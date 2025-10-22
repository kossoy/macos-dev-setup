# DataGrip Setup Guide
## Context-Aware Database Connections

This guide helps you set up DataGrip to work with your context-aware database architecture.

---

## Quick Setup

### 1. Launch DataGrip
- Open from JetBrains Toolbox or Applications
- If not installed, install via JetBrains Toolbox (included in All-Products subscription)

### 2. Create Connection Groups

Create three folders to organize your databases by context:

```
📁 Shared Databases
📁 Company Work
📁 PersonalOrg Personal
```

---

## Database Connections

### 📁 Shared Databases (General Development)

#### PostgreSQL - Shared
- **Host:** localhost
- **Port:** 5434
- **Database:** shared_dev
- **User:** shared_dev
- **Password:** shared_dev_123
- **Driver:** PostgreSQL (auto-download if needed)

#### MySQL - Shared
- **Host:** localhost
- **Port:** 3307
- **Database:** shared_dev
- **User:** shared_dev
- **Password:** shared_dev_123
- **Driver:** MySQL (auto-download if needed)

#### MongoDB - Shared
- **Host:** localhost
- **Port:** 27019
- **Authentication Database:** admin
- **User:** admin
- **Password:** admin123
- **Driver:** MongoDB (auto-download if needed)

#### Redis - Shared
- **Host:** localhost
- **Port:** 6381
- **Driver:** Redis (auto-download if needed)

---

### 📁 Company Work Context

#### PostgreSQL - Company
- **Host:** localhost
- **Port:** 5432 (standard port)
- **Database:** company_dev
- **User:** company_dev
- **Password:** company_dev_123
- **Driver:** PostgreSQL

#### Redis - Company
- **Host:** localhost
- **Port:** 6379 (standard port)
- **Driver:** Redis

---

### 📁 PersonalOrg Personal Context

#### PostgreSQL - PersonalOrg
- **Host:** localhost
- **Port:** 5433
- **Database:** personal-org_dev
- **User:** personal-org_dev
- **Password:** personal-org_dev_123
- **Driver:** PostgreSQL

#### MongoDB - PersonalOrg
- **Host:** localhost
- **Port:** 27018
- **Authentication Database:** admin
- **User:** admin
- **Password:** admin123
- **Driver:** MongoDB

#### Redis - PersonalOrg
- **Host:** localhost
- **Port:** 6380
- **Driver:** Redis

---

## Step-by-Step Connection Setup

### Adding a PostgreSQL Connection

1. Click **+** (New) → **Data Source** → **PostgreSQL**
2. Fill in the connection details (see above)
3. Click **Test Connection** (DataGrip will download drivers if needed)
4. If successful, click **OK**
5. Right-click the connection → **Move to** → Select appropriate folder

### Adding a MySQL Connection

1. Click **+** (New) → **Data Source** → **MySQL**
2. Fill in the connection details
3. Click **Test Connection**
4. Click **OK**

### Adding a MongoDB Connection

1. Click **+** (New) → **Data Source** → **MongoDB**
2. Fill in the connection details
3. **Important:** Set Authentication Database to `admin`
4. Click **Test Connection**
5. Click **OK**

### Adding a Redis Connection

1. Click **+** (New) → **Data Source** → **Redis**
2. Enter host and port
3. Click **Test Connection**
4. Click **OK**

---

## DataGrip Features to Use

### 1. Query Console
- Right-click database → **New** → **Query Console**
- Write and execute SQL queries
- Use `Ctrl+Enter` (Mac: `Cmd+Enter`) to execute

### 2. Schema Navigation
- Browse tables, views, procedures
- Double-click to view data
- Right-click for context actions

### 3. Data Editor
- Edit data directly in table view
- Use filters and sorting
- Export data in multiple formats

### 4. Query History
- View all executed queries
- Re-run previous queries
- Organize favorites

### 5. Database Comparison
- Compare schemas between databases
- Generate migration scripts
- Sync database structures

### 6. SSH Tunneling (for remote databases)
- Configure SSH tunnel in connection settings
- Useful for production database access

---

## Sharing Connections Across JetBrains IDEs

All JetBrains IDEs (IntelliJ IDEA, PyCharm, WebStorm) include database tools:

1. **Enable Settings Sync:**
   - File → Settings → Settings Sync
   - Enable sync for Database settings

2. **Access Database Tool Window:**
   - View → Tool Windows → Database
   - All DataGrip connections appear here

3. **Use in Your IDE:**
   - Write SQL in your code editor
   - Execute directly from IDE
   - Auto-completion for database objects

---

## Quick Commands

### Start Databases Before Connecting
```bash
# Start shared databases
cd ~/work/databases && docker compose up -d

# Or use context-aware commands
start-shared-db      # Shared databases only
start-work-db        # Company work databases
start-personal-db    # PersonalOrg personal databases
start-db             # All databases (shared + context)
```

### Check Database Status
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Connect from Terminal (for quick checks)
```bash
# PostgreSQL Shared
docker exec postgres-shared-dev psql -U shared_dev -d shared_dev

# MySQL Shared
docker exec mysql-shared-dev mysql -u shared_dev -pshared_dev_123

# MongoDB Shared
docker exec mongodb-shared-dev mongosh

# Redis Shared
docker exec redis-shared-dev redis-cli
```

---

## Troubleshooting

### Connection Refused
- Ensure Docker containers are running: `docker ps`
- Start databases: `start-shared-db`
- Check port availability: `lsof -i :5434`

### Driver Download Failed
- Go to File → Settings → Database → Drivers
- Select driver → Download/Update

### Authentication Failed
- Verify credentials match docker-compose.yml
- Check environment files in `~/work/databases/.env.shared`

### Can't See Database
- Refresh connection (right-click → Refresh)
- Check database exists: `docker exec <container> psql -U <user> -l`

---

## Best Practices

1. **Use Folders:** Organize connections by context (Shared, Work, Personal)
2. **Color Code:** Assign colors to connections (right-click → Properties → Color)
3. **Set Defaults:** Mark frequently used databases as default
4. **Enable Auto-Sync:** Sync settings across all JetBrains IDEs
5. **Use Query Console:** Keep separate consoles for different tasks
6. **Save Queries:** Save frequently used queries as favorites
7. **Export Connections:** Backup connection settings regularly

---

## Advanced Features

### Database Diagrams
- Right-click schema → Diagrams → Show Visualization
- View table relationships
- Export as image

### SQL Formatting
- Format SQL: `Ctrl+Alt+L` (Mac: `Cmd+Option+L`)
- Customize formatting: Settings → Editor → Code Style → SQL

### Data Import/Export
- Right-click table → Import/Export Data
- Support for CSV, JSON, SQL, Excel
- Batch operations available

### Version Control
- Track database schema changes
- Generate migration scripts
- Compare with production

---

## Connection String Reference

For use in application configuration files:

```bash
# PostgreSQL Shared
postgresql://shared_dev:shared_dev_123@localhost:5434/shared_dev

# MySQL Shared
mysql://shared_dev:shared_dev_123@localhost:3307/shared_dev

# MongoDB Shared
mongodb://admin:admin123@localhost:27019/shared_dev?authSource=admin

# Redis Shared
redis://localhost:6381

# PostgreSQL Company (Work)
postgresql://company_dev:company_dev_123@localhost:5432/company_dev

# PostgreSQL PersonalOrg (Personal)
postgresql://personal-org_dev:personal-org_dev_123@localhost:5433/personal-org_dev
```

---

## Resources

- **DataGrip Documentation:** https://www.jetbrains.com/datagrip/documentation/
- **Keyboard Shortcuts:** Help → Keymap Reference
- **Video Tutorials:** https://www.jetbrains.com/datagrip/learn/
- **Database Tool Window (in IDEs):** https://www.jetbrains.com/help/idea/database-tool-window.html

---

**Pro Tip:** Use DataGrip's built-in HTTP client to test REST APIs that interact with your databases!

---

*Last Updated: October 5, 2025*
