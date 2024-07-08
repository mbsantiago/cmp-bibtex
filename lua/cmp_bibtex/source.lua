local path = require("cmp_bibtex.path")
local parser = require("cmp_bibtex.parser")
local options = require("cmp_bibtex.options")
local utils = require("cmp_bibtex.formatting")

---@class cmp_bibtex.FileInfo
---@field path string Path to the file
---@field updated_on number Last time the file was updated
---@field indexed boolean Whether the file has been indexed
---@field indexed_on number|nil Last time the file was indexed
---@field processing boolean Whether the file is currently being processed

---@class cmp_bibtext.Source: cmp.Source
---@field parser cmp_bibtex.Parser
local source = {}

function source.new()
  local self = setmetatable({}, { __index = source })
  self.parser = parser.new(path.get_root())
  return self
end

---@return string[]
function source.get_trigger_characters()
  return { "@" }
end

function source.get_keyword_pattern()
  return "[@][[:alnum:]]*"
end

---@return string
function source.get_position_encoding_kind()
  return "utf-8"
end

---@return boolean
function source:is_available()
  return vim.o.filetype == "typst"
end

---@param params cmp.SourceCompletionApiParams
---@param callback fun(response?: lsp.CompletionList)
function source:complete(params, callback)
  local opts = self:validate_options(params)

  -- Avoid unexpected completion.
  if
    not vim
      .regex(self.get_keyword_pattern() .. "$")
      :match_str(params.context.cursor_before_line)
  then
    return callback()
  end

  self.parser:update()
  local ready = self.parser:is_ready()

  --- Might need to defer the completion to allow for the parser to finish
  vim.defer_fn(function()
    local items = {}
    for _, entry in pairs(self.parser:get_entries()) do
      table.insert(items, utils.prepare_item(entry, opts))
    end
    callback({
      items = items,
      isIncomplete = not ready,
    })
  end, ready and 0 or 100)
end

---@private
---@param params cmp.SourceCompletionApiParams
---@return cmp_bibtex.Options
function source:validate_options(params)
  return options.validate(params.option)
end

return source
