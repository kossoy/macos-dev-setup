#!/bin/zsh
# Python Development Environment Configuration

# uv - fast Python package installer and resolver
# No initialization needed for uv - it's just a binary in PATH

# Python virtual environment helpers
alias venv-create='uv venv'
alias venv-activate='source .venv/bin/activate'
alias venv-ai='source ~/.venvs/ai/bin/activate'

# Quick access to common AI venv
alias aienv='source ~/.venvs/ai/bin/activate'

# Python aliases
alias py='python'
alias py3='python3'
alias ipy='ipython'
alias jl='jupyter lab'
alias jn='jupyter notebook'

# uv helpers (replacing pip)
alias uv-sync='uv pip sync requirements.txt'
alias uv-compile='uv pip compile requirements.in -o requirements.txt'
alias uv-outdated='uv pip list --outdated'
alias uv-freeze='uv pip freeze > requirements.txt'

# Backwards compatibility - use uv instead of pip where possible
alias pip-upgrade='uv pip install --upgrade pip'
alias pip-outdated='uv pip list --outdated'
alias pip-freeze='uv pip freeze > requirements.txt'

# Virtual environment detection in prompt (already handled by virtualenv plugin)
# Auto-activate venv if in project with .venv/ directory
autoload_python_venv() {
    if [[ -d "./.venv" && -z "$VIRTUAL_ENV" ]]; then
        source ./.venv/bin/activate
    elif [[ -d "./venv" && -z "$VIRTUAL_ENV" ]]; then
        source ./venv/bin/activate
    fi
}

# Add to chpwd hook for auto-activation
autoload -U add-zsh-hook
add-zsh-hook chpwd autoload_python_venv
