local M = {}

local telescope = require('telescope')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

M.config = {
  base_url = "https://cht.sh/",
  default_lang = nil,
  keymap = "<leader>ch",
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

function M.fetch_cheat_sheet(query)
  local url = M.config.base_url .. query
  local cmd = string.format("curl -s '%s'", url)
  
  local handle = io.popen(cmd)
  if not handle then
    vim.notify("Failed to execute curl command", vim.log.levels.ERROR)
    return nil
  end
  
  local result = handle:read("*a")
  handle:close()
  
  if result and result ~= "" then
    return vim.split(result, "\n")
  else
    return {"No results found for: " .. query}
  end
end

function M.show_result_picker(query, results)
  pickers.new({}, {
    prompt_title = "cht.sh: " .. query,
    finder = finders.new_table {
      results = results,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        
        if selection then
          vim.fn.setreg('"', selection.value)
          vim.notify("Copied to clipboard: " .. selection.value:sub(1, 50) .. "...")
        end
      end)
      
      map('i', '<C-y>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          vim.fn.setreg('"', selection.value)
          vim.notify("Yanked: " .. selection.value:sub(1, 50) .. "...")
        end
      end)
      
      return true
    end,
  }):find()
end

function M.search()
  vim.ui.input({ prompt = "cht.sh query: " }, function(input)
    if input and input ~= "" then
      local results = M.fetch_cheat_sheet(input)
      if results then
        M.show_result_picker(input, results)
      end
    end
  end)
end

function M.search_current_word()
  local word = vim.fn.expand("<cword>")
  if word and word ~= "" then
    local filetype = vim.bo.filetype
    local query = filetype ~= "" and (filetype .. "/" .. word) or word
    
    local results = M.fetch_cheat_sheet(query)
    if results then
      M.show_result_picker(query, results)
    end
  else
    vim.notify("No word under cursor", vim.log.levels.WARN)
  end
end

return M