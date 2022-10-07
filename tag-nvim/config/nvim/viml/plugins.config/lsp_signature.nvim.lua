
local signature_config = {
  log_path = "/tmp/sig.log",
  debug = false,
  hint_enable = true,
  handler_opts = { border = "rounded" },
  max_width = 80,
  hint_prefix = "🐼 ", 
}

require "lsp_signature".setup(signature_config)