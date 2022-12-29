; This Source Code Form is subject to the terms of the Mozilla Public
; License, v. 2.0. If a copy of the MPL was not distributed with this
; file, You can obtain one at https://mozilla.org/MPL/2.0/.

(var *config* {:project_path (.. vim.env.HOME :/projects)})

(var *templates* [])

(fn cd-project [project]
  (let [path (.. *config*.project_path "/" project)
        session (.. path :/.nvim/session.vim)]
    ;; Raise error if path isn't directory
    (let [dir? #(= 1 (vim.fn.isdirectory $1))]
      (assert (dir? path) (.. project " is not a directory")))
    ;; Try to load session
    (if (vim.loop.fs_access session :R)
        (vim.cmd.source session)
        ;; Just open explorer in root of project when no session file found
        (vim.cmd.edit path))
    (vim.cmd.cd path)
    (set vim.g.project_root path)))

(fn open-project [project]
  (if (or (= "" project) (= nil project))
      ;; No project specified
      (let [projects (icollect [p (vim.fs.dir *config*.project_path)]
                       p)]
        (vim.ui.select projects {:prompt "Select project:" :kind :project}
                       (fn [project]
                         (if (= nil project) nil (cd-project project)))))
      ;; Project specified
      (cd-project project)))

(fn expand-template [{: expand}]
  (vim.ui.input {:prompt "Enter project name:" :default :unnamed}
                #(if (= nil $1) nil
                     (let [path (.. *config*.project_path "/" $1)]
                       (assert (= 1 (vim.fn.mkdir path))
                               "Failed to create directory")
                       (vim.cmd.cd path)
                       (set vim.g.project_root path)
                       (match (type expand)
                         :string (os.execute expand)
                         :function (expand $1 path))
                       (vim.cmd.edit path)))))

(fn new-project []
  (vim.ui.select *templates*
                 {:prompt "Select template"
                  :kind :project-template
                  :format_item #$1.name}
                 #(if (= nil $1) nil (expand-template $1))))

(fn save-session []
  (assert (and (= :string (type vim.g.project_root))
               (not= "" vim.g.project_root)) "Not in project")
  (let [nvim-dir (.. vim.g.project_root :/.nvim)]
    (when (= 0 (vim.fn.isdirectory nvim-dir))
      (assert (= 1 (vim.fn.mkdir nvim-dir)) "Failed to save session"))
    (vim.cmd (.. "mksession! " nvim-dir :/session.vim))))

(fn setup [config]
  (assert (= :table (type config)) "config: expected table")
  (set *config* (vim.tbl_deep_extend :force *config* config)))

(fn register-template [template]
  (assert (= :string (type template.name)) "name: expected string")
  (let [t (type template.expand)]
    (assert (or (= :string t) (= :function t))
            "expand: expected string|function"))
  (table.insert *templates* template))

{:open_project open-project
 :new_project new-project
 : setup
 :register_template register-template
 :save_session save-session}
