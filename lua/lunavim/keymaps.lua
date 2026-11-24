-- Global keymaps. Plugin-specific maps that should trigger lazy loading live in
-- the `keys` field of the plugin's spec in lua/lunavim/plugins/.
local function map(mode, lhs, rhs, desc, opts)
  opts = vim.tbl_extend("force", { desc = desc, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Telescope
map("n", "<C-p>", "<cmd>Telescope git_files<cr>", "Search git files")
map("n", "<leader>,", "<cmd>Telescope buffers<cr>", "Switch buffer")
map("n", "<leader>/", "<cmd>Telescope live_grep<cr>", "Grep (root dir)")
map("n", "<leader>:", "<cmd>Telescope command_history<cr>", "Command History")
map("n", "<leader><space>", "<cmd>Telescope find_files<cr>", "Find project files")
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", "Buffers")
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", "Find project files")
map("n", "<leader>fp", "<cmd>Telescope projects<cr>", "Projects")
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", "Recent")
map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", "Commits")
map("n", "<leader>gs", "<cmd>Telescope git_status<cr>", "Status")
map("n", "<leader>sC", "<cmd>Telescope commands<cr>", "Commands")
map("n", "<leader>sD", "<cmd>Telescope diagnostics<cr>", "Workspace diagnostics")
map("n", "<leader>sH", "<cmd>Telescope highlights<cr>", "Search Highlight Groups")
map("n", "<leader>sM", "<cmd>Telescope man_pages<cr>", "Man pages")
map("n", "<leader>sR", "<cmd>Telescope resume<cr>", "Resume")
map("n", "<leader>sa", "<cmd>Telescope autocommands<cr>", "Auto Commands")
map("n", "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Buffer")
map("n", "<leader>sc", "<cmd>Telescope command_history<cr>", "Command History")
map("n", "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", "Document Diagnostics")
map("n", "<leader>sh", "<cmd>Telescope help_tags<cr>", "Help pages")
map("n", "<leader>sk", "<cmd>Telescope keymaps<cr>", "Keymaps")
map("n", "<leader>sm", "<cmd>Telescope marks<cr>", "Jump to Mark")
map("n", "<leader>so", "<cmd>Telescope vim_options<cr>", "Options")
map("n", "<leader>st", "<cmd>Telescope todo-comments<cr>", "Todo (Telescope)")
map("n", "<leader>uC", "<cmd>Telescope colorscheme<cr>", "Colorscheme preview")

-- Utilities
map("n", "<leader>ut", "<cmd>UndotreeToggle<CR>", "Undotree")
map("n", "<leader>o", "<cmd>Oil --float<CR>", "Open parent directory")
map("n", "<leader>cp", "<cmd>MarkdownPreview<cr>", "Markdown Preview")
map("n", "<leader>un", function()
  require("notify").dismiss({ silent = true, pending = true })
end, "Dismiss All Notifications")

-- Terminal
map("n", "<leader>tf", "<Cmd>ToggleTerm direction=float<CR>", "Open floating terminal")
map("n", "<leader>th", "<Cmd>ToggleTerm size=10 direction=horizontal<CR>", "Open terminal in horizontal split")
map("n", "<leader>tv", "<Cmd>ToggleTerm size=80 direction=vertical<CR>", "Open terminal in vertical split")
map("n", "<F7>", "<Cmd>execute v:count . 'ToggleTerm'<CR>", "Toggle terminal")
map("t", "<F7>", "<Cmd>ToggleTerm<CR>", "Toggle terminal")
map("i", "<F7>", "<Esc><Cmd>ToggleTerm<CR>", "Toggle terminal")
map("t", "<Esc><Esc>", "<C-\\><C-n>", "Switch to normal mode")
map({ "n", "t" }, "<leader>tn", function()
  local curterm = require("toggleterm.terminal").get_focused_id()
  if curterm ~= nil then
    vim.cmd(curterm .. "ToggleTermSetName")
  end
end, "Rename current terminal")
map({ "n", "t" }, "<leader>tl", "<cmd>TermSelect<cr>", "List terminals")
map("t", "<C-H>", "<Cmd>wincmd h<CR>", "Terminal left window navigation")
map("t", "<C-J>", "<Cmd>wincmd j<CR>", "Terminal down window navigation")
map("t", "<C-K>", "<Cmd>wincmd k<CR>", "Terminal up window navigation")
map("t", "<C-L>", "<Cmd>wincmd l<CR>", "Terminal right window navigation")

-- Diagnostics / Trouble
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics (Trouble)")
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Buffer Diagnostics (Trouble)")
map("n", "<leader>xt", "<cmd>Trouble todo<cr>", "Todo (Trouble)")
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", "Quickfix List (Trouble)")
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, "Next Diagnostic")
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, "Previous Diagnostic")

-- Formatting
map("n", "<leader>uf", "<cmd>FormatToggle<CR>", "Toggle Format Globally")
map("n", "<leader>uF", "<cmd>FormatToggle!<CR>", "Toggle Format Locally")
map("n", "<leader>cf", function()
  require("conform").format()
end, "Format Buffer")
map("v", "<leader>cF", function()
  require("conform").format()
end, "Format Lines")

-- Git
map("n", "<leader>gg", "<cmd>LazyGit<CR>", "LazyGit (root dir)")
map("n", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<CR>", "Toggle inline blame")
map("n", "<leader>ghb", "<cmd>Gitsigns blame_line<CR>", "Blame line")
map("n", "<leader>ghd", "<cmd>Gitsigns diffthis<CR>", "Diff This")
map("n", "<leader>ghp", "<cmd>Gitsigns preview_hunk<CR>", "Preview hunk")
map("n", "<leader>ghR", "<cmd>Gitsigns reset_buffer<CR>", "Reset Buffer")
map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
map("n", "<leader>ghS", "<cmd>Gitsigns stage_buffer<CR>", "Stage Buffer")
map("n", "<leader>ghu", "<cmd>Gitsigns undo_stage_hunk<CR>", "Undo Stage Hunk")

-- Neo-tree
map("n", "<leader>e", "<cmd>Neotree toggle reveal_force_cwd<cr>", "Explorer NeoTree (root dir)")
map("n", "<leader>E", "<cmd>Neotree toggle<CR>", "Explorer NeoTree (cwd)")
map("n", "<leader>be", "<cmd>Neotree buffers<CR>", "Buffer explorer")
map("n", "<leader>ge", "<cmd>Neotree git_status<CR>", "Git explorer")

-- Buffers
-- mini.bufremove keeps the window open (showing another buffer) instead of
-- closing it like :bdelete does, so the window layout is preserved (e.g. with
-- neo-tree open you aren't left with only the tree).
map("n", "<leader>bc", function()
  require("mini.bufremove").delete(0, false)
end, "Close buffer")
map("n", "<leader>bb", "<cmd>e #<cr>", "Switch to Other Buffer")
map("n", "<leader>br", "<cmd>BufferLineCloseRight<cr>", "Close buffers to the right")
map("n", "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", "Close buffers to the left")
map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", "Close other buffers")
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", "Toggle pin")
map("n", "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", "Close non-pinned buffers")
-- Not on <Tab>: in a terminal <Tab> is the same key as <C-i> (jump forward).
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", "Cycle to next buffer")
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Cycle to previous buffer")

-- Tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", "Last tab")
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", "First Tab")
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", "New Tab")
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", "Next Tab")
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", "Close tab")
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", "Previous Tab")

-- Windows
map("n", "<leader>ww", "<C-W>p", "Other window")
map("n", "<leader>wd", "<C-W>c", "Delete window")
map("n", "<leader>w-", "<C-W>s", "Split window below")
map("n", "<leader>w|", "<C-W>v", "Split window right")

-- Files / sessions
map("n", "<C-s>", "<cmd>w<cr><esc>", "Save file")
map("n", "<leader>qq", "<cmd>quitall<cr><esc>", "Quit all")
map("n", "<leader>qs", function()
  require("persistence").load()
end, "Restore session")
map("n", "<leader>ql", function()
  require("persistence").load({ last = true })
end, "Restore last session")
map("n", "<leader>qd", function()
  require("persistence").stop()
end, "Don't save current session")
map("n", "<leader>a", "<cmd>Alpha<cr>", "Open Alpha dashboard")

-- UI toggles (functions defined in lunavim.autocmds)
map("n", "<leader>ul", function()
  LunaVim.toggle_line_number()
end, "Toggle Line Numbers")
map("n", "<leader>uL", function()
  LunaVim.toggle_relative_line_number()
end, "Toggle Relative Line Numbers")
map("n", "<leader>uw", function()
  LunaVim.toggle_wrap()
end, "Toggle Line Wrap")
map("n", "<leader>uh", function()
  LunaVim.toggle_inlay_hints()
end, "Toggle Inlay Hints")

-- Editing
map("v", "J", ":m '>+1<CR>gv=gv", "Move down when line is highlighted")
map("v", "K", ":m '<-2<CR>gv=gv", "Move up when line is highlighted")
map("n", "J", "mzJ`z", "Join lines and keep the cursor in place")
map("v", "<", "<gv", "Indent while remaining in visual mode.")
map("v", ">", ">gv", "Indent while remaining in visual mode.")
map("n", "<C-d>", "<C-d>zz", "Half page down and center")
map("n", "<C-u>", "<C-u>zz", "Half page up and center")
map("n", "j", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], "Down (wrap aware, adds jumps)", { expr = true })
map("n", "k", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], "Up (wrap aware, adds jumps)", { expr = true })
map("n", "n", "nzzzv", "Next match, centered")
map("n", "N", "Nzzzv", "Previous match, centered")
map("x", "<leader>p", '"_dP', "Deletes to void register and paste over")
map({ "n", "v" }, "<leader>y", '"+y', "Copy to system clipboard")
map({ "n", "v" }, "<leader>Y", '"+Y', "Copy to system clipboard")
map({ "n", "v" }, "<leader>D", '"_d', "Delete to void register")
map("i", "<C-c>", "<Esc>")
-- Only take over <C-f> (page down) where the tmux-sessionizer script exists.
if vim.fn.executable("tmux-sessionizer") == 1 then
  map("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", "Switch between projects")
end
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
