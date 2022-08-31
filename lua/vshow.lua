local DEFAULT_CONFIG = {
  all = {
    { character = 'eol', symbol = '' },
    { character = 'tab', symbol = '> ' },
    { character = 'space', symbol = '' },
    { character = 'multispace', symbol = '' },
    { character = 'lead', symbol = '' },
    { character = 'trail', symbol = '-' },
    { character = 'extends', symbol = '' },
    { character = 'precedes', symbol = '' },
    { character = 'precedes', symbol = '' },
    { character = 'conceal', symbol = '' },
    { character = 'nbsp', symbol = '+' },
  },
  char = {},
  line = {},
  block = {},
}

local _config = {}

---@return table A deep copy of config
local function get_config()
  return vim.deepcopy(_config)
end

---@param user_config table|nil Configuration to merge with the default configuration
---@return table Merged configuration table
local function merge_configs(user_config)
  if not user_config then
    return vim.deepcopy(DEFAULT_CONFIG)
  else
    return vim.tbl_deep_extend('force', DEFAULT_CONFIG, user_config)
  end
end

---@param config table
local function setup_autocmds(config)
  local old_list
  local old_listchars
  local vshow_group_id = vim.api.nvim_create_augroup('vshow.lua', { clear = true })

  ---@param listchars table Existing listchars to update
  ---@param mode_settings table[] Data to update listchars
  ---@return table Updated listchars
  local function make_listchars(listchars, mode_settings)
    for _, setting in ipairs(mode_settings) do
      if setting.symbol ~= '' then
        if type(setting.character) == 'string' then
          listchars[setting.character] = setting.symbol
        else
          for _, char in ipairs(setting.character) do
            listchars[char] = setting.symbol
          end
        end
      end
    end
    return listchars
  end

  local function on_mode_changed(autocmd_tbl)
    local VISUAL_MODES = 'vV\x16'
    local previous_mode = string.sub(autocmd_tbl.match, 1, string.find(autocmd_tbl.match, ':') - 1)
    local current_mode = string.sub(autocmd_tbl.match, string.find(autocmd_tbl.match, ':') + 1, -1)
    local is_previous_mode_visual = string.find(VISUAL_MODES, previous_mode)
    local is_current_mode_visual = string.find(VISUAL_MODES, current_mode)

    if not is_previous_mode_visual and not is_current_mode_visual then
      return
    end

    if is_previous_mode_visual and not is_current_mode_visual then
      vim.opt_local.listchars = old_listchars
      vim.opt_local.list = old_list
      return
    end

    if not is_previous_mode_visual then
      old_list = vim.opt_local.list
      old_listchars = vim.opt_local.listchars
    end

    local new_listchars = make_listchars({}, config[1] or config.all)
    if current_mode == 'v' then
      new_listchars = make_listchars(new_listchars, config.char)
    elseif current_mode == 'V' then
      new_listchars = make_listchars(new_listchars, config.line)
    else -- '^V'
      new_listchars = make_listchars(new_listchars, config.block)
    end

    vim.opt_local.list = true
    vim.opt_local.listchars = new_listchars
  end

  vim.api.nvim_create_autocmd('ModeChanged', {
    pattern = '*:*',
    callback = on_mode_changed,
    group = vshow_group_id,
  })

end

---Characters `:` and `,` should not be used as symbols
---All characters used as symbols must be single width
---@param user_config table|nil
local function setup(user_config)
  _config = merge_configs(user_config)
  setup_autocmds(_config)
end

local vshow = {
  setup = setup,
  get_config = get_config,
}

return vshow
