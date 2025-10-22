# Migrate VaultWarden Backup from Plain Text to Encrypted

## Your Situation

You have:
- Existing GitHub repo: `username/VaultWarden-Backup` (private)
- Old plain text JSON backups in the repo
- Want to switch to encrypted backups

## Quick Migration Steps

### Step 1: Clone and Clean Your Existing Repository

```zsh
# Clone your existing repository to ~/work
cd ~/work
gh repo clone username/VaultWarden-Backup vaultwarden-backups
cd vaultwarden-backups

# Check what's currently in there
ls -la

# Create versions directory if it doesn't exist
mkdir -p versions

# SECURITY: Archive old plain text backups locally (just in case)
mkdir -p ~/work/old-plaintext-backups-ARCHIVE
mv *.json ~/work/old-plaintext-backups-ARCHIVE/ 2>/dev/null || true
mv vault*.json ~/work/old-plaintext-backups-ARCHIVE/ 2>/dev/null || true

# List what we archived
ls -la ~/work/old-plaintext-backups-ARCHIVE/

# Update .gitignore
cat > .gitignore << 'EOF'
.env
*.log
.DS_Store
EOF

# Remove old plain text files from git
git rm *.json 2>/dev/null || true
git add .gitignore

# Commit the cleanup
git commit -m "Security: Remove plain text backups, switching to encrypted exports

BREAKING CHANGE: All future backups will be encrypted with a separate password.
Old plain text backups removed from working directory for security.

- Removed all plain text JSON files
- Archived locally at ~/work/old-plaintext-backups-ARCHIVE
- Will use encrypted_json format going forward
"

# Push the cleanup
git push origin main
```

### Step 2: (Optional but HIGHLY Recommended) Purge Plain Text from Git History

Since your plain text backups are in git history, anyone with repo access could still retrieve them. Here's how to completely remove them:

**Option A: Using BFG Repo-Cleaner (Easier, Recommended)**

```zsh
cd ~/backups/vaultwarden-backups

# Install BFG (one-time)
brew install bfg

# Backup your repo first!
cd ~/work
git clone --mirror git@github.com:username/VaultWarden-Backup.git vaultwarden-backup.mirror

# Remove all .json files from history
bfg --delete-files '*.json' vaultwarden-backup.mirror

# Clean up
cd vaultwarden-backup.mirror
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Push the cleaned history (DESTRUCTIVE - rewrites history!)
git push --force

# Clean up mirror
cd ~/work
rm -rf vaultwarden-backup.mirror

# Re-clone the cleaned repo
cd ~/work
rm -rf vaultwarden-backups
gh repo clone username/VaultWarden-Backup vaultwarden-backups
cd vaultwarden-backups
mkdir -p versions
```

**Option B: Manual with git filter-repo (More Control)**

```zsh
cd ~/backups/vaultwarden-backups

# Install git-filter-repo (one-time)
brew install git-filter-repo

# Remove all .json files from entire history
git filter-repo --path-glob '*.json' --invert-paths --force

# Push the cleaned history (DESTRUCTIVE!)
git push origin --force --all
git push origin --force --tags
```

**⚠️ WARNING**: Both options rewrite git history. If anyone else has cloned this repo, they'll need to re-clone it!

### Step 3: Generate Your New Backup Encryption Password

Create a NEW strong password for encrypting your backups:

```zsh
# Generate a random strong password
BACKUP_PASSWORD=$(openssl rand -base64 32)

# Display it (WRITE THIS DOWN IMMEDIATELY!)
echo "Your new backup encryption password:"
echo "$BACKUP_PASSWORD"
echo ""
echo "⚠️  WRITE THIS DOWN NOW!"
echo "Store it in:"
echo "  - Physical safe"
echo "  - Separate password manager (NOT Vaultwarden itself)"
echo "  - Sealed envelope with trusted person"
```

### Step 4: Store Credentials in Keychain

```zsh
# Store your EXISTING Vaultwarden master password
security add-generic-password \
  -a "$USER" \
  -s "vaultwarden-backup-master" \
  -w "$VAULTWARDEN_MASTER_PASSWORD" \
  -U

# Store the NEW backup encryption password (from Step 3)
# Replace PASTE_THE_PASSWORD_HERE with the actual password
security add-generic-password \
  -a "$USER" \
  -s "vaultwarden-backup-encrypt" \
  -w "$VAULTWARDEN_ENCRYPTION_PASSWORD" \
  -U

# Verify they're stored
security find-generic-password -a "$USER" -s "vaultwarden-backup-master" -w
security find-generic-password -a "$USER" -s "vaultwarden-backup-encrypt" -w
```

### Step 5: Create Configuration File

```zsh
cat > ~/.vaultwarden-backup-config << 'EOF'
# Vaultwarden Backup Configuration
# Sensitive credentials are stored in macOS Keychain

# Bitwarden server URL
BW_SERVER="https://pwd.oklabs.uk"

# Bitwarden account email
BW_ACCOUNT="john@personal-org.com"

# Backup directory (using ~/work to avoid iCloud sync)
BACKUP_DIR="$HOME/work/vaultwarden-backups"
VERSIONS_DIR="$BACKUP_DIR/versions"

# Backup retention (days)
RETENTION_DAILY=7
RETENTION_WEEKLY=30
RETENTION_MONTHLY=365

# Telegram notifications (set to 1 to enable)
TELEGRAM_ENABLED=1

# Git repository
GIT_PUSH_ENABLED=1
GIT_REMOTE="origin"
GIT_BRANCH="main"

# Backup file prefix
BACKUP_PREFIX="vault"
EOF
```

### Step 6: Install Backup Script

```zsh
# Create bin directory if needed
mkdir -p ~/bin

# Copy the backup script
cp ~/work/docs/scripts/vaultwarden-backup.zsh ~/bin/
chmod +x ~/bin/vaultwarden-backup.zsh

# Test it!
~/bin/vaultwarden-backup.zsh
```

### Step 7: Set Up LaunchAgent

Follow the main guide from here to set up automated backups:
- See: [vaultwarden-backup-macos.md](vaultwarden-backup-macos.md#7-set-up-automatic-scheduling-with-launchagent)

## Security Checklist

After migration, verify:

- [ ] Old plain text backups removed from working directory
- [ ] Old plain text backups removed from git history (optional but recommended)
- [ ] New backup encryption password created and stored securely
- [ ] New backup encryption password stored in Keychain
- [ ] Master password stored in Keychain
- [ ] First encrypted backup successful
- [ ] Encrypted backup pushed to GitHub
- [ ] Can restore from encrypted backup (test it!)
- [ ] **Consider**: Rotating passwords for any items in the old plain text backups

## Verify Everything Works

```zsh
cd ~/backups/vaultwarden-backups

# Check that only encrypted backups exist now
ls -la versions/

# Verify backup is encrypted (should see "encrypted":true)
head -n 5 versions/vault-current.json

# Check git status
git log --oneline -5

# Test restore (just to verify you have the password)
BACKUP_PASSWORD=$(security find-generic-password -a "$USER" -s "vaultwarden-backup-encrypt" -w)
echo "Backup password retrieved: ${BACKUP_PASSWORD:0:10}..." # Shows first 10 chars
```

## What Happened to Old Backups?

Your old plain text backups are:
1. **Archived locally** at `~/work/old-plaintext-backups-ARCHIVE/`
2. **Removed from working directory**
3. **Removed from latest commit**
4. **Still in git history** (unless you ran Step 2)

### Should You Keep the Archive?

**Keep temporarily (1-2 months)**:
- In case you need to verify migration worked
- In case you need to access historical data
- Then securely delete after confidence period

**Delete the archive after migration**:
```zsh
# After you're confident everything is working
rm -rf ~/work/old-plaintext-backups-ARCHIVE/
```

## Troubleshooting

### "Repository not found"

```zsh
# Verify you have access
gh repo view username/VaultWarden-Backup

# Check SSH key
ssh -T git@github.com
```

### "git rm: pathspec did not match any files"

That's okay! It means there were no .json files to remove. Continue to next step.

### "Password incorrect"

Make sure you're using your Vaultwarden MASTER password to login, not the new backup encryption password.

---

**Last Updated**: October 6, 2025  
**Your Setup**: username/VaultWarden-Backup → Encrypted backups

