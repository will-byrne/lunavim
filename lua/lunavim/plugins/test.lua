return {
  {
    "nvim-neotest/neotest",
    enabled = require("nixCatsUtils").enableForCategory("test"),
    cmd = "Neotest",
    dependencies = {
      "nvim-nio",
      "plenary.nvim",
      "nvim-treesitter",
      "rcasia/neotest-java",
      "nvim-neotest/neotest-plenary",
      "nvim-neotest/neotest-python",
      "marilari88/neotest-vitest",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-java"),
          require("neotest-plenary"),
          require("neotest-python"),
          require("neotest-vitest"),
        },
        output = { enabled = true, open_on_run = true },
        summary = { enabled = true },
      })
    end,
    keys = {
      {
        "<leader>Tt",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run File",
      },
      {
        "<leader>TT",
        function()
          require("neotest").run.run(vim.uv.cwd())
        end,
        desc = "Run All Test Files",
      },
      {
        "<leader>Tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Nearest",
      },
      {
        "<leader>Td",
        function()
          require("lazy").load({ plugins = { "nvim-dap" } })
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Run Nearest with debugger",
      },
      {
        "<leader>Ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle Summary",
      },
      {
        "<leader>To",
        function()
          require("neotest").output.open({ enter = true, auto_close = true })
        end,
        desc = "Show Output",
      },
      {
        "<leader>TO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Toggle Output Panel",
      },
      {
        "<leader>TS",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop",
      },
    },
  },
}
