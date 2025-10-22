#!/bin/zsh
# Python Development Environment Configuration

# Pyenv initialization
if command -v pyenv >/dev/null 2>&1; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# Python virtual environment helpers
alias venv-create='python -m venv'
alias venv-activate='source venv/bin/activate'
alias venv-ai='source ~/.venvs/ai/bin/activate'

# Quick access to common AI venv
alias aienv='source ~/.venvs/ai/bin/activate'

# Python aliases
alias py='python'
alias py3='python3'
alias ipy='ipython'
alias jl='jupyter lab'
alias jn='jupyter notebook'

# Pip helpers
alias pip-upgrade='pip install --upgrade pip'
alias pip-outdated='pip list --outdated'
alias pip-freeze='pip freeze > requirements.txt'

# Virtual environment detection in prompt (already handled by virtualenv plugin)
# Auto-activate venv if in project with venv/ directory
autoload_python_venv() {
    if [[ -d "./venv" && -z "$VIRTUAL_ENV" ]]; then
        source ./venv/bin/activate
    fi
}

# Add to chpwd hook for auto-activation
autoload -U add-zsh-hook
add-zsh-hook chpwd autoload_python_venv
