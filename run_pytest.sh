#!/usr/bin/env bash

# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

eval "$(direnv hook bash)"
pytest="$(which pytest)"
exec direnv exec "$pytest" "$@"
