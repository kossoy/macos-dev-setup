# macOS Fresh Setup - Restructuring Plan

**Based on analysis of debian-fresh-setup architecture**

## Executive Summary

This document outlines a comprehensive restructuring plan to adopt the proven patterns from the debian-fresh-setup project, creating a more modular, maintainable, and user-friendly macOS development environment setup system.

## Current State Analysis

### What Works Well
- ✅ Context switching system (work/personal)
- ✅ Shell configuration structure (modular zsh configs)
- ✅ Comprehensive documentation
- ✅ Docker testing environment
- ✅ Utility scripts collection
- ✅ Vaultwarden backup system

### What Needs Improvement
- ❌ **Single entry point** - Only bootstrap.sh, no progressive disclosure
- ❌ **Monolithic bootstrap** - All-in-one script vs modular helpers
- ❌ **No one-liner installer** - Can't install with single command
- ❌ **Limited installation modes** - Could benefit from more granular control
- ❌ **Setup helper numbering** - Inconsistent (01-04 exist but not comprehensive)
- ❌ **Optional tools integration** - Python/Node.js/databases not modular
- ❌ **Config deployment pattern** - Not clearly separated from source

---

## Proposed Architecture

### Three-Tier Entry Point System

```
┌─────────────────────────────────────────────────────────────┐
│ TIER 1: One-Liner (install.sh)                             │
│ Target: New users wanting quick setup                       │
│ Command: bash <(curl -fsSL https://raw.../install.sh)     │
├─────────────────────────────────────────────────────────────┤
│ • Validates macOS compatibility                             │
│ • Installs git if missing (Xcode Command Line Tools)       │
│ • Clones repository to ~/macos-fresh-setup                 │
│ • Automatically runs simple-bootstrap.sh                    │
│ • Offers to run full bootstrap.sh                          │
└─────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────┐
│ TIER 2: Simple Bootstrap (simple-bootstrap.sh)             │
│ Target: Users wanting automated, non-interactive setup      │
│ Features: Unattended installation                           │
├─────────────────────────────────────────────────────────────┤
│ • Non-interactive (uses sensible defaults)                  │
│ • Installs Homebrew + essential packages                    │
│ • Installs Oh My Zsh + plugins + Powerlevel10k            │
│ • Deploys shell configuration                               │
│ • Creates work directory structure                          │
│ • Installs utility scripts                                  │
│ • No Git/SSH configuration (deferred)                       │
└─────────────────────────────────────────────────────────────┘
         ↓ (Optional)
┌─────────────────────────────────────────────────────────────┐
│ TIER 3: Full Bootstrap (bootstrap.sh)                      │
│ Target: Users wanting customized interactive setup          │
│ Features: Interactive prompts, full customization           │
├─────────────────────────────────────────────────────────────┤
│ • Interactive user information collection                   │
│ • Git/SSH/GitHub CLI configuration                         │
│ • Context switching setup (work/personal)                   │
│ • Browser preferences configuration                         │
│ • VPN automation setup                                      │
│ • Installation mode selection (Full/Minimal/Custom)         │
└─────────────────────────────────────────────────────────────┘
         ↓ (Optional - Specialized)
┌─────────────────────────────────────────────────────────────┐
│ TIER 4: Optional Environment Helpers                        │
│ Target: Users needing specific development environments     │
├─────────────────────────────────────────────────────────────┤
│ • ./setup-helpers/05-install-python.sh                     │
│ • ./setup-helpers/06-install-nodejs.sh                     │
│ • ./setup-helpers/07-setup-databases.sh                    │
│ • ./setup-helpers/08-install-java.sh                       │
│ • ./setup-helpers/09-install-ai-ml-tools.sh               │
└─────────────────────────────────────────────────────────────┘
```

---

## Detailed File Structure Changes

### New Entry Point
```
install.sh                           [NEW]
  Purpose: Web-accessible one-liner entry point
  Responsibilities:
    - Validate macOS + version check
    - Install Xcode Command Line Tools if missing
    - Clone repository
    - Execute simple-bootstrap.sh
    - Offer full bootstrap.sh
```

### Refactored Simple Bootstrap
```
simple-bootstrap.sh                  [REFACTOR]
  Purpose: Non-interactive automated setup
  Changes from current:
    - Remove ALL interactive prompts
    - Use sensible defaults
    - Skip Git/SSH configuration (deferred to bootstrap.sh)
    - Focus on: Homebrew, packages, Oh My Zsh, shell config, directories
  Steps:
    1. System compatibility check
    2. Homebrew installation
    3. Essential package installation
    4. Oh My Zsh installation
    5. Shell configuration deployment
    6. Work directory creation
    7. Utility scripts installation
```

### Enhanced Full Bootstrap
```
bootstrap.sh                         [REFACTOR]
  Purpose: Interactive advanced setup
  Changes from current:
    - Clearer separation of phases
    - Better progress indication
    - Modular helper invocation
    - Post-installation summary
  Sections:
    1. System verification
    2. User information collection
    3. Installation mode selection
    4. Component customization
    5. Installation plan display
    6. Helper execution
    7. Post-install instructions
```

### Modular Setup Helpers (Idempotent)

```
setup-helpers/
├── 01-install-homebrew.sh           [EXISTS - ENHANCE]
│   └── Add idempotency checks, better error handling
│
├── 02-install-oh-my-zsh.sh          [EXISTS - ENHANCE]
│   └── Add check for existing installation
│
├── 03-setup-shell.sh                [EXISTS - ENHANCE]
│   └── Better config deployment, backup existing configs
│
├── 03-git-and-ssh-setup.sh          [NEW - INTERACTIVE]
│   Purpose: Git config, SSH key generation, GitHub CLI auth
│   Note: Same prefix (03-) indicates parallel track to 03-setup-shell
│
├── 04-install-docker.sh             [NEW]
│   Purpose: Docker Desktop installation and configuration
│   Responsibilities:
│     - Check for existing Docker
│     - Install Docker Desktop via Homebrew cask
│     - Wait for Docker daemon
│     - Verify installation
│
├── 05-install-python.sh             [NEW/ADAPT from setup-python-ai.sh]
│   Purpose: Python environment (pyenv + Python versions)
│   Modes:
│     - Minimal: pyenv only
│     - Standard: pyenv + Python 3.11
│     - Full: pyenv + multiple Python versions
│     - AI/ML: Standard + AI packages (pip, jupyter, pytorch, etc.)
│
├── 06-install-nodejs.sh             [NEW]
│   Purpose: Node.js environment (Volta + Node.js)
│   Modes:
│     - Minimal: Volta only
│     - Standard: Volta + latest Node LTS
│     - Full: Volta + Node LTS + global packages (npm, yarn, pnpm)
│
├── 07-setup-databases.sh            [NEW]
│   Purpose: Docker-based database containers
│   Features:
│     - Context-aware database setup
│     - PostgreSQL, MySQL, MongoDB, Redis
│     - Docker Compose configurations
│     - Port isolation (work vs personal)
│
├── 08-restore-sensitive.sh          [EXISTS as 04-restore-sensitive.sh - RENAME]
│   Purpose: Restore API keys, SSH keys, credentials
│
└── 09-install-ai-ml-tools.sh        [NEW]
    Purpose: AI/ML development environment
    Features:
      - Ollama (local LLM)
      - MLflow
      - TensorFlow / PyTorch
      - Jupyter extensions
```

### Configuration Structure (Enhanced)

```
config/zsh/
├── zshrc                            [EXISTS - MINOR UPDATES]
│   └── Main config that sources all modules
│
├── config/                          [EXISTS - REORGANIZE]
│   ├── aliases.zsh                  [EXISTS - KEEP]
│   ├── functions.zsh                [EXISTS - ENHANCE]
│   │   └── Add more robust context switching
│   ├── paths.zsh                    [EXISTS - KEEP]
│   ├── tools.zsh                    [EXISTS - KEEP]
│   ├── python.zsh                   [EXISTS - KEEP]
│   ├── context.zsh                  [NEW - EXTRACT from functions.zsh]
│   │   └── Dedicated context switching module
│   └── custom.zsh                   [EXISTS - KEEP]
│
├── contexts/
│   ├── current.zsh                  [EXISTS - KEEP]
│   │   └── Generated file (gitignored)
│   └── current.zsh.template         [EXISTS - KEEP]
│
└── private/
    ├── api-keys.zsh                 [EXISTS - KEEP]
    │   └── User secrets (gitignored)
    └── api-keys.zsh.template        [EXISTS - KEEP]
```

---

## Implementation Plan

### Phase 1: Foundation (Week 1)
1. **Create install.sh** (one-liner entry point)
   - macOS validation
   - Xcode Command Line Tools check/install
   - Repository cloning
   - Simple bootstrap invocation

2. **Refactor simple-bootstrap.sh**
   - Remove all interactive prompts
   - Implement default context names
   - Focus on essential setup only
   - Defer Git/SSH to full bootstrap

3. **Enhance existing helpers (01-03)**
   - Add idempotency checks
   - Improve error handling
   - Add progress indicators
   - Test in isolation

### Phase 2: Modular Helpers (Week 2)
4. **Create 03-git-and-ssh-setup.sh**
   - Interactive Git configuration
   - SSH key generation
   - GitHub CLI authentication
   - Context-specific key setup

5. **Create 04-install-docker.sh**
   - Docker Desktop installation
   - Configuration
   - Daemon verification

6. **Create 05-install-python.sh**
   - Adapt from setup-python-ai.sh
   - Add installation modes
   - Make fully idempotent

7. **Create 06-install-nodejs.sh**
   - Volta installation
   - Node.js setup
   - Global package management

### Phase 3: Advanced Features (Week 3)
8. **Create 07-setup-databases.sh**
   - Docker Compose configurations
   - Context-aware database setup
   - Port management

9. **Create 09-install-ai-ml-tools.sh**
   - Ollama installation
   - ML framework setup
   - Jupyter configuration

10. **Rename 04-restore-sensitive.sh → 08-restore-sensitive.sh**
    - Update all references
    - Enhance with better prompts

### Phase 4: Enhancement & Testing (Week 4)
11. **Refactor bootstrap.sh**
    - Cleaner structure
    - Better helper orchestration
    - Improved post-install instructions

12. **Extract context.zsh module**
    - Separate from functions.zsh
    - Add better context persistence
    - Enhance switching logic

13. **Update Docker test environment**
    - Test all new helpers
    - Validate idempotency
    - Document test results

14. **Documentation updates**
    - Update CLAUDE.md
    - Create setup guide sequence
    - Update README.md

---

## Key Changes Summary

### Entry Points
| Old | New | Change |
|-----|-----|--------|
| bootstrap.sh only | install.sh | Added one-liner entry point |
| - | simple-bootstrap.sh | Enhanced to be non-interactive |
| bootstrap.sh | bootstrap.sh | Refactored for better structure |

### Setup Helpers
| Old | New | Change |
|-----|-----|--------|
| 01-install-homebrew.sh | 01-install-homebrew.sh | Enhanced with idempotency |
| 02-install-oh-my-zsh.sh | 02-install-oh-my-zsh.sh | Enhanced with checks |
| 03-setup-shell.sh | 03-setup-shell.sh | Enhanced deployment |
| - | 03-git-and-ssh-setup.sh | **NEW** - Interactive Git/SSH |
| - | 04-install-docker.sh | **NEW** - Docker Desktop |
| setup-python-ai.sh | 05-install-python.sh | **REFACTOR** - Modular modes |
| - | 06-install-nodejs.sh | **NEW** - Volta + Node |
| - | 07-setup-databases.sh | **NEW** - Docker databases |
| 04-restore-sensitive.sh | 08-restore-sensitive.sh | **RENAME** - Sequential order |
| - | 09-install-ai-ml-tools.sh | **NEW** - AI/ML environment |

### Configuration Structure
| Old | New | Change |
|-----|-----|--------|
| config/zsh/config/functions.zsh | + context.zsh | Context switching extracted |
| - | config/zsh/config/context.zsh | **NEW** - Dedicated module |

---

## Testing Strategy

### Unit Testing (Per Helper)
Each helper script should be testable in isolation:
```bash
# Test individual helper
./setup-helpers/01-install-homebrew.sh

# Test idempotency (run twice)
./setup-helpers/01-install-homebrew.sh
./setup-helpers/01-install-homebrew.sh  # Should skip already installed
```

### Integration Testing (Docker)
```bash
# Test complete flow in Docker
cd docker
docker compose up --build
docker compose run test-environment /bin/zsh -c "./install.sh"

# Test simple bootstrap
docker compose run test-environment /bin/zsh -c "./simple-bootstrap.sh"

# Test full bootstrap (non-interactive mode)
docker compose run test-environment /bin/zsh -c "./bootstrap.sh --test"
```

### Manual Testing (macOS)
- Test on clean user account
- Test on existing system (idempotency)
- Test each installation mode (Full/Minimal/Custom)
- Test context switching
- Test optional helpers

---

## Migration Guide (For Existing Users)

Users who already installed the current version:

### Option 1: Fresh Install (Recommended)
```bash
# Backup current configuration
cp -r ~/.config/zsh ~/.config/zsh.backup
cp ~/.zshrc ~/.zshrc.backup

# Pull latest changes
cd ~/macos-fresh-setup  # or wherever you cloned it
git pull origin main

# Re-run bootstrap
./bootstrap.sh
```

### Option 2: Partial Update
```bash
# Update shell configuration only
cd ~/macos-fresh-setup
git pull origin main
./setup-helpers/03-setup-shell.sh

# Install optional tools as needed
./setup-helpers/05-install-python.sh
./setup-helpers/06-install-nodejs.sh
```

---

## Benefits of This Restructuring

### For New Users
1. ✅ **One-liner installation** - Single command to get started
2. ✅ **Progressive disclosure** - Start simple, add complexity as needed
3. ✅ **Clear entry points** - Know which script to run for what purpose
4. ✅ **Better onboarding** - Guided experience from simple to advanced

### For Existing Users
1. ✅ **Modular updates** - Update individual components without full reinstall
2. ✅ **Idempotent scripts** - Safe to re-run without breaking existing setup
3. ✅ **Optional tools** - Install only what you need
4. ✅ **Backward compatible** - Existing configs continue to work

### For Maintainers
1. ✅ **Modular architecture** - Easier to maintain and test individual components
2. ✅ **Clear separation** - Each script has single responsibility
3. ✅ **Consistent patterns** - Same structure across all helpers
4. ✅ **Better testing** - Can test each module independently
5. ✅ **Documentation alignment** - Structure matches documentation

### For Code Quality
1. ✅ **DRY principle** - No duplication between simple and full bootstrap
2. ✅ **Idempotency** - All scripts safe to run multiple times
3. ✅ **Error handling** - Consistent error handling patterns
4. ✅ **Graceful degradation** - Optional components fail gracefully

---

## Rollout Plan

### Milestone 1: Core Structure (Week 1)
- [ ] Create install.sh
- [ ] Refactor simple-bootstrap.sh
- [ ] Enhance helpers 01-03
- [ ] Test basic flow

### Milestone 2: Modular Helpers (Week 2)
- [ ] Create helpers 03-git through 06-nodejs
- [ ] Test each in isolation
- [ ] Integration testing

### Milestone 3: Advanced Features (Week 3)
- [ ] Create helper 07-databases
- [ ] Create helper 09-ai-ml-tools
- [ ] Rename helper 04 → 08
- [ ] Extract context.zsh

### Milestone 4: Polish & Launch (Week 4)
- [ ] Refactor bootstrap.sh
- [ ] Update all documentation
- [ ] Comprehensive testing
- [ ] Migration guide
- [ ] Release notes

---

## Success Metrics

### Quantitative
- [ ] All helpers are idempotent (can run 3+ times without errors)
- [ ] Install.sh completes in < 15 minutes
- [ ] Simple bootstrap completes in < 10 minutes
- [ ] Docker tests pass 100%
- [ ] Zero interactive prompts in simple-bootstrap.sh

### Qualitative
- [ ] Clear entry point for new users
- [ ] Easy to understand which script to run
- [ ] Modular helpers can be run independently
- [ ] Documentation matches implementation
- [ ] Migration path for existing users

---

## Risks & Mitigation

### Risk: Breaking Existing User Setups
**Mitigation**:
- Maintain backward compatibility
- Test with existing configs
- Provide migration guide
- Keep old bootstrap.sh working

### Risk: Complexity Creep
**Mitigation**:
- Keep simple-bootstrap truly simple
- Don't add interactive prompts to simple bootstrap
- Optional tools stay optional

### Risk: Testing Overhead
**Mitigation**:
- Docker-based automated testing
- Clear testing checklist
- Test each helper independently

---

## Open Questions

1. Should we maintain both old and new bootstrap flows during transition?
   - **Recommendation**: Yes, for one release cycle

2. How to handle users who cloned via git vs curl one-liner?
   - **Recommendation**: Both paths should work identically

3. Should install.sh require sudo for Xcode Command Line Tools?
   - **Recommendation**: Yes, prompt user when needed

4. Keep setup-python-ai.sh or fully replace with 05-install-python.sh?
   - **Recommendation**: Replace, add AI/ML mode to 05-

---

## Next Steps

1. **Review this plan** with stakeholders
2. **Create feature branch** for restructuring
3. **Implement Phase 1** (Foundation)
4. **Test extensively** in Docker and macOS VM
5. **Iterate based on feedback**
6. **Merge to main** when stable
7. **Update documentation**
8. **Announce changes** to users

---

**Document Version**: 1.0
**Created**: 2025-10-28
**Status**: Draft for Review
