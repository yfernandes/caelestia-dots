#!/usr/bin/env fish

if test "$argv[1]" = '-g'
    set group
    set -e $argv[1]
end

if test (count $argv) -ne 2
    echo 'Wrong number of arguments. Usage: ./wsaction.fish [-g] <dispatcher> <workspace>'
    exit 1
end

set -l active_ws (hyprctl activeworkspace -j | jq -r '.id')
set -l ws_num

if set -q group
    # Move to group
    set ws_num (math "($argv[2] - 1) * 10 + $active_ws % 10")
else
    # Move to ws in group
    set ws_num (math "floor(($active_ws - 1) / 10) * 10 + $argv[2]")
end

if hyprctl systeminfo | grep -qi "configProvider:.*lua"
    switch $argv[1]
        case workspace
            hyprctl dispatch "hl.dsp.focus({ workspace = $ws_num })"
        case movetoworkspace
            hyprctl dispatch "hl.dsp.window.move({ workspace = $ws_num })"
        case movetoworkspacesilent
            hyprctl dispatch "hl.dsp.window.move({ workspace = $ws_num, follow = false })"
        case '*'
            hyprctl dispatch $argv[1] $ws_num
    end
else
    hyprctl dispatch $argv[1] $ws_num
end
