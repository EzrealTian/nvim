local M = {}

function M.setup()
  -- 检查是否是WSL环境
  local is_wsl = false
  local uname = vim.fn.system('uname -r')
  if uname:find('microsoft') then
    is_wsl = true
  end

  -- 设置默认剪贴板
  vim.opt.clipboard = "unnamedplus"

  if is_wsl then
    M.setup_wsl_clipboard()
  else
    M.setup_linux_clipboard()
  end

  -- 设置快捷键映射
  M.set_keymaps()
end

function M.setup_wsl_clipboard()
  -- 优先使用wl-clipboard (Wayland)
  if vim.fn.executable('wl-copy') == 1 then
    vim.g.clipboard = {
      name = 'wl-clipboard-wsl',
      copy = {
        ['+'] = 'wl-copy --foreground --type text/plain',
        ['*'] = 'wl-copy --foreground --type text/plain',
      },
      paste = {
        ['+'] = {'wl-paste'},
        ['*'] = {'wl-paste'},
      },
      cache_enabled = 1,
    }
    vim.notify("Using wl-clipboard for WSL")
  -- 其次使用xclip (X11)
  elseif vim.fn.executable('xclip') == 1 then
    vim.g.clipboard = {
      name = 'xclip-wsl',
      copy = {
        ['+'] = 'xclip -selection clipboard -in',
        ['*'] = 'xclip -selection primary -in',
      },
      paste = {
        ['+'] = 'xclip -selection clipboard -out',
        ['*'] = 'xclip -selection primary -out',
      },
      cache_enabled = 1,
    }
    vim.notify("Using xclip for WSL")
  
  -- 最后使用Windows的clip.exe作为备选
  elseif vim.fn.executable('clip.exe') == 1 then
    vim.g.clipboard = {
      name = 'win-clipboard',
      copy = {
        ['+'] = 'clip.exe',
        ['*'] = 'clip.exe',
      },
      paste = {
        ['+'] = 'powershell.exe -Command Get-Clipboard',
        ['*'] = 'powershell.exe -Command Get-Clipboard',
      },
      cache_enabled = 0,
    }
    vim.notify("Using Windows clip.exe for WSL")
  
  else
    vim.notify("No clipboard tool found for WSL!", vim.log.levels.WARN)
  end
end

function M.setup_linux_clipboard()
  -- 标准Linux系统的剪贴板设置
  if vim.fn.executable('wl-copy') == 1 then
    vim.g.clipboard = {
      name = 'wl-clipboard-linux',
      copy = {
        ['+'] = 'wl-copy',
        ['*'] = 'wl-copy --primary',
      },
      paste = {
        ['+'] = 'wl-paste --no-newline',
        ['*'] = 'wl-paste --no-newline --primary',
      },
      cache_enabled = 1,
    }
  elseif vim.fn.executable('xclip') == 1 then
    vim.g.clipboard = {
      name = 'xclip-linux',
      copy = {
        ['+'] = 'xclip -selection clipboard',
        ['*'] = 'xclip -selection primary',
      },
      paste = {
        ['+'] = 'xclip -selection clipboard -o',
        ['*'] = 'xclip -selection primary -o',
      },
      cache_enabled = 1,
    }
  end
end


function M.set_keymaps()
  -- 设置剪贴板快捷键
  local keymap = vim.keymap.set

  -- 定义复制文件路径的函数
  local function copy_file_path()
    local path = vim.fn.expand('%:p')  -- 完整路径
    vim.fn.setreg('+', path)
    vim.notify("Copied: " .. path, vim.log.levels.INFO, { title = "Copy Path" })
  end

  -- 复制文件名（不含路径）
  local function copy_file_name()
    local name = vim.fn.expand('%:t')  -- 文件名（tail）
    vim.fn.setreg('+', name)
    vim.notify("Copied: " .. name, vim.log.levels.INFO, { title = "Copy Name" })
  end

  -- 复制文件所在目录
  local function copy_file_dir()
    local dir = vim.fn.expand('%:p:h')  -- 目录（head of path）
    vim.fn.setreg('+', dir)
    vim.notify("Copied: " .. dir, vim.log.levels.INFO, { title = "Copy Dir" })
  end

  -- 复制到系统剪贴板
  keymap('v', '<Leader>y', '"+y', { desc = "Copy to system clipboard" })
  keymap('n', '<Leader>Y', '"+Y', { desc = "Copy line to system clipboard" })
  
  -- 从系统剪贴板粘贴
  keymap('n', '<Leader>p', '"+p', { desc = "Paste from system clipboard" })
  keymap('n', '<Leader>P', '"+P', { desc = "Paste before from system clipboard" })
  keymap('v', '<Leader>p', '"+p', { desc = "Paste from system clipboard" })
  
  -- 使用Ctrl键映射（如果终端支持）
  keymap('v', '<C-c>', '"+y', { desc = "Copy to clipboard (Ctrl+C)" })
  keymap('n', '<C-v>', '"+p', { desc = "Paste from clipboard (Ctrl+V)" })
  keymap('i', '<C-v>', '<C-r>+', { desc = "Paste from clipboard in insert mode" })
  
  -- 剪贴板操作命令
  keymap('n', '<Leader>cp', copy_file_path,  { desc = "Copy full file path" })
  keymap('n', '<Leader>cf', copy_file_name,  { desc = "Copy file name" })
  keymap('n', '<Leader>cd', copy_file_dir,   { desc = "Copy file directory" })
end

return M