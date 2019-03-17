set nocompatible
filetype off                  " 必须要添加
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" 另一种选择, 指定一个vundle安装插件的路径
"call vundle#begin('~/some/path/here')

" 让vundle管理插件版本,必须
Plugin 'VundleVim/Vundle.vim'

"add NERDTree
Plugin 'scrooloose/nerdtree'
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
" " F2关闭与打开文件列表
nnoremap <F2> :NERDTreeToggle<CR>
" " F2关闭与打开文件列表
" " 设置文件列表窗口大小

" " 设置文件列表大小
" nerdtree文件列表设置

" python设置
au BufNewFile,BufRead *.py
\set tabstop=4
\set softtabstop=4
\set shiftwidth=4
\set textwidth=79
\set expandtab
\set autoindent
\set fileformat=unix
" python设置

" ycm 通用设置
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
" " 设置python路径
let g:ycm_python_binary_path='/home/sins/anaconda2/envs/356/bin/python'
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

" tab 配置
" " tab 打开新标签页
nnoremap <C-n> :tabnew<CR>
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
" " 快捷键F3关闭函数列表
map <F4> :TlistToggle<cr>
" " 快捷键F4切换函数列表
" taglist配置

" " 文件保存时的更新函数
function! WriteUpdate()
	:TlistUpdate
endfunction
autocmd BufWritePost *.c,*.h,*.cpp,*.py,*.cc call WriteUpdate()
" " 文件保存时的更新函数
