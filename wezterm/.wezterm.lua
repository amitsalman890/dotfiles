-- ~/.wezterm.lua
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()
local HOME = os.getenv 'HOME'

-- color scheme
local color = 'Rosé Pine Moon (Gogh)'
config.color_scheme = color

-- performance
config.max_fps = 240
config.animation_fps = 240
config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'
config.scrollback_lines = 10000

-- font
config.harfbuzz_features = {
  'calt=1',
  'clig=1',
  'liga=1',
  'zero=1',
  'ss02=1',
  'ss19=1',
}
config.font = wezterm.font_with_fallback {
  { family = 'CaskaydiaCove Nerd Font', weight = 'DemiBold' },
}
config.font_size = 16
config.freetype_load_target = 'Normal'
config.custom_block_glyphs = false
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500
config.cursor_thickness = 2
config.line_height = 0.9

-- tab bar
config.use_fancy_tab_bar = true
config.show_close_tab_button_in_tabs = true
config.tab_max_width = 999
config.window_frame = {
  font = wezterm.font { family = 'Roboto', weight = 'Bold' },
  font_size = 13.0,
}
config.colors = {
  background = '#000000',
  scrollbar_thumb = 'white',
  tab_bar = {
    active_tab = { bg_color = '#5B5B5A', fg_color = '#FFFFFF' },
    inactive_tab = { bg_color = '#1B1B1B', fg_color = '#808080' },
  },
}

-- window
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.inactive_pane_hsb = { saturation = 0.4, brightness = 0.7 }
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.enable_scroll_bar = true
config.min_scroll_bar_height = '2cell'
config.native_macos_fullscreen_mode = true

-- background
config.background = {
  {
    source = { File = HOME .. '/Pictures/wp4.jpg' },
    repeat_y = 'NoRepeat',
    hsb = { brightness = 0.15, hue = 1.0, saturation = 1.0 },
    height = 'Cover',
    width = 'Contain',
    opacity = 1.0,
  },
}
config.macos_window_background_blur = 50

-- mouse
config.mouse_bindings = {
  {
    event = { Down = { streak = 3, button = 'Left' } },
    action = act.SelectTextAtMouseCursor 'SemanticZone',
    mods = 'NONE',
  },
}

-- keys: each binding is its own table; the array is properly closed
config.keys = {
  -- Unmap Option+Enter
  { key = 'Enter', mods = 'OPT', action = act.DisableDefaultAssignment },

  -- Shift+Enter: send ESC + CR (your intent)
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\x1b\r' },

  -- split pane
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'SHIFT|CMD', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- command palette
  { key = 'P', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },

  -- activate copy mode
  { key = 'C', mods = 'CMD|SHIFT', action = act.ActivateCopyMode },

  -- enter full screen with cmd+enter
  { key = 'Enter', mods = 'CMD', action = act.ToggleFullScreen },

  -- kill pane
  { key = 'w', mods = 'CMD', action = act.CloseCurrentPane { confirm = true } },

  -- increase font size by cmd-+
  { key = '+', mods = 'CMD', action = act.IncreaseFontSize },
} -- ← this closes the keys array

-- arrow keys keybindings (append more entries to config.keys)
for _, direction in ipairs { 'Left', 'Right', 'Up', 'Down' } do
  if direction == 'Left' or direction == 'Right' then
    -- ESC+b / ESC+f for word back/forward
    local letter = (direction == 'Left') and 'b' or 'f'
    table.insert(config.keys, {
      key = direction .. 'Arrow',
      mods = 'OPT',
      action = act.SendKey { key = letter, mods = 'OPT' },
    })

    -- Move to the left/right tab
    local relative = (direction == 'Left') and -1 or 1
    table.insert(config.keys, { key = direction .. 'Arrow', mods = 'CMD', action = act.ActivateTabRelative(relative) })

    -- rotate panes
    local rotate = (direction == 'Left') and 'CounterClockwise' or 'Clockwise'
    table.insert(config.keys, { key = direction .. 'Arrow', mods = 'CTRL|SHIFT', action = act.RotatePanes(rotate) })

    -- move tab left/right with cmd+shift+arrow
    table.insert(config.keys, { key = direction .. 'Arrow', mods = 'CMD|SHIFT', action = act.MoveTabRelative(relative) })
  else
    -- scroll up/down using option+arrow
    table.insert(config.keys, { key = direction .. 'Arrow', mods = 'OPT', action = act.ScrollByPage(direction == 'Up' and -0.2 or 0.2) })

    -- scroll to last/next prompt with cmd+arrow
    table.insert(config.keys, { key = direction .. 'Arrow', mods = 'CMD', action = act.ScrollToPrompt(direction == 'Up' and -1 or 1) })
  end
end

-- number keys: switch to tabs 1–9
for i = 1, 9 do
  table.insert(config.keys, { key = tostring(i), mods = 'CMD', action = act.ActivateTab(i - 1) })
end

-- plugin
local smart_splits = wezterm.plugin.require 'https://github.com/mrjones2014/smart-splits.nvim'
smart_splits.apply_to_config(config, {
  direction_keys = { 'h', 'j', 'k', 'l' },
  modifiers = { move = 'CTRL', resize = 'META' },
  log_level = 'info',
})

return config
