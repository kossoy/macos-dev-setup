# Zsh Configuration Organization

This directory contains an organized zsh configuration structure for development environment management.

## Structure

```
~/.config/zsh/
├── zshrc                 # Main configuration file
├── paths/
│   └── paths.zsh         # Environment paths and variables
├── aliases/
│   └── aliases.zsh       # Command aliases
├── functions/
│   └── functions.zsh     # Custom functions
└── contexts/
    └── current.zsh       # Current context configuration (auto-generated)
```

## Key Features

### Context Switching
- `work` - Switch to Company work context (Git: John Doe <john.doe@company.com>)
- `personal` - Switch to PersonalOrg Organization personal context (Git: John Doe <john@personal-org.com>)
- `show-context` - Display current context information

### Project Management
- `new-work <name>` - Create new Company work project
- `new-personal <name>` - Create new PersonalOrg Organization personal project

### Database Management
- `start-work-db` - Start Company work databases
- `start-personal-db` - Start PersonalOrg Organization personal databases
- `start-db` - Start all development databases
- `stop-work-db` - Stop Company work databases
- `stop-personal-db` - Stop PersonalOrg Organization personal databases
- `stop-db` - Stop all development databases
- `clean-databases` - Clean all databases and volumes

### Navigation
- `cdwork` - Navigate to work projects
- `cdpersonal` - Navigate to personal projects
- `cdconfig` - Navigate to configuration directory
- `cdscripts` - Navigate to scripts directory
- `cdtools` - Navigate to tools directory
- `cddocs` - Navigate to documentation directory

## Environment Variables

### Global Paths
- `WORK_ROOT` - Base work directory (~/work)
- `PROJECTS_ROOT` - Projects directory (~/work/projects)
- `CONFIGS_ROOT` - Configurations directory (~/work/configs)
- `SCRIPTS_ROOT` - Scripts directory (~/work/scripts)
- `TOOLS_ROOT` - Tools directory (~/work/tools)
- `DOCS_ROOT` - Documentation directory (~/work/docs)

### Context-Specific (set by context functions)
- `WORK_CONTEXT` - Current work context (COMPANY_ORG or PERSONAL_ORG)
- `PROJECT_ROOT` - Current project root directory
- `CONFIG_ROOT` - Current configuration root directory

## Usage Examples

```bash
# Switch to work context (sets Git to john.doe@company.com)
work

# Create a new work project
new-work my-new-project

# Start work databases
start-work-db

# Switch to personal context (sets Git to john@personal-org.com)
personal

# Create a new personal project
new-personal my-personal-project

# Check current context
show-context

# Navigate to work projects
cdwork

# Start all databases
start-db
```

## Benefits

1. **Organized Structure**: Clear separation of concerns with dedicated files for paths, aliases, and functions
2. **Context Switching**: Easy switching between work and personal development contexts with automatic Git configuration
3. **Persistent Configuration**: Context settings persist across shell sessions
4. **Modular Design**: Easy to extend with additional functions and configurations
5. **Version Control Friendly**: Configuration files can be easily tracked in version control
