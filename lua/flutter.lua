local M = {}

M.job_id = nil

M.start_flutter_dev = function(cmd)
  local current_win_id = vim.api.nvim_get_current_win()

  vim.cmd("vnew")
  vim.fn.termopen(cmd)
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.cursorline = false
  M.job_id = vim.b.terminal_job_id

  vim.api.nvim_set_current_win(current_win_id)
end

M.send_to_flutter = function(key)
  return function()
    if M.job_id then
      vim.fn.jobsend(M.job_id, key)
    else
      print("No Flutter terminal found!")
    end
  end
end

local get_flutter_term_bufnr = function(cmd)
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(bufnr, '&buftype') == 'terminal' and string.find(vim.api.nvim_buf_get_name(bufnr), "term://.+:"..cmd) then
            return bufnr
        end
    end
    return -1
end

local get_flutter_term_winid = function(term_bufnr)
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win_id) == term_bufnr then
            return win_id
        end
    end
    return -1
end

M.toggle_flutter_terminal = function(cmd)
  -- 1. Check if the terminal window for the Flutter job is currently open.
  local term_buf_nr = get_flutter_term_bufnr(cmd)
  local term_win_id = get_flutter_term_winid(term_buf_nr)

  -- If the terminal window for the Flutter job is visible, close it and return.
  if term_win_id ~= -1 then
    vim.api.nvim_win_close(term_win_id, true)
    return
  end

  -- 2. If the terminal window isn't visible but there's a running Flutter job and its buffer exists,
  -- bring that buffer in a new vertical split.
  if term_buf_nr ~= -1 then
    vim.cmd("vsplit")
    vim.cmd("buffer " .. term_buf_nr)
    return
  end

  -- 3. If we reach here, it means one of the following:
  -- - There's no Flutter job ID stored.
  -- - The stored job has stopped running.
  -- - The buffer corresponding to the job doesn't exist anymore.
  -- Therefore, start a new Flutter development session.
  M.start_flutter_dev(cmd)
end

return M

-- vim: et sw=2 ts=2
