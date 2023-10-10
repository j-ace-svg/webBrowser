" Documentation {{{1
"
" Upstream: {{{2
" Name: webBrowser.vim
" Version: 1.6
" Description: Uses the lynx text browser to browse websites and local files and return the rendered web pages inside vim. The links in the web pages may be "clicked" to follow them, so it turns vim into a simple web text based web browser. This plugin is based on the "browser.vim" plugin.
" Author: Alexandre Viau (alexandreviau@gmail.com)
" Website: The latest version is found on "vim.org"
"
" Fork: {{{2
" Version: 1.6.1
" Fork Author: John Montgomery (j.ace.svg@gmail.com)
"
" (Note: Versioning is MAJOR.MINOR-UPSTREAM.MINOR-DOWNSTREAM)
"
" Installation: {{{2
" Copy the plugin to the vim plugin directory.
" In the lynx.cfg file, set the following parameters:
" ```
" ACCEPT_ALL_COOKIES:TRUE
" MAKE_LINKS_FOR_ALL_IMAGES:TRUE
" ```
" Change the following paths to your lynx files:
" ```VimL
" let g:lynxPath = $HOME.'/.vim/lynx/'
" let g:lynxExe = '/usr/bin/lynx'
" let g:lynxCfg = '-cfg=' . g:lynxPath . 'lynx.cfg'
" let g:lynxLss = '-lss=' . g:lynxPath . 'lynx.lss'
" let g:lynxCmd = g:lynxExe . ' ' . g:lynxCfg . ' ' . g:lynxLss
"
" let g:WbLynxDumpPath = g:lynxPath . '/dump/'
" let g:lynxToolsPath = g:lynxPath . '/tools/'
" ```
"
" Usage: {{{2
" ```
" L (Open link)
" <C-l> (Jump to link at bottom of page)
" H (Previous page ("back button"))
" J (Highlight links and go to next link)
" K (Highlight links and go to previous link)
" gf (Open prompt for address to navigate to)
" gF (Navigate to the address under the cursor)
" ```
"
" Suggested mappings: {{{2
" ```VimL
" " Open a new web browser tab with the address specified
" <leader>wb :WebBrowser
" " Open a new web browser tab with the address in the clipboard
" <leader>wc :exe 'WebBrowser "' . @* . '"'<cr>
" " Do a google search using the specified search keywords and open the results in a new tab
" <leader>wg :exe 'WebBrowser www.google.com/search?q="' . input("Google ") . '"'<cr>
" " Do a wikipedia search using the specified search keywords and open the results in a new tab
" <leader>wp :exe 'WebBrowser www.wikipedia.com/wiki/"' . input("Wikipedia ") . '"'<cr>
" " Downloads the specified webpage without opening it in vim
" <leader>wd :WebDump
" ```
"
" Todo: {{{2
" - Redo the code that gets the link number and search for it at the end of the file (no need to move cursor) and to do it in a mapping, it may be done in a function
" - I added basicXmlParser in the plugin, add a webBrowser.xml file and in it, have 2 keys: history and favorites, which will be string of utl links
" - Add links bar like vimExplorer (favorites & history) with links not from utl but with brackets [http://yahoo.com] thus no need for utl
" - Use image_links and accept_all_cookies options in the command run from the plugin instead of having to modify the .cfg file
"
" History: {{{2
" 1.1 {{{3
" - Changed the file format to unix
" 1.2 {{{3
" - Changed the mappings
" 1.3 {{{3
" - Now the lynx command and others are ran using a call to the system() function so that the dos prompt window is not displayed on the screen
" - Added suggested mappings in comments (<insert>, <delete>, etc)
" - Added folds
" 1.4 {{{3
" - Changed mappings \wb etc to <leader>wb because it was causing my "w" key in normal mode to wait for another key
" 1.5 {{{3
" - Added the webdump command and function to download in batch
" 1.6 {{{3
" - Added documentation and usage
" 1.6.1 {{{3
" - Port to Unix file paths by default
" - Make lynx interaction globally configurable
" - Use nnoremap mappings
" - Uniformly use `g:lynxPath`
" - Fix formatting
" - Make web page buffers unmodifiable
" - Create a new buffer when browsing in the same tab
" - Improve link finding
" - Use HLKJ rather than leader key bindings
" - Add gf and gF bindings
" 1.6.2 {{{3
" - Add vertical split option
" - Only make current buffer unmodifiable
" - Add autocommand to allow for external hooks

" Commands: To start the plugin {{{1
com! -nargs=+ WebBrowser enew | call OpenWebBrowser(<q-args>, 0)
com! -nargs=1 WebDump call DoWebDump(<q-args>)

"" Mappings: To start the plugin {{{1
"" Open a new web browser tab with the address specified
"nnoremap <leader>wb :WebBrowser
"" Open a new web browser tab with the address in the clipboard
"nnoremap <leader>wc :exe 'WebBrowser "' . @* . '"'<cr>
"" Do a google search using the specified search keywords and open the results in a new tab
"nnoremap <leader>wg :exe 'WebBrowser www.google.com/search?q="' . input("Google ") . '"'<cr>
"" Do a wikipedia search using the specified search keywords and open the results in a new tab
"nnoremap <leader>wp :exe 'WebBrowser www.wikipedia.com/wiki/"' . input("Wikipedia ") . '"'<cr>
"" Downloads the specified webpage without opening it in vim
"nnoremap <leader>wd :WebDump

" Suggested mappings to add to your vimrc {{{2
" Open a web browser tab with the address specified
" nnoremap <insert> :WebBrowser
" Open a new web browser tab with the address in the clipboard
" nnoremap <s-insert> :exe 'WebBrowser ' . @*<cr>
" Show dump (history-cache) directory
" nnoremap <c-insert> :exe 'VimExplorerSP ' . g:WbLynxDumpPath<cr>
" Do a google search using the specified search keywords and open the results in a new tab
" nnoremap <delete> :exe 'WebBrowser www.google.com/search?q="' . input("Google ") . '"'<cr>
" Do a wikipedia search using the specified search keywords and open the results in a new tab
" nnoremap <s-delete> :exe 'WebBrowser www.wikipedia.com/wiki/"' . input("Wikipedia ") . '"'<cr>

" Variables {{{1
let g:lynxPath = $HOME.'/.vim/lynx/'
let g:lynxExe = '/usr/bin/lynx'
let g:lynxCfg = '-cfg=' . g:lynxPath . 'lynx.cfg'
let g:lynxLss = '-lss=' . g:lynxPath . 'lynx.lss'
let g:lynxCmd = g:lynxExe . ' ' . g:lynxCfg . ' ' . g:lynxLss

let g:WbLynxDumpPath = g:lynxPath . '/dump/'
let g:lynxToolsPath = g:lynxPath . '/tools/'

let g:WbAddress = ''

" Initialization {{{1
" Create path to dump the files (may act as an history path but files of same name are replaced) {{{2
if isdirectory(g:WbLynxDumpPath) == 0
    call mkdir(g:WbLynxDumpPath)
endif

" Functions {{{1

function! DoWebDump(address) " {{{2
    " Download a page to a file
    " Percent-encode some characters because it causes problems in the command line on the windows test computer {{{3
    "! 		# 		$ 		& 		' 		( 		) 		* 		+ 		, 		/ 		: 		; 		= 		? 		@ 		[ 		]
    "%21 	%23 	%24 	%26 	%27 	%28 	%29 	%2A 	%2B 	%2C 	%2F 	%3A 	%3B 	%3D 	%3F 	%40 	%5B 	%5D
    let l:address = substitute(a:address, '&', '\\%26', 'g')
    let l:address = substitute(l:address, '#', '\\%23', 'g')
    " Substitute invalid characters
    let l:dumpFile = substitute(l:address, '\', '_', 'g')
    let l:dumpFile = substitute(l:dumpFile, '/', '-', 'g')
    let l:dumpFile = substitute(l:dumpFile, ':', '_', 'g')
    let l:dumpFile = substitute(l:dumpFile, '*', '_', 'g')
    let l:dumpFile = substitute(l:dumpFile, '?', '_', 'g')
    let l:dumpFile = substitute(l:dumpFile, '"', '_', 'g')
    let l:dumpFile = substitute(l:dumpFile, '<', '_', 'g')
    let l:dumpFile = substitute(l:dumpFile, '>', '_', 'g')
    let l:dumpFile = substitute(l:dumpFile, '|', '_', 'g')
    let l:dumpFile = substitute(l:dumpFile, '%', '_', 'g')
    let l:dumpFile = substitute(l:dumpFile, '=', '_', 'g')
    " Get extension of the file {{{3
    let l:extPos = strridx(a:address, '.')
    let l:extLen = strlen(a:address) - l:extPos
    let l:extName = strpart(a:address, l:extPos, l:extLen)
    " Open the webpage/file and dump it using the lynx -dump feature to the dump directory {{{3
    exe 'silent ! ' . g:lynxCmd . ' -dump ' . l:address . ' > "' . g:WbLynxDumpPath . l:dumpFile . '"'
    " Select view method according to the page/file extension {{{3
    let l:vimFile = ''
    " View image files {{{4
    if l:extName == '.jpg' || l:extName == '.gif' || l:extName == '.png'
        " Windows
        if has('Win32')
            exe 'silent !start "' . g:lynxToolsPath . 'i_view32.exe" "' . g:WbLynxDumpPath . l:dumpFile . '"'
        " Linux
        else
            exe 'silent !"' . g:lynxToolsPath . 'i_view32.exe" "' . g:WbLynxDumpPath . l:dumpFile . '"'
        endif
    " View pdf files {{{4
    elseif l:extName == '.pdf'
        exe 'silent ! "' . g:lynxToolsPath . 'pdftotext.exe" "' . g:WbLynxDumpPath . l:dumpFile . '" "' . g:WbLynxDumpPath . l:dumpFile . '.txt"'
        let l:vimFile = g:WbLynxDumpPath . l:dumpFile . '.txt'
    " View any other extension (html, htm or no extension etc.) {{{4
    else
        let l:vimFile = g:WbLynxDumpPath . l:dumpFile
    endif
    return l:vimFile
endfunction

function! OpenWebBrowser(address, openInNewTabSplit) " {{{2
    " Download the file
    let l:vimFile = DoWebDump(a:address)
    " Open the dumped file in the buffer {{{3
    if l:vimFile != ''
        if a:openInNewTabSplit == 1
            exe "tabnew"
        elseif a:openInNewTabSplit == 2
            exe "vnew"
        else
            " Clear the buffer
            setlocal modifiable
            exe "normal  ggdG"
        endif
        exe "set buftype=nofile"
        " L (Open link)
        exe 'nnoremap <buffer> <silent> L F[h/^ *<c-r><c-w>. \zs\(http\\|file\)<cr>GN$?http<cr>"py$:call OpenWebBrowser("<c-r>p", 0)<cr>'
        exe 'nnoremap <buffer> <silent> <C-l> F[h/^ *<c-r><c-w>. \zs\(http\\|file\)<cr>GN'
        exe 'nnoremap <buffer> gf "py$:call OpenWebBrowser("<c-r>p", 0)<cr>'
        exe 'nnoremap <buffer> gF :call OpenWebBrowser("", 0)<left><left><left><left><left>'
        " H (Previous page ("back button"))
        exe 'nnoremap <buffer> <silent> H :setlocal modifiable<cr>:normal u<cr>:setlocal nomodifiable<cr>'
        " J (Highlight links and go to next link)
        exe "nnoremap <buffer> <silent> J /\[\\zs\\d*\\]\\w*<cr>"
        " K (Highlight links and go to previous link)
        exe "nnoremap <buffer> <silent> K ?\[\\zs\\d*\\]\\w*<cr>"
        " Read the file in the buffer
        exe 'silent r ' . l:vimFile
        " Set syntax to have bold links
        syn reset
        syn match Keyword /\[\d*\]\w*/ contains=Ignore
        syn match Ignore /\[\d*\]/ contained
        exe "norm gg"
        let g:WbAddress = substitute(a:address, '"', '', 'g')
        call append(0, [g:WbAddress])
        doautocmd User BrowseEnter
        exe "norm k"
        setlocal nomodifiable
    else
        " Return to previous cursor position to return to where the link was executed
        exe "norm! \<c-o>"
    endif
    " Add address to append register which acts as an history for the current session
    "let @H = strftime("%x %X") . ' <url:' . g:WbAddress . '>'
endfun

" }}}
" vim: foldmethod=marker:foldlevel=1
