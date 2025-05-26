" notes.vim - Simple Zettelkasten note taking plugin for Vim
" Author: ErHakanCem
" Last Change: 2025-05-26
" Version: 0.2
" Repository: https://github.com/ErHakanCem/vim-notes

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

" Create the notes directory if it doesn't exist
if !isdirectory(expand(g:zettelkasten))
  call mkdir(expand(g:zettelkasten), 'p')
endif

" Define key mappings if they don't exist in .vimrc
if !hasmapto('<Plug>NotesNewNote')
  map <leader>nn <Plug>NotesNewNote
endif

if !hasmapto('<Plug>NotesFindNote')
  " Avoid using nf which is used by timestamp_notes.vim
  nmap <leader>ns <Plug>NotesFindNote
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
  map <leader>nc <Plug>NotesCreateLinked
  vmap <leader>nc <Plug>NotesCreateLinked
endif

" Define plug mappings
nnoremap <silent> <Plug>NotesNewNote :<C-U>call notes#make_new_note()<CR>
vnoremap <silent> <Plug>NotesNewNote :call notes#make_new_note()<CR>
" More explicit mapping for find notes
nnoremap <silent> <Plug>NotesFindNote :<C-U>call notes#find_note()<CR>
nnoremap <silent> <Plug>NotesListNotes :<C-U>call notes#list_notes()<CR>
nnoremap <silent> <Plug>NotesAddLink :<C-U>call notes#add_link()<CR>
nnoremap <silent> <Plug>NotesFollowLink :<C-U>call notes#follow_link()<CR>
nnoremap <silent> <Plug>NotesCreateLinked :<C-U>call notes#create_linked_note()<CR>
vnoremap <silent> <Plug>NotesCreateLinked :call notes#create_linked_note()<CR>

" Command definitions
command! -range Notes call notes#make_new_note()
" Add debug command
command! -nargs=0 NotesFindDebug echom "Debug: Executing find_note function in " . expand(g:zettelkasten)

" Update the original command definition to be consistent
command! -nargs=0 NoteFind call notes#find_note()
command! -nargs=0 NoteList call notes#list_notes()
command! -nargs=0 NoteLink call notes#add_link()
command! -nargs=0 NoteFollow call notes#follow_link()
command! -nargs=0 NoteCreateLinked call notes#create_linked_note()

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

