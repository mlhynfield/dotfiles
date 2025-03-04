let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

Plug 'junegunn/vim-github-dashboard'
Plug 'preservim/nerdtree'

call plug#end()

map <F5> :NERDTreeToggle<CR>
map <F6> :NERDTreeFocus<CR>

set backspace=indent,eol,start

