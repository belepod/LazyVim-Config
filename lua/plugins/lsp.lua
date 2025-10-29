-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },

    -- Keymaps registered by Lazy
    keys = {
      { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Goto Definition" },
      { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
      { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
      { "gI", "<cmd>Telescope lsp_implementations<cr>", desc = "Goto Implementation" },
      { "K", vim.lsp.buf.hover, desc = "Hover" },
    },

    opts = {
      -- Optional per-server overrides
      setup = {
        lua_ls = function()
          local capabilities = require("cmp_nvim_lsp").default_capabilities()
          require("lspconfig").lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = { version = "LuaJIT" },
                diagnostics = { globals = { "vim" } },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                  checkThirdParty = false,
                },
              },
            },
          })
        end,
      },
    },

    config = function(_, opts)
      -- Autoformat on save for clients that support it
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format()
              end,
            })
          end
        end,
      })

      -- Mason setup
      require("mason").setup()
      local mlsp = require("mason-lspconfig")
      mlsp.setup({
        -- ensure_installed = { "lua_ls" }, -- optionally list servers you want auto-installed
        automatic_installation = false,
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Prefer setup_handlers when available; otherwise fall back gracefully
      if type(mlsp.setup_handlers) == "function" then
        mlsp.setup_handlers({
          function(server_name)
            if server_name ~= "lua_ls" then
              require("lspconfig")[server_name].setup({ capabilities = capabilities })
            end
          end,
          ["lua_ls"] = function()
            if opts and opts.setup and type(opts.setup.lua_ls) == "function" then
              opts.setup.lua_ls()
            else
              require("lspconfig").lua_ls.setup({
                capabilities = capabilities,
                settings = {
                  Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = { globals = { "vim" } },
                    workspace = {
                      library = vim.api.nvim_get_runtime_file("", true),
                      checkThirdParty = false,
                    },
                  },
                },
              })
            end
          end,
        })
      else
        -- Fallback path if setup_handlers is missing (e.g., stale/wrong plugin)
        local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
        if ok_lspconfig then
          -- Setup for all installed servers
          local installed = {}
          if type(mlsp.get_installed_servers) == "function" then
            installed = mlsp.get_installed_servers()
          end

          -- If Mason can't list servers, just try a minimal set
          if not installed or #installed == 0 then
            installed = { "lua_ls" }
          end

          for _, server in ipairs(installed) do
            if server == "lua_ls" and opts and opts.setup and type(opts.setup.lua_ls) == "function" then
              opts.setup.lua_ls()
            else
              if lspconfig[server] then
                lspconfig[server].setup({ capabilities = capabilities })
              end
            end
          end
        end
      end
    end,
  },
}
