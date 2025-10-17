# byte_san

Sanitizes source code and plain text files at the byte level.
Formats and **scrubs bytes** with character filtering, whitespace normalization, and newline cleanup.

## Description

`byte_san` is a lightweight **shell script** that processes source code and raw text files byte by byte.
It finds and fixes low-level formatting quirks that regular formatters might miss.

Great for:

* **Cleaning up** messy copy-pasted or machine-generated code
* Keeping formatting consistent across different systems and editors
* Avoiding **whitespace issues** in version control diffs

## Features

* Keeps all **printable ASCII** characters plus a few basic UTF-8 diacritics
* Removes control characters and other non-printable stuff, keeping only **space and newline**
* Interprets tabs using **tabstop logic** and normalizes them into spaces
* Handles exotic line ending sequences and normalizes them into standard newlines
* Trims trailing whitespace and collapses extra blank lines
* **Thresholds** are easy to tweak right in the script file

## Usage

### 1. POSIX Shell Script

Run `byte_san.sh` using the **shell**:

```
sh /path/to/byte_san.sh /path/to/file.txt
```

Or make it **executable** to run directly:

```
chmod +x /path/to/byte_san.sh
/path/to/byte_san.sh /path/to/file.txt
```

Note: For convenience, `byte_san` overwrites files **in place**.
It's a good idea to keep the file open in an editor with **undo** support (good old `Ctrl+Z`).
Most editors will reload the file when it's modified externally and let you revert changes if needed.

### 2. VS Code Integration

You can use `byte_san` as a **task** in VS Code:

* The script is embedded into the custom `tasks.json`, so no external script file is needed
* It can be executed from the Run Task menu or triggered using the custom `keybindings.json`
* The keybinding enables a **two-step save**: first `Ctrl+S` saves, second `Ctrl+S` sanitizes with `byte_san`

## Requirements

* A computer
* A POSIX-compliant shell (`sh`, `ash`, `bash`, `dash`, etc.)
