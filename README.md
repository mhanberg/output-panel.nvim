# output-panel.nvim

A panel to view the logs from your LSP servers.

<img width="700" alt="image" src="https://user-images.githubusercontent.com/5523984/231956595-5ebc8060-b408-49df-979d-7b6db62f284e.png">

## Install

### lazy.nvim

```lua
{
  "mhanberg/output-panel.nvim",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("output_panel").setup({
      max_buffer_size = 5000 -- default
    })
  end,
  cmd = { "OutputPanel" },
  keys = {
    {
      "<leader>o",
      vim.cmd.OutputPanel,
      mode = "n",
      desc = "Toggle the output panel",
    },
  }
}
```

## Usage

- `:OutputPanel` to toggle the panel

Each tab in the panel can be navigated to by hitting the number in the tab next to the tab name.
