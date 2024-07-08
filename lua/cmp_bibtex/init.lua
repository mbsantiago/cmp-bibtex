--- cmp_bibtex Plugin
-- Entry point for the `cmp_bibtex` Neovim plugin.
--
-- This plugin provides a completion source for nvim-cmp that allows you to
-- easily insert and autocomplete citations from your BibTeX files.
--
-- Plugin Structure:
--
-- The plugin is organized into several modules to manage different aspects of
-- its functionality:
--
-- - `cmp_bibtex.parser`: Handles parsing and indexing of BibTeX files.
-- - `cmp_bibtex.path`: Provides utilities for finding and working with file
-- paths.
-- - `cmp_bibtex.options`: Defines and validates configuration options.
-- - `cmp_bibtex.formatting`: Formats BibTeX entries for display in the
-- completion menu.
-- - `cmp_bibtex.source`: Implements the completion source for nvim-cmp.

return require("cmp_bibtex.source"):new()
