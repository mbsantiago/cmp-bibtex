---@class cmp_bibtex.OptionsModule
local options = {}

---@class cmp_bibtex.Options
---@field search_fields string[]
---@field cite_key_search boolean
---@field doc_fields string[]
---@field info_in_window boolean
---@field symbols_in_menu boolean
options.defaults = {
  cite_key_search = true,
  search_fields = { "title", "author", "abstract" },
  doc_fields = { "title", "author", "year", "journal", "abstract" },
  info_in_window = true,
  symbols_in_menu = false,
}

---@return cmp_bibtex.Options
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
