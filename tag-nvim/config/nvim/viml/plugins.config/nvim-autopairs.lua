local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')
local hasCoc = vim.g.coc_global_extensions ~= nil

local map_cr = true

if (hasCoc) then
  map_cr = false
end
npairs.setup({
  map_cr = map_cr,
  check_ts = true,
  enable_check_bracket_line = false,
  ignored_next_char = "[%w]"
})

-- skip it, if you use another global object
_G.MUtils = {}

-- old version
-- MUtils.completion_confirm=function()
-- if vim.fn["coc#pum#visible"]() ~= 0 then
-- return vim.fn["coc#_select_confirm"]()
-- else
-- return npairs.autopairs_cr()
-- end
-- end

-- new version for custom pum
MUtils.completion_confirm = function()
  if vim.fn["coc#pum#visible"]() ~= 0 then
    return vim.fn["coc#pum#confirm"]()
  else
    return npairs.autopairs_cr()
  end
end

if (hasCoc) then

  remap('i', '<CR>', 'v:lua.MUtils.completion_confirm()', { expr = true, noremap = true })
end
