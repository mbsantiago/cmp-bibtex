local Path = require("plenary.path")
local scan = require("plenary.scandir")

---@class cmp_bibtex.PathModule
local path = {}

--- @param startpath string
--- @return string|nil
function path.find_git_ancestor(startpath)
  local current_path = Path:new(startpath)

  local guard = 100
  while current_path:exists() do
    -- guard to prevent infinite loops
    guard = guard - 1
    if guard == 0 then
      return nil
    end

    if current_path:joinpath(".git"):exists() then
      return current_path:absolute()
    end

    if current_path:is_root() then
      return nil
    end

    current_path = current_path:parent()
  end
  return nil
end

---@return string
function path.get_root()
  local current_dir = vim.fn.expand("%:p:h")
  return path.find_git_ancestor(current_dir) or current_dir
end

---@class PathInfo
---@field path string
---@field updated_on number

---@param root string
---@return PathInfo[]
function path.get_bib_files(root)
  local files = scan.scan_dir(root, {
    search_pattern = ".bib",
    add_dirs = false,
    hidden = true,
    depth = 1,
    silent = true,
  })
  return vim.tbl_map(function(file)
    return {
      path = file,
      updated_on = vim.fn.getftime(file),
    }
  end, files)
end

return path
