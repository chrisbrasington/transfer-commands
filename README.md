# Transfer Commands

This is a lightweight abstraction over `rsync` and SSH to reduce repetitive file transfer syntax and provide simple, memorable commands (`push`, `pull`) for working with a remote transfer directory.

Instead of remembering full `rsync`/`scp` commands and paths, this setup provides consistent, minimal commands with sensible defaults.

---

## Configure

Connection settings live in a `.env` file. Copy the example and edit it:

```bash
cp .env.example .env
```

| Variable        | Meaning                          | Default        |
| --------------- | -------------------------------- | -------------- |
| `SSH_HOST`      | Remote host or IP                | —              |
| `SSH_USER`      | SSH user                         | —              |
| `SSH_PORT`      | SSH port                         | `22`           |
| `TRANSFER_DIR`  | Default remote directory         | `./transfer`   |
| `AUDIOBOOK_DIR` | Remote dir for `--audiobook`     | `./audiobook`  |

Coming from the old SSH-style `config` file? Run the one-time migration — it
converts `config` into `.env` and deletes it:

```bash
./migrate.sh
```

---

## Install

```bash
./deploy.sh
````

Installs:

* `pull` → download from server
* `push` → upload to server
* config → `~/.config/transfer-commands/.env`

At runtime the commands read `.env` from `$TRANSFER_COMMANDS_CONFIG` (default
`~/.config/transfer-commands`), falling back to a `.env` next to the script.

---

## Usage

### Upload files

```bash
push file.txt
push file*
push file1 file2
```

### Download files

```bash
pull file.txt
pull file*
```

### List remote files

```bash
pull
```

### Audiobook folder

Pass `--audiobook` to target `storage:/home/chris/audiobook` instead of the default transfer folder:

```bash
push --audiobook book.m4b
pull --audiobook book*
pull --audiobook
```

---

## Notes

* Uses `rsync` over SSH (`ssh -p $SSH_PORT $SSH_USER@$SSH_HOST`)
* Default remote target: `$TRANSFER_DIR` (default `./transfer`)
* `--audiobook` flag switches the remote target to `$AUDIOBOOK_DIR` (default `./audiobook`)
* Supports wildcards and multiple files


