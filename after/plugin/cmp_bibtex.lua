vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("cmp_bibtex", { clear = true }),
  pattern = "*.typ",
  callback = function()
    require("cmp").register_source("bibtex", require("cmp_bibtex"))
  end,
})
