-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at https://mozilla.org/MPL/2.0/.

local neoproj = require "neoproj"

-- Commands
local command = vim.api.nvim_create_user_command
local function project_open_callback(tbl)
  return neoproj.open_project(tbl.args)
end
command("ProjectOpen", project_open_callback, { nargs = "?" })
command("ProjectNew", neoproj.new_project, {})
command("ProjectSaveSession", neoproj.save_session, {})

-- Default templates
neoproj.register_template {
  name = "Empty project",
  expand = function() end,
}
