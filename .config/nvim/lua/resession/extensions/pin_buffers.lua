local M = {}

M.on_save = function()
  local data = {}

  data.pinned_buffers = vim.g.pinned_buffers or {}
  for _, bufnr in ipairs(data.pinned_buffers) do
    data[bufnr] = {}
    data[bufnr].is_buffer_pinned = vim.b[bufnr].is_buffer_pinned
    data[bufnr].buffer_pinned_index = vim.b[bufnr].buffer_pinned_index
    data[vim.api.nvim_buf_get_name(bufnr)] = bufnr
  end

  return data
end

M.on_post_load = function(data)
  ---Create map from old buffer numbers to new buffer numbers
  local new_data = { pinned_buffers = {} }
  for _, new_bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local bufname = vim.api.nvim_buf_get_name(new_bufnr)
    local old_bufnr = data[bufname]
    local bufname_match_found = bufname and old_bufnr
    if bufname_match_found then
      new_data[new_bufnr] = {}
      new_data[new_bufnr].is_buffer_pinned = data[tostring(old_bufnr)].is_buffer_pinned
      new_data[new_bufnr].buffer_pinned_index = data[tostring(old_bufnr)].buffer_pinned_index
      table.insert(new_data.pinned_buffers, new_bufnr)
    end
  end

  vim.g.pinned_buffers = new_data.pinned_buffers
  for _, bufnr in ipairs(vim.g.pinned_buffers) do
    vim.b[bufnr].is_buffer_pinned = new_data[bufnr].is_buffer_pinned
    vim.b[bufnr].buffer_pinned_index = new_data[bufnr].buffer_pinned_index
  end
end

return M
