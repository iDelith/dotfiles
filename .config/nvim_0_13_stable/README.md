# INSTALLATION GUIDE FOR NVIM 0.12.1

The preferred method for installing neovim will be via Homebrew (MacOS), also this will be tracking the nightly builds.


For any errors or troubleshooting, try following the steps referenced by the links below:

1. https://github.com/benjiwolff/homebrew-neovim-nightly
2. https://github.com/orgs/Homebrew/discussions/5960


## Install the newest NVIM version

brew tap benjiwolff/neovim-nightly
brew install --HEAD tree-sitter
brew install --HEAD neovim


## If you already have NVIM installed previously on your machine

If that doesn't work or throw any errors, make sure to uninstall your previous version using Homebrew.


brew unlink neovim
brew uninstall neovim
brew tap benjiwolff/neovim-nightly
brew uninstall --force tree-sitter
brew install --HEAD tree-sitter
brew install --HEAD neovim

Note: By using --HEAD as argument for the neovim installation you will be tracking the nightly build, so be cautious about the version to be installed.

# Configuration

As NVIM 0.12.0+ offers a new package manager, that will be the preferred method for adding configuration, so this will be a reminder that for each package this should be the new standard moving forward.


## LSP Configuration

For the time being I will stick to using `nvim-lspconfig` as my LSP of choice and `mason` as the LSP Manager, since it takes away the heavy lifting of finding manual configurations for each LSP server. It's also a nice feature since it gets combined with any other configuration server added, so there's no downside for using it.

There are a few tricks we can do in order to facilitate all the plugins management, which is to use some `mason` related tools to avoid errors and keep somewhat of a backwards compatibility with LUA's table style management for the linters.


Add this bit to the file `init.lua`

```lua
vim.pack.add{
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/mason-org/mason.nvim' },
}
```


