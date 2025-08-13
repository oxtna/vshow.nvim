local M = {}

M.CHAR_VISUAL_MODE = 'v'
M.LINE_VISUAL_MODE = 'V'
M.BLOCK_VISUAL_MODE = '\22'
M.VISUAL_MODES = M.CHAR_VISUAL_MODE .. M.LINE_VISUAL_MODE .. M.BLOCK_VISUAL_MODE

---@class vshow.Configuration
---@field [1]? vshow.Listchars Settings applying to all visual modes
---@field char? vshow.Listchars Character-wise visual mode settings
---@field line? vshow.Listchars Line-wise visual mode settings
---@field block? vshow.Listchars Block-wise visual mode settings
---@field user_default? boolean Use user-defined listchars instead of Neovim's default listchars (default: false)

---@class vshow.Listchars
---@field eol? string
---@field tab? string
---@field space? string
---@field multispace? string
---@field lead? string
---@field leadmultispace? string
---@field trail? string
---@field extends? string
---@field precedes? string
---@field conceal? string
---@field nbsp? string

---@type vshow.Configuration
local config = {
  {
    tab = '> ',
    trail = '-',
    nbsp = '+',
  },
}

-- Merges the tables similar to vim.tbl_deep_extend with the **force** behavior, but removes values set to 0
---@generic T
---@param ... T
---@return T
local function merge(...)
  local ret = select(1, ...)
  for i = 2, select('#', ...) do
    local value = select(i, ...)
    if type(value) == 'table' then
      for k, v in pairs(value) do
        if v == 0 then
          ret[k] = nil
        else
          ret[k] = merge(ret[k], v)
        end
      end
    elseif value ~= nil then
      ret = value
    end
  end
  return ret
end

---@param autocmd_tbl table See nvim_create_autocmd() documentation for details
local function on_mode_changed(autocmd_tbl)
  local previous_mode, current_mode = autocmd_tbl.match:match('([^:]+):([^:]+)')
  local is_previous_mode_visual = string.find(M.VISUAL_MODES, previous_mode) ~= nil
  local is_current_mode_visual = string.find(M.VISUAL_MODES, current_mode) ~= nil

  if not is_previous_mode_visual and not is_current_mode_visual then
    return
  end

  -- Restore old listchars settings
  if is_previous_mode_visual and not is_current_mode_visual then
    vim.opt_local.list = M.old_list or vim.opt.list:get()
    vim.opt_local.listchars = M.old_listchars or vim.opt.listchars:get()
    return
  end

  -- Save old listchars settings
  if not is_previous_mode_visual then
    -- For some reason LSP is giving a warning that :get() is an undefined field
    ---@diagnostic disable-next-line: undefined-field
    M.old_list = vim.opt_local.list:get()
    ---@diagnostic disable-next-line: undefined-field
    M.old_listchars = vim.opt_local.listchars:get()
  end

  ---@type vshow.Listchars
  local listchars = vim.deepcopy(config[1]) or {}
  if current_mode == 'v' and config.char ~= nil then
    listchars = merge(listchars, config.char)
  elseif current_mode == 'V' and config.line ~= nil then
    listchars = merge(listchars, config.line)
  elseif current_mode == '\22' and config.block ~= nil then
    listchars = merge(listchars, config.block)
  end

  vim.opt_local.list = true
  vim.opt_local.listchars = listchars
end

---Characters `:` and `,` should not be used as symbols
---All characters used as symbols must be single width
---@param opts vshow.Configuration?
function M.setup(opts)
  if M.did_setup then
    return vim.notify('vshow.nvim is already setup', vim.log.levels.ERROR, { title = 'vshow.nvim' })
  end
  M.did_setup = true

  if opts ~= nil and opts.user_default then
    config = vim.tbl_deep_extend('force', { vim.opt.listchars:get() }, opts)
  elseif opts ~= nil then
    config = vim.tbl_deep_extend('force', config, opts)
  end

  local vshow_group_id = vim.api.nvim_create_augroup('vshow.lua', { clear = true })

  -- It's not possible to make a more specific pattern without alternatives which are not available in Lua
  vim.api.nvim_create_autocmd('ModeChanged', {
    pattern = '*:*',
    callback = on_mode_changed,
    group = vshow_group_id,
  })
end

return M
