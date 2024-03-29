local wezterm = require 'wezterm';

return {
    --color_scheme = 'Gruvbox dark, hard (base16)',
    color_scheme = 'Dracula Pro (Morbius)',
    --font = wezterm.font('SauceCodePro Nerd Font Mono', {weight='Medium'}),
    font = wezterm.font('GoMono Nerd Font', {weight='Medium'}),
    font_size = 12.0,
    hide_tab_bar_if_only_one_tab = true,
    scrollback_lines = 1000,
    enable_scroll_bar = false,
    window_background_opacity = 0.97,
}
