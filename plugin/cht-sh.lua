if vim.g.loaded_cht_sh then
  return
end
vim.g.loaded_cht_sh = 1

local cht_sh = require('cht-sh')

vim.api.nvim_create_user_command('ChtSh', function(opts)
  if opts.args and opts.args ~= "" then
    local results = require('cht-sh').fetch_cheat_sheet(opts.args)
    if results then
      require('cht-sh').show_result_picker(opts.args, results)
    end
  else
    cht_sh.search()
  end
end, {
  nargs = '?',
  desc = 'Search cht.sh with optional query'
})

vim.api.nvim_create_user_command('ChtShWord', function()
  cht_sh.search_current_word()
end, {
  desc = 'Search cht.sh for word under cursor'
})

vim.api.nvim_create_user_command('ChtShLang', function()
  cht_sh.search_language()
end, {
  desc = 'Show cht.sh cheat sheet for current language'
})

local function setup_default_keymaps()
  vim.keymap.set('n', '<leader>ch', function() cht_sh.search() end, { desc = 'Search cht.sh' })
  vim.keymap.set('n', '<leader>cw', function() cht_sh.search_current_word() end, { desc = 'Search cht.sh for current word' })
  vim.keymap.set('n', '<leader>cL', function() cht_sh.search_language() end, { desc = 'Show cht.sh cheat sheet for current language' })
end

setup_default_keymaps()