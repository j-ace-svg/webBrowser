### This is a mirror of http://www.vim.org/scripts/script.php?script_id=4315

## Upstream
- Name: webBrowser.vim
- Version: 1.6
- Description: Uses the lynx text browser to browse websites and local files and return the rendered web pages inside vim. The links in the web pages may be "clicked" to follow them, so it turns vim into a simple web text based web browser. This plugin is based on the "browser.vim" plugin.
- Author: Alexandre Viau (alexandreviau@gmail.com)
- Website: The latest version is found on "vim.org"

## Fork
- Version: 1.6.1
- Fork Author: John Montgomery (j.ace.svg@gmail.com)

(Note: Versioning is MAJOR.MINOR-UPSTREAM.MINOR-DOWNSTREAM)

## Installation
Copy the plugin to the vim plugin directory.
In the lynx.cfg file, set the following parameters: 
```
ACCEPT_ALL_COOKIES:TRUE
MAKE_LINKS_FOR_ALL_IMAGES:TRUE
```
Change the following paths to your lynx files:
```VimL
" Variables {{{1
let g:lynxPath = $HOME.'/.vim/lynx/'
let g:lynxExe = '/usr/bin/lynx'
let g:lynxCfg = '-cfg=' . g:lynxPath . 'lynx.cfg'
let g:lynxLss = '-lss=' . g:lynxPath . 'lynx.lss'
let g:lynxCmd = g:lynxExe . ' ' . g:lynxCfg . ' ' . g:lynxLss

let g:WbLynxDumpPath = g:lynxPath . '/dump/'
let g:lynxToolsPath = g:lynxPath . '/tools/'
```

## Usage
```
L (Open link)
<C-l> (Jump to link at bottom of page)
H (Previous page ("back button"))
J (Highlight links and go to next link)
K (Highlight links and go to previous link)
gf (Open prompt for address to navigate to)
gF (Navigate to the address under the cursor)
```

### Suggested mappings
```VimL
" Open a new web browser tab with the address specified
<leader>wb :WebBrowser
" Open a new web browser tab with the address in the clipboard
<leader>wc :exe 'WebBrowser "' . @* . '"'<cr>
" Do a google search using the specified search keywords and open the results in a new tab
<leader>wg :exe 'WebBrowser www.google.com/search?q="' . input("Google ") . '"'<cr>
" Do a wikipedia search using the specified search keywords and open the results in a new tab
<leader>wp :exe 'WebBrowser www.wikipedia.com/wiki/"' . input("Wikipedia ") . '"'<cr>
" Downloads the specified webpage without opening it in vim
<leader>wd :WebDump
```

## Todo
- Redo the code that gets the link number and search for it at the end of the file (no need to move cursor) and to do it in a mapping, it may be done in a function
- I added basicXmlParser in the plugin, add a webBrowser.xml file and in it, have 2 keys: history and favorites, which will be string of utl links
- Add links bar like vimExplorer (favorites & history) with links not from utl but with brackets [http://yahoo.com] thus no need for utl
- Use image_links and accept_all_cookies options in the command run from the plugin instead of having to modify the .cfg file

## History 
1.1 
- Changed the file format to unix<br>

1.2 
- Changed the mappings<br>

1.3 
- Now the lynx command and others are ran using a call to the system() function so that the dos prompt window is not displayed on the screen<br>
- Added suggested mappings in comments (<insert>, <delete>, etc)<br>
- Added folds<br>

1.4 
- Changed mappings \wb etc to <leader>wb because it was causing my "w" key in normal mode to wait for another key<br>

1.5 
- Added the webdump command and function to download in batch<br>

1.6 
- Added documentation and usage<br>

1.6.1
- Port to Unix file paths by default
- Make lynx interaction globally configurable
- Use nnoremap mappings
- Uniformly use `g:lynxPath`
- Fix formatting
- Make web page buffers unmodifiable
- Create a new buffer when browsing in the same tab
- Improve link finding
- Use HLKJ rather than leader key bindings
- Add gf and gF bindings
