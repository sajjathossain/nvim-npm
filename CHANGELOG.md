# Changelog

All notable changes to this project will be documented in this file.

## [2.1.0] - 2024-12-24

### 🚀 Major Enhancement: @antfu/ni Integration

This release integrates the powerful `@antfu/ni` package for universal package manager support, providing a seamless experience across all major JavaScript package managers.

### ✨ Added

- **@antfu/ni Integration**: Universal package manager interface
  - Automatic detection of npm, yarn, pnpm, and bun
  - Smart command mapping (`ni`, `nr`, `nun`, `nid`)
  - Auto-installation of ni if not present
- **Enhanced Package Management**:
  - `:RemovePackage` command for package removal
  - Dev dependency installation support
  - Better package manager detection
- **Improved Health Checks**:
  - ni installation verification
  - Package manager compatibility checks
  - Command availability validation
- **Better Project Information**:
  - Display detected package manager in project selector
  - Lock file type detection
  - Project compatibility validation

### 🔧 Improved

- **Terminal Commands**: Now use ni for all package operations
- **Error Handling**: Better fallback to npm if ni installation fails
- **User Experience**: 
  - Ask for dev dependency preference during installation
  - Show package manager type in project listings
  - Better error messages and notifications
- **Performance**: Optimized package manager detection
- **Documentation**: Updated README with ni integration details

### 🐛 Fixed

- **Package Installation**: More reliable package installation across different managers
- **Command Execution**: Better handling of different project structures
- **Error Recovery**: Graceful fallback when ni is not available

### 📋 New Commands

- `:RemovePackage` - Remove packages using ni
- Enhanced `:InstallPackage` - Now supports dev dependencies

### 🔄 API Changes

- Added `removePackage()` function to public API
- Enhanced terminal utilities with ni support
- Improved project information retrieval

### 🏗️ Technical Improvements

- **New Module**: `utils/ni.lua` for ni integration
- **Enhanced Terminal Utils**: Better command building and execution
- **Improved Health Checks**: Comprehensive ni status verification
- **Better Caching**: Package manager info included in cache debug output

## [2.0.0] - 2024-12-24

### 🚀 Major Refactor

This release represents a complete rewrite of the plugin with improved architecture, better error handling, and enhanced maintainability.

### ✨ Added

- **Modular Architecture**: Complete restructure with clear separation of concerns
- **Enhanced Error Handling**: Comprehensive error handling throughout the codebase
- **Health Check System**: Added `:checkhealth nvim-npm` command for setup verification
- **Better Documentation**: Improved inline documentation and type annotations
- **Development Guide**: Added comprehensive development documentation
- **Plugin Initialization**: Proper plugin loading with dependency checking

### 🔧 Improved

- **Configuration System**: More robust configuration management with validation
- **Cache System**: Improved caching with better performance and reliability
- **Package Manager Detection**: Enhanced auto-detection logic
- **Terminal Management**: Better terminal handling with improved error recovery
- **UI Components**: Cleaner Telescope integration with better user feedback
- **Code Organization**: Logical folder structure with clear module boundaries

### 🐛 Fixed

- **Memory Leaks**: Fixed potential memory issues in cache management
- **Error Messages**: More descriptive error messages and user feedback
- **Edge Cases**: Better handling of edge cases in file system operations
- **Terminal Cleanup**: Improved terminal session management

### 📁 Project Structure

```
lua/nvim-npm/
├── init.lua              # Main entry point
├── config.lua            # Configuration management
├── commands.lua          # User commands
├── keymaps.lua           # Keymap handling
├── api.lua               # Public API
├── health.lua            # Health checks
├── core/
│   └── cache.lua         # Caching system
├── utils/
│   ├── init.lua          # Utility exports
│   ├── fs.lua            # File system utils
│   ├── package-manager.lua # Package manager detection
│   ├── terminal.lua      # Terminal management
│   └── ni.lua            # ni integration
└── ui/
    └── telescope.lua     # UI components
```

### 🔄 Migration Guide

The public API remains the same, so existing configurations should continue to work without changes:

```lua
require('nvim-npm').setup({
  mappings = {
    t = {
      ["<esc><esc>"] = "<C-\\><C-n>",
    },
    n = {
      [";pl"] = "<cmd>ShowScriptsInTelescope<cr>",
      [";po"] = "<cmd>OpenTerminal<cr>",
      [";pi"] = "<cmd>InstallPackage<cr>",
      [";pr"] = "<cmd>RefreshPackageJsonCache<cr>",
    }
  }
})
```

### 📋 Breaking Changes

None - the public API remains backward compatible.

### 🙏 Acknowledgments

This refactor maintains all existing functionality while providing a much more maintainable and extensible codebase for future development.
