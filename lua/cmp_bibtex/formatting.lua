--- cmp_bibtex.formatting Module
-- Handles the formatting of BibTeX entries for display in the autocomplete
-- menu and documentation window.

local cmp = require("cmp")

--- Mappings from BibTeX entry types to LSP completion item kinds.
local types = {
  article = "Text",
  book = "Method",
  booklet = "Function",
  conference = "Constructor",
  inbook = "Field",
  incollection = "Variable",
  inproceedings = "Class",
  manual = "Interface",
  mastersthesis = "Module",
  misc = "Property",
  phdthesis = "Unit",
  proceedings = "Value",
  techreport = "Enum",
  unpublished = "Keyword",
  default = "Snippet",
  empty = "Color",
}

--- Symbol mapping for display in the completion menu.
local kind = {
  [types["article"]] = "󰈙 article",
  [types["book"]] = " book",
  [types["booklet"]] = " booklet",
  [types["conference"]] = " conference",
  [types["inbook"]] = "󰂺 inbook",
  [types["incollection"]] = "󱉟 incollection",
  [types["inproceedings"]] = " inproceedings",
  [types["manual"]] = " manual",
  [types["mastersthesis"]] = "󱛉 mastersthesis",
  [types["misc"]] = " misc",
  [types["phdthesis"]] = "󱛉 phdthesis",
  [types["proceedings"]] = " proceedings",
  [types["techreport"]] = " techreport",
  [types["unpublished"]] = "󰷉 unpublished",
  [types["default"]] = "󰈙 default",
  [types["empty"]] = "",
  default = "󰈙 default",
}

--- Formatters for specific BibTeX fields.
---@type table<string, fun(value: string, type: string): string>
local formatters = {
  title = function(value, _)
    return "# " .. value:gsub("[%}%{}]", ""):upper()
  end,
  author = function(value, _)
    return "**authors**: *" .. value:gsub("[%}%{}]", "") .. "*"
  end,
  abstract = function(value, _)
    return "\n" .. value:gsub("[%}%{}]", "")
  end,
  default = function(value, type)
    return "**" .. type .. "**: " .. value:gsub("[%}%{}]", "")
  end,
}

---@class cmp_bibtex.FormattingModule
local formatting = {}

--- Prepares a completion item for a BibTeX entry.
---@param entry cmp_bibtex.BibTexEntry The BibTeX entry.
---@param opts cmp_bibtex.Options The plugin options.
---@return lsp.CompletionItem The formatted completion item.
function formatting.prepare_item(entry, opts)
  return {
    label = formatting.get_label(entry),
    kind = formatting.get_kind(entry, opts),
    insertText = formatting.get_insert_text(entry),
    documentation = formatting.get_documentation(entry, opts),
    filterText = formatting.get_filter_text(entry, opts),
  }
end

--- Gets the LSP completion item kind for a BibTeX entry.
---@param entry cmp_bibtex.BibTexEntry The BibTeX entry.
---@param opts cmp_bibtex.Options The plugin options.
---@return lsp.CompletionItemKind The completion item kind.
function formatting.get_kind(entry, opts)
  if not opts.symbols_in_menu then
    return cmp.lsp.CompletionItemKind[types["empty"]]
  end
  local type = entry.type:lower():sub(2)
  return cmp.lsp.CompletionItemKind[types[type] or types.default]
end

--- Gets the completion label for a BibTeX entry
---@param entry cmp_bibtex.BibTexEntry The BibTeX entry.
---@return string The label.
function formatting.get_label(entry)
  return "@" .. entry.cite_key
end

--- Gets the text to insert when completing a BibTeX entry.
---@param entry cmp_bibtex.BibTexEntry The BibTeX entry.
---@return string The insert text.
function formatting.get_insert_text(entry)
  return "@" .. entry.cite_key
end

--- Gets the filter text for a BibTeX entry (for fuzzy matching).
---@param entry cmp_bibtex.BibTexEntry The BibTeX entry.
---@param opts cmp_bibtex.Options The plugin options.
---@return string The filter text.
function formatting.get_filter_text(entry, opts)
  local filter_text = { "@" }

  if opts.cite_key_search then
    table.insert(filter_text, entry.cite_key)
  end

  for _, field in pairs(opts.search_fields) do
    local value = entry.fields[field]
    if value then
      table.insert(filter_text, value)
    end
  end

  return table.concat(filter_text, " ")
end

--- Gets the documentation content in markdown for a BibTeX entry.
---@param entry cmp_bibtex.BibTexEntry The BibTeX entry.
---@param opts cmp_bibtex.Options The plugin options.
---@return lsp.MarkupContent The documentation content.
function formatting.get_documentation(entry, opts)
  local docs = {}

  for _, field in pairs(opts.doc_fields) do
    local value = entry.fields[field]
    if value then
      local formatter = formatters[field] or formatters.default
      table.insert(docs, formatter(value, field))
    end
  end

  local docstring = table.concat(docs, "\n")

  return {
    kind = "markdown",
    value = docstring,
  }
end

--- Formats a completion item for display in the completion menu.
---@param vim_item table The completion item data.
---@return table The formatted completion item.
function formatting.format(_, vim_item)
  vim_item.menu = "[BibTex]"

  if vim_item.kind ~= nil then
    vim_item.kind = kind[vim_item.kind] or kind["default"]
  end

  return vim_item
end

return formatting
