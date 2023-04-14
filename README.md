# output-panel.nvim

A panel to view the logs from your LSP servers.

<img width="700" alt="image" src="https://user-images.githubusercontent.com/5523984/231956595-5ebc8060-b408-49df-979d-7b6db62f284e.png">

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
