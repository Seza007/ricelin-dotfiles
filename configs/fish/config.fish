zoxide init fish | source

abbr -a ff fastfetch

function fish_greeting
    ~/.config/fish/torii-greeting.sh
end

# Added by Antigravity CLI installer
fish_add_path -g $HOME/.local/bin

# Start ssh-agent if one isn't running
if not pgrep -u "$USER" ssh-agent >/dev/null
    eval (ssh-agent -c) >/dev/null
end

# Load the environment from the running agent
set -l agent_socket (find "$HOME/.ssh/agent" -type s 2>/dev/null | head -n1)

if test -n "$agent_socket"
    set -gx SSH_AUTH_SOCK "$agent_socket"
end

function obs
    ssh-add -l >/dev/null 2>&1; or ssh-add ~/.ssh/id_ed25519; or return

    cd "$HOME/development/IITM/IIT-M"; or return

    # Launch through Hyprland so Obsidian outlives this terminal (ghostty kills
    # everything in a surface's cgroup scope on close, setsid included), and hand
    # it the agent socket so the vault's git sync can use the unlocked key.
    if set -q HYPRLAND_INSTANCE_SIGNATURE
        hyprctl eval "hl.dispatch(hl.dsp.exec_cmd(\"cd '$PWD' && SSH_AUTH_SOCK='$SSH_AUTH_SOCK' obsidian .\"))" >/dev/null
    else
        setsid -f obsidian . >/dev/null 2>&1
    end
end

# ls: names in plain text grey, the "/" (and other type marks like * and @) in the
# theme accent. GNU ls prints the mark after the "rs" reset sequence, so rs carries
# the accent (256-colour slot 17, written by wallcolors.py) and every type gets an
# explicit colour so the accent cannot leak into the next name. The default red/green/
# yellow codes (31-33) are dark slots in this palette, so they become the plain grey too.
if status is-interactive; and command -sq dircolors
    set -gx LS_COLORS (dircolors -b | string replace -rf ".*LS_COLORS='([^']*)'.*" '$1' | string replace -ra ';3[123](?=[;:])' ';37'):"rs=0;38;5;17:di=0;37:fi=0;37:ln=0;37:ex=0;37"
end
# Prompt path: grey one step darker than normal text (ANSI 5 in the generated palette).
set -g fish_color_cwd magenta
