let g:powerline_pycmd="py3"
execute pathogen#infect()

filetype plugin indent on

syntax on

set nocompatible
set number
set encoding=utf-8
set laststatus=2
set t_Co=256
set splitbelow
set splitright
set noshowmode
set tabstop=4
set background=dark

if ($TERM == 'linux')
		colorscheme default
else
		colorscheme solarized
endif

let g:livepreview_previewer = 'zathura'
so ~/.vim/bundle/vim-colors-solarized/autoload/togglebg.vim

map <C-o> :NERDTreeToggle<CR>
map <C-p> :LLPStartPreview<CR>
