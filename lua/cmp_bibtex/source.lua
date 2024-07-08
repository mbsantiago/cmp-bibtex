--- cmp_bibtex.source Module
-- Defines the BibTeX completion source for nvim-cmp.

local path = require("cmp_bibtex.path")
local parser = require("cmp_bibtex.parser")
local options = require("cmp_bibtex.options")
local utils = require("cmp_bibtex.formatting")

---@class cmp_bibtext.Source: cmp.Source
---@field parser cmp_bibtex.Parser The BibTeX parser instance.
local source = {}

--- Constructor for the BibTeX source.
-- Initializes the source and creates a new parser instance with the Git root
-- directory as the base path.
function source.new()
  local self = setmetatable({}, { __index = source })
  self.parser = parser.new(path.get_root())
  return self
end

---@return string[]
function source.get_trigger_characters()
  return { "@" }
end

--- Retrieves the keyword pattern for BibTeX completion.
-- Matches a pattern starting with '@' followed by alphanumeric characters.
---@return string The keyword pattern.
function source.get_keyword_pattern()
  return "[@][[:alnum:]]*"
end

---@return string
function source.get_position_encoding_kind()
  return "utf-8"
end

--- Checks if the source is available for completion.
-- Currently, the source is only available in 'typst' filetypes.
---@return boolean True if available, false otherwise.
function source:is_available()
  return vim.o.filetype == "typst"
end

--- Completes BibTeX entries based on the provided parameters.
-- Updates the BibTeX file index, parses the entries, prepares completion items,
-- and handles asynchronous completion based on the parser's readiness.
---@param params cmp.SourceCompletionApiParams The completion parameters.
---@param callback fun(response?: lsp.CompletionList) The callback function.
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

--- Validates the options passed to the source.
---@param params cmp.SourceCompletionApiParams The completion parameters.
---@return cmp_bibtex.Options The validated options.
---@private
function source:validate_options(params)
  return options.validate(params.option)
end

return source
