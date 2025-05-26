" notes.vim - Simple Zettelkasten note taking plugin for Vim
" Author: Generated for ahmetomay
" Last Change: 2025-04-12
" Version: 0.1

" Prevent loading the plugin multiple times
if exists("g:loaded_notes")
  finish
endif
let g:loaded_notes = 1

" Default configuration
if !exists("g:zettelkasten")
  let g:zettelkasten = expand('~/Documents/zets/')
endif

if !exists("g:notes_extension")
  let g:notes_extension = '.md'
endif

" Ensure the notes directory exists
function! s:EnsureNotesDir()
  if !isdirectory(expand(g:zettelkasten))
    call mkdir(expand(g:zettelkasten), 'p')
  endif
endfunction

" Generate a timestamp-based filename for new notes
function! s:GenerateNoteFilename(title)
  let timestamp = strftime("%Y%m%d.%H%M")
  let cleaned_title = substitute(a:title, '[^A-Za-z0-9_-]', '_', 'g')
  return timestamp . '_' . cleaned_title . g:notes_extension
endfunction

" Create a new note with the given title
function! notes#make_new_note() range
  call s:EnsureNotesDir()
  
  " If a visual selection is provided, use it as note content
  let content = ""
  if a:firstline != a:lastline
    let content = join(getline(a:firstline, a:lastline), "\n")
  endif
  
  let title = input("Note title: ")
  if title == ""
    echo "Cancelled"
    return
  endif
  
  let filename = s:GenerateNoteFilename(title)
  let full_path = expand(g:zettelkasten) . '/' . filename
  
  " Create the new note file
  execute "edit " . full_path
  
  " Add title and content
  call setline(1, "# " . title)
  call setline(2, "")
  call setline(3, "Created: " . strftime("%Y-%m-%d %H:%M"))
  call setline(4, "Tags: ")
  call setline(5, "")
  call setline(6, "---")
  call setline(7, "")
  
  " Add the selected content if any
  if content != ""
    call append(7, split(content, "\n"))
  endif
  
  " Position cursor for editing
  normal! 8G
endfunction

" Find notes by title (partial match)
function! notes#find_note()
  call s:EnsureNotesDir()
  
  let search_term = input("Search notes: ")
  if search_term == ""
    echo "Cancelled"
    return
  endif
  
  " Use grep or fzf if available
  if exists("*fzf#run")
    " Use FZF to search notes
    call fzf#run({
      \ 'source': 'grep -l "' . search_term . '" ' . expand(g:zettelkasten) . '/*' . g:notes_extension,
      \ 'sink': 'edit',
      \ 'options': '--preview "bat --style=numbers --color=always {}"',
      \ 'down': '40%'
      \ })
  else
    " Fallback to simple grep
    let files = systemlist('grep -l "' . search_term . '" ' . expand(g:zettelkasten) . '/*' . g:notes_extension)
    if len(files) == 0
      echo "No matching notes found"
      return
    elseif len(files) == 1
      execute "edit " . files[0]
    else
      let i = 0
      for file in files
        let i += 1
        echo i . ": " . fnamemodify(file, ":t")
      endfor
      
      let choice = input("Select note (1-" . i . "): ")
      if choice =~ '^\d\+$' && choice > 0 && choice <= i
        execute "edit " . files[choice-1]
      else
        echo "Invalid selection"
      endif
    endif
  endif
endfunction

" List all notes
function! notes#list_notes()
  call s:EnsureNotesDir()
  
  if exists("*fzf#run")
    " Use FZF to list notes
    call fzf#run({
      \ 'source': 'find ' . expand(g:zettelkasten) . ' -name "*' . g:notes_extension . '"',
      \ 'sink': 'edit',
      \ 'options': '--preview "bat --style=numbers --color=always {}"',
      \ 'down': '40%'
      \ })
  else
    " Fallback to simple list
    let files = glob(expand(g:zettelkasten) . '/*' . g:notes_extension, 0, 1)
    if len(files) == 0
      echo "No notes found"
      return
    else
      let i = 0
      for file in files
        let i += 1
        echo i . ": " . fnamemodify(file, ":t")
      endfor
      
      let choice = input("Select note (1-" . i . "): ")
      if choice =~ '^\d\+$' && choice > 0 && choice <= i
        execute "edit " . files[choice-1]
      else
        echo "Invalid selection"
      endif
    endif
  endif
endfunction

" Add backlinks between notes
function! notes#add_link()
  let current_file = expand('%:t')
  let target = input("Link to note: ")
  
  if target == ""
    echo "Cancelled"
    return
  endif
  
  " Find matching notes
  let matches = glob(expand(g:zettelkasten) . '/*' . target . '*' . g:notes_extension, 0, 1)
  
  if len(matches) == 0
    echo "No matching notes found"
    return
  elseif len(matches) == 1
    let link_path = fnamemodify(matches[0], ":t:r")
    execute "normal! i[[" . link_path . "]]"
  else
    let i = 0
    for match in matches
      let i += 1
      echo i . ": " . fnamemodify(match, ":t")
    endfor
    
    let choice = input("Select note (1-" . i . "): ")
    if choice =~ '^\d\+$' && choice > 0 && choice <= i
      let link_path = fnamemodify(matches[choice-1], ":t:r")
      execute "normal! i[[" . link_path . "]]"
    else
      echo "Invalid selection"
    endif
  endif
endfunction

" Follow a link under the cursor
function! notes#follow_link()
  let line = getline('.')
  let pos = col('.')
  
  " Find the link around the cursor position
  let start = searchpos('\[\[', 'bn', line('.'))[1]
  let end = searchpos('\]\]', 'n', line('.'))[1]
  
  if start == 0 || end == 0 || pos < start || pos > end
    echo "No link under cursor"
    return
  endif
  
  let link = line[start+1:end-2]
  let matches = glob(expand(g:zettelkasten) . '/' . link . '*' . g:notes_extension, 0, 1)
  
  if len(matches) == 0
    echo "No matching note found for [[" . link . "]]"
    return
  elseif len(matches) == 1
    execute "edit " . matches[0]
  else
    let i = 0
    for match in matches
      let i += 1
      echo i . ": " . fnamemodify(match, ":t")
    endfor
    
    let choice = input("Select note (1-" . i . "): ")
    if choice =~ '^\d\+$' && choice > 0 && choice <= i
      execute "edit " . matches[choice-1]
    else
      echo "Invalid selection"
    endif
  endif
endfunction

" Create a new linked note and insert a link at current cursor position
function! notes#create_linked_note()
  " Store the current buffer number
  let source_buf = bufnr('%')
  let cur_pos = getpos('.')
  
  " Get the note title
  let title = input("New note title: ")
  if title == ""
    echo "Cancelled"
    return
  endif
  
  " Generate the filename
  let timestamp = strftime("%Y%m%d.%H%M")
  let cleaned_title = substitute(title, '[^A-Za-z0-9_-]', '_', 'g')
  let filename = timestamp . '_' . cleaned_title . g:notes_extension
  let full_path = expand(g:zettelkasten) . '/' . filename
  
  " Insert the link at current cursor position
  let link = "[[" . timestamp . '_' . cleaned_title . "]]"
  call append(line('.'), link)
  
  " Create and prepare the new note file
  execute "split " . full_path
  
  " Add title and content
  call setline(1, "# " . title)
  call setline(2, "")
  call setline(3, "Created: " . strftime("%Y-%m-%d %H:%M"))
  call setline(4, "Tags: ")
  call setline(5, "")
  call setline(6, "---")
  call setline(7, "")
  
  " Save the new file
  write
  
  " Return to the original buffer and position
  execute "buffer " . source_buf
  call setpos('.', cur_pos)
  normal! j
endfunction

" Define key mappings if they don't exist in .vimrc
if !hasmapto('<Plug>NotesNewNote')
  map <leader>nn <Plug>NotesNewNote
endif

if !hasmapto('<Plug>NotesFindNote')
  map <leader>nf <Plug>NotesFindNote
endif

if !hasmapto('<Plug>NotesListNotes')
  map <leader>nl <Plug>NotesListNotes
endif

if !hasmapto('<Plug>NotesAddLink')
  map <leader>na <Plug>NotesAddLink
endif

if !hasmapto('<Plug>NotesFollowLink')
  map <leader>ng <Plug>NotesFollowLink
endif

if !hasmapto('<Plug>NotesCreateLinked')
  map <leader>nk <Plug>NotesCreateLinked
endif

" Define plug mappings
nnoremap <silent> <Plug>NotesNewNote :<C-U>call notes#make_new_note()<CR>
vnoremap <silent> <Plug>NotesNewNote :call notes#make_new_note()<CR>
nnoremap <silent> <Plug>NotesFindNote :<C-U>call notes#find_note()<CR>
nnoremap <silent> <Plug>NotesListNotes :<C-U>call notes#list_notes()<CR>
nnoremap <silent> <Plug>NotesAddLink :<C-U>call notes#add_link()<CR>
nnoremap <silent> <Plug>NotesFollowLink :<C-U>call notes#follow_link()<CR>
nnoremap <silent> <Plug>NotesCreateLinked :<C-U>call notes#create_linked_note()<CR>

" Create the notes directory if it doesn't exist
call s:EnsureNotesDir()

" Set up autocommands for note files
augroup Notes
  autocmd!
  " When opening a note file, set appropriate options
  autocmd BufReadPost,BufNewFile */zets/*.md setlocal wrap linebreak conceallevel=2
  " Highlight [[links]] in notes
  autocmd BufReadPost,BufNewFile */zets/*.md syntax region NoteLink matchgroup=NoteDelimiter start="\[\[" end="\]\]" concealends
  autocmd BufReadPost,BufNewFile */zets/*.md highlight NoteLink ctermfg=39 guifg=#0087ff
  autocmd BufReadPost,BufNewFile */zets/*.md highlight NoteDelimiter ctermfg=248 guifg=#a8a8a8
augroup END

" Command definitions
command! -range Notes call notes#make_new_note()
command! -nargs=0 NoteFind call notes#find_note()
command! -nargs=0 NoteList call notes#list_notes()
command! -nargs=0 NoteLink call notes#add_link()
command! -nargs=0 NoteFollow call notes#follow_link()
command! -nargs=0 NoteCreateLinked call notes#create_linked_note()
" Ensure the Zettelkasten directory exists
if !isdirectory(expand(g:zettelkasten))
  call mkdir(expand(g:zettelkasten), 'p')
endif

