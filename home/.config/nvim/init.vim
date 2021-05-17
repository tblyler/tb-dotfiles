scriptencoding utf-8

function GoPostUpdate()
	:GoInstallBinaries
	:GoUpdateBinaries
endfunction

" automatically install vim-plug if it doesn't exist
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" disable ALE LSP since we have coc.nvim
let g:ale_disable_lsp = 1

call plug#begin($HOME.'/.nvim/plugged')

Plug 'morhetz/gruvbox' " color scheme

Plug 'airblade/vim-gitgutter'                                                    " show file changes for git VCS
Plug 'bronson/vim-trailing-whitespace'                                           " per the name, remove trailing whitespace
Plug 'easymotion/vim-easymotion'                                                 " easy code navigation with <Leader><Leader>
Plug 'editorconfig/editorconfig-vim'                                             " EditorConfig support
Plug 'fatih/vim-go', { 'do': ':exec GoPostUpdate()' }                            " THE Go plugin
Plug 'junegunn/fzf', { 'do': { -> fzf#install } }                                " fast file name search
Plug 'majutsushi/tagbar'                                                         " class & variable lister
Plug 'mg979/vim-visual-multi', { 'branch': 'master' }                            " multi cursor support
Plug 'mhinz/vim-signify'                                                         " show file changes for pretty much any VCS
Plug 'mileszs/ack.vim'                                                           " easy code searching
Plug 'moll/vim-bbye'                                                             " Bdelete a buffer without removing the split
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': { -> coc#util#install() }} " ezpz LSP support
Plug 'scrooloose/nerdcommenter'                                                  " perform quick comments with <Leader>
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }                           " shows a directory view
Plug 'sheerun/vim-polyglot'                                                      " highlighting & indent for languages
Plug 'tpope/vim-fugitive'                                                        " awesome git support
Plug 'tpope/vim-sensible'                                                        " some obviously sane default config changes
Plug 'tpope/vim-surround'                                                        " easy surrounding modifier
Plug 'vim-airline/vim-airline'                                                   " nice lightweight status line
Plug 'vim-airline/vim-airline-themes'                                            " themes for vim-airline
Plug 'w0rp/ale'                                                                  " async linting engine

call plug#end()

" speed improvements for fzf
if executable('ag')
	let $FZF_DEFAULT_COMMAND = 'ag --skip-vcs-ignores --nocolor -g "" -l'
	let g:ackprg = 'ag --vimgrep'
endif

set background=dark                             " make sure dark mode is used
autocmd vimenter * ++nested colorscheme gruvbox " Color scheme
set laststatus=2                                " Enable airline
let g:airline_theme = 'gruvbox'                 " Airline color scheme
let g:airline#extensions#tabline#enabled = 1    " Enable tab list in airline
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#whitespace#mixed_indent_algo = 1
let g:airline_powerline_fonts = 1
set list                                        " Show tabs
set listchars=tab:\|\ ,trail:·                  " Show whitestape by using the pipe symbol and dots
set tabstop=4                                   " Tabs look like 4 spaces
set softtabstop=0 noexpandtab                   " Tabs look like 4 spaces
set shiftwidth=4                                " Tabs look like 4 spaces
set number                                      " Show line numbers
set cursorline                                  " Highlight entire line that cursor is on
let g:tagbar_left = 1                           " Make tagbar appear on the left
autocmd CompleteDone * pclose                   " Remove scratchpad after selection
set mouse=                                      " Disable mouse
set lazyredraw                                  " Make large files bearable
set regexpengine=1                              " Make searching large files bearable

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

" Key mappings
" use FZF for control p
map <C-p> :FZF <CR>
map <F2> :NERDTreeToggle <CR>
map <F3> :TagbarToggle <CR>
