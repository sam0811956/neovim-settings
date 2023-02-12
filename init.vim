" Plugins
call plug#begin()
Plug 'EdenEast/nightfox.nvim'
Plug 'ojroques/nvim-hardline'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'romgrk/barbar.nvim'
Plug 'preservim/nerdtree'
Plug 'thoughtbot/vim-rspec'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-fugitive'
Plug 'williamboman/nvim-lsp-installer'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } 
Plug 'junegunn/fzf.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'
Plug 'hrsh7th/vim-vsnip'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'sharkdp/fd'
Plug 'BurntSushi/ripgrep'
Plug 'ludovicchabant/vim-gutentags'
Plug 'skywind3000/gutentags_plus'
Plug 'yegappan/taglist'
Plug 'nvim-treesitter/nvim-treesitter'
call plug#end()

""""""""""""""""""""""" Regular configuration
let mapleader = ","
imap ,, <Esc>
set ru
" Show the line number
set number
" Enable Syntax Highlighting
" Enable using the mouse to click or select some peace of code
set mouse=
" Set copy to clipboard
set clipboard=unnamed
" Set the Tab to 2 spaces
set ai
set tabstop=2
set shiftwidth=2
" barbar tag
nnoremap gt :bnext<CR>
nnoremap gT :bprevious<CR>
nnoremap gd <Cmd>BufferClose<CR>
""""""""""""""""""""" theme
set termguicolors
lua require('hardline').setup {}
"lua require('nvim-web-devicons').get_icon(filename, extension, { default = true })
lua require('nvim-web-devicons').get_icons()
syntax enable
colorscheme nightfox
""""""""""""" nerdtree
nnoremap nt :NERDTreeToggle<CR>
nnoremap nf :NERDTreeFind<CR>
let g:NERDTreeWinSize=20
"""""""" taglist
nnoremap <leader>tl :Tlist<CR>
" nvim-compe
lua << EOF
vim.o.completeopt = "menuone,noselect"

require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = false;

  source = {
    path = true;
    buffer = true;
    calc = true;
    vsnip = true;
    nvim_lsp = true;
    nvim_lua = true;
    spell = true;
    tags = true;
    snippets_nvim = true;
    treesitter = true;
  };
}
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    -- If <S-Tab> is not working in your terminal, change it to <C-h>
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
EOF


""" telescope
lua << EOF
local actions = require("telescope.actions")
require('telescope').setup {
	defaults = {
		mappings = {
			i = {
				["<esc>"] = actions.close,
				["<C-k>"] = actions.move_selection_previous,
				["<C-j>"] = actions.move_selection_next,
			}
		},
		extensions = {
			fzf = {
				fuzzy = true,                    -- false will only do exact matching
				override_generic_sorter = true,  -- override the generic sorter
				override_file_sorter = true,     -- override the file sorter
				case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
			}
		}
	}
}

require('telescope').load_extension('fzf')
EOF

nnoremap FF <cmd>Telescope live_grep<cr>
nnoremap FB <cmd>Telescope buffers<cr>
nnoremap <silent> <C-p> <cmd>Telescope find_files<CR>

" ctags
" gutentags搜尋工程目錄的標誌，碰到這些檔案/目錄名就停止向上一級目錄遞迴 "
let $GTAGSLABEL = 'native'
let $GTAGSCONF = '/usr/local/share/gtags/gtags.conf'
let g:gutentags_project_root = ['.root', '.git']
let g:gutentags_ctags_tagfile = '.tags'
let g:gutentags_modules = []

if executable('ctags')
	let g:gutentags_modules += ['ctags']
endif
if executable('gtags-cscope') && executable('gtags')
	let g:gutentags_modules += ['gtags_cscope']
endif

" 將自動生成的 tags 檔案全部放入 ~/.cache/tags 目錄中，避免污染工程目錄 "
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
" 檢測 ~/.cache/tags 不存在就新建 "
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

" 組態 ctags 的參數 "
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+pxI']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']
let g:gutentags_auto_add_gtags_cscope = 0
