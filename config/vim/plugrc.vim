" -----------------------------------------------------------------------------
"  Dependency Check
"
if !executable('git')
  echo '"git" is required for vim-plug installation.'
  finish
endif

if !has('win32') && !('win64')
  if !executable('curl') && !executable('wget')
    echo '"curl" or "wget" is required for vim-plug installation.'
    finish
  endif
endif


" -----------------------------------------------------------------------------
"  Initialize variables
"
let s:plugvim_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
let s:plugin_home = expand('$HOME/.vim/plugged')

if exists('$VIM_PLUGIN_HOME')
  s:plugin_home = expand('$VIM_PLUGIN_HOME')
else
  if has('win32') || has('win64')
    s:plugin_home = expand('$HOME/vimfiles/plugged')
  endif
endif

if !isdirectory(s:plugin_home)
  call mkdir(s:plugin_home, 'p')
endif

let s:plugvim_file = s:plugin_home . '/plug.vim'


" -----------------------------------------------------------------------------
"  Download plug.vim
"
if !filereadable(s:plugvim_file)
  if has('win32') || has('win64')
    silent execute '!iwr -useb ' . s:plugvim_url . ' | ni ' . s:plugvim_file . ' -Force'
  else
    if executable('curl')
      silent execute '!curl -fLo ' . s:plugvim_file . ' ' .  s:plugvim_url
    elseif executable('wget')
      silent execute '!wget -O ' . s:plugvim_file . ' ' . s:plugvim_url
    endif
  endif

  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" -----------------------------------------------------------------------------
"  Load plug.vim
"
autocmd FuncUndefined plug#* execute 'source ' . s:plugvim_file


" -----------------------------------------------------------------------------
"  Begin plugin section
"
call plug#begin(s:plugin_home)


" -----------------------------------------------------------------------------
"  plugin: vim-plug
"
Plug 'junegunn/vim-plug'


" -----------------------------------------------------------------------------
"  plugin: editorconfig
"
if !has('patch-9.0.1799')
  Plug 'editorconfig/editorconfig-vim'
endif


" -----------------------------------------------------------------------------
"  plugin: tinted-vim
"
if has('patch-8.0.1038')
  Plug 'tinted-theming/tinted-vim'

  autocmd VimEnter *
        \ if has('termguicolors')                                             |
        \   set termguicolors                                                 |
        \ endif                                                               |
        \ colorscheme base16-eighties                                         |
        \ hi MatchParen guibg=#747369                                         |
        \ hi helpHyperTextJump cterm=underline ctermfg=15
else
  Plug 'chriskempson/base16-vim'

  let base16colorspace=256

  autocmd VimEnter *
        \ if has('termguicolors')                                             |
        \   set termguicolors                                                 |
        \ endif                                                               |
        \ colorscheme base16-eighties
endif


" -----------------------------------------------------------------------------
"  plugin: vim-lsp
"
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

let g:lsp_diagnostics_signs_enabled = 0
let g:lsp_document_code_action_signs_enabled = 0
let g:lsp_diagnostics_virtual_text_enabled = 0

let g:lsp_diagnostics_highlights_enabled = 1
let g:lsp_diagnostics_highlights_insert_mode_enabled = 1

let g:lsp_diagnostics_float_cursor = 1
let g:lsp_diagnostics_float_insert_mode_enabled = 1

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=no
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> gs <plug>(lsp-document-symbol-search)
  nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
  nmap <buffer> gr <plug>(lsp-references)
  nmap <buffer> gi <plug>(lsp-implementation)
  nmap <buffer> gt <plug>(lsp-type-definition)

  " <leader> is backslash by default
  nmap <buffer> <leader>rn <plug>(lsp-rename)

  nmap <buffer> [g <plug>(lsp-next-diagnostic)
  nmap <buffer> ]g <plug>(lsp-previous-diagnostic)
  nmap <buffer> gl <plug>(lsp-document-diagnostics)
  nmap <buffer> ca <plug>(lsp-code-action-float)

  nmap <buffer> K <plug>(lsp-hover)

  nnoremap <buffer> <expr><C-J> lsp#scroll(+4)
  nnoremap <buffer> <expr><C-K> lsp#scroll(-4)

  autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
endf

augroup lsp_install
  autocmd!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END


" -----------------------------------------------------------------------------
"  plugin: asyncomplete
"
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'


" -----------------------------------------------------------------------------
"  plugin: vim-osyank
"
if exists('##TextYankPost')
  Plug 'ojroques/vim-oscyank'

  let g:oscyank_silent = v:true

  let s:vim_oscyank_registers = ['', '+', '*']
  let s:vim_oscyank_operators = ['y', 'd']

  function! s:vim_oscyank_callback(event)
    if index(s:vim_oscyank_registers, a:event.regname)  != -1 &&
          \ index(s:vim_oscyank_operators, a:event.operator) != -1
      call OSCYankRegister(a:event.regname)
    endif
  endfunction

  augroup VimOSCYankPost
    autocmd!
    autocmd TextYankPost * call s:vim_oscyank_callback(v:event)
  augroup END
endif


" -----------------------------------------------------------------------------
"  plugin: cscope-maps
"
Plug 'joe-skb7/cscope-maps'


" -----------------------------------------------------------------------------
"  plugin: Vimjas/vim-python-pep8-indent
"
Plug 'Vimjas/vim-python-pep8-indent'


" -----------------------------------------------------------------------------
"  plugin: vimdoc-ja
"
Plug 'vim-jp/vimdoc-ja'


" -----------------------------------------------------------------------------
"  plugin: vim-abnf
"
Plug 'navalux/vim-abnf'


" -----------------------------------------------------------------------------
"  plugin: vim-css3-syntax
"
Plug 'hail2u/vim-css3-syntax'


" -----------------------------------------------------------------------------
"  Update rtp and initialize plugin system
"
call plug#end()
