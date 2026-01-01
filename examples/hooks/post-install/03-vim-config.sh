#!/usr/bin/env bash
# Example hook: Configure vim with modern defaults
# Place in: /etc/harmonize/hooks.d/post-install/

log "Configuring vim with modern defaults..."

install_packages vim

if [[ "$DRY_RUN" == "0" ]]; then
  # Create global vimrc
  cat > /etc/vim/vimrc.local <<'VIMRC'
" Harmonize vim configuration
" Modern sensible defaults

" Appearance
syntax on
set number
set relativenumber
set cursorline
set showmatch
set colorcolumn=80

" Indentation
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set smartindent

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch

" Performance
set lazyredraw
set ttyfast

" Usability
set mouse=a
set clipboard=unnamedplus
set backspace=indent,eol,start
set wildmenu
set wildmode=longest:full,full

" Files
set encoding=utf-8
set fileencoding=utf-8
set nobackup
set noswapfile
set undofile
set undodir=/tmp

" Splits
set splitbelow
set splitright

" Status line
set laststatus=2
set statusline=%F%m%r%h%w\ [%l/%L,%c]\ [%p%%]

" Better navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
VIMRC

  log "Created /etc/vim/vimrc.local"
fi

print_success "Vim configured with modern defaults"
