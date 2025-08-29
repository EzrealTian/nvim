-- 基本设置
require("config.basic")
require("config.keybindings")

-- 加载剪贴板配置
local clipboard_ok, clipboard = pcall(require, 'config.clipboard')
if clipboard_ok then
  clipboard.setup()
else
  vim.notify("Clipboard config not found, using defaults", vim.log.levels.WARN)
  vim.opt.clipboard = "unnamedplus"
end

require("config.lazy")
