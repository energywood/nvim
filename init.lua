-- Presetup
-- Run command cargo install proximity-sort
-- always set leader first!
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "


-- always draw sign column. prevents buffer moving when adding/deleting sign
vim.opt.signcolumn = 'yes'

-- keep more context on screen while scrolling
vim.opt.scrolloff = 2

-- sweet sweet relative line numbers
vim.opt.relativenumber = true
-- and show the absolute line number for the current line
vim.opt.number = true

-- infinite undo!
-- NOTE: ends up in ~/.local/state/nvim/undo/
vim.opt.undofile = true

-------------------------------------------------------------------------------
--
-- hotkeys
--
-------------------------------------------------------------------------------
-- quick-open
vim.keymap.set('', '<C-p>', '<cmd>Files<cr>')
-- search buffers
vim.keymap.set('n', '<leader>;', '<cmd>Buffers<cr>')
-- quick-save
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>')



-- Plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- auto-cd to root of git project
  -- 'airblade/vim-rooter'
  {
	'notjedi/nvim-rooter.lua',
	config = function()
	require('nvim-rooter').setup()
	end
  },
	-- fzf support for ^p
	{
		'junegunn/fzf.vim',
		dependencies = {
			{ 'junegunn/fzf', dir = '~/.fzf', build = './install --all' },
		},
		config = function()
			-- stop putting a giant window over my editor
			vim.g.fzf_layout = { down = '~20%' }
			-- when using :Files, pass the file list through
			--
			--   https://github.com/jonhoo/proximity-sort
			--
			-- to prefer files closer to the current file.
			function list_cmd()
				local base = vim.fn.fnamemodify(vim.fn.expand('%'), ':h:.:S')
				if base == '.' then
					-- if there is no current file,
					-- proximity-sort can't do its thing
					return 'fd --type file --follow'
				else
					return vim.fn.printf('fd --type file --follow | proximity-sort %s', vim.fn.shellescape(vim.fn.expand('%')))
				end
			end
			vim.api.nvim_create_user_command('Files', function(arg)
				vim.fn['fzf#vim#files'](arg.qargs, { source = list_cmd(), options = '--tiebreak=index' }, arg.bang)
			end, { bang = true, nargs = '?', complete = "dir" })
		end
	},
})
