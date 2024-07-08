local cmp = require("cmp")

--- Kinds
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

---@param entry cmp_bibtex.BibTexEntry
---@param opts cmp_bibtex.Options
---@return lsp.CompletionItem
function formatting.prepare_item(entry, opts)
  return {
    label = formatting.get_label(entry),
    kind = formatting.get_kind(entry, opts),
    insertText = formatting.get_insert_text(entry),
    documentation = formatting.get_documentation(entry, opts),
    filterText = formatting.get_filter_text(entry, opts),
  }
end

---@param entry cmp_bibtex.BibTexEntry
---@return lsp.CompletionItemKind
function formatting.get_kind(entry, opts)
  if not opts.symbols_in_menu then
    return cmp.lsp.CompletionItemKind[types["empty"]]
  end
  local type = entry.type:lower():sub(2)
  return cmp.lsp.CompletionItemKind[types[type] or types.default]
end

---@param entry cmp_bibtex.BibTexEntry
---@return string
function formatting.get_label(entry)
  return "@" .. entry.cite_key
end

---@param entry cmp_bibtex.BibTexEntry
---@return string
function formatting.get_insert_text(entry)
  return "@" .. entry.cite_key
end

---@param entry cmp_bibtex.BibTexEntry
---@param opts cmp_bibtex.Options
---@return string
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

---@param entry cmp_bibtex.BibTexEntry
---@param opts cmp_bibtex.Options
---@return lsp.MarkupContent
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

function formatting.format(entry, vim_item)
  if (vim_item == nil) then
    vim.notify("vim_item is nil " .. vim.inspect(entry), vim.log.levels.ERROR)
  end

  vim_item.menu = "[BibTex]"

  -- if vim_item.kind ~= nil then
  --   vim_item.kind = kind[vim_item.kind] or kind["default"]
  -- end

  return vim_item
end

return formatting
