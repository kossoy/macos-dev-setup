#!/bin/zsh
# =============================================================================
# ALIASES CONFIGURATION
# =============================================================================
# Organized aliases with categories and improved functionality
# =============================================================================

# =============================================================================
# SYSTEM ALIASES
# =============================================================================

# Enhanced ls commands
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -laht'  # Sort by modification time

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias dir='open -a Forklift'
alias downloads='open -a Forklift ~/Downloads'

# =============================================================================
# NETWORK ALIASES
# =============================================================================

# IP address utilities
alias myip='curl -s ipinfo.io/ip'
alias myipx='curl -s ipinfo.io | jq'
alias myip4='curl -4 -s ipinfo.io/ip'
alias myip6='curl -6 -s ipinfo.io/ip'

# Network diagnostics
alias ping='ping -c 5'
alias fastping='ping -c 100 -s.2'

# =============================================================================
# DEVELOPMENT ALIASES
# =============================================================================

# Laravel/Sail
alias sail='bash vendor/bin/sail'
alias laravel='$HOME/.composer/vendor/bin/laravel'

# File operations
alias files='find . -type f | wc -l'
alias dirs='find . -type d | wc -l'

# =============================================================================
# KUBERNETES ALIASES
# =============================================================================

# kubectl shortcuts
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kctx='kubectl config current-context'
alias kns='kubectl config set-context --current --namespace'

# kubectl with verbose logging
alias kgetc='kubectl -v=8 config get-contexts'
alias kpod='kubectl -v=8 get pods'

# =============================================================================
# SYSTEM UTILITIES
# =============================================================================

# Process management
# psme and psmes are now functions (see functions.zsh)

# System information
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias top='htop'  # If htop is installed

# =============================================================================
# MACOS SPECIFIC ALIASES
# =============================================================================

# macOS utilities
alias ds_wipe='find . -name ".DS_Store" -type f -delete'
alias no_notifications='killall NotificationCenter'
alias show_hidden='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hide_hidden='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'

# LaunchAgent management
alias la-status='$HOME/work/projects/personal/common/macos-fresh-setup/scripts/launchagent-status.sh'

# =============================================================================
# DOCKER ALIASES
# =============================================================================

alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'

# =============================================================================
# GIT ALIASES (Enhanced)
# =============================================================================

alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gf='git fetch'
alias gl='git log --oneline'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias gst='git stash'
alias gstp='git stash pop'

# =============================================================================
# CUSTOM ALIASES
# =============================================================================

# DNS testing
alias dnstest='bash $HOME/work/home/playground/_net/dnsperftest/dnstest.sh | sort -k 36 -n'

# Disk usage analyzer
if [[ -f "$HOME/macos-dev-setup/scripts/wdu.sh" ]]; then
    alias wdu="bash $HOME/macos-dev-setup/scripts/wdu.sh"
    alias wdu-quick="bash $HOME/macos-dev-setup/scripts/wdu-quick.sh"
elif [[ -f "$HOME/work/bin/ai_wdu.sh" ]]; then
    alias wdu="bash $HOME/work/bin/ai_wdu.sh 2> /dev/null"
fi

alias vw-monitor="$HOME/bin/vaultwarden-backup-monitor.zsh"
alias vw-preview="$HOME/bin/vaultwarden-preview.zsh"

# =============================================================================
# NAS MOUNT ALIASES
# =============================================================================

# NAS volume mounting (only set if scripts exist)
if [[ -f "$HOME/work/scripts/mount-nas-volumes.sh" ]]; then
    alias nas-mount='$HOME/work/scripts/mount-nas-volumes.sh'
    alias nas-mount-retry='$HOME/work/scripts/mount-nas-volumes-with-retry.sh'
fi

# NAS mount management (only set if script exists)
if [[ -f "$HOME/work/scripts/nas-mount-control.sh" ]]; then
    alias nas-status='$HOME/work/scripts/nas-mount-control.sh status'
    alias nas-enable='$HOME/work/scripts/nas-mount-control.sh enable'
    alias nas-disable='$HOME/work/scripts/nas-mount-control.sh disable'
    alias nas-restart='$HOME/work/scripts/nas-mount-control.sh restart'
    alias nas-logs='$HOME/work/scripts/nas-mount-control.sh logs'
    alias nas-test='$HOME/work/scripts/nas-mount-control.sh test'
fi

# NAS logs viewing (only if logs exist)
if [[ -f "$HOME/Library/Logs/mount-nas-volumes.log" ]]; then
    alias nas-tail='tail -f $HOME/Library/Logs/mount-nas-volumes.log'
fi

# =============================================================================
# SAFETY ALIASES
# =============================================================================

# Make commands safer
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# =============================================================================
# UTILITY ALIASES
# =============================================================================

# Quick edits
alias zshconfig='$EDITOR ~/.zshrc'
alias zshreload='source ~/.zshrc'
alias ohmyzsh='$EDITOR ~/.oh-my-zsh'

# Weather (if curl is available)
alias weather='curl -s wttr.in'

# =============================================================================
# CONDITIONAL ALIASES
# =============================================================================

# Only set aliases if the commands exist
if command -v jq >/dev/null 2>&1; then
    alias json='jq .'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
    # Remove existing ll alias that might be set by Oh My Zsh
    unalias ll 2>/dev/null || true
    alias ll='eza -la'
    alias la='eza -a'
fi
# Vaultwarden Backup Tools
alias vw-backup="$HOME/bin/vaultwarden-backup.zsh"
alias vw-monitor="$HOME/bin/vaultwarden-backup-monitor.zsh"
alias vw-preview="$HOME/bin/vaultwarden-preview.zsh"
