````markdown
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

---

## Notes

* Uses `rsync` over SSH
* Remote target: `storage:/home/chris/transfer`
* Supports wildcards and multiple files

```
```

