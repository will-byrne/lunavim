local enabled = require("nixCatsUtils").enableForCategory("debug")

-- Python with debugpy: from Nix if available, otherwise Mason's debugpy venv.
local function debugpy_python()
  local from_nix = nixCats.extra("debugpyPython")
  if from_nix then
    return from_nix
  end
  local venv = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv"
  if vim.fn.has("win32") == 1 then
    return venv .. "/Scripts/python.exe"
  end
  return venv .. "/bin/python"
end

return {
  {
    "mfussenegger/nvim-dap",
    enabled = enabled,
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      { url = "https://codeberg.org/mfussenegger/nvim-dap-python", name = "nvim-dap-python" },
    },
    cmd = {
      "DapToggleBreakpoint",
      "DapContinue",
      "DapStepInto",
      "DapStepOut",
      "DapStepOver",
      "DapToggleRepl",
      "DapTerminate",
    },
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle Breakpoint" },
      { "<leader>dc", "<cmd>DapContinue<cr>", desc = "Continue" },
      { "<leader>di", "<cmd>DapStepInto<cr>", desc = "Step into" },
      { "<leader>do", "<cmd>DapStepOut<cr>", desc = "Step Out" },
      { "<leader>dO", "<cmd>DapStepOver<cr>", desc = "Step Over" },
      { "<leader>dr", "<cmd>DapToggleRepl<cr>", desc = "Toggle REPL" },
      { "<leader>dt", "<cmd>DapTerminate<cr>", desc = "Terminate" },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Breakpoint Condition",
      },
      {
        "<leader>da",
        function()
          require("dap").continue({
            before = function(config)
              local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
              local args_str = type(args) == "table" and table.concat(args, " ") or args
              config = vim.deepcopy(config)
              config.args = function()
                local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str))
                if config.type == "java" then
                  return new_args
                end
                return require("dap.utils").splitstr(new_args)
              end
              return config
            end,
          })
        end,
        desc = "Run with Args",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Run to cursor",
      },
      {
        "<leader>dg",
        function()
          require("dap").goto_()
        end,
        desc = "Go to line (no execute)",
      },
      {
        "<leader>dj",
        function()
          require("dap").down()
        end,
        desc = "Down",
      },
      {
        "<leader>dk",
        function()
          require("dap").up()
        end,
        desc = "Up",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Run Last",
      },
      {
        "<leader>dp",
        function()
          require("dap").pause()
        end,
        desc = "Pause",
      },
      {
        "<leader>ds",
        function()
          require("dap").session()
        end,
        desc = "Session",
      },
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Widgets",
      },
    },
    config = function()
      local dap = require("dap")
      dap.configurations.java = {
        {
          type = "java",
          request = "launch",
          name = "Debug (Attach) - Remote",
          hostName = "127.0.0.1",
          port = 5005,
        },
      }
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition" })
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint" })

      require("dap-python").setup(debugpy_python())
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    enabled = enabled,
    lazy = true,
    dependencies = { "nvim-dap", "nvim-nio" },
    opts = { floating = { mappings = { close = { "<ESC>", "q" } } } },
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Dap UI",
      },
      {
        "<leader>de",
        function()
          require("dapui").eval()
        end,
        desc = "Eval",
        mode = { "n", "v" },
      },
    },
  },
  { "theHamsta/nvim-dap-virtual-text", enabled = enabled, lazy = true, opts = {} },
}
