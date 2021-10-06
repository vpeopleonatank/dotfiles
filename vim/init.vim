set nocompatible
 """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
 """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 set history=500

 filetype plugin on
 filetype indent on

 set autoread
 au FocusGained,BufEnter * checktime

 let mapleader = " "

let maplocalleader = ","

 " Fast saving
 nmap <leader>w :w!<cr>
 nmap <c-s> :w!<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" Linebreak on 500 characters
"set lbr
"set tw=500

set ai "Auto indent
set si "Smart indent
" set wrap "Wrap lines

" Security
set modelines=0

" Show line numbers
set nu
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set rnu
  autocmd BufLeave,FocusLost,InsertEnter * set nornu
augroup END


" Show file stats
set ruler

" Blink cursor on error instead of beeping (grr)
set visualbell
set t_vb=
set cursorline

" Encoding
set encoding=utf-8

" Whitespace
set wrap
set textwidth=79
set formatoptions=tcqrn1
set tabstop=2
set shiftwidth=2
set softtabstop=2
set noshiftround

" Cursor motion
set scrolloff=3
set backspace=indent,eol,start
set matchpairs+=<:> " use % to jump between pairs
" runtime! macros/matchit.vim

" Move up/down editor lines
nnoremap j gj
nnoremap k gk

" Allow hidden buffers
set hidden

" Rendering
" set ttyfast
set lazyredraw


" Status bar
set laststatus=2

" Last line
set showmode
set showcmd

" Searching
nnoremap / /\v
vnoremap / /\v
set hlsearch
set incsearch
set ignorecase
set smartcase
" set showmatch
map <leader><space> :let @/=''<cr> " clear search

set wildmenu
set wildmode=longest:full,full

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git etc. anyway...
set nobackup
set nowb
set noswapfile

"
" =============================================================================================================================
"	config copy
" =============================================================================================================================

nnoremap <c-p> "0p
"Delete without yank
nnoremap <leader>d "_d
vnoremap <leader>d "_d
nnoremap x "_x

 nnoremap ,c "+Y
 vnoremap ,c "+y
 " nnoremap <leader>y "+Y
 " vnoremap <leader>y "+y
 nnoremap ,p "+p
 vnoremap ,p "+p
 nnoremap gA :%y+<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Split window
nmap sq :close<Return>
nmap sm :split<Return><C-w>w
nmap sn :vsplit<Return><C-w>w
" Move window
"nmap s<Space> <C-w>w
map s<left> <C-w>h
map s<up> <C-w>k
map s<down> <C-w>j
map s<right> <C-w>l
map sh <C-w>h
map sk <C-w>k
map sj <C-w>j
map sl <C-w>l

" Resize window
nnoremap <leader>[ :vertical resize -5<cr>
nnoremap <leader>] :vertical resize +5<cr>

nmap <silent> `    :BufferNext<cr>
nmap <silent> ~    :BufferPrevious<cr>

" Close the current buffer
nmap <silent> <Leader>xn    <Plug>BufKillBack
nmap <silent> <Leader>xp    <Plug>BufKillForward
nmap <silent> <A-w>    :BufferClose<CR>
nmap <silent> <Leader>xu    <Plug>BufKillUndo

" Switch CWD to the directory of the open buffer
" map <leader>cd :cd %:p:h<cr>:pwd<cr>

"map <leader>q gqip

map <leader>q :qa!<CR>

map <leader>s :w<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^

" Delete trailing white space on save, useful for some filetypes ;)
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

if has("autocmd")
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
endif

imap <c-h> <bs>
imap <c-d> <del>
imap <c-u> <C-G>u<C-U>
imap <c-b> <Left>
imap <c-f> <Right>
imap <c-a> <ESC>^i
imap <c-e> <End>
imap <c-g> <ESC>o
imap <c-k> <Esc>O

" command line mode
cmap <C-p> <Up>
cmap <C-n> <Down>
cmap <C-b> <Left>
cmap <C-f> <Right>
cmap <C-a> <Home>
cmap <C-e> <End>
cnoremap <C-d> <Del>
cnoremap <C-h> <BS>
cnoremap <C-k> <C-f>D<C-c><C-c>:<Up>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Save with root permission
command! W w !sudo tee > /dev/null %

" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction

set mouse+=a
if has('nvim')
    set mouse+=nicr
endif
" set clipboard+=unnamed,unnamedplus
if has('nvim')
    let g:loaded_clipboard_provider = 0
    unlet g:loaded_clipboard_provider
    runtime autoload/provider/clipboard.vim
endif

filetype off

" TODO: Load plugins here (pathogen or vundle)
call plug#begin('~/.vim/plugged')
Plug 'sirver/ultisnips'
let g:UltiSnipsExpandTrigger = '<c-l>'
" let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
" autocmd BufEnter,BufNew *.md setf md.tex
Plug 'honza/vim-snippets'
Plug 'mattn/emmet-vim', { 'for': ['html', 'htmldjango']}
Plug 'mg979/vim-visual-multi'
Plug 'jiangmiao/auto-pairs'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
noremap <leader>mo :MarkdownPreview<CR>
noremap <leader>mc :MarkdownPreviewStop<CR>
" noremap <leader>mt <Plug>MarkdownPreviewToggle

" Plug 'liuchengxu/vim-which-key'
Plug 'folke/which-key.nvim'
set timeoutlen=100
" nnoremap <silent> <leader>      :<c-u>WhichKey ','<CR>
" nnoremap <silent> <localleader> :<c-u>WhichKey  ';'<CR>
Plug 'qpkorr/vim-bufkill'

Plug 'jpalardy/vim-slime', { 'for': 'python' }
Plug 'hanschen/vim-ipython-cell', { 'for': 'python' }
Plug 'liuchengxu/vista.vim'
nnoremap <leader>i :Vista<CR>
Plug 'Asheq/close-buffers.vim'
Plug 'thaerkh/vim-workspace'
" let g:workspace_autosave_always = 0
let g:workspace_autosave = 0
let g:workspace_session_directory = $HOME . '/.cache/.nvim/sessions/'
let g:workspace_undodir= $HOME . '/.cache/.nvim/.undodir'
nnoremap <leader>ts :ToggleWorkspace<CR>

Plug 'kkoomen/vim-doge', { 'do': { -> doge#install()  }  }
let g:doge_doc_standard_python = 'google'
nnoremap ,gd :DogeGenerate<CR>

Plug 'lervag/vimtex'
Plug 'KeitaNakamura/tex-conceal.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'wellle/tmux-complete.vim'
Plug 'tpope/vim-commentary'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
Plug 'tpope/vim-fugitive'
" UI
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update

Plug 'ChristianChiarulli/nvcode-color-schemes.vim'
Plug 'sheerun/vim-polyglot'
Plug 'ryanoasis/vim-devicons'
Plug 'itchyny/lightline.vim'
Plug 'niklaas/lightline-gitdiff'

Plug 'kyazdani42/nvim-web-devicons'
Plug 'romgrk/barbar.nvim'
nmap <leader>1 :BufferGoto 1<CR>
nmap <leader>2 :BufferGoto 2<CR>
nmap <leader>3 :BufferGoto 3<CR>
nmap <leader>4 :BufferGoto 4<CR>
nmap <leader>5 :BufferGoto 5<CR>
nmap <leader>6 :BufferGoto 6<CR>
nmap <leader>7 :BufferGoto 7<CR>
nmap <leader>8 :BufferGoto 8<CR>
nmap <leader>9 :BufferGoto 9<CR>
nmap <leader>0 :BufferGoto 0<CR>

" Plug 'kyazdani42/nvim-tree.lua'
"  nmap <leader>e :NvimTreeToggle<CR>

" React
Plug 'peitalin/vim-jsx-typescript'
Plug 'mlaursen/vim-react-snippets'
Plug 'styled-components/vim-styled-components'
Plug 'neoclide/vim-jsx-improve'
Plug 'vuki656/package-info.nvim'

Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/asyncrun.extra'
Plug 'benmills/vimux'
" Plug 'skywind3000/vim-terminal-help'

Plug 'voldikss/vim-floaterm'

let g:floaterm_position = 'center'
let g:floaterm_wintype = 'popup'

" Set floaterm window's background to black
hi Floaterm guibg=black
" Set floating window border line color to cyan, and background to orange
" hi FloatermBorder guibg=orange guifg=cyan

nnoremap   <silent>   <F7>    :FloatermNew<CR>
tnoremap   <silent>   <F7>    <C-\><C-n>:FloatermNew<CR>
nnoremap   <silent>   <F8>    :FloatermPrev<CR>
tnoremap   <silent>   <F8>    <C-\><C-n>:FloatermPrev<CR>
nnoremap   <silent>   <F9>    :FloatermNext<CR>
tnoremap   <silent>   <F9>    <C-\><C-n>:FloatermNext<CR>
nnoremap   <silent>   <F12>   :FloatermToggle<CR>
tnoremap   <silent>   <F12>   <C-\><C-n>:FloatermToggle<CR>
" nnoremap <silent> <Leader>gz :<C-u>FloatermNew height=0.7 width=0.8 lazygit<CR>
nnoremap <silent> <Leader>gz :FloatermNew --height=0.8 --width=0.8 lazygit<CR>

nnoremap <silent> <C-_>  :FloatermNew --height=0.5 --width=0.5 --wintype=popup --position=bottomright<CR>

" let g:floaterm_keymap_kill = '<C-t>q'

let g:floaterm_autoclose = 1


Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

nnoremap <leader>ft :Vista finder<CR>
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fa :RG<CR>
nnoremap <leader>fg :GF?<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fl :BLines<CR>

Plug 'nvim-lua/plenary.nvim'
Plug 'lewis6991/gitsigns.nvim'

Plug 'tyru/open-browser.vim'
Plug 'aklt/plantuml-syntax'
Plug 'weirongxu/plantuml-previewer.vim'
call plug#end()

filetype plugin indent on
syntax on


 "
 " =============================================================================================================================
 "	config coc.nvim
 " =============================================================================================================================
 "

 " Use tab for trigger cVompletion with characters ahead and navigate.
 " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
 " other plugin before putting this into your config.
 inoremap <silent><expr> <TAB>
   \ pumvisible() ? "\<C-n>" :
   \ <SID>check_back_space() ? "\<TAB>" :
   \ coc#refresh()
 inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

 function! s:check_back_space() abort
   let col = col('.') - 1
   return !col || getline('.')[col - 1]  =~# '\s'
 endfunction


 inoremap <silent><expr> <c-space> coc#refresh()

 " Use <c-space> to trigger completion.
 if has('nvim')
   inoremap <silent><expr> <c-space> coc#refresh()
 else
   inoremap <silent><expr> <c-@> coc#refresh()
 endif

 " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
 " position. Coc only does snippet and additional edit on confirm.
 " <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
 if exists('*complete_info')
   inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
 else
   inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
 endif

 " Use `[g` and `]g` to navigate diagnostics
 " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
 nmap <silent> [g <Plug>(coc-diagnostic-prev)
 nmap <silent> ]g <Plug>(coc-diagnostic-next)

 " GoTo code navigation.
 nmap <silent> gd <Plug>(coc-definition)
 nmap <silent> gy <Plug>(coc-type-definition)
 nmap <silent> gi <Plug>(coc-implementation)
 nmap <silent> gr <Plug>(coc-references)

 " Use K to show documentation in preview window.
 nnoremap <silent> K :call <SID>show_documentation()<CR>

 function! s:show_documentation()
   if (index(['vim','help'], &filetype) >= 0)
     execute 'h '.expand('<cword>')
   else
     call CocAction('doHover')
   endif
 endfunction

 " Symbol renaming.
 nmap <leader>rn <Plug>(coc-rename)

 " Formatting selected code.
 xmap <leader>F  <Plug>(coc-format-selected)
 nmap <leader>F  :Format<CR>

 augroup mygroup
   autocmd!
   " Setup formatexpr specified filetype(s).
   autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
   " Update signature help on jump placeholder.
   autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
 augroup end

 " Introduce function text object
 " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
 xmap if <Plug>(coc-funcobj-i)
 xmap af <Plug>(coc-funcobj-a)
 omap if <Plug>(coc-funcobj-i)
 omap af <Plug>(coc-funcobj-a)

 " Add `:Format` command to format current buffer.
 command! -nargs=0 Format :call CocAction('format')

 " Add `:Fold` command to fold current buffer.
 command! -nargs=? Fold :call     CocAction('fold', <f-args>)

 " Add `:OR` command for organize imports of the current buffer.
 command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

 " Show all diagnostics.
 nnoremap <silent> <leader>a  :<C-u>CocList diagnostics<cr>
 " Manage extensions.
 " nnoremap <silent> <leader>e  :<C-u>CocList extensions<cr>
 " Show commands.
 nnoremap <silent> <leader>c  :<C-u>CocList commands<cr>
 " Find symbol of current document.
 nnoremap <silent> <leader>ol  :<C-u>CocList outline<cr>
 " Search workspace symbols.
 nnoremap <silent> <leader>s  :<C-u>CocList -I symbols<cr>
 " Do default action for next item.
 nnoremap <silent> <leader>j  :<C-u>CocNext<CR>
 " Do default action for previous item.
 nnoremap <silent> <leader>k  :<C-u>CocPrev<CR>

 nmap <leader>do <Plug>(coc-codeaction)

 " Resume latest coc list.
 " nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

 let g:coc_global_extensions = ['coc-pyright', 'coc-json', 'coc-tsserver', 'coc-prettier', 'coc-eslint']

 let g:tex_flavor='latex'
 let g:vimtex_view_method='zathura'
 let g:vimtex_quickfix_mode=0
 "let g:vimtex_compiler_latexmk=1

 set conceallevel=1
 let g:tex_conceal='abdmg'
 hi Conceal ctermbg=none


" Show filename in command bar
function! s:ShowFilename()
    let s:node_info = CocAction('runCommand', 'explorer.getNodeInfo', 0)
    redraw | echohl Debug | echom exists('s:node_info.fullpath') ?
   \ 'CoC Explorer: ' . s:node_info.fullpath : '' | echohl None
endfunction
autocmd CursorMoved \[coc-explorer\]* :call <SID>ShowFilename()

" List all presets
 nmap <leader>e :CocCommand explorer<CR>

 inoremap {<CR>  {<CR>}<Esc>O

 autocmd filetype cpp nnoremap ,r :AsyncRun -mode=term -pos=tmux  g++ -std=c++14 -O2 -Wall "%" -o "%:r".bin && "./%:r".bin <CR>
 autocmd filetype cpp nnoremap ,rf :AsyncRun -mode=term -pos=tmux "%:r".bin<CR>
 autocmd filetype cpp nnoremap ,c :AsyncRun -mode=term -pos=tmux pcm tt<CR>
 autocmd filetype python nnoremap ,rf :AsyncRun -mode=term -pos=tmux python3 %<CR>

 nnoremap <leader>lc :source $MYVIMRC<CR>
 nnoremap <leader>oc :e $MYVIMRC<CR>

 " Visualize tabs and newlines
 set listchars=tab:▸\ ,eol:¬

 " Color scheme (terminal)
 set background=dark
 " colorscheme oceanic_material
 colorscheme nvcode

 " fix cursor color in gvim
 " highlight Cursor guifg=white guibg=black
 " highlight iCursor guifg=white guibg=steelblue
 set guicursor=n-v-c:block-Cursor
 set guicursor+=i:ver100-iCursor
 set guicursor+=n-v-c:blinkon0
 set guicursor+=i:blinkwait10

 function! CocCurrentFunction()
     return get(b:, 'coc_current_function', '')
 endfunction
let g:lightline#gitdiff#indicator_added = 'A: '
let g:lightline#gitdiff#indicator_deleted = 'D: '
let g:lightline#gitdiff#indicator_modified = 'M: '
let g:lightline#gitdiff#separator = ' '

 	function! LightlineFugitive()
 		if exists('*FugitiveHead')
 			let branch = FugitiveHead()
 			return branch !=# '' ? ''.branch : ''
 		endif
 		return ''
 	endfunction

function! LightlineGitGlobalStatus() abort
  let global_git_status = get(g:, 'coc_git_status', '')
  " return blame
  return global_git_status
endfunction

function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction

 let g:lightline = {
\ 'enable': {
\   'tabline': 0
\ },
\ 'mode_map': {
\ 'n' : 'N',
\ 'i' : 'I',
\ 'R' : 'R',
\ 'v' : 'V',
\ 'V' : 'VL',
\ "\<C-v>": 'VB',
\ 'c' : 'C',
\ 's' : 'S',
\ 'S' : 'SL',
\ "\<C-s>": 'SB',
\ 't': 'T',
\ },
\ 'colorscheme': 'one',
\ 'active': {
\   'left': [ [ 'mode', 'paste' ],
\             [ 'currentfunction', 'readonly', 'filename', 'modified', 'gitstatus', 'cocstatus', 'blame' ],
\             [ 'gitdiff' ] ],
   \   'right': [ [ 'lineinfo' ],
   \              [ 'percent' ] ]
\ },
   \ 'inactive': {
   \   'left': [ [ 'filename', 'gitversion' ] ],
   \ },
\ 'component_function': {
\   'gitbranch': 'FugitiveHead',
\   'cocstatus': 'coc#status',
\   'currentfunction': 'CocCurrentFunction',
\   'gitstatus': 'LightlineGitGlobalStatus',
\   'method': 'NearestMethodOrFunction',
\ },
   \ 'component_expand': {
   \   'gitdiff': 'lightline#gitdiff#get',
   \ },
   \ 'component_type': {
   \   'gitdiff': 'middle',
   \ },
\ }
autocmd VimEnter * call vista#RunForNearestMethodOrFunction()
" 

 " Remap <C-i>
 nnoremap <C-i> <C-i>

 "------------------------------------------------------------------------------
 " slime configuration
 "------------------------------------------------------------------------------
 " always use tmux
 let g:slime_target = 'tmux'

 " fix paste issues in ipython
 let g:slime_python_ipython = 1

 " always send text to the top-right pane in the current tmux tab without asking
 let g:slime_default_config = {
          \ 'socket_name': get(split($TMUX, ','), 0),
          \ 'target_pane': '{top-right}' }
 let g:slime_dont_ask_default = 1

 "------------------------------------------------------------------------------
 " ipython-cell configuration
 "------------------------------------------------------------------------------
 " Keyboard mappings. <Leader> is \ (backslash) by default

 " map <Leader>s to start IPython
 nnoremap <leader>as :SlimeSend1 ipython --matplotlib<CR>

 " map <Leader>r to run script
 nnoremap <leader>ar :IPythonCellRun<CR>

 " map <Leader>R to run script and time the execution
 nnoremap <leader>aR :IPythonCellRunTime<CR>

 " map <Leader>c to execute the current cell
 nnoremap <leader>ac :IPythonCellExecuteCell<CR>

 " map <Leader>C to execute the current cell and jump to the next cell
 nnoremap <leader>aC :IPythonCellExecuteCellJump<CR>

 " map <Leader>l to clear IPython screen
 nnoremap <leader>al :IPythonCellClear<CR>

 " map <Leader>x to close all Matplotlib figure windows
 nnoremap <leader>ax :IPythonCellClose<CR>

 " map [c and ]c to jump to the previous and next cell header
 nnoremap [z :IPythonCellPrevCell<CR>
 nnoremap ]z :IPythonCellNextCell<CR>

 " map <Leader>h to send the current line or current selection to IPython
 nmap <leader>ah <Plug>SlimeLineSend
 xmap <leader>ah <Plug>SlimeRegionSend

 " map <Leader>p to run the previous command
 nnoremap <leader>ap :IPythonCellPrevCommand<CR>

 " map <Leader>Q to restart ipython
 nnoremap <leader>aQ :IPythonCellRestart<CR>

 " map <Leader>d to start debug mode
 nnoremap <leader>ad :SlimeSend1 %debug<CR>

 " map <Leader>q to exit debug mode or IPython
 nnoremap <leader>aq :SlimeSend1 exit<CR>

 if strlen($TMUX) != 0
   let g:slime_default_config = {"socket_name": split($TMUX, ",")[0], "target_pane": ":.2"}
 endif

 " Coc-snippets configuration
 " Use <C-l> for trigger snippet expand.
 imap <C-l> <Plug>(coc-snippets-expand)

 " Use <C-j> for select text for visual placeholder of snippet.
 vmap <C-j> <Plug>(coc-snippets-select)

 " Use <C-j> for jump to next placeholder, it's default of coc.nvim
 let g:coc_snippet_next = '<c-j>'

 " Use <C-k> for jump to previous placeholder, it's default of coc.nvim
 let g:coc_snippet_prev = '<c-k>'

 " Use <C-j> for both expand and jump (make expand higher priority.)
 imap <C-j> <Plug>(coc-snippets-expand-jump)

 " Use <leader>x for convert visual selected code to snippet
 xmap <leader>x  <Plug>(coc-convert-snippet)


 " Switch IBus dynamically
 function! IBusOff()
 	" Lưu engine hiện tại
 	let g:ibus_prev_engine = system('ibus engine')
 	" Chuyển sang engine tiếng Anh
 	" Nếu bạn thấy cái cờ ở đây
 	" khả năng là font của bạn đang render emoji lung tung...
 	" xkb : us :: eng (không có dấu cách)
 	silent! execute '!ibus engine xkb:us::eng'
 endfunction


 function! IBusOn()
 	let l:current_engine = system('ibus engine')
 	" nếu engine được set trong normal mode thì
 	" lúc vào insert mode duùn luôn engine đó
 	if l:current_engine !~? 'xkb:us::eng'
 		let g:ibus_prev_engine = l:current_engine
 	endif
 	" Khôi phục lại engine
 	silent! execute '!ibus engine ' . g:ibus_prev_engine
 endfunction

 function! ToggleIBusHandler()
     if !exists('g:AugroupToggleIBus')
         let g:AugroupToggleIBus = 1
     endif

     " Enable if the group was previously disabled
     if (g:AugroupToggleIBus == 1)
         let g:AugroupToggleIBus = 0

         echo "Toggle IBus Handler"
         augroup IBusHandler
           " Khôi phục ibus engine khi tìm kiếm
           autocmd CmdLineEnter [/?] silent call IBusOn()
           autocmd CmdLineLeave [/?] silent call IBusOff()
           autocmd CmdLineEnter \? silent call IBusOn()
           autocmd CmdLineLeave \? silent call IBusOff()
           " Khôi phục ibus engine khi vào insert mode
           autocmd InsertEnter * silent call IBusOn()
           " Tắt ibus engine khi vào normal mode
           autocmd InsertLeave * silent call IBusOff()
         augroup END
     else
           echo "IBus Handler Turn off"
           let g:AugroupToggleIBus = 1
           augroup IBusHandler
             autocmd!
           augroup END
     endif
 endfunction

 nnoremap <F4> :call ToggleIBusHandler() <CR>
 nmap <localleader>cp :call coc#float#close_all() <CR>

 " Disable auto comment in insertion mode
 autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

 let g:vimtex_indent_enabled = 0

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

let $DATA_PATH = '~/.vim'

set nobackup
set nowritebackup
set undofile noswapfile
set directory=$DATA_PATH/swap//,$DATA_PATH,~/tmp,/var/tmp,/tmp
set undodir=$DATA_PATH/undo//,$DATA_PATH,~/tmp,/var/tmp,/tmp
set backupdir=$DATA_PATH/backup/,$DATA_PATH,~/tmp,/var/tmp,/tmp

lua << EOF
  require('init')

  require("which-key").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }

  require'nvim-treesitter.configs'.setup {
    context_commentstring = {
      enable = true
    }
  }

EOF
