# Load shell modules in a predictable order.
zsh_state_file="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/selections/zsh-integrations/enabled.zsh"
[[ -r "$zsh_state_file" ]] && source "$zsh_state_file"

zsh_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
zsh_module_dirs=(
  environment
  history
  shell-options
  completion
  aliases
  functions
  integrations
)

for zsh_module_dir in "${zsh_module_dirs[@]}"; do
  for zsh_module_file in "$zsh_config_dir/$zsh_module_dir"/*.zsh(N); do
    source "$zsh_module_file"
  done
done

unset zsh_state_file zsh_config_dir zsh_module_dirs zsh_module_dir zsh_module_file
