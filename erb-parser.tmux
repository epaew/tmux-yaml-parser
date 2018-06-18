#!/usr/bin/env bash
# vim:set ft=sh:

CURRENT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}) && pwd)
cmd="${CURRENT_DIR}/bin/tmux-erb-parser"
opts="--inline"

TMUX_CONF_EXT_DEFAULT="${HOME}/.config/tmux/*.erb"
tmux run-shell "${cmd} ${opts} ${TMUX_CONF_EXT_PATH:-$TMUX_CONF_EXT_DEFAULT}"
