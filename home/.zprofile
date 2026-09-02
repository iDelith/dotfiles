# Load environment for login shells before interactive configuration.
zsh_environment_file="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/environment/init.zsh"
[[ -r "$zsh_environment_file" ]] && source "$zsh_environment_file"
unset zsh_environment_file