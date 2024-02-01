if (( ! $+commands[pipenv] )); then
  return
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `pipenv`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_pipenv" ]]; then
  typeset -g -A _comps
  autoload -Uz _pipenv
  _comps[pipenv]=_pipenv
fi

_PIPENV_COMPLETE=zsh_source pipenv >| "$ZSH_CACHE_DIR/completions/_pipenv" &|

if zstyle -T ':omz:plugins:pipenv' auto-shell; then
  # Automatic pipenv shell activation/deactivation
  _togglePipenvShell() {
    # deactivate shell if Pipfile doesn't exist and not in a subdir
    if [[ "$PIPENV_ACTIVE" == 1 ]]; then
      if [[ "$PWD" != "$pipfile_dir"* ]]; then
        echo "writing "$PWD "to /tmp/omz_pipenv_target_exit_dir"
        # preserve the target dir we are switching to in a tmp file
        echo $PWD > /tmp/omz_pipenv_target_exit_dir
        exit
      fi
    fi

    # activate the shell if Pipfile exists
    if [[ "$PIPENV_ACTIVE" != 1 ]]; then
      if [[ -f "$PWD/Pipfile" ]]; then
        export pipfile_dir="$PWD"
        pipenv shell
        # echo "done with pipenv shell"
        # only switch to the target exit dir if the tmp file exists
        # if the user exits the pipenv shell with exit, then there won't be a
        # tmp file so it won't cd to any dir
        if [[ -f "/tmp/omz_pipenv_target_exit_dir" ]]; then
          echo "reading /tmp/omz_pipenv_target_exit_dir"
          target_dir=$(cat /tmp/omz_pipenv_target_exit_dir)
          echo "cleaning up /tmp/omz_pipenv_target_exit_dir"
          rm /tmp/omz_pipenv_target_exit_dir
          echo "switching to target dir: $target_dir"
          cd $target_dir
          # cleanup temp file
        fi
      fi
    fi
  }
  autoload -U add-zsh-hook
  add-zsh-hook chpwd _togglePipenvShell
  _togglePipenvShell
fi

# Aliases
alias pch="pipenv check"
alias pcl="pipenv clean"
alias pgr="pipenv graph"
alias pi="pipenv install"
alias pidev="pipenv install --dev"
alias pl="pipenv lock"
alias po="pipenv open"
alias prun="pipenv run"
alias psh="pipenv shell"
alias psy="pipenv sync"
alias pu="pipenv uninstall"
alias pupd="pipenv update"
alias pwh="pipenv --where"
alias pvenv="pipenv --venv"
alias ppy="pipenv --py"
