# Node.js & JavaScript Development Environment

Complete Node.js setup with Volta for version management and essential packages for modern JavaScript/TypeScript development.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- Homebrew installed
- Xcode Command Line Tools installed

## 1. Volta (Node.js Version Manager)

Volta is the recommended version manager - it's fast, reliable, and automatically switches Node versions per project.

```bash
# Install Volta
curl https://get.volta.sh | bash

# Reload shell to activate Volta
source ~/.zshrc

# Verify installation
volta --version
```

### Why Volta over NVM?

- ✅ **Faster** - Written in Rust
- ✅ **Automatic** - Switches versions based on `package.json`
- ✅ **Reliable** - No shell hooks needed
- ✅ **Cross-platform** - Works on macOS, Linux, Windows

## 2. Install Node.js

```bash
# Install latest LTS (Long Term Support) version
volta install node@lts

# Install latest stable version
volta install node@latest

# Verify installation
node --version
npm --version

# Example output:
# v20.10.0
# 10.2.3
```

### Install Specific Versions

```bash
# Install specific version for older projects
volta install node@18

# Install specific minor version
volta install node@18.17.0

# List installed versions
volta list node
```

## 3. Essential Global Packages

Install commonly used global packages via Volta:

```bash
# Package managers
volta install yarn pnpm

# ⚠️ IMPORTANT: Reload shell after installing
exec zsh

# TypeScript ecosystem
volta install typescript ts-node
exec zsh

# Development tools
volta install nodemon eslint prettier
exec zsh

# Build tools
volta install webpack webpack-cli vite
exec zsh

# Framework CLIs
volta install @angular/cli @vue/cli create-react-app
exec zsh

# Or install all at once, then reload ONCE
volta install yarn pnpm typescript ts-node nodemon eslint prettier webpack webpack-cli vite @angular/cli @vue/cli create-react-app
exec zsh
```

**Critical:** After EVERY `volta install` command, run `exec zsh` to reload your shell. Otherwise, the command won't be available.

### Package Descriptions

| Package | Purpose |
|---------|---------|
| `yarn` | Alternative package manager (faster than npm) |
| `pnpm` | Efficient package manager (saves disk space) |
| `typescript` | TypeScript compiler |
| `ts-node` | Run TypeScript directly |
| `nodemon` | Auto-restart on file changes |
| `eslint` | JavaScript linter |
| `prettier` | Code formatter |
| `webpack` | Module bundler |
| `vite` | Fast build tool |
| `@angular/cli` | Angular framework CLI |
| `@vue/cli` | Vue.js framework CLI |
| `create-react-app` | React app generator |

## 4. Project-Specific Version Management

Volta automatically manages Node versions per project using `package.json`:

```bash
# Navigate to your project
cd ~/work/projects/personal/my-app

# Pin Node version for this project
volta pin node@18.17.0

# Pin npm version
volta pin npm@9.6.7

# Pin yarn version
volta pin yarn@1.22.19

# This updates package.json with:
# "volta": {
#   "node": "18.17.0",
#   "npm": "9.6.7",
#   "yarn": "1.22.19"
# }
```

### Automatic Version Switching

```bash
# When you cd into a project, Volta automatically switches versions!

cd ~/work/projects/work/legacy-app   # Uses Node 16
node --version  # 16.20.0

cd ~/work/projects/personal/new-app  # Uses Node 20
node --version  # 20.10.0

# No manual switching needed! 🎉
```

## 5. Deno (Alternative JavaScript Runtime)

Deno is a modern alternative to Node.js with built-in TypeScript support.

```bash
# Install Deno
curl -fsSL https://deno.land/install.sh | sh

# Add to PATH
echo 'export DENO_INSTALL="$HOME/.deno"' >> ~/.zshrc
echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> ~/.zshrc

# Reload shell
source ~/.zshrc

# Verify installation
deno --version
```

### Deno vs Node.js

**Use Deno for:**
- ✅ New projects with modern standards
- ✅ TypeScript-first development
- ✅ Secure-by-default applications
- ✅ Simpler dependency management

**Use Node.js for:**
- ✅ Existing projects with npm dependencies
- ✅ Large ecosystem requirements
- ✅ Enterprise/corporate environments
- ✅ Mature tooling needs

## 6. Project Templates

### Basic Node.js Project

```bash
# Create new project
mkdir -p ~/work/projects/personal/my-node-app
cd ~/work/projects/personal/my-node-app

# Initialize with npm
npm init -y

# Pin Node version
volta pin node@20

# Create project structure
mkdir -p src tests

# Create package.json with proper scripts
cat > package.json << 'EOF'
{
  "name": "my-node-app",
  "version": "1.0.0",
  "description": "",
  "main": "src/index.js",
  "type": "module",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest",
    "lint": "eslint src/",
    "format": "prettier --write src/"
  },
  "keywords": [],
  "author": "",
  "license": "MIT",
  "volta": {
    "node": "20.10.0"
  }
}
EOF

# Install dev dependencies
npm install --save-dev nodemon eslint prettier jest

# Create main file
cat > src/index.js << 'EOF'
console.log('Hello from Node.js!');
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
node_modules/
dist/
build/
.env
.env.local
*.log
.DS_Store
EOF
```

### TypeScript Project

```bash
# Create new TypeScript project
mkdir -p ~/work/projects/personal/my-ts-app
cd ~/work/projects/personal/my-ts-app

# Initialize
npm init -y
volta pin node@20

# Install TypeScript
npm install --save-dev typescript @types/node ts-node nodemon

# Create tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "node",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

# Create src directory and main file
mkdir -p src
cat > src/index.ts << 'EOF'
const greeting: string = 'Hello from TypeScript!';
console.log(greeting);
EOF

# Update package.json scripts
npm pkg set scripts.start="node dist/index.js"
npm pkg set scripts.build="tsc"
npm pkg set scripts.dev="nodemon --exec ts-node src/index.ts"

# Build and run
npm run build
npm start
```

### Express API Project

```bash
# Create Express API project
mkdir -p ~/work/projects/personal/my-api
cd ~/work/projects/personal/my-api

# Initialize
npm init -y
volta pin node@20

# Install dependencies
npm install express dotenv
npm install --save-dev nodemon @types/express @types/node

# Create .env
cat > .env << 'EOF'
PORT=3000
NODE_ENV=development
EOF

# Create src/index.js
mkdir -p src
cat > src/index.js << 'EOF'
import express from 'express';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'API is running' });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
EOF

# Update package.json
npm pkg set type="module"
npm pkg set scripts.start="node src/index.js"
npm pkg set scripts.dev="nodemon src/index.js"

# Run development server
npm run dev
```

## 7. Common Commands

```bash
# Check versions
node --version
npm --version
volta list

# Update npm (globally)
volta install npm@latest

# Update all packages in current project
npm update

# Check for outdated packages
npm outdated

# Audit security vulnerabilities
npm audit
npm audit fix

# Clean install (removes node_modules and reinstalls)
rm -rf node_modules package-lock.json
npm install

# Clear npm cache
npm cache clean --force

# Run scripts from package.json
npm run <script-name>
npm start
npm test
npm run build
```

## 8. Package Manager Comparison

| Feature | npm | yarn | pnpm |
|---------|-----|------|------|
| **Speed** | Moderate | Fast | Fastest |
| **Disk Usage** | High | High | Low (symlinks) |
| **Workspaces** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Offline Mode** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Lockfile** | package-lock.json | yarn.lock | pnpm-lock.yaml |
| **Install Command** | `npm install` | `yarn` | `pnpm install` |

### Switching Package Managers

```bash
# npm to yarn
yarn import  # converts package-lock.json to yarn.lock

# yarn to npm
npm install  # reads package.json, creates package-lock.json

# Any to pnpm
pnpm import  # converts existing lockfile
```

## 9. Node.js in JetBrains WebStorm

WebStorm provides the best JavaScript/TypeScript IDE experience:

```bash
# Open project in WebStorm (if installed via JetBrains Toolbox)
webstorm ~/work/projects/personal/my-app
```

**Key WebStorm Features:**
- Intelligent code completion
- Built-in debugger
- Git integration
- npm/yarn script runner
- TypeScript support
- Framework support (React, Vue, Angular)
- Database tools
- Docker integration

## 10. Troubleshooting

### Permission Errors

**Never use `sudo` with npm!**

```bash
# If you get permission errors, use Volta (recommended)
volta install <package>

# Or use npm with --user flag
npm install --global <package>
```

### Volta Not Switching Versions

```bash
# Verify volta is in PATH
which volta

# Reinstall volta hooks
volta setup

# Reload shell
source ~/.zshrc

# Check project has volta config
cat package.json | grep volta
```

### Command Not Found After `volta install`

**Problem:** After running `volta install yarn` (or similar), you get "command not found" error.

**Example:**
```bash
❯ volta install yarn
success: installed and set yarn@4.10.3 as default
   note: cannot find command yarn. Please ensure that /Users/tester/.volta/bin is available on your PATH.

❯ yarn --version
zsh: command not found: yarn
```

**Solution:** Run this command now:

```bash
exec zsh
```

Then verify it works:
```bash
yarn --version
```

**Why this happens:** When Volta installs a new tool (like yarn, pnpm, or any global package), it adds the binary to `~/.volta/bin/`. Your current shell session already has its PATH set, so it doesn't see the newly added binary until you reload the shell or start a new terminal session.

**Always do this:** After EVERY `volta install` command, immediately run `exec zsh`.

### Module Not Found

```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Check if module is in package.json
cat package.json

# Install missing module
npm install <module-name>
```

### ENOSPC Error (File Watchers)

```bash
# Increase file watcher limit (macOS/Linux)
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## 11. Best Practices

### 1. Always Use Version Pinning

```bash
# Pin versions in every project
volta pin node
volta pin npm
```

### 2. Use .nvmrc Alternative

For projects without Volta, create `.nvmrc` or `.node-version`:

```bash
# Create .node-version
echo "20.10.0" > .node-version
```

### 3. Keep Dependencies Updated

```bash
# Check for updates weekly
npm outdated

# Update non-breaking changes
npm update

# Update to latest (including breaking changes)
npm install <package>@latest
```

### 4. Use .gitignore

Always include in `.gitignore`:

```
node_modules/
npm-debug.log
.env
.env.local
dist/
build/
```

### 5. Use Environment Variables

```bash
# Never commit .env files
# Use .env.example as template

cat > .env.example << 'EOF'
PORT=3000
DATABASE_URL=
API_KEY=
EOF
```

## Next Steps

Continue with:
- **[Java Environment](04-java-environment.md)** - Java development setup
- **[Docker & Kubernetes](05-docker-kubernetes.md)** - Containerization
- **[IDEs & Editors](09-ides-editors.md)** - WebStorm configuration

---

**Estimated Time**: 15 minutes  
**Difficulty**: Beginner  
**Last Updated**: October 5, 2025
