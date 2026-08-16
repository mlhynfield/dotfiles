-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

hl.config({
  input = {
    -- Compose key on Caps Lock.
    kb_options = "compose:caps",

    -- Change speed of keyboard repeat.
    repeat_rate = 40,
    repeat_delay = 300,

    -- Start with numlock on by default.
    numlock_by_default = true,

    touchpad = {
      -- Control the speed of your scrolling.
      scroll_factor = 0.4,
    },
  },
})

-- Scroll nicely in the terminal.
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
