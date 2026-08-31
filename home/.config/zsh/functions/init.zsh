# Small shell helpers
mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
}
