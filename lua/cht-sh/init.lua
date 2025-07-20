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

local function strip_ansi_codes(text)
  return text:gsub("\27%[[0-9;]*m", "")
end

local function get_language_from_filetype(filetype)
  local lang_map = {
    javascript = "js",
    typescript = "js",
    typescriptreact = "js",
    javascriptreact = "js",
    python = "python",
    lua = "lua",
    rust = "rust",
    go = "go",
    cpp = "cpp",
    c = "c",
    java = "java",
    php = "php",
    ruby = "ruby",
    shell = "bash",
    sh = "bash",
    bash = "bash",
    zsh = "bash",
    vim = "vim",
    sql = "sql",
    html = "html",
    css = "css",
    scss = "css",
    sass = "css",
    json = "json",
    yaml = "yaml",
    yml = "yaml",
    markdown = "markdown",
    dockerfile = "docker",
    makefile = "make",
  }
  
  return lang_map[filetype] or filetype
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
    local clean_result = strip_ansi_codes(result)
    local lines = vim.split(clean_result, "\n")
    
    local filtered_lines = {}
    for _, line in ipairs(lines) do
      if line:match("%S") then
        table.insert(filtered_lines, line)
      end
    end
    
    return #filtered_lines > 0 and filtered_lines or {"No results found for: " .. query}, query
  else
    return {"No results found for: " .. query}, query
  end
end

local function get_filetype_from_query(query)
  local lang_to_ft = {
    js = "javascript",
    javascript = "javascript", 
    python = "python",
    lua = "lua",
    rust = "rust",
    go = "go",
    cpp = "cpp",
    c = "c",
    java = "java",
    php = "php",
    ruby = "ruby",
    bash = "bash",
    shell = "bash",
    sh = "bash",
    vim = "vim",
    sql = "sql",
    html = "html",
    css = "css",
    json = "json",
    yaml = "yaml",
    dockerfile = "dockerfile",
    make = "make",
  }
  
  local lang = query:match("^([^/]+)/")
  return lang and lang_to_ft[lang] or "text"
end

function M.show_result_picker(query, results)
  local filetype = get_filetype_from_query(query)
  
  local function create_highlighted_buffer()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, results)
    vim.api.nvim_buf_set_option(buf, 'filetype', filetype)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    return buf
  end
  
  pickers.new({}, {
    prompt_title = "cht.sh: " .. query,
    results_title = "Results (" .. filetype .. ")",
    finder = finders.new_table {
      results = results,
    },
    sorter = conf.generic_sorter({}),
    layout_config = {
      preview_width = 0.6,
    },
    previewer = require('telescope.previewers').new_buffer_previewer({
      title = "Full Content",
      define_preview = function(self, entry, status)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, results)
        vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', filetype)
      end
    }),
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
      
      map('i', '<C-v>', function()
        actions.close(prompt_bufnr)
        local buf = create_highlighted_buffer()
        vim.cmd('vsplit')
        vim.api.nvim_win_set_buf(0, buf)
      end)
      
      map('n', '<C-v>', function()
        actions.close(prompt_bufnr)
        local buf = create_highlighted_buffer()
        vim.cmd('vsplit')
        vim.api.nvim_win_set_buf(0, buf)
      end)
      
      return true
    end,
  }):find()
end

function M.search()
  local filetype = vim.bo.filetype
  local lang = filetype ~= "" and get_language_from_filetype(filetype) or ""
  local prompt = lang ~= "" and string.format("cht.sh query (%s): ", lang) or "cht.sh query: "
  
  vim.ui.input({ prompt = prompt }, function(input)
    if input and input ~= "" then
      local query = input
      if lang ~= "" and not input:match("/") then
        query = lang .. "/" .. input
      end
      
      local results, final_query = M.fetch_cheat_sheet(query)
      if results then
        M.show_result_picker(final_query, results)
      end
    end
  end)
end

function M.search_current_word()
  local word = vim.fn.expand("<cword>")
  if word and word ~= "" then
    local filetype = vim.bo.filetype
    local lang = filetype ~= "" and get_language_from_filetype(filetype) or ""
    local query = lang ~= "" and (lang .. "/" .. word) or word
    
    local results, final_query = M.fetch_cheat_sheet(query)
    if results then
      M.show_result_picker(final_query, results)
    end
  else
    vim.notify("No word under cursor", vim.log.levels.WARN)
  end
end

function M.search_language()
  local filetype = vim.bo.filetype
  local lang = filetype ~= "" and get_language_from_filetype(filetype) or ""
  
  if lang == "" then
    vim.notify("No language detected for current buffer", vim.log.levels.WARN)
    return
  end
  
  local results, final_query = M.fetch_cheat_sheet(lang)
  if results then
    M.show_result_picker(final_query, results)
  end
end

return M