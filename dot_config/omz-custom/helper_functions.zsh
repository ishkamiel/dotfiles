__prepend_to_PATH() {
  local new_path="$1"
  if [[ -d "$new_path" ]]; then
    # Remove new_path from PATH if it already exists
    PATH=$(echo "$PATH" | sed -e "s;:$new_path;;" -e "s;$new_path:;;" -e "s;$new_path;;")
    # Prepend new_path to PATH
    export PATH="$new_path:$PATH"
  fi
  return 0
}

__get_nproc() {
  if command -v nproc >/dev/null 2>&1; then
    nproc
  elif command -v sysctl >/dev/null 2>&1; then
    sysctl -n hw.ncpu
  fi
}
