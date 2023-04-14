local lines_by_lsp = {}
local output_panel_bufnr
local output_panel_winid
local current_tab
local tabs = {}

local M = {}

function M.winbar()
  local tab = "Output Panel "
  for i, name in ipairs(tabs) do
    local hl
    if name == current_tab then
      hl = "%#Visual#"
    else
      hl = "%#Normal#"
    end
    tab = tab .. " " .. hl .. " " .. name .. " (" .. tostring(i) .. ") " .. "%#Normal#"
  end

  return tab
end

function M.panel()
  if not output_panel_bufnr then
    local names = vim.tbl_keys(lines_by_lsp)
    current_tab = current_tab or names[1]

    output_panel_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(output_panel_bufnr, "Output Panel")
    for i, tab in ipairs(tabs) do
      vim.keymap.set("n", tostring(i), function()
        current_tab = tab
        M.render()
      end, { buffer = output_panel_bufnr })
    end
  end

  vim.cmd.split()

  vim.api.nvim_win_set_buf(0, output_panel_bufnr)
  vim.api.nvim_win_set_height(0, 30)
  vim.wo.number = false
  vim.wo.scrolloff = 0
  vim.wo.winbar = [[%{%v:lua.require('output_panel').winbar()%}]]
  output_panel_winid = vim.api.nvim_get_current_win()
  M.render()
end

function M.render()
  if output_panel_bufnr and current_tab and not vim.tbl_isempty(lines_by_lsp) then
    local lines = {}

    vim.list_extend(lines, lines_by_lsp[current_tab])
    vim.api.nvim_buf_set_lines(output_panel_bufnr, 0, -1, false, lines)
  end
end

function M.setup()
  vim.api.nvim_create_user_command("OutputPanel", function()
    if output_panel_winid and vim.tbl_contains(vim.api.nvim_list_wins(), output_panel_winid) then
      vim.api.nvim_win_close(output_panel_winid, true)
      output_panel_winid = nil
    else
      M.panel()
    end
  end, { desc = "Toggle the Output Panel" })

  vim.lsp.handlers["window/logMessage"] = function(err, result, context)
    if not err then
      local client_id = context.client_id
      local client = vim.lsp.get_client_by_id(client_id)

      if not current_tab then
        current_tab = client.name
      end

      if not lines_by_lsp[client.name] then
        lines_by_lsp[client.name] = {}
        vim.list_extend(tabs, { client.name })

        if output_panel_bufnr then
          vim.keymap.set("n", tostring(#tabs), function()
            current_tab = client.name
            M.render()
          end, { buffer = output_panel_bufnr })
        end
      end

      local message = vim.split("[" .. vim.lsp.protocol.MessageType[result.type] .. "] " .. result.message, "\n")

      vim.list_extend(lines_by_lsp[client.name], message)

      M.render()
    end
  end
end

return M
