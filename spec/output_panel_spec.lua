local helpers = require("nvim-test.helpers")
local exec_lua = helpers.exec_lua
local eq = helpers.eq

helpers.options = { verbose = true }

local function log(msg)
  exec_lua(string.format(
    [[
      vim.lsp.handlers["window/logMessage"](
        false,
        {
          type = 1,
          message = %q
        },
        {}
      )
    ]],
    msg
  ))
end

describe("output panel", function()
  before_each(function()
    helpers.clear()

    exec_lua([[
      vim.opt.rtp:append'.'
      vim.lsp.get_client_by_id = function()
        return {name = "foobar lsp"}
      end
      require('output_panel').setup({max_buffer_size = 5})
    ]])

    log("this is a really\nmessage\nthat everyone should see")
  end)

  it("inserts log into buffer", function()
    local lines = exec_lua([[
      vim.cmd.OutputPanel()
      return vim.api.nvim_buf_get_lines(0, 0, -1, false)
    ]])

    eq({ "", "[Error] this is a really", "message", "that everyone should see" }, lines)
  end)

  it("buffer is circular", function()
    log([[
this is another
long message
that should
make the buffer overflow]])
    local lines = exec_lua([[
      vim.cmd.OutputPanel()
      return vim.api.nvim_buf_get_lines(0, 0, -1, false)
    ]])

    eq({
      "that everyone should see",
      "[Error] this is another",
      "long message",
      "that should",
      "make the buffer overflow",
    }, lines)
  end)
end)
