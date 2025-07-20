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
  
  local function open_results_buffer()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, results)
    vim.api.nvim_buf_set_option(buf, 'filetype', filetype)
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    
    vim.cmd('vsplit')
    vim.api.nvim_win_set_buf(0, buf)
    
    local function setup_buffer_keymaps()
      local opts = { buffer = buf, silent = true }
      
      vim.keymap.set('n', 'yy', function()
        local line = vim.api.nvim_get_current_line()
        vim.fn.setreg('"', line)
        vim.notify("Yanked: " .. line:sub(1, 50) .. "...")
      end, opts)
      
      vim.keymap.set('v', 'y', function()
        vim.cmd('normal! "vy')
        local yanked = vim.fn.getreg('"')
        vim.notify("Yanked " .. vim.fn.len(vim.split(yanked, '\n')) .. " lines")
      end, opts)
      
      vim.keymap.set('n', 'Y', function()
        vim.cmd('normal! ggVG"yy')
        vim.notify("Yanked entire cheat sheet")
      end, opts)
      
      vim.keymap.set('n', 'q', function()
        vim.cmd('close')
      end, opts)
      
      vim.keymap.set('n', '<Esc>', function()
        vim.cmd('close')
      end, opts)
    end
    
    setup_buffer_keymaps()
    
    vim.api.nvim_buf_set_name(buf, "cht.sh: " .. query)
    vim.notify("Use visual mode to select, 'y' to yank, 'Y' for all, 'q' to quit")
  end
  
  pickers.new({}, {
    prompt_title = "cht.sh: " .. query .. " (Press <Enter> to open full buffer)",
    finder = finders.new_table {
      results = results,
    },
    sorter = conf.generic_sorter({}),
    layout_config = {
      preview = false,
    },
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        open_results_buffer()
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