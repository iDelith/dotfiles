# Optional Starship prompt
if [[ "${DOTFILES_ZSH_INTEGRATIONS_ALL:-0}" == 1 ||
    "${ZSH_INTEGRATION_STARSHIP:-0}" == 1 ]] &&
    command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
