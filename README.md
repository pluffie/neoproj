# Neoproj

Small yet powerful project manager for Neovim written in fennel.

## Features

- Open projects
- Manage sessions (see [Sessions](#sessions))
- Create projects from templates
- Add custom templates

## Installation

- Packer
  ```lua
  use "pluffie/neoproj"
  ```
- [lazy.nvim](https://github.com/folke/lazy.nvim)
  ```lua
  {
    "pluffie/neoproj",
    cmd = { "ProjectOpen", "ProjectNew" },
  }
  ```

## Configuration

NOTE: calling `setup` is not necessary at all, plugin will work even without it

```lua
require "neoproj".setup {
  -- Directory which contains all of your projects
  project_path = "~/projects",
}
```

### Adding templates

You can add your own templates using `register_template` function:

```lua
require "neoproj".register_template {
  name = "Empty project (Git)",
  expand = "git init",
}
```

More information can be found in the help-file (`:h neoproj-templates`).

### Sessions

Neoproj does some session management out-of-box:

- automatically loads file `project_root/.nvim/session.vim` (if exists)
- has command for saving sessions (`:ProjectSaveSession`)

But Neoproj doesn't save sessions automatically, so you need to write
`:ProjectSaveSession` all time. Let's fix it using autocmd!

- Lua
  ```lua
  vim.api.nvim_create_autocmd(["VimLeavePre"], {
    callback = function()
      if vim.g.project_root ~= nil then
        require "neoproj".save_session()
      end
    end,
  })
  ```
- Fennel
  ```fennel
  (let [{:save_session save-session} (require :neoproj)
        callback #(when (not= nil vim.g.project_root)
                    (save-session))]
    (vim.api.nvim_create_autocmd [:VimLeavePre] {: callback}))
  ```

