cite about-plugin
about-plugin 'rust cargo bin directory'

__init_rust_plugin() {
    local CARGO_BIN_DIR="${HOME}/.cargo/bin"

    [[ -e "${CARGO_BIN_DIR}" ]] && pathmunge "${CARGO_BIN_DIR}"
}

__init_rust_plugin
