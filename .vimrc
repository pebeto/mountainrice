call plug#begin()
    Plug 'vim-syntastic/syntastic'
    Plug 'godlygeek/tabular'
    Plug 'altercation/vim-colors-solarized'
    Plug 'sheerun/vim-polyglot'
    Plug 'xuhdev/vim-latex-live-preview', { 'for': 'tex' }
    Plug 'alvan/vim-closetag'
    Plug 'jiangmiao/auto-pairs'
    Plug 'StanAngeloff/php.vim'
    Plug 'airblade/vim-gitgutter'
    Plug 'keith/swift.vim'
    Plug 'vim-perl/vim-perl'
    Plug 'scrooloose/nerdtree'
    Plug 'tpope/vim-surround'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'Valloric/YouCompleteMe'
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
    Plug 'scrooloose/nerdcommenter'
    Plug 'suan/vim-instant-markdown', { 'for': 'markdown' }
call plug#end()

let g:livepreview_previewer = 'zathura'
let g:airline_powerline_fonts = 1
let g:airline_theme = 'ravenpower'
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#keymap#enabled = 0
let g:airline#extensions#syntastic#enabled = 0
let g:airline#extensions#wordcount#enabled = 0
let g:airline#extensions#po#enabled = 0
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
let g:ycm_autoclose_preview_window_after_completion = 1
let g:UltiSnipsExpandTrigger = "<C-w>"
let g:UltiSnipsJumpForwardTrigger = "<C-b>"
let g:UltiSnipsJumpBackwardTrigger = "<C-z>"
let mapleader = ","

set timeout timeoutlen=1500
set nocompatible
set encoding=utf-8
set nowrap
set t_Co=256 
set number
set smartindent
set autoindent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set expandtab
set laststatus=2
set splitbelow
set splitright
set noshowmode
set backspace=indent,eol,start
set background=dark

if ($TERM == 'linux')
		colorscheme default
else
		colorscheme solarized
endif

so ~/.vim/plugged/vim-colors-solarized/autoload/togglebg.vim
map <C-o> :NERDTreeToggle<CR>
map <C-p> :LLPStartPreview<CR>
