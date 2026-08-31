# Portable aliases
alias l='ls -lah'
alias la='ls -lAh'
alias lsa='ls -lah'
alias ls='ls -G'
alias tn='tmux new -s'
alias which-command=whence

if command -v eza >/dev/null 2>&1; then
  alias ll='eza --all --group --header --group-directories-first --long --icons --tree --level 1'
else
  alias ll='ls -lah'
fi

if command -v tree >/dev/null 2>&1; then
  alias t=tree
  alias tt='tree -L 1'
fi

# Git aliases
alias gs='git status -s'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gp='git push'
alias gpu='git push -u origin'
alias gu='git pull'
alias gl='git log --oneline'
alias gb='git branch'
alias gcl='git clone'
