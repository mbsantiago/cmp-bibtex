--- cmp_bibtex.path Module
-- Provides utilities for working with file paths in the context of BibTeX
-- files.
-- Includes functionality for:
-- - Finding the Git root directory.
-- - Finding BibTeX files within a directory.

---@class cmp_bibtex.PathModule
local path = {}

local Path = require("plenary.path")
local scan = require("plenary.scandir")

--- Finds the nearest Git ancestor directory.
-- Starts at `startpath` and traverses upwards until it finds a directory
-- containing a `.git` subdirectory. Returns the absolute path of the Git
-- ancestor or `nil` if not found. Includes a loop guard to prevent infinite
-- loops.
---@param startpath string The starting path to search from.
---@return string|nil The absolute path of the Git ancestor or `nil` if not
---found.
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

--- Gets the root directory for BibTeX file searches.
-- Attempts to find the Git root directory using the current file's directory.
-- If no Git root is found, falls back to the current file's directory.
---@return string The root directory.
function path.get_root()
  local current_dir = vim.fn.expand("%:p:h")
  return path.find_git_ancestor(current_dir) or current_dir
end

---@class PathInfo
---@field path string Absolute path of the file.
---@field updated_on number Timestamp of the last file modification.

--- Finds BibTeX files within a root directory.
-- Recursively searches for files with the `.bib` extension within the `root`
-- directory. Does not include directories in the results. Returns an array of
-- `PathInfo` objects for each BibTeX file found.
---@param root string The root directory to search.
---@return PathInfo[] Array of BibTeX file information.
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
