local lspkind = require('lspkind')
local cmp = require 'cmp'
local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local luasnip = require("luasnip")
local nvim_lsp = lspconfig

local mason = require("mason")
local mason_lsp = require("mason-lspconfig")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

mason.setup()
mason_lsp.setup({
  ensure_installed = {
    -- "bash-language-server",
    "efm",
    "lua-language-server",
    "eslint",
    "tsserver",
    "vimls",
    -- "clangd",
    -- "gopls",
    -- "pyright",
  },
  automatic_installation = true,
  ui = {
    icons = {
      sautomatic_installation = true, -- automatically detect which servers to install (based on which servers are set up via lspconfig)
      ui = {
        icons = {
          server_installed = "✓",
          server_pending = "➜",
          server_uninstalled = "✗"
        }
      },
      server_installed = "✓",
      server_pending = "➜",
      server_uninstalled = "✗"
    }
  }
})


local function custom_attach(client, bufnr)
  require("lsp_signature").on_attach({
    bind = true,
    use_lspsaga = false,
    floating_window = true,
    fix_pos = true,
    hint_enable = true,
    hi_parameter = "Search",
    handler_opts = { "double" },
  })
  require("nvim-navic").attach(client, bufnr)
end

vim.cmd([[set pumheight=15]])
vim.cmd([[set nobackup]])
vim.cmd([[set nowritebackup]])
vim.cmd([[set cmdheight=1]])
vim.cmd([[set completeopt=menu,menuone,noselect]])

-- local has_words_before = function()
--   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
--   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
-- end

-- local t = function(str)
--   return vim.api.nvim_replace_termcodes(str, true, true, true)
-- end

local function tab(fallback)
  if luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  elseif cmp.visible() then
    cmp.confirm({ select = true })
    -- elseif has_words_before() then
    --   cmp.complete()
  else
    fallback()
  end
end

cmp.setup {
  -- 指定 snippet 引擎
  snippet = {
    expand = function(args)
      -- For `vsnip` users.
      -- vim.fn["vsnip#anonymous"](args.body)

      -- For `luasnip` users.
      require('luasnip').lsp_expand(args.body)

      -- For `ultisnips` users.
      -- vim.fn["UltiSnips#Anon"](args.body)

      -- For `snippy` users.
      -- require'snippy'.expand_snippet(args.body)
    end,
  },
  -- 来源
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    -- { name = 'copilot' },
    -- For luasnip users.
    { name = 'luasnip' },
    { name = "spell" },
    { name = "nvim_lua" },

  }, {
    { name = 'buffer' },
    { name = 'path' }
  }),

  -- 快捷键
  mapping = {
    ["<Tab>"] = cmp.mapping({
      i = tab,
      c = cmp.mapping.select_next_item()
    }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)

      -- local mode = vim.api.nvim_get_mode()["mode"]
      -- if mode == 'c' then
      --   if cmp.visible() then
      --     cmp.mapping.select_prev_item()
      --   else
      --     fallback()
      --   end
      -- end

      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)

      else
        fallback()
      end
    end, {
      "i",
      "s",
      "c"
    }),

    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
    ['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
    ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
    ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
    ['<S-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<Esc>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      -- c = cmp.mapping.close(),
      c = cmp.mapping.abort()
    }),
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({
      select = true,
    }),

    -- ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
  },
  -- 使用lspkind-nvim显示类型图标
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol',
      with_text = false, -- do not show text alongside icons
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      -- before = function (entry, vim_item)
      --   -- Source 显示提示来源
      --   vim_item.menu = "["..string.upper(entry.source.name).."]"
      --   return vim_item
      -- end
    })
  },
  experimental = {
    ghost_text = true,
  },
  -- `cmp.PreselectMode`

  -- 1. `cmp.PreselectMode.Item`
  --   nvim-cmp will preselect the item that the source specified.
  -- 2. `cmp.PreselectMode.None`
  --   nvim-cmp will not preselect any items.
  preselect = cmp.PreselectMode.Item,
}

-- Use buffer source for `/`.
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':'.
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

local group = vim.api.nvim_create_augroup("LspConfig", { clear = true })

local format_async = function(err, _, result, _, bufnr)
  if err ~= nil or result == nil then
    return
  end
  if not vim.api.nvim_buf_get_option(bufnr, "modified") then
    local view = vim.fn.winsaveview()
    vim.lsp.util.apply_text_edits(result, bufnr)
    vim.fn.winrestview(view)
    if bufnr == vim.api.nvim_get_current_buf() then
      vim.api.nvim_command("noautocmd :update")
    end
  end
end

vim.lsp.handlers["textDocument/formatting"] = format_async

local lsp_organize_imports = function()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
    title = ""
  }
  vim.lsp.buf.execute_command(params)
end
-- _G makes this function available to vimscript lua calls
_G.lsp_organize_imports = lsp_organize_imports

local border = {
  { "╭", "FloatBorder" },
  { "─", "FloatBorder" },
  { "╮", "FloatBorder" },
  { "│", "FloatBorder" },
  { "╯", "FloatBorder" },
  { "─", "FloatBorder" },
  { "╰", "FloatBorder" },
  { "│", "FloatBorder" },
}
-- show diagnostic line with custom border and styling
local lsp_show_diagnostics = function()
  vim.diagnostic.open_float({ border = border })
end

local on_attach = function(client, bufnr)
  vim.cmd [[command! OR lua lsp_organize_imports()]]
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })

  local opts = { noremap = true, silent = true }
  vim.keymap.set("n", "<leader>aa", lsp_show_diagnostics, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>aq", vim.diagnostic.setloclist, opts)

  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gO", lsp_organize_imports, bufopts)
  -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  -- vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
  vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, bufopts)
  -- vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "ga", vim.lsp.buf.code_action, bufopts)

  -- vim.keymap.set("n", "<leader>cc", vim.lsp.buf.code_action, bufopts)

  if client.server_capabilities.document_highlight then
    vim.api.nvim_create_autocmd(
      "CursorHold",
      {
        pattern = "*",
        callback = function()
          vim.lsp.buf.document_highlight()
        end,
        group = group
      }
    )
    vim.api.nvim_create_autocmd(
      "CursorMoved",
      {
        pattern = "*",
        callback = function()
          vim.lsp.buf.clear_references()
        end,
        group = group
      }
    )
  end

  -- disable document formatting (currently handled by formatter.nvim)
  client.server_capabilities.document_formatting = false

  -- if client.server_capabilities.document_formatting then
  --   vim.api.nvim_create_autocmd(
  --     "BufEnter",
  --     {
  --       pattern = "*",
  --       callback = function()
  --         vim.lsp.buf.formatting()
  --       end,
  --       group = group
  --     }
  --   )
  -- end
end

local diagnosticls_settings = {
  filetypes = {
    "sh"
  },
  init_options = {
    linters = {
      shellcheck = {
        sourceName = "shellcheck",
        command = "shellcheck",
        debounce = 100,
        args = { "--format=gcc", "-" },
        offsetLine = 0,
        offsetColumn = 0,
        formatLines = 1,
        formatPattern = {
          "^[^:]+:(\\d+):(\\d+):\\s+([^:]+):\\s+(.*)$",
          { line = 1, column = 2, message = 4, security = 3 }
        },
        securities = { error = "error", warning = "warning", note = "info" }
      }
    },
    filetypes = {
      sh = "shellcheck"
    }
  }
}

local function make_config(callback)
  callback = callback or function(config)
    return config
  end
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits"
    }
  }
  capabilities.textDocument.colorProvider = { dynamicRegistration = false }
  capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

  return callback(
    {
      capabilities = capabilities,
      on_attach = on_attach
    }
  )
end

lspconfig.rust_analyzer.setup(
  make_config(
    function(config)
      return config
    end
  )
)

lspconfig.eslint.setup(
  make_config(
    function(config)
      config.filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
      return config
    end
  )
)

lspconfig.tsserver.setup(
  make_config(
    function(config)
      config.root_dir = lspconfig.util.root_pattern("tsconfig.json")
      config.handlers = {
        ["textDocument/definition"] = function(err, result, ctx, conf)
          -- if there is more than one result, just use the first one
          if #result > 1 then
            result = { result[1] }
          end
          vim.lsp.handlers["textDocument/definition"](err, result, ctx, conf)
        end
      }
      return config
    end
  )
)

lspconfig.vimls.setup(
  make_config(
    function(config)
      config.init_options = { isNeovim = true }
      return config
    end
  )
)

lspconfig.diagnosticls.setup(
  make_config(
    function(config)
      config.settings = diagnosticls_settings
      return config
    end
  )
)

local cmp_autopairs = require "nvim-autopairs.completion.cmp"

require('nvim-autopairs').setup {}

local ts_utils = require("nvim-treesitter.ts_utils")

cmp.event:on("confirm_done", function(evt)
  local name = ts_utils.get_node_at_cursor():type()
  -- print(name)
  if name ~= "named_imports" and name ~= "export_clause" then
    cmp_autopairs.on_confirm_done()(evt)
  end
end)

for _, server in ipairs(mason_lsp.get_installed_servers()) do
  if server == "jsonls" then
    nvim_lsp.jsonls.setup({
      flags = { debounce_text_changes = 500 },
      capabilities = capabilities,
      on_attach = custom_attach,
      settings = {
        json = {
          -- Schemas https://www.schemastore.org
          schemas = {
            {
              fileMatch = { "package.json" },
              url = "https://json.schemastore.org/package.json",
            },
            {
              fileMatch = { "tsconfig*.json" },
              url = "https://json.schemastore.org/tsconfig.json",
            },
            {
              fileMatch = {
                ".prettierrc",
                ".prettierrc.json",
                "prettier.config.json",
              },
              url = "https://json.schemastore.org/prettierrc.json",
            },
            {
              fileMatch = { ".eslintrc", ".eslintrc.json" },
              url = "https://json.schemastore.org/eslintrc.json",
            },
            {
              fileMatch = {
                ".babelrc",
                ".babelrc.json",
                "babel.config.json",
              },
              url = "https://json.schemastore.org/babelrc.json",
            },
            {
              fileMatch = { "lerna.json" },
              url = "https://json.schemastore.org/lerna.json",
            },
            {
              fileMatch = {
                ".stylelintrc",
                ".stylelintrc.json",
                "stylelint.config.json",
              },
              url = "http://json.schemastore.org/stylelintrc.json",
            },
            {
              fileMatch = { "/.github/workflows/*" },
              url = "https://json.schemastore.org/github-workflow.json",
            },
          },
        },
      },
    })
  elseif server ~= "efm" then
    nvim_lsp[server].setup({
      capabilities = capabilities,
      on_attach = custom_attach,
    })
  end
end

-- https://github.com/vscode-langservers/vscode-html-languageserver-bin

nvim_lsp.html.setup({
  cmd = { "html-languageserver", "--stdio" },
  filetypes = { "html" },
  init_options = {
    configurationSection = { "html", "css", "javascript" },
    embeddedLanguages = { css = true, javascript = true },
  },
  settings = {},
  single_file_support = true,
  flags = { debounce_text_changes = 500 },
  capabilities = capabilities,
  on_attach = custom_attach,
})

-- efm
local formatting = require("formatting")

local efmls = require("efmls-configs")

-- Init `efm-langserver` here.

efmls.init({
  on_attach = custom_attach,
  capabilities = capabilities,
  init_options = { documentFormatting = true, codeAction = true },
})

-- Require `efmls-configs-nvim`'s config here

local vint = require("efmls-configs.linters.vint")
local eslint = require("efmls-configs.linters.eslint")
local flake8 = require("efmls-configs.linters.flake8")
local shellcheck = require("efmls-configs.linters.shellcheck")

local black = require("efmls-configs.formatters.black")
local luafmt = require("efmls-configs.formatters.stylua")
local prettier = require("efmls-configs.formatters.prettier_d")
local shfmt = require("efmls-configs.formatters.shfmt")

-- Add your own config for formatter and linter here

-- local rustfmt = require("modules.completion.efm.formatters.rustfmt")
-- local clangfmt = require("modules.completion.efm.formatters.clangfmt")

-- Override default config here

flake8 = vim.tbl_extend("force", flake8, {
  prefix = "flake8: max-line-length=160, ignore F403 and F405",
  lintStdin = true,
  lintIgnoreExitCode = true,
  lintFormats = { "%f:%l:%c: %t%n%n%n %m" },
  lintCommand = "flake8 --max-line-length 160 --extend-ignore F403,F405 --format '%(path)s:%(row)d:%(col)d: %(code)s %(code)s %(text)s' --stdin-display-name ${INPUT} -",
})

-- Setup formatter and linter for efmls here

efmls.setup({
  vim = { formatter = vint },
  lua = { formatter = luafmt },
  -- c = { formatter = clangfmt },
  -- cpp = { formatter = clangfmt },
  python = { formatter = black },
  vue = { formatter = prettier },
  typescript = { formatter = prettier, linter = eslint },
  javascript = { formatter = prettier, linter = eslint },
  typescriptreact = { formatter = prettier, linter = eslint },
  javascriptreact = { formatter = prettier, linter = eslint },
  yaml = { formatter = prettier },
  html = { formatter = prettier },
  css = { formatter = prettier },
  scss = { formatter = prettier },
  sh = { formatter = shfmt, linter = shellcheck },
  markdown = { formatter = prettier },
  -- rust = {formatter = rustfmt},
})

formatting.configure_format_on_save()
