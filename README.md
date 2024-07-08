# cmp-bibtex

A [BibTeX](https://www.bibtex.org/) completion source for [`nvim-cmp`](https://github.com/hrsh7th/nvim-cmp).
`cmp-bibtex` adds BibTeX citation autocompletion to nvim-cmp, specifically for [typst](https://typst.app/) documents.

## Features

- **Fuzzy matching**: Easily find the right citation from your entire BibTeX library.
- **Rich details**: View all relevant information about your references directly in the completion menu.
- **Automatic triggering**: Start completing citations as soon as you type @.
- **Customizable**: Tailor the appearance and behavior to your preferences.

## Installation

Use your preferred plugin manager. For example, with [`lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
require("lazy").setup({
  "mbsantiago/cmp-bibtex",
})
```

## Setup

Add cmp-bibtex to your nvim-cmp sources:

```lua
require('cmp').setup({
  sources = {
    { name = 'bibtex', },
  },
})
```

## Enhancing the Completion Menu (Optional)

For a better visual experience, consider customizing the format function:

```lua
require('cmp').setup({
  --- Other configurations
  formatting = {
    format = function(entry, vim_item)
      if (entry.source.name == 'bibtex') then
        return require("cmp_bibtex.formatting").format(entry, vim_item)
      end
      -- Your default formatting logic here
      return vim_item
    end
  }
})

```

## Configuration

Fine-tune `cmp-bibtex` to your liking:

```lua
require('cmp').setup({
  sources = {
    {
      name = 'bibtex',
      option = {
        -- See the documentation for available options
      }
    },
  },
})
```

## Acknowledgments

Inspired by [`cmp-vimtex`](https://github.com/micangl/cmp-vimtex), this plugin builds upon its core concepts while adapting to typst's specific needs.
The main change is the use of [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) to parse the document and extract the bibliography entries.
Timer implementation is borrowed from [`cmp-buffer`](https://github.com/hrsh7th/cmp-buffer).
