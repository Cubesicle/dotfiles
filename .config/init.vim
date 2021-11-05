" Source plugins
source $HOME/.config/nvim/vim-plug/plugins.vim

" Vim stuff
set ignorecase
set smartcase
set number
set mouse=a


" Colors
set termguicolors
colorscheme dracula

" Font
set encoding=utf8
set guifont=CodeNewRoman\ Nerd\ Font:h20

" NERDTree
autocmd VimEnter * NERDTree
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" System clipboard
set clipboard+=unnamedplus
nnoremap y "+y
vnoremap y "+y
nnoremap p "+p
inoremap <c-s-v> <c-r>+
cnoremap <c-s-v> <c-r>+
inoremap <c-r> <c-v>

" Neovide stuff
let g:neovide_refresh_rate=144
