<h1 align="center">Nvim NPM</h1>

<p align="center">A Neovim plugin for JavaScript, TypeScript projects. It provides a way to execute npm scripts without leaving the editor.</p>

<p align="center">
  <a href="##features">Features</a> •
  <a href="##screenshots">Screenshots</a> •
  <a href="##installation">Installation</a> •
  <a href="##commands">Commands</a> •
  <a href="##api">Api</a> •
  <a href="##default-mappings">Default Mappings</a> •
  <a href="##configuration">Configuration</a> •
  <a href="##configuration-options">Configuration options</a> •
</p>

## Features
 Execute npm scripts without leaving the editor 

## Screenshots
- Search projects that contain a package.json file
<img src="./assets/sc-search-projects.png" width="100%" alt="search projects" align="center">

- Show scripts in a telescope window
<img src="./assets/sc-search-scripts-in-the-project.png" width="100%" alt="search scripts in the project" align="center">

- execute script
<img src="./assets/sc-execute-command.png" width="100%" alt="execute command" align="center">

## Installation

Install the plugin with your favorite package manager:

- [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'sajjahossain/nvim-npm'
Plug 'akinsho/toggleterm.nvim',
Plug 'nvim-telescope/telescope.nvim'
Plug 'rcarriga/nvim-notify'
```

- [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'sajjahossain/nvim-npm'
use 'akinsho/toggleterm.nvim',
use 'nvim-telescope/telescope.nvim'
use 'rcarriga/nvim-notify'
```

- [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
require('lazy').setup({
  {
    'sajjahossain/nvim-npm',
    config = true,
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'akinsho/toggleterm.nvim',
      'rcarriga/nvim-notify',
    }
  }
})
```

## Commands

| Command | Description |
| --- | --- |
| `:InstallPackage` | Installs a package in the current project |
| `:OpenTerminal` | Opens one of the available terminals |
| `:RefreshPackageJsonCache` | Refreshes the package.json cache |
| `:ShowScriptsInTelescope` | Shows the available scripts in a telescope window |

## Api

| Function | Description |
| --- | --- |
| `require('nvim-npm').exitAllTerminal()` | Closes all the terminals |
| `require('nvim-npm').exitTerminal()` | Closes the current terminal |
| `require('nvim-npm').installPackage()` | Installs a package in the current project |
| `require('nvim-npm').openTerminal()` | Opens one of the available terminals |
| `require('nvim-npm').showScripts()` | Shows the available scripts in a telescope window |


## Default Mappings

| Mode | Key | Action |
| --- | --- | --- |
| Normal | `;pi` | Installs a package in the current project |
| Normal | `;pl` | Lists the available scripts |
| Normal | `;po` | Opens one of the available terminals |
| Normal | `;pr` | Refreshes the package.json cache |

## Configuration

You can configure the plugin by setting the following options:

```lua
require('nvim-npm').setup({
    mappings = { -- key mappings [optional]
        t = {}, -- terminal mode mappings
        n = {} -- normal mode mappings
    }
})
```

## Configuration options
| Option | Type | Default | Description |
| --- | --- | --- | --- |
| mappings | table or false | default mappings | key mappings. set to false to disable default mappings |
