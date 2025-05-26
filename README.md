# vim-notes

A simple Zettelkasten note-taking plugin for Vim.

## Features

- Create timestamped Markdown notes with a consistent format
- Organize notes using a Zettelkasten system
- Easily search, list, and navigate between notes
- Create links between notes using wiki-style [[links]]
- Create new linked notes from within existing notes
- Support for FZF for enhanced navigation (optional)

## Installation

### Using a plugin manager (recommended)

#### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'ErHakanCem/vim-notes'
```

#### [Vundle](https://github.com/VundleVim/Vundle.vim)

```vim
Plugin 'ErHakanCem/vim-notes'
```

#### [NeoBundle](https://github.com/Shougo/neobundle.vim)

```vim
NeoBundle 'ErHakanCem/vim-notes'
```

### Manual installation

Clone the repository:

```
git clone https://github.com/ErHakanCem/vim-notes.git ~/.vim/pack/plugins/start/vim-notes
```

## Configuration

Set the location for your notes directory (default is `~/Documents/zets/`):

```vim
let g:zettelkasten = '~/path/to/your/notes/'
```

Set the file extension for notes (default is `.md`):

```vim
let g:notes_extension = '.md'
```

## Usage

### Key Mappings

The plugin defines the following key mappings:

- `<leader>nn`: Create a new note
- `<leader>nf`: Find a note by searching
- `<leader>nl`: List all notes
- `<leader>na`: Add a link to another note
- `<leader>ng`: Follow a link under the cursor
- `<leader>nk`: Create a new linked note (inserts link at cursor position)

### Commands

- `:Notes`: Create a new note
- `:NoteFind`: Find a note by searching
- `:NoteList`: List all notes
- `:NoteLink`: Add a link to another note
- `:NoteFollow`: Follow a link under the cursor
- `:NoteCreateLinked`: Create a new linked note

### Creating a New Note

To create a new note, press `<leader>nn` or run `:Notes`. You will be prompted for a title, and a new note will be created with a timestamp-based filename.

### Creating a Linked Note

While editing a note, you can create a new note and insert a link to it by pressing `<leader>nk` or running `:NoteCreateLinked`. This will:

1. Prompt you for a title for the new note
2. Insert a link at your cursor position
3. Create the new note with appropriate formatting
4. Return you to your original position

### FZF Integration

If you have FZF installed, the plugin will use it for enhanced note searching and listing.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

