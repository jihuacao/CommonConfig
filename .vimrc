set nocompatible
filetype off	" 必须要添加
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" 另一种选择, 指定一个vundle安装插件的路径
"call vundle#begin('~/some/path/here')
" 让vundle管理插件版本,必须
Plugin 'VundleVim/Vundle.vim'

"add NERDTree
Plugin 'scrooloose/nerdtree'
" " NERDTree advance plugin make nerdtree open Synchronously between tabs
Bundle 'jistr/vim-nerdtree-tabs'
" " NERDTree advance Plugin make nerdtree contain git information
Bundle 'Xuyuanp/nerdtree-git-plugin'
"add YouCompleteMe
Plugin 'Valloric/YouCompleteMe'
"add taglist
Plugin 'taglist.vim'
"add tagbar
Plugin 'majutsushi/tagbar'
Plugin 'https://github.com/sillybun/vim-repl'
Plugin 'sillybun/vim-async'
Plugin 'sillybun/zytutil'
" 文件模糊搜索功能
Plugin 'ctrlpvim/ctrlp.vim'
" 程序debug插件 vedebug
Plugin 'vim-vdebug/vdebug'
" 智能语法提示插件
Plugin 'vim-syntastic/syntastic.git'
" git文件对比信息显示
Plugin 'airblade/vim-gitgutter'
" 代码片段插件
Plugin 'SirVer/ultisnips'
" " 代码片段资源库
Plugin 'honza/vim-snippets'
" Add maktaba and bazel to the runtimepath.
" (The latter must be installed before it can be used.)
Plugin 'google/vim-maktaba'
" 运行shell命令时的插件
Plugin 'skywind3000/asyncrun.vim'
" mark显示
Plugin 'kshenoy/vim-signature' 
call vundle#end()            " 必须

filetype on
filetype indent on
filetype plugin on

"通用设置
" "操作相关说明
" " ' 模式转换
" " : a在后一个字符插入，i在本字符前插入
" " ' 模式转换*/
" " '游标移动
" " : h,j,k,l为左，下，上，右移动
" " : e以单词单位向前移动，b以单词单位向后移动
" " : E以空格单位向前移动，B以空格单位向后移动
" " : Ctrl+f以页为单位向前移动， Ctrl+b以页为单位向后移动
" " : 数字+eg跳转到某一行
" " : gg移动到文档始行
" " : G移动到文档末行
" " ' 游标移动*/
" " ' 复制粘贴剪切
" " : dd剪切一行，D剪切游标处到行末
" " : yy复制一行
" " : 在visual模式中使用配合移动方法能够进行高效的复制剪切
" "操作相关说明
" "
" " 键位映射更改
" " : 通过Ctrl-]在插入模式下进行backspace
imap <C-]> <BS>
" " : 通过Ctrl+[在插入模式下进行esc
imap <C-[> <Esc>
" " 键位映射更改
" " 设置行列高亮
set cursorcolumn
set cursorline
highlight CursorLine   cterm=NONE ctermbg=black ctermfg=blue guibg=NONE guifg=NONE
highlight CursorColumn cterm=NONE ctermbg=black ctermfg=blue guibg=NONE guifg=NONE
" " 设置行列高亮
set nu!
set ai
syntax on 
set background=dark
set encoding=utf-8
" "窗口切换快捷键设置
" "Ctrl+方向键进行窗口切换 
set splitbelow
set splitright
" "窗口切换快捷键设置
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
" "窗口切换快捷键设置， Ctrl+h,j,k,l进行窗口切换
" "窗口大小调整快捷键设置
nnoremap - :resize-3<CR>
nnoremap = :resize+3<CR>
nnoremap _ :vertical resize-3<CR>
nnoremap + :vertical resize+3<CR>
" "窗口大小调整，使用-/=调节垂直大小，使用_/+调节水平大小
" "快捷保存与保存关闭缓存快捷键设置
inoremap <C-w> <Esc>:w<CR>a
nnoremap <C-W> :w<CR>
" " '说明由于发现了默认的：保存退出命令：shift+zz;不保存退出命令：shift+zq，就不添加这两个快捷键了
" "快捷保存快捷键设置， insert模式下Ctrl+w进行保存(由于Ctrl+s是位于vim之上的信息检测，是终端暂停功能，因此vim中的Ctrl+s会被上层劫持，此处不使用Ctrl+s,Esc推出insert模式，:w保存， CR代表Enter，a重回输入模式)
" "状态栏设置
" " '显示状态行当前设置
" " '设置状态行显示常用信息
" " '%F 完整文件路径名
" " '%m 当前缓冲被修改标记
" " '%m 当前缓冲只读标记
" " '%h 帮助缓冲标记
" " '%w 预览缓冲标记
" " '%Y 文件类型
" " '%b ASCII值
" " '%B 十六进制值
" " '%l 行数
" " '%v 列数
" " '%p 当前行数占总行数的的百分比
" " '%L 总行数
" " '%{...} 评估表达式的值，并用值代替
" " '显示文件编码
" " '%{&ff} 显示文件类型
set statusline=%F%m%r%h%w%=\[ft=%Y]\%{\"[fenc=\".(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\&bomb)?\"+\":\"\").\"]\"}\[ff=%{&ff}]\[asc=%03.3b]\[hex=%02.2B]\[pos=%04l,%04v][%p%%]\[len=%L]
" " '设置 laststatus = 0 ，不显式状态行
" " '设置 laststatus = 1 ，仅当窗口多于一个时，显示状态行
" " '设置 laststatus = 2 ，总是显式状态行
set laststatus=2
" "状态栏设置
"通用设置

" nerdtree 文件列表设置
" " 设置窗口大小
let NERDTreeWinSize=20
" " leader+<F2>关闭与打开文件列表
nnoremap <leader><F2> :NERDTreeTabsToggle<CR>
" " leader+<F2>关闭与打开文件列表
" " 刷新文件列表
" 在文件列表窗口中按r会刷新文件列表
" " 刷新文件列表
" " 在nerdtree中的相关文件操作
" 在文件列表窗口中按m可以显示文件操作命令列表
" " 在nerdtree中的相关文件操作
" " 设置默认显示隐藏文件
let NERDTreeShowHidden=1
" “ 设置默认显示隐藏文件
" " 设置git信息显示图标
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }
" " 设置git信息显示图标
" " 设置文件列表窗口大小

" " 设置文件列表大小
" nerdtree文件列表设置

" " 通用缩进设置
set tabstop=4
			\ softtabstop=4
			\ shiftwidth=4
			\ expandtab
			\ autoindent
			\ fileformat=unix
" " 通用缩进设置

"" " BUILD设置
"au BufNewFile,BufRead BUILD
"			\set tabstop=4
"			\ softtabstop=4
"			\ shiftwidth=4
"			\ expandtab
"			\ autoindent
"			\ fileformat=unix
"" " BUILD设置

" python设置
au BufNewFile,BufRead *.py
			\set tabstop=4
			\ softtabstop=4
			\ shiftwidth=4
			\ expandtab
			\ autoindent
			\ fileformat=unix
" python设置

" c++设置
au BufNewFIle,BufRead *.hpp,*.cpp,*.h,*.c,*.cc 
			\ set tabstop=4 
			\ shiftwidth=4
			\ softtabstop=4
			\ cindent
			\ fileformat=unix
			\ fileformat=unix
" c++设置

" ycm 通用设置
" " ycm 列表移动选取，向下
let g:ycm_key_list_select_completion = ['<c-u>', '<Down>']
" " ycm 列表移动选取， 向上
let g:ycm_key_list_previous_completion = ['<c-p>', '<Up>']
" " 让vim自动加载ycm配置文件，不再提示询问是否加载
let g:ycm_confirm_extra_conf=0  
" " 让vim自动加载ycm配置文件，不再提示询问是否加载
" " 跳转时自动水平分屏
let g:ycm_goto_buffer_command = 'horizontal-split'
" " 跳转时自动水平分屏
" " 开启 YCM 标签补全引擎
let g:ycm_collect_identifiers_from_tags_files=1 
" " 开启 YCM 标签补全引擎
" " 补全功能在注释中同样有效
let g:ycm_complete_in_comments=1                  
" " 补全功能在注释中同样有效
" " 快捷键Alt-q实现关闭提示框功能
let g:ycm_key_list_stop_completion=['<CR>']
" " 快捷键Alt-q实现关闭提示框功能
" "跳转快捷键
"nnoremap <leader>gl :YcmCompleter GoToDeclaration<CR>
"nnoremap <leader>gf :YcmCompleter GoToDefinition<CR>
"nnoremap <leader>gg :YcmCompleter GoToDefinitionElseDeclaration<CR>
" "跳转快捷键
" " 补全方式
let g:ycm_semantic_triggers = {
	\ 'c, python, cpp': ['re!\w{2}'],
	\ }
" " 设置解析补全的目标python路径 
let g:ycm_python_binary_path='/home/sins/anaconda3/envs/356/bin/python'
" " 设置ycm服务使用的是哪个python，这需要与ycm编译时以来的那个python版本一致
let g:ycm_server_python_interpreter='/usr/bin/python'
" " 错误诊断关闭
let g:ycm_show_diagnostics_ui = 0
" " 关闭补全框快捷
" " 设置跳转快捷键
map <C-]> :YcmCompleter GoToDefinitionElseDeclaration<CR>
" " 设置跳转快捷键
" " 设置白名单文件列表，避免ycm处理无关文件造成卡顿
let g:ycm_filetype_whitelist = {
			\ "py": 1,
			\ "python":1,
			\ "c":1,
			\ "cpp":1, 
			\ "objc":1,
			\ "sh":1,
			\ "zsh":1,
			\ "zimbu":1,
            \ "bzl":1,
            \ "cmake":1,
			\ }
" " 设置白名单列表
" ycm 通用设置

" ctrlpvim/ctrlp.vim文件模糊搜索插件配置
" "默认leader是\字符， 使用\+f打开缓存历史
let g:ctrlp_map = '<leader>p'
let g:ctrlp_cmd = 'CtrlP'
nnoremap <leader>f :CtrlPMRU<CR>
vnoremap <leader>f :CtrlPMRU<CR>
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn|rvm)$',
    \ 'file': '\v\.(exe|so|dll|zip|tar|tar.gz|pyc)$',
    \ }
let g:ctrlp_working_path_mode=0
let g:ctrlp_match_window_bottom=1
let g:ctrlp_max_height=15
let g:ctrlp_match_window_reversed=0
let g:ctrlp_mruf_max=500
let g:ctrlp_follow_symlinks=1
" ctrlpvim/ctrlp.vim文件模糊搜索插件配置

" vim帮助文档说明
" " 在指定关键字上按下shift+k能够打开说明
" vim帮助文档说明

" 代码片段配置
" " 相关说明
" " "关于实时更新的问题：当你在文件编辑状态中，去更改snippets文件的内容,更改已存在的snippet是会实时更新的，但是如果是增加snippet则不会实时更新
" "
" " 代码片段选择，由于在ycm中配置了列表的选择，使用Ctrl+u向下选，使用Ctrl+p向上选,此处无需再进行配置
" 以下配置占位符锁定，当代码片段有多个占位符输入时,通过tab锁定下一个，通过shift+tab锁定上一个
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-tab>"
" " 当选到对应的snip时，按下tab键会进行展开 
let g:UltiSnipsExpandTrigger="<tab>"
" " while use :UltiSnipsEdit, the file would be opened vertical
let g:UltiSnipsEditSplit="vertical"
" " 设置个人代码片段库 个人的代码片段库必须存放到~/.vim/下才会有效
" " 由于与ycm共用模块，因此想支持的文件类型需要在ycm白名单中添加类型
let g:UltiSnipSSnippetDirectories=['~/.vim/UltiSnips', '~/.vim/snippets']
" " vim 使用的python版本
let g:UltiSnipsUsePythonVersion = 3
" 代码片段配置

" tab 配置
" " tab 打开新标签页
nnoremap <C-n> :tabnew<CR>
" " 显示标签号, 使用ngt来跳转到某个标签页，比如跳转到第一个标签页：1gt
set tabline=%!MyTabLine()  " custom tab pages line
function MyTabLine()
    let s = '' " complete tabline goes here
    " loop through each tab page
    for t in range(tabpagenr('$'))
        " set highlight
        if t + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif
        " set the tab page number (for mouse clicks)
        let s .= '%' . (t + 1) . 'T'
        let s .= ' '
        " set page number string
        let s .= t + 1 . ' '
        " get buffer names and statuses
        let n = ''      "temp string for buffer names while we loop and check buftype
        let m = 0       " &modified counter
        let bc = len(tabpagebuflist(t + 1))     "counter to avoid last ' '
        " loop through each buffer in a tab
        for b in tabpagebuflist(t + 1)
            " buffer types: quickfix gets a [Q], help gets [H]{base fname}
            " others get 1dir/2dir/3dir/fname shortened to 1/2/3/fname
            if getbufvar( b, "&buftype" ) == 'help'
                let n .= '[H]' . fnamemodify( bufname(b), ':t:s/.txt$//' )
            elseif getbufvar( b, "&buftype" ) == 'quickfix'
                let n .= '[Q]'
            else
                let n .= pathshorten(bufname(b))
            endif
            " check and ++ tab's &modified count
            if getbufvar( b, "&modified" )
                let m += 1
            endif
            " no final ' ' added...formatting looks better done later
            if bc > 1
                let n .= ' '
            endif
            let bc -= 1
        endfor
        " add modified label [n+] where n pages in tab are modified
        if m > 0
            let s .= '[' . m . '+]'
        endif
        " select the highlighting for the buffer names
        " my default highlighting only underlines the active tab
        " buffer names.
        if t + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif
        " add buffer names
        if n == ''
            let s.= '[New]'
        else
            let s .= n
        endif
        " switch to no underlining and add final space to buffer list
        let s .= ' '
    endfor
    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'
    " right-align the label to close the current tab page
    if tabpagenr('$') > 1
        let s .= '%=%#TabLineFill#999Xclose'
    endif
    return s
endfunction
" " 显示标签号
" " normal 模式下使用ctrl+n打开新标签也
" " 标签页跳转：使用num ctrl+PgUp/PgDn进行tab切换
" " 标签页跳转:使用Ctrl+Pgup/PgDn进行逐个标签切换
" tab 配置

" taglist配置
" " 配置打开函数列表的时候不改变窗口大小
let g:Tlist_Inc_Winwidth=0
" " 配置打开函数列表的时候不改变窗口大小
" " 配置函数列表挂靠在屏幕右手边
let g:Tlist_Use_Right_Window=1
" " 配置函数列表挂靠在屏幕右手边
" " 配置自动关闭非活动的文件
let g:Tlist_File_Fold_Auto_Close=1
" " 配置自动关闭非活动的文件
" " 只有当前函数列表窗口的时候退出vim
let g:Tlist_Exit_OnlyWindow=1
" " 配置当前只有函数列表窗口的时候退出vim
" " 快捷键leader+<F3>关闭函数列表
map <leader><F3> :TlistToggle<cr>
" " 快捷键leader+<F3>切换函数列表
" taglist配置

" vdebug 配置
" 打开
" " 键位

let g:vdebug_keymap = {
\    "get_context" : "<F4>",
\}
" " " F2 step over; F3 step into; F4 step out; F5 start debug/run; F6 stop; F9 run to cursor; F10 set break; F12 eval at the cursor;
" " 键位
" " VdebugEval
" " " 使用:VdebugEval <code>来eval任何变量，结果在VdebugWatchWindow中显示，如想回到VdebugWatchWindow中则使用:VdebugEval!
" " " 或者使用:VdebugTrace <code>新建一个分割窗口显示Eval结果
" " VdebugEval
" "当使用eval进行查看变量值时可能出现错误，阅读vdebug帮助文档，help vdebugSetupPython, 查看相关内容，会有个patch地址，链接里面有提供解决方案
" " 配置leader
" " 配置leader
" vdebug 配置

" syntastic 配置
" "
set statusline+=%#warningmsg#
" "
set statusline+=%{SyntasticStatuslineFlag()}
" "
set statusline+=%*
" "
let g:syntastic_always_populate_loc_list = 1
" "
let g:syntastic_auto_loc_list = 1
" "
let g:syntastic_check_on_open = 1
" "
let g:syntastic_check_on_wq = 0
" " 配置python部分
" " 配置python代码分析器，改分析器需要另外安装，syntastic主要是将分析器的分析信息在vim中进行可视化:mutable
" " 为了支持多版本python，要在对应环境python进行pip安装pylint，在对应环境下运行pylint,才能使用对应环境的语法规范:mutable
let g:syntastic_python_flake8_checkers = 'flake8'
let g:syntastic_python_checkers = ['flake8']
" " :配置flake8的参数 flake8说明文档：http://flake8.pycqa.org/en/latest/
" " " flake8 的id说明：
" " "   F841: local variable is assigned to but never used
" " "   E402: 没有在文件顶层进行import的错误
" " "   F401: import but not used
" " "   E201: has whitespace after (
" " "   E202: has whitespace before )
" " "   E501: line too long
" " "   E266: too many leading '#'
let g:syntastic_python_flake8_args='--ignore F841,E402,F401,E201,E202,E501,E266'
" " 配置flake8的参数
" " : 配置pylint的参数
let g:syntastic_python_pylint_args='--disable=C0111,R0903,C0301'
" " 配置python部分
" " 配置CPP部分
" " 使用python安装cpplint
" " " 配置cpplint的路径
let g:syntastic_cpp_cpplint_exec = "cpplint"
let g:syntastic_cpp_checkers = ['cpplint']
" " " 使用clang无法使用，预计原因：是调用python的clang，而环境中存在clang编译器
"let g:syntastic_cpp_clang_exec = 'clang'
"let g:syntastic_cpp_checkers = ['clang']
" " 配置CPP部分
" " 窗口大小设置
let g:syntastic_loc_list_height=3
" syntastic 配置

" " 文件保存时的更新函数
function! WriteUpdate()
	:TlistUpdate
endfunction
autocmd BufWritePost *.c,*.h,*.cpp,*.py,*.cc call WriteUpdate()
" " 文件保存时的更新函数

" " 配置asyncrun
" " "使用AsyncRun + command就会在分窗口中执行命令
" " 自动打开 quickfix window ，高度为 6
let g:asyncrun_open = 6
" " 任务结束时候响铃提醒
let g:asyncrun_bell = 1
" " 设置 F10 打开/关闭 Quickfix 窗口
nnoremap leader+<F10> :call asyncrun#quickfix_toggle(6)<cr>Plugin 'bazelbuild/vim-bazel'
" 配置asyncrun
