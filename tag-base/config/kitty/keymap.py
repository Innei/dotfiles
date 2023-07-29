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
        key_to_sequence = {
            "S-s": "\x1b\x1b[115;5u",
            "M-f": "\x1b\x1b[102;9u",
            "C-p": "\x1b\x1b[112;5u",
            "C-d": "\x1b\x1b[100;5u",
            "M-d": "\x1b\x1b[100;3u",
            "M-x": "\x1b\x1b[120;3u",
            "M-c": "\x1b\x1b[99;3u",
            "M-z": "\x1b\x1b[122;3u",
            "M-p": "\x1b\x1b[112;3u",
            "M-backspace": "\x1b\x1b[127;3u",
            "M-.": "\x1b\x1b[46;9u",
            "M-b": "\x1b\x1b[98;5u",
            "C-a": "\x1b\x1b[97;5u",
            "M-right": "\x1b\x1b[1;3C",
            "M-left": "\x1b\x1b[1;3D",
            "M-up": "\x1b\x1b[1;3A",
            "M-down": "\x1b\x1b[1;3B",
        }

        sequence = key_to_sequence.get(args[1])
        if sequence:
             window.write_to_child(sequence)

