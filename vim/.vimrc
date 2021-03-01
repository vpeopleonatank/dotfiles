" Don't try to be vi compatible
set nocompatible

" Helps force plugins to load correctly when it is turned back on below

" Turn on syntax highlighting
" syntax on


 """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
 """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 " Sets how many lines of history VIM has to remember
 set history=500

 " Enable filetype plugins
 filetype plugin on
 filetype indent on

 " Set to auto read when a file is changed from the outside
 set autoread
 au FocusGained,BufEnter * checktime

 " With a map leader it's possible to do extra key combinations
 " like <leader>w saves the current file
 let mapleader = ","

let maplocalleader = " "

 " Fast saving
 nmap <leader>w :w!<cr>
 nmap <C-s> :w!<cr>

 " :W sudo saves the file
 " (useful for handling the permission-denied error)
 command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

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

""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
" map <space> /
" map <C-space> ?

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

nnoremap <C-[> :vertical resize -5<cr>
nnoremap <C-]> :vertical resize +5<cr>


" Close the current buffer

nmap <silent> <Leader>bn    <Plug>BufKillBack
nmap <silent> <Leader>bp    <Plug>BufKillForward
nmap <silent> <Leader>bd    <Plug>BufKillBd
nmap <silent> <Leader>bu    <Plug>BufKillUndo

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>t<leader> :tabnext

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()


" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Textmate holdouts

" Formatting
"map <leader>q gqip

map <leader>qa :qa!<CR>

map <leader>s :w<CR>

map <leader>c "+y
map <leader>v "+p

imap jk <Esc>
imap kj <Esc>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^


" Move a line of text using ALT+[jk] or Command+[jk] on mac
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Quickly open a buffer for scribble
" map <leader>q :e ~/buffer<cr>

" Quickly open a markdown buffer for scribble
map <leader>x :e ~/buffer.md<cr>

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

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")

    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif

    if bufnr("%") == l:currentBufNum
        new
    endif

    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

function! CmdLine(str)
    call feedkeys(":" . a:str)
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

set mouse+=a
if has('nvim')
    set mouse+=nicr
endif
set clipboard+=unnamed,unnamedplus
if has('nvim')
    let g:loaded_clipboard_provider = 0
    unlet g:loaded_clipboard_provider
    runtime autoload/provider/clipboard.vim
endif


filetype off

" TODO: Load plugins here (pathogen or vundle)
call plug#begin('~/.vim/plugged')
Plug 'sirver/ultisnips'
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
autocmd BufEnter,BufNew *.md setf md.tex

Plug 'honza/vim-snippets'

Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

noremap <leader>mo :MarkdownPreview<CR>
noremap <leader>mc :MarkdownPreviewStop<CR>
" noremap <leader>mt <Plug>MarkdownPreviewToggle

Plug 'liuchengxu/vim-which-key'

set timeoutlen=500
nnoremap <silent> <leader>      :<c-u>WhichKey ','<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  ';'<CR>
Plug 'ryanoasis/vim-devicons'
Plug 'qpkorr/vim-bufkill'
" Plug 'bagrat/vim-buffet'
Plug 'hardcoreplayers/vim-buffet'
let g:buffet_powerline_separators = 1
let g:buffet_tab_icon = "\uf00a"
let g:buffet_left_trunc_icon = "\uf0a8"
let g:buffet_right_trunc_icon = "\uf0a9"

nmap <leader>1 <Plug>BuffetSwitch(1)
nmap <leader>2 <Plug>BuffetSwitch(2)
nmap <leader>3 <Plug>BuffetSwitch(3)
nmap <leader>4 <Plug>BuffetSwitch(4)
nmap <leader>5 <Plug>BuffetSwitch(5)
nmap <leader>6 <Plug>BuffetSwitch(6)
nmap <leader>7 <Plug>BuffetSwitch(7)
nmap <leader>8 <Plug>BuffetSwitch(8)
nmap <leader>9 <Plug>BuffetSwitch(9)
nmap <leader>0 <Plug>BuffetSwitch(10)

Plug 'jpalardy/vim-slime', { 'for': 'python' }
Plug 'hanschen/vim-ipython-cell', { 'for': 'python' }
Plug 'liuchengxu/vista.vim'

nnoremap <leader>i :Vista<CR>

Plug 'lervag/vimtex'

Plug 'KeitaNakamura/tex-conceal.vim'

" Use release branch (recommend)
Plug 'neoclide/coc.nvim', {'branch': 'release'}


Plug 'tyru/caw.vim'

Plug 'tpope/vim-fugitive'

" Theme
Plug 'hardcoreplayers/oceanic-material'
Plug 'NLKNguyen/papercolor-theme'
Plug 'arcticicestudio/nord-vim'
Plug 'cormacrelf/vim-colors-github'
Plug 'dracula/vim'

Plug 'ryanoasis/vim-devicons'
Plug 'itchyny/lightline.vim'
Plug 'sainnhe/artify.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'niklaas/lightline-gitdiff'
" Plug 'maximbaz/lightline-ale'
" Plug 'albertomontesg/lightline-asyncrun'

Plug 'skywind3000/asyncrun.vim'

Plug 'skywind3000/vim-terminal-help'

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
nnoremap <silent> <Leader>gz :<C-u>FloatermNew lazygit<CR>

nnoremap <silent> <C-_>  :FloatermNew --height=0.5 --width=0.5 --wintype=popup --position=bottomright<CR>

" let g:floaterm_keymap_kill = '<C-t>q'

let g:floaterm_autoclose = 1


"Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary!' }

call plug#end()

filetype plugin indent on
syntax on

"
" =============================================================================================================================
"	config copy
" =============================================================================================================================

 nnoremap <leader>y "+Y
 vnoremap <leader>y "+y
 nnoremap <leader>p "+p
 vnoremap <leader>p "+p

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

 " Highlight the symbol and its references when holding the cursor.
 autocmd CursorHold * silent call CocActionAsync('highlight')

 " Symbol renaming.
 nmap <leader>rn <Plug>(coc-rename)

 " Formatting selected code.
 xmap <leader>f  <Plug>(coc-format-selected)
 nmap <leader>f  <Plug>(coc-format-selected)

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

 " Use <TAB> for selections ranges.
 " NOTE: Requires 'textDocument/selectionRange' support from the language server.
 " coc-tsserver, coc-python are the examples of servers that support it.
 nmap <silent> <TAB> <Plug>(coc-range-select)
 xmap <silent> <TAB> <Plug>(coc-range-select)

 " Add `:Format` command to format current buffer.
 command! -nargs=0 Format :call CocAction('format')

 " Add `:Fold` command to fold current buffer.
 command! -nargs=? Fold :call     CocAction('fold', <f-args>)

 " Add `:OR` command for organize imports of the current buffer.
 command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

 " Add (Neo)Vim's native statusline support.
 " NOTE: Please see `:h coc-status` for integrations with external plugins that
 " provide custom statusline: lightline.vim, vim-airline.
 " set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

 " Mappings using CoCList:
 " Show all diagnostics.
 nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
 " Manage extensions.
 nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
 " Show commands.
 nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
 " Find symbol of current document.
 nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
 " Search workspace symbols.
 nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
 " Do default action for next item.
 nnoremap <silent> <space>j  :<C-u>CocNext<CR>
 " Do default action for previous item.
 nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
 " Resume latest coc list.
 nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

 let g:coc_global_extensions = ['coc-pyright', 'coc-json', 'coc-prettier']

 let g:tex_flavor='latex'
 let g:vimtex_view_method='zathura'
 let g:vimtex_quickfix_mode=0
 "let g:vimtex_compiler_latexmk=1

 set conceallevel=1
 let g:tex_conceal='abdmg'
 hi Conceal ctermbg=none


 nmap <space>e :CocCommand explorer<CR>

 inoremap {<CR>  {<CR>}<Esc>O

 autocmd filetype cpp nnoremap <leader>r :w <bar> AsyncRun -mode=term -pos=thelp g++ -std=c++14 % -o %:r && %:r<CR>
 autocmd filetype cpp nnoremap <leader>rf :AsyncRun -mode=term -pos=thelp %:r<CR>
 autocmd filetype python nnoremap <leader>rf :AsyncRun -mode=term -pos=thelp python3 %<CR>

 nnoremap <leader>lc :source $MYVIMRC<CR>
 nnoremap <leader>ev :tabe $MYVIMRC<CR>

 " Visualize tabs and newlines
 set listchars=tab:▸\ ,eol:¬
 " Uncomment this to enable by default:
 " set list " To enable by default
 " Or use your leader key + l to toggle on/off
 " map <leader>l :set list!<CR> " Toggle tabs and EOL

 " Color scheme (terminal)

 " use the dark theme
 set background=dark
 " colorscheme oceanic_material
 colorscheme dracula
" colorscheme PaperColor

 " fix cursor color in gvim
 highlight Cursor guifg=white guibg=black
 highlight iCursor guifg=white guibg=steelblue
 set guicursor=n-v-c:block-Cursor
 set guicursor+=i:ver100-iCursor
 set guicursor+=n-v-c:blinkon0
 set guicursor+=i:blinkwait10
 " colorscheme nord
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
 \ 'colorscheme': 'dracula',
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
 \ },
     \ 'component_expand': {
     \   'gitdiff': 'lightline#gitdiff#get',
     \ },
     \ 'component_type': {
     \   'gitdiff': 'middle',
     \ },
 \ }

 if has('win32')
     " Command output encoding for Windows
     let g:asyncrun_encs = 'gbk'
 endif

 setlocal spell
 set spelllang=en_us
 inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

 let g:clap_theme = 'material_design_dark'
 nnoremap <leader>ff :Clap files<CR>
 nnoremap <leader>fa :Clap grep<CR>

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
 nnoremap [c :IPythonCellPrevCell<CR>
 nnoremap ]c :IPythonCellNextCell<CR>

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

 let g:slime_default_config = {"socket_name": split($TMUX, ",")[0], "target_pane": ":.2"}

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

