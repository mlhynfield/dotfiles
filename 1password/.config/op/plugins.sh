export OP_PLUGIN_ALIASES_SOURCED=1
tea() { op plugin run -- tea "$@"; }
claude() { CLAUDE_CODE_OAUTH_TOKEN="op://private/claude/token" op run --no-masking -- claude "$@"; }
