--- cmp_bibtex.options Module
-- Defines configuration options for the BibTeX autocompletion source.
-- Provides:
--   - Default options
--   - Validation of user-provided options

---@class cmp_bibtex.Options Configuration options for the BibTeX
---autocompletion source.
---@field search_fields string[] Array of BibTeX fields to search for matches
---(e.g., "title", "author").
---@field cite_key_search boolean Whether to include citation keys in the
---search.
---@field doc_fields string[] Array of fields to display in the completion
---item's documentation window.
---@field info_in_window boolean If true, displays BibTeX entry information in
---a preview window.
---@field symbols_in_menu boolean If true, includes symbols in the completion
---menu.

---@class cmp_bibtex.OptionsModule
---@field defaults cmp_bibtex.Options Default options for the BibTeX
local options = {}

options.defaults = {
  cite_key_search = true,
  search_fields = { "title", "author", "abstract" },
  doc_fields = { "title", "author", "year", "journal", "abstract" },
  info_in_window = true,
  symbols_in_menu = false,
}


--- Validates user-provided options.
-- Merges user options with defaults, ensuring that all required options are
-- present and of the correct type. Raises an error if any option is invalid.
---@param opts cmp_bibtex.Options (Optional) User-provided options.
---@return cmp_bibtex.Options Validated and merged options.
function options.validate(opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, options.defaults)
  vim.validate({
    cite_key_search = { opts.cite_key_search, "boolean" },
    search_fields = { opts.search_fields, "table" },
    doc_fields = { opts.doc_fields, "table" },
    info_in_window = { opts.info_in_window, "boolean" },
    symbols_in_menu = { opts.symbols_in_menu, "boolean" },
  })
  return opts
end

return options
