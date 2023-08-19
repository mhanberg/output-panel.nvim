local output_panel_winid
local current_tab
local tabs = {}

local P = {}

function P.create_tab(name)
  if not tabs[name] then
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].ft = "outputpanel"
    local tab = { id = #vim.tbl_keys(tabs) + 1, bufnr = bufnr }
    tabs[name] = tab

    if not current_tab then
      current_tab = name
    end
  end
  for _, t in pairs(tabs) do
    for tname, tb in pairs(tabs) do
      vim.keymap.set("n", tostring(tb.id), function()
        current_tab = tname
        vim.api.nvim_set_current_buf(tb.bufnr)
        vim.wo.winbar = [[%{%v:lua.require('output_panel').winbar()%}]]
      end, { buffer = t.bufnr })
    end
  end

  P.create_tab(coroutine.yield(tabs[name]))
end

local create_tab = coroutine.wrap(P.create_tab)

local M = {}

function M.winbar()
  local tab = "Output Panel "

  local names =  vim.tbl_keys(tabs)
  table.sort(names, function(a, b)
    return tabs[a].id < tabs[b].id
  end)

  for _, name in ipairs(names) do
    local hl
    if name == current_tab then
      hl = "%#Visual#"
    else
      hl = "%#Normal#"
    end
    tab = tab .. " " .. hl .. " " .. name .. " (" .. tostring(tabs[name].id) .. ") " .. "%#Normal#"
  end

  return tab
end

function M.panel()
  vim.cmd.split()

  local tab = tabs[current_tab] or { id = 0, bufnr = vim.api.nvim_create_buf(false, true) }

  vim.api.nvim_win_set_buf(0, tab.bufnr)
  vim.api.nvim_win_set_height(0, 30)
  vim.wo.number = false
  vim.wo.scrolloff = 0
  vim.wo.winbar = [[%{%v:lua.require('output_panel').winbar()%}]]
  output_panel_winid = vim.api.nvim_get_current_win()
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
      if client then
        local tab = create_tab(client.name)

        local message = vim.split("[" .. vim.lsp.protocol.MessageType[result.type] .. "] " .. result.message, "\n")

        local bufnr = tab.bufnr

        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, message)
      end
    end
  end
end

return M
