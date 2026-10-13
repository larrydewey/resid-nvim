# resid-nvim

Neovim support for [Resid](https://github.com/larrydewey/Resid): filetype
detection, syntax highlighting, indentation, folding, `:make` through the
compiler, snippets, `:checkhealth resid`, and the Resid language server
(`residc lsp`) wired through Neovim's built-in client (`vim.lsp.config` /
`vim.lsp.enable`, Neovim 0.11+).

Vim users want [resid-vim](https://github.com/larrydewey/resid-vim) and Emacs
users [resid-mode](https://github.com/larrydewey/resid-mode).

## Install

[lazy.nvim](https://github.com/folke/lazy.nvim) (LazyVim included):

```lua
{ 'larrydewey/resid-nvim', ft = 'resid', opts = {} }
```

The plugin's `plugin/resid.lua` registers the filetype, so `ft = 'resid'`
lazy-loading works. Any other manager: add the repository to the runtimepath;
no `setup()` call is needed.

You also need the compiler: `./install.sh` in the Resid repository puts
`residc` in `~/.resid/bin`. Inside a Resid checkout the plugin uses that
checkout's `build/boot/stage2.bin` instead.

## Configuration

```lua
require('resid').setup({
  compiler = nil,   -- path to residc; nil: build/boot/stage2.bin, then residc on PATH
  lsp = true,       -- vim.lsp.enable('resid')
  lsp_config = {},  -- merged into vim.lsp.config('resid')
})
```

Or change the server through Neovim directly:

```lua
vim.lsp.config('resid', { root_markers = { 'resid.toml' } })
```

## Language server

`residc lsp` is the compiler's own front end run on the buffer: diagnostics
with error codes, hover (signature, `///` docs, type, format specs), go to
definition across imports, document symbols and completion. Neovim's default
mappings apply: `K`, `CTRL-]`, `gO`, `<C-x><C-o>`.

## Snippets

`snippets/` is VSCode-format with a `package.json`:

```lua
-- LuaSnip
require('luasnip.loaders.from_vscode').lazy_load()

-- blink.cmp: add the directory to the snippets source
sources = { providers = { snippets = { opts = {
  search_paths = { vim.fn.stdpath('data') .. '/lazy/resid-nvim/snippets' },
} } } }
```

## Tree-sitter

There is no tree-sitter grammar for Resid yet; highlighting is the Vim syntax
file, which Neovim uses when no parser is installed.

## Tests

```sh
test/run.sh
```

Headless: filetype, syntax groups, a reindent fixed point, the error format,
and, when `residc` is on `PATH`, the language server end to end (attach,
document symbols, a diagnostic for a type error).

## License

MIT
