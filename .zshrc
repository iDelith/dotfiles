# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Path to your Oh My Zsh installation.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

alias l='ls -lah'
alias la='ls -lAh'
alias ll='eza --all --group --header --group-directories-first --long --icons --tree --level 1'
alias ls='ls -G'
alias lsa='ls -lah'
alias md='mkdir -p'
alias p=pnpm
alias rd=rmdir
alias run-help=man
alias t=tree
alias tn='tmux new -s'
alias tt='tree -L 1'
alias which-command=whence
alias z='zshz 2>&1'
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
