# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from libqtile.config import Key, Screen, Group, Drag, Click
from libqtile.command import lazy
from libqtile import layout, bar, hook, widget

import logging
import os
import subprocess

@hook.subscribe.startup_once
def dbus_register():
    x = os.environ['DESKTOP_AUTOSTART_ID']
    subprocess.Popen(['dbus-send',
                      '--session',
                      '--print-reply',
                      '--dest=org.gnome.SessionManager',
                      '/org/gnome/SessionManager',
                      'org.gnome.SessionManager.RegisterClient',
                      'string:qtile',
                      'string:' + x])

@hook.subscribe.startup_once
def setup_keyboard():
    subprocess.Popen(['setxkbmap', '-layout', 'us', '-option', 'ctrl:nocaps'])

mod = "mod4"

keys = [
    # Switch between windows in current stack pane
    Key([mod], "k", lazy.layout.down()),
    Key([mod], "j", lazy.layout.up()),

    # Move windows to next or prev stack
    Key([mod, "control", "shift"], "k", lazy.layout.client_to_prev()),
    Key([mod, "control", "shift"], "j", lazy.layout.client_to_next()),

    # Move windows up or down in current stack
    Key([mod, "control"], "k", lazy.layout.shuffle_down()),
    Key([mod, "control"], "j", lazy.layout.shuffle_up()),

    # Switch window focus to other pane(s) of stack
    Key([mod], "space", lazy.layout.next()),

    # Swap panes of split stack
    Key([mod, "shift"], "space", lazy.layout.rotate()),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split()),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout()),

    Key([mod], "Return", lazy.spawn("gnome-terminal")),
    Key([mod], "w", lazy.window.kill()),
    Key([mod], "r", lazy.spawncmd()),
    Key([mod], "x", lazy.qtilecmd()),

    Key([mod, "control"], "r", lazy.restart()),
    Key([mod, "control"], "l", lazy.spawn('gnome-screensaver-command -l')),
    Key([mod, "control", "shift"], "q", lazy.spawn('gnome-session-quit --logout --no-prompt')),
]

def find_global_stack(screens, n):
    """Returns the tuple of <screen idx, layout, local stack idx>"""
    offset = 0
    for i, screen in enumerate(screens):
        group = screen.group
        lay = group.layout
        if isinstance(lay, layout.Stack):
            if n - 1 < offset + len(lay.stacks):
                return i, lay, n - offset - 1
            offset += len(lay.stacks)
        elif isinstance(lay, layout.Max):
            if n - 1 == offset:
                return i, lay, 0
            offset += 1
        else:
            # Handle other layouts?
            offset += 1

    return -1, None, -1

def switch_to_global_stack(n):
    def callback(qtile):
        screen_idx, lay, stack_idx = find_global_stack(qtile.screens, n)
        if screen_idx == -1:
            return

        qtile.toScreen(screen_idx)
        if isinstance(lay, layout.Stack):
            lay.group.focus(lay.stacks[stack_idx].cw)
        elif isinstance(lay, layout.Max):
            lay.group.focus(lay.current)

    return callback

def send_to_global_stack(n):
    def callback(qtile):
        screen_idx, target_layout, stack_idx = find_global_stack(qtile.screens, n)
        if screen_idx == -1:
            return

        cur_win = qtile.currentWindow
        cur_layout = qtile.currentLayout
        cur_group = qtile.currentGroup

        cur_layout.remove(cur_win)
        cur_group.remove(cur_win)
        target_layout.group.add(cur_win)
        if isinstance(target_layout, layout.Stack):
            target_layout.cmd_client_to_stack(stack_idx)

    return callback

for i in range(1, 9):
    keys.append(Key([mod], str(i), lazy.function(switch_to_global_stack(i))))
    keys.append(Key([mod, "control"], str(i), lazy.function(send_to_global_stack(i))))

groups = [Group(i) for i in "asdf"]

for i in groups:
    # mod1 + letter of group = switch to group
    keys.append(
        Key([mod], i.name, lazy.group[i.name].toscreen())
    )

    # mod1 + control + letter of group = switch to & move focused window to group
    keys.append(
        Key([mod, "control"], i.name, lazy.window.togroup(i.name))
    )

layouts = [
    layout.Max(),
    layout.Stack(num_stacks=2)
]

widget_defaults = dict(
    font='Ubuntu Medium',
    fontsize=14,
    padding=3,
)

def makebar():
    return bar.Bar(
            [
                widget.GroupBox(),
                widget.Prompt(),
                widget.TaskList(),
                widget.Systray(),
                widget.CPUGraph(),
                widget.BatteryIcon(),
#                widget.Volume(),
                widget.Clock(format='%Y-%m-%d %a %H:%M'),
            ],
            30,
        )

screens = [
    Screen(top=makebar()),
    Screen(top=makebar())
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
        start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
        start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating()
auto_fullscreen = True

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, github issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"

@hook.subscribe.client_new
def new_client(client):
    # Banish the Gnome "desktop" window
    if client.window.get_wm_type() == 'desktop':
        client.static(0)

def setup_screens():
    subprocess.Popen(['xrandr', '--output', 'VIRTUAL1', '--off', '--output',
                      'eDP1', '--primary', '--auto', '--pos', '0x0', '--rotate',
                      'normal', '--output', 'DP1', '--off', '--output', 'HDMI2',
                      '--off', '--output', 'HDMI1', '--off', '--output', 'DP2',
                      '--auto', '--pos', '1920x0'])

@hook.subscribe.screen_change
def restart_on_screen_change(qtile, ev):
    setup_screens()
    qtile.cmd_restart()

def main(qtile):
    pass
