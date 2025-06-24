# Development Guide

This document provides information for developers who want to contribute to or understand the nvim-npm plugin.

## Project Structure

```
lua/nvim-npm/
├── init.lua              # Main plugin entry point
├── config.lua            # Configuration management
├── commands.lua          # User command definitions
├── keymaps.lua           # Keymap management
├── api.lua               # Public API functions
├── health.lua            # Health check functionality
├── core/
│   └── cache.lua         # Package.json caching system
├── utils/
│   ├── init.lua          # Utility module exports
│   ├── fs.lua            # File system utilities
│   ├── package-manager.lua # Package manager detection (legacy)
│   ├── terminal.lua      # Terminal management
│   └── ni.lua            # @antfu/ni integration
└── ui/
    └── telescope.lua     # Telescope UI components

plugin/
└── nvim-npm.lua          # Plugin initialization
```

## Architecture

### Core Components

1. **Configuration System** (`config.lua`)
   - Manages user configuration
   - Provides default settings
   - Handles configuration validation

2. **Cache System** (`core/cache.lua`)
   - Caches package.json file locations
   - Provides efficient project discovery
   - Handles cache invalidation

3. **Utility Modules** (`utils/`)
   - **File System**: Git root detection, file reading, package.json parsing
   - **Package Manager**: Auto-detection of npm/yarn/pnpm (legacy)
   - **ni Integration**: Universal package manager interface via @antfu/ni
   - **Terminal**: Terminal management and command execution

4. **UI Components** (`ui/telescope.lua`)
   - Telescope integration
   - Project and script selection
   - Terminal management UI

### Data Flow

1. User triggers command or keymap
2. API function is called
3. Cache is checked/refreshed if needed
4. ni handles package manager detection and command execution
5. UI is presented via Telescope
6. User selection triggers terminal execution via ni

## Key Features

### @antfu/ni Integration

The plugin now uses [@antfu/ni](https://www.npmjs.com/package/@antfu/ni) for universal package manager support:

- **Automatic Detection**: ni detects the package manager based on lock files
- **Universal Commands**: 
  - `ni` - install dependencies
  - `nr` - run scripts
  - `nun` - uninstall packages
  - `nid` - install dev dependencies
- **Auto-installation**: Plugin automatically installs ni if not present
- **Fallback**: Falls back to npm if ni installation fails

### Package Manager Detection

The plugin automatically detects the package manager based on lock files:
- `pnpm-lock.yaml` → pnpm
- `yarn.lock` → yarn  
- `package-lock.json` → npm
- `bun.lockb` → bun
- Default: npm (via ni fallback)

### Smart Caching

- Caches package.json locations for performance
- Automatically refreshes when needed
- Ignores common directories (node_modules, .git, etc.)
- Includes package manager information in debug output

### Terminal Management

- Integrates with toggleterm.nvim
- Creates named terminals for each script
- Reuses existing terminals when possible
- Supports terminal cleanup
- Uses ni for all package operations

## Error Handling

The plugin includes comprehensive error handling:
- Dependency checking (telescope, toggleterm, ni)
- File system error handling
- JSON parsing error handling
- Terminal operation error handling
- ni installation and fallback handling

## Health Checks

Run `:checkhealth nvim-npm` to verify:
- Required dependencies (telescope, toggleterm)
- Optional dependencies (nvim-notify)
- ni installation and command availability
- Configuration status
- Project setup and compatibility

## Testing

To test the plugin:

1. Install in a test Neovim configuration
2. Open a JavaScript/TypeScript project
3. Run health check: `:checkhealth nvim-npm`
4. Test each command and keymap
5. Verify ni integration and package manager detection
6. Test with different package managers (npm, yarn, pnpm, bun)

## Contributing

1. Follow the existing code structure
2. Add appropriate error handling
3. Update documentation
4. Test thoroughly with different package managers
5. Follow Lua best practices
6. Ensure ni integration works correctly

## Dependencies

### Required
- telescope.nvim
- toggleterm.nvim

### Optional
- nvim-notify (falls back to vim.notify)
- @antfu/ni (auto-installed if not present)

## Debugging

Enable debug output by checking:
- `:messages` for error messages
- `:checkhealth nvim-npm` for setup issues
- `:PrintScripts` to verify cache contents with package manager info

## ni Integration Details

### Command Mapping

| Operation | ni Command | Description |
|-----------|------------|-------------|
| Run script | `nr <script>` | Execute npm script |
| Install package | `ni <package>` | Install package |
| Install dev | `nid <package>` | Install as dev dependency |
| Remove package | `nun <package>` | Uninstall package |

### Auto-installation Process

1. Check if ni is installed globally (`which ni`)
2. If not found, attempt installation via `npm install -g @antfu/ni`
3. Verify installation success
4. Fall back to direct npm commands if installation fails
5. Show appropriate notifications to user

### Project Compatibility

The plugin checks project compatibility by:
1. Verifying package.json exists
2. Detecting lock files for package manager identification
3. Ensuring ni can handle the project structure
4. Providing fallback mechanisms for edge cases
