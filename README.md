# output-panel.nvim

A panel to view the logs from your LSP servers.

TODO: Screenshot

## Install

### lazy.nvim

```lua
{
  "mhanberg/output-panel.nvim",
  event = "VeryLazy",
  config = function()
    require("output_panel").setup()
  end
}
```

## Usage

- `:OutputPanel` to toggle the panel
