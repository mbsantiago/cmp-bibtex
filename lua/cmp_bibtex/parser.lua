local path = require("cmp_bibtex.path")
local timer = require("cmp_bibtex.timer")
local api = vim.api
local ts = vim.treesitter

local entry_query = ts.query.parse(
  "bibtex",
  [[(entry
      ty: (entry_type) @type
      key: (key_brace) @key) @entry
  ]]
)

local field_query = ts.query.parse(
  "bibtex",
  [[(field
      name: (identifier) @key
      value: (value) @value)
  ]]
)

---@class cmp_bibtex.Parser
---@field private files table<string, cmp_bibtex.FileInfo>
---@field private entries table<string, cmp_bibtex.BibTexEntry>
---@field private root string
local parser = {}

---@param root string
---@return cmp_bibtex.Parser
function parser.new(root)
  local self = setmetatable({}, { __index = parser })
  self.root = root
  self.files = {}
  self.entries = {}
  return self
end

function parser:update()
  self:update_files()
  self:update_entries()
end

function parser:is_ready()
  for _, file in pairs(self.files) do
    if not file.indexed then
      return false
    end
  end
  return true
end

function parser:get_entries()
  return self.entries
end

---@private
function parser:update_files()
  local new_files = path.get_bib_files(self.root)
  for _, file in pairs(new_files) do
    if not self.files[file.path] then
      self.files[file.path] = {
        path = file.path,
        updated_on = file.updated_on,
        indexed = false,
        indexed_on = nil,
        processing = false,
      }
    elseif
      self.files[file.path].indexed_on ~= nil
      and self.files[file.path].indexed_on > file.updated_on
    then
      self.files[file.path].updated_on = file.updated_on
      self.files[file.path].indexed = false
      self.files[file.path].indexed_on = nil
    end
  end
end

---@private
function parser:update_entries()
  for _, file in pairs(self.files) do
    if not file.indexed then
      if not file.processing then
        self:process_file(file)
      end
    end
  end
end

---@private
---@param file cmp_bibtex.FileInfo
function parser:process_file(file)
  local t = timer.new()
  file.processing = true
  t:start(0, 50, function()
    -- Parse the bib file
    local entries = parser.parse(file.path)

    -- Update the entries. Note that this will overwrite any existing entries
    for _, entry in pairs(entries) do
      self.entries[entry.cite_key] = entry
    end

    file.indexed = true
    file.indexed_on = os.time()
    file.processing = false

    t:stop()
  end)
end

---@class cmp_bibtex.BibTexEntry
---@field type string
---@field bibtex_file string
---@field cite_key string
---@field fields table<string, string>

---@class cmp_bibtex.BixTexBlock
---@field start_line number
---@field end_line number
---@field type string
---@field content string

---@param filename string
---@return cmp_bibtex.BibTexEntry[]
function parser.parse(filename)
  local bufnr = vim.api.nvim_create_buf(true, false)

  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("e " .. filename)
  end)

  local tree = ts.get_parser(bufnr, "bibtex"):parse(true)[1]
  local root = tree:root()

  local entries = {}
  for _, match, _ in entry_query:iter_matches(root, bufnr, 0, -1) do
    table.insert(entries, {
      bibtex_file = filename,
      type = parser.read_node(match[1], bufnr),
      cite_key = parser.read_node(match[2], bufnr),
      fields = parser.get_fields(match[3], bufnr),
    })
  end

  return entries
end

---@private
---@param node TSNode
---@return table<string, string>
function parser.get_fields(node, bufnr)
  local fields = {}
  for _, match, _ in field_query:iter_matches(node, bufnr, 0, -1) do
    local key = parser.read_node(match[1], bufnr)
    local value = parser.read_node(match[2], bufnr)
    fields[key] = value
  end
  return fields
end

---@private
---@param node TSNode
---@return string
function parser.read_node(node, bufnr)
  local start_row, start_col, end_row, end_col = node:range()
  local lines = api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)

  if #lines == 1 then
    return lines[1]:sub(start_col + 1, end_col)
  end

  lines[1] = lines[1]:sub(start_col + 1)
  lines[#lines] = lines[#lines]:sub(1, end_col)
  return table.concat(lines, "\n")
end

return parser
