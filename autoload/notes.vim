" notes.vim - Autoload functions for the notes plugin
" Author: ErHakanCem
" Last Change: 2025-05-26
" Version: 0.2

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
  
  " Debug message to confirm function is executing
  echo "Searching for: " . search_term . " in " . expand(g:zettelkasten)
  
  " Define grep command properly
  let grep_cmd = 'grep -l "' . search_term . '" ' . expand(g:zettelkasten) . '/*' . g:notes_extension . ' 2>/dev/null'
  
  " Use grep or fzf if available
  if exists("*fzf#run")
    " Use FZF to search notes
    call fzf#run({
      \ 'source': grep_cmd,
      \ 'sink': 'edit',
      \ 'options': '--preview "bat --style=numbers --color=always {}"',
      \ 'down': '40%'
      \ })
  else
    " Fallback to simple grep
    let files = systemlist(grep_cmd)
    if len(files) == 0
      " Try using find as an alternative in case grep is failing
      let find_cmd = 'find ' . expand(g:zettelkasten) . ' -type f -name "*' . g:notes_extension . '" | xargs grep -l "' . search_term . '" 2>/dev/null || echo ""'
      echo "Trying alternative: " . find_cmd
      let files = systemlist(find_cmd)
    endif
    
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

