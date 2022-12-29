local _2aconfig_2a = {project_path = (vim.env.HOME .. "/projects")}
local _2atemplates_2a = {}
local function cd_project(project)
  local path = (_2aconfig_2a.project_path .. "/" .. project)
  local session = (path .. "/.nvim/session.vim")
  do
    local dir_3f
    local function _1_(_241)
      return (1 == vim.fn.isdirectory(_241))
    end
    dir_3f = _1_
    assert(dir_3f(path), (project .. " is not a directory"))
  end
  if vim.loop.fs_access(session, "R") then
    vim.cmd.source(session)
  else
    vim.cmd.edit(path)
  end
  vim.cmd.cd(path)
  vim.g.project_root = path
  return nil
end
local function open_project(project)
  if (("" == project) or (nil == project)) then
    local projects
    do
      local tbl_17_auto = {}
      local i_18_auto = #tbl_17_auto
      for p in vim.fs.dir(_2aconfig_2a.project_path) do
        local val_19_auto = p
        if (nil ~= val_19_auto) then
          i_18_auto = (i_18_auto + 1)
          do end (tbl_17_auto)[i_18_auto] = val_19_auto
        else
        end
      end
      projects = tbl_17_auto
    end
    local function _4_(project0)
      if (nil == project0) then
        return nil
      else
        return cd_project(project0)
      end
    end
    return vim.ui.select(projects, {prompt = "Select project:", kind = "project"}, _4_)
  else
    return cd_project(project)
  end
end
local function expand_template(_7_)
  local _arg_8_ = _7_
  local expand = _arg_8_["expand"]
  local function _9_(_241)
    if (nil == _241) then
      return nil
    else
      local path = (_2aconfig_2a.project_path .. "/" .. _241)
      assert((1 == vim.fn.mkdir(path)), "Failed to create directory")
      vim.cmd.cd(path)
      vim.g.project_root = path
      do
        local _10_ = type(expand)
        if (_10_ == "string") then
          os.execute(expand)
        elseif (_10_ == "function") then
          expand(_241, path)
        else
        end
      end
      return vim.cmd.edit(path)
    end
  end
  return vim.ui.input({prompt = "Enter project name:", default = "unnamed"}, _9_)
end
local function new_project()
  local function _13_(_241)
    return _241.name
  end
  local function _14_(_241)
    if (nil == _241) then
      return nil
    else
      return expand_template(_241)
    end
  end
  return vim.ui.select(_2atemplates_2a, {prompt = "Select template", kind = "project-template", format_item = _13_}, _14_)
end
local function save_session()
  assert((("string" == type(vim.g.project_root)) and ("" ~= vim.g.project_root)), "Not in project")
  local nvim_dir = (vim.g.project_root .. "/.nvim")
  if (0 == vim.fn.isdirectory(nvim_dir)) then
    assert((1 == vim.fn.mkdir(nvim_dir)), "Failed to save session")
  else
  end
  return vim.cmd(("mksession! " .. nvim_dir .. "/session.vim"))
end
local function setup(config)
  assert(("table" == type(config)), "config: expected table")
  _2aconfig_2a = vim.tbl_deep_extend("force", _2aconfig_2a, config)
  return nil
end
local function register_template(template)
  assert(("string" == type(template.name)), "name: expected string")
  do
    local t = type(template.expand)
    assert((("string" == t) or ("function" == t)), "expand: expected string|function")
  end
  return table.insert(_2atemplates_2a, template)
end
return {open_project = open_project, new_project = new_project, setup = setup, register_template = register_template, save_session = save_session}
