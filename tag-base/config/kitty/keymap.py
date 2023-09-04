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

    elif cmd.endswith("nvim") or window.child_title.endswith("nvim"):
        key_to_sequence = {
            # "C-a": "\x1b\x1b[97;5u",
            # "C-d": "\x1b\x1b[100;5u",
            # "C-p": "\x1b\x1b[112;5u",
            # "M-.": "\x1b\x1b[46;9u",
            # "M-/": "\x1b\x1b[47;3u",
            # "M-b": "\x1b\x1b[98;5u",
            "M-backspace": "\x1b\x1b[127;3u",
            # "M-c": "\x1b\x1b[99;3u",
            # "M-d": "\x1b\x1b[100;3u",
            "M-down": "\x1b\x1b[1;3B",
            # "M-f": "\x1b\x1b[102;3u",
            "M-left": "\x1b\x1b[1;3D",
            # "M-p": "\x1b\x1b[112;3u",
            "M-right": "\x1b\x1b[1;3C",
            "M-up": "\x1b\x1b[1;3A",
            # "M-x": "\x1b\x1b[120;3u",
            # "M-z": "\x1b\x1b[122;3u",
            # "S-s": "\x1b\x1b[115;5u",
            "F5": "\x1b[15~",
            "F6": "\x1b[17~",
            "F7": "\x1b[18~",
            "F8": "\x1b[19~",
            "F9": "\x1b[20~",
            "F10": "\x1b[21~",
            "F11": "\x1b[23~",
            "F12": "\x1b[24~",
            "F13": "\x1b[25~",
            "F14": "\x1b[26~",
            "F15": "\x1b[28~",
            "F16": "\x1b[29~",
            "F17": "\x1b[30~",
        }

        sequence = key_to_sequence.get(args[1])
        if sequence:
             window.write_to_child(sequence)
    else:
        key_to_sequence = {
            "M-left": "\x1b[1;3D",
            "M-right": "\x1b[1;3C",
            "M-up": "\x1b[1;3A",
            "M-down": "\x1b[1;3B",
        }
        sequence = key_to_sequence.get(args[1])
        if sequence:
             window.write_to_child(sequence)

