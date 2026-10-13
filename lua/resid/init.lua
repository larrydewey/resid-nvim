-- Resid language support for Neovim.
local M = {}

M.config = {
  -- Path to the compiler; nil finds one (see M.compiler).
  compiler = nil,
  -- Enable the language server (`residc lsp`) through vim.lsp.enable.
  lsp = true,
}

local function executable(path)
  return path and vim.fn.executable(path) == 1
end

--- The compiler to run: the configured path, then the nearest
--- build/boot/stage2.bin above `dir` (a Resid checkout), then `residc`.
---@param dir? string
---@return string
function M.compiler(dir)
  local configured = M.config.compiler or vim.g.resid_compiler
  if configured and configured ~= '' then
    return vim.fn.expand(configured)
  end
  dir = dir or vim.fn.expand('%:p:h')
  if dir == '' then
    dir = vim.fn.getcwd()
  end
  for parent in vim.fs.parents(vim.fs.joinpath(dir, '_')) do
    local boot = vim.fs.joinpath(parent, 'build', 'boot', 'stage2.bin')
    if executable(boot) then
      return boot
    end
  end
  return 'residc'
end

--- Configure the plugin. Calling it is optional: the defaults apply without it.
---@param opts? { compiler?: string, lsp?: boolean, lsp_config?: vim.lsp.Config }
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend('force', M.config, opts)
  if opts.lsp_config then
    vim.lsp.config('resid', opts.lsp_config)
  end
  if vim.lsp.enable then
    vim.lsp.enable('resid', M.config.lsp and vim.g.resid_lsp ~= false)
  end
end

return M
