# Pi Podman Harness

`tmux-podman` starts or reuses a Podman container for the current workspace and
opens an SSH session into it.

## Usage

```sh
pi_scripts/build-image
tmux-podman
tmux-podman /path/to/workspace
tmux-podman start /path/to/workspace
tmux-podman status /path/to/workspace
tmux-podman stop /path/to/workspace
tmux-podman exec /path/to/workspace -- sh
tmux-podman /path/to/workspace -- pi
```

## Environment

- `PI_PODMAN_IMAGE`: container image, default `localhost/pi-dev-env`
- `PI_AGENT_VERSION`: npm package version baked by `build-image`, default `0.70.2`
- `PI_CODING_AGENT_HOST_DIR`: host state dir, default `~/.local/share/pi-agent`
- `PI_PODMAN_CONTAINER_PREFIX`: container name prefix, default `pi-harness`
- `PI_PODMAN_SSH_USER`: SSH user, default `root`
- `PI_PODMAN_SSH_CONTAINER_PORT`: internal SSH port, default `2222`
- `PI_PODMAN_NETWORK`: Podman network mode, auto-detected from `slirp4netns`,
  `pasta`, then `bridge`
- `PI_PODMAN_ALLOW_PULL=1`: allow `podman run` to pull a missing image

The launcher stores SSH client keys, host keys, `authorized_keys`, and the
container `sshd_config` under `~/.local/share/pi-agent/ssh`.

The image installs:

- Node 24 with npm
- `@mariozechner/pi-coding-agent`
- OpenSSH server/client
- common coding tools: git, ripgrep, fd, jq, curl, Python, tmux, neovim, zsh
