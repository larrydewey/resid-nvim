-- Run by test/run.sh: nvim --headless --clean with this plugin on the
-- runtimepath and the fixture as the current buffer.
local fails = 0
local function check(ok, what)
  if not ok then
    fails = fails + 1
  end
  io.stdout:write((ok and 'ok   ' or 'FAIL ') .. what .. '\n')
end

local function group(pat)
  local pos = vim.fn.searchpos(pat, 'cnw')
  return vim.fn.synIDattr(vim.fn.synID(pos[1], pos[2], 1), 'name')
end

check(vim.bo.filetype == 'resid', 'filetype is resid')
check(vim.bo.commentstring == '// %s', 'commentstring')
check(vim.bo.shiftwidth == 4 and vim.bo.expandtab, 'shiftwidth 4, expandtab')
check(vim.filetype.match({ filename = 'x/resid.toml' }) == 'toml', 'resid.toml is toml')

local before = vim.api.nvim_buf_get_lines(0, 0, -1, false)
vim.cmd('silent normal! gg=G')
local after = vim.api.nvim_buf_get_lines(0, 0, -1, false)
check(vim.deep_equal(before, after), 'reindent is a fixed point')

check(group([[\<behavior\>]]) == 'residBehavior', 'behavior keyword')
check(group('@requires') == 'residAnnotation', '@requires annotation')
check(group('readonly') == 'residCapMode', 'capability mode')
check(group([[\<area(S]]) == 'residFuncDef', 'function name')
check(group(':8}') == 'residFormatSpec', 'f-string format spec')

local items = vim.fn.getqflist({
  lines = { 'error[E0001]: type error: expected Int, got Str', '  --> /tmp/x.resid:2:13', '2 | x' },
  efm = vim.bo.errorformat,
}).items
items = vim.tbl_filter(function(i) return i.valid == 1 end, items)
check(#items == 1 and items[1].lnum == 2 and items[1].col == 13 and items[1].type == 'E', 'errorformat')

local cfg = vim.lsp.config.resid
check(cfg ~= nil and vim.tbl_contains(cfg.filetypes, 'resid'), 'lsp config resolved')
check(vim.lsp.is_enabled('resid'), 'lsp enabled')

-- The language server, when a compiler is installed.
local compiler = require('resid').compiler()
if vim.fn.executable(compiler) == 1 then
  local client
  vim.wait(10000, function()
    client = vim.lsp.get_clients({ bufnr = 0, name = 'resid' })[1]
    return client ~= nil and client.initialized
  end, 50)
  check(client ~= nil, 'language server attached')
  if client then
    vim.fn.cursor(vim.fn.search([[\<area(S]], 'nw'), 1)
    local res = client:request_sync('textDocument/documentSymbol',
      { textDocument = vim.lsp.util.make_text_document_params(0) }, 10000, 0)
    local names = {}
    for _, s in ipairs(res and res.result or {}) do
      names[s.name] = true
    end
    check(names.area ~= nil, 'document symbols include area')
    if not names.area then io.stdout:write(vim.inspect(res) .. '\n') end

    -- A type error in the buffer comes back as a diagnostic with its code.
    vim.api.nvim_buf_set_lines(0, -1, -1, false, { 'Int bad() { Int x = "a"; return x; }' })
    vim.wait(15000, function() return #vim.diagnostic.get(0) > 0 end, 50)
    local d = vim.diagnostic.get(0)[1]
    check(d ~= nil and tostring(d.code or d.message):find('E0') ~= nil, 'diagnostic from the server')
  end
else
  io.stdout:write('skip language server: no compiler (' .. compiler .. ')\n')
end

io.stdout:write(fails == 0 and 'DONE\n' or 'FAILED\n')
vim.cmd(fails == 0 and 'qa!' or 'cq!')
