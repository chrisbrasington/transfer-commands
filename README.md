# Transfer Commands

This is a lightweight abstraction over `rsync` and SSH to reduce repetitive file transfer syntax and provide simple, memorable commands (`push`, `pull`) for working with a remote transfer directory.

Instead of remembering full `rsync`/`scp` commands and paths, this setup provides consistent, minimal commands with sensible defaults.

---

## Install

```bash
./deploy.sh
````

Installs:

* `pull` → download from server
* `push` → upload to server
* SSH host alias: `storage`

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

* Uses `rsync` over SSH
* Default remote target: `storage:/home/chris/transfer`
* `--audiobook` flag switches the remote target to `storage:/home/chris/audiobook`
* Supports wildcards and multiple files


