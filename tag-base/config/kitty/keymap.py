from kittens.tui.handler import result_handler
from kitty.keys import keyboard_mode_name


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.active_window
    if window is None:
        return

    cmd = window.child.foreground_cmdline[0]
    if args[1] == "C-i":
        # Move cursor to the end of line, specific to zsh
        if cmd.endswith("zsh"):
            window.write_to_child("\x1b[105;5u")

        # A workaround for tmux to fix its bug of Ctrl+i recognition, sending a Ctrl-; instead
        elif cmd.endswith("tmux"):
            window.write_to_child("\x1b[59;5u")
            return

        # Other programs that support CSI u
        elif keyboard_mode_name(window.screen) == "kitty":
            window.write_to_child("\x1b[105;5u")

        # Otherwise send a ^I
        else:
            window.write_to_child("\x09")

    elif cmd.endswith("nvim"):
        if args[1] == "S-s":
            window.write_to_child("\x1b\x1b[115;5u")
        elif args[1] == "M-f":
            window.write_to_child('\x1b\x1b[102;9u')
        elif args[1] == "C-p":
            window.write_to_child('\x1b\x1b[112;5u')
        elif args[1] == "C-d":
            window.write_to_child('\x1b\x1b[100;5u')
        elif args[1] == "M-x":
            window.write_to_child('\x1b\x1b[120;3u')
        elif args[1] == "M-c":
            window.write_to_child('\x1b\x1b[99;3u')
        elif args[1] == "M-z":
            window.write_to_child('\x1b\x1b[122;3u')
        elif args[1] == "M-p":
            window.write_to_child('\x1b\x1b[112;3u')
        elif args[1] == "M-backspace":
            window.write_to_child('\x1b\x1b[127;3u')
        elif args[1] == "M-.":
            window.write_to_child('\x1b\x1b[46;9u')

