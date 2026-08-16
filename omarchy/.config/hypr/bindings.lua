-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.
--
-- See current bindings and descriptions:
--   omarchy menu keybindings --print
--
-- Personal web apps.
o.bind("SUPER + SHIFT + J", "Jellyfin", { webapp = "https://jellyfin.teck.lol", focus = true })
o.bind("SUPER + SHIFT + R", "Rancher", { webapp = "https://rancher.teck.lol", focus = true })

-- Steam in gamescope on workspace 5.
hl.unbind("SUPER + SHIFT + S")
o.bind(
  "SUPER + SHIFT + S",
  "Steam (gamescope)",
  "[workspace 5] gamescope -W 2560 -H 1440 -r 165 --steam --force-grab-cursor -f -- steam -gamepadui"
)

-- 1Password quick access.
hl.unbind("SUPER + SHIFT + SPACE")
o.bind(
  "SUPER + SHIFT + SPACE",
  "Passwords quick access",
  "1password --quick-access --enable-features=UseOzonePlatform --ozone-platform=x11"
)

-- clipthat -- save clip from gpu-screen-recorder replay buffer.
o.bind("SUPER + F10", "Save clip", "clipthat save")
