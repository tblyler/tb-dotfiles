scriptencoding utf-8

let s:uname = system("echo -n \"$(uname)\"")
if v:shell_error
	let s:uname = 'Unknown'
endif

function GoPostUpdate()
	:GoInstallBinaries
	:GoUpdateBinaries
endfunction

" automatically install vim-plug if it doesn't exist
if empty(glob('~/.vim/autoload/plug.vim'))
	silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin($HOME.'/.nvim/plugged')

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
let g:deoplete#enable_at_startup = 1

Plug 'Chiel92/vim-autoformat'
Plug 'Lokaltog/vim-easymotion'
Plug 'airblade/vim-gitgutter'
Plug 'bling/vim-airline'
Plug 'bronson/vim-trailing-whitespace'
Plug 'fatih/vim-go', { 'do': ':exec GoPostUpdate()' }
Plug 'godlygeek/tabular'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'majutsushi/tagbar'
Plug 'moll/vim-bbye'
Plug 'nanotech/jellybeans.vim'
Plug 'rking/ag.vim'
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'sheerun/vim-polyglot'
Plug 'terryma/vim-multiple-cursors'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline-themes'
Plug 'w0rp/ale'

call plug#end()

" speed improvements for fzf
if executable('ag')
	let $FZF_DEFAULT_COMMAND = 'ag --skip-vcs-ignores --nocolor -g "" -l'
endif

colorscheme jellybeans                       " Color scheme
set laststatus=2                             " Enable airline
let g:airline_theme = 'jellybeans'           " Airline color scheme
let g:airline#extensions#tabline#enabled = 1 " Enable tab list in airline
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#whitespace#mixed_indent_algo = 1
let g:airline_powerline_fonts = 1
set list                                     " Show tabs
set listchars=tab:\|\ ,trail:·               " Show whitestape by using the pipe symbol and dots
set tabstop=4                                " Tabs look like 4 spaces
set softtabstop=0 noexpandtab                " Tabs look like 4 spaces
set shiftwidth=4                             " Tabs look like 4 spaces
set number                                   " Show line numbers
set cursorline                               " Highlight entire line that cursor is on
let g:tagbar_left = 1                        " Make tagbar appear on the left
autocmd CompleteDone * pclose                " Remove scratchpad after selection
set mouse=                                   " Disable mouse
set lazyredraw                               " Make large files bearable
set regexpengine=1                           " Make searching large files bearable

" make J work with docblocks and such (if possible)
if v:version > 703 || v:version == 703 && has('patch541')
	set formatoptions+=j
endif

" Enable syntax-highlighting for Go
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

" Use goimports instead of gofmt for import paths
let g:go_fmt_command = "goimports"

" Use golangci-lint instead of gometalinter for linting
let g:go_metalinter_command = "golangci-lint"

" Lint Go on save
let g:go_metalinter_autosave = 1

" make sure errcheck is enabled for autosave
let g:go_metalinter_autosave_enabled = ['govet', 'golint', 'errcheck', 'deadcode', 'errcheck', 'gosimple', 'ineffassign', 'staticcheck', 'structcheck', 'typecheck', 'unused', 'varcheck']

" enable autocompletion for Go
call deoplete#custom#option('omni_patterns', { 'go': '[^. *\t]\.\w*' })

" Key mappings
" use FZF for control p
map <C-p> :FZF <CR>
map <F2> :NERDTreeToggle <CR>
map <F3> :TagbarToggle <CR>
" clear search highlight until next search
map <F4> :noh <CR>
