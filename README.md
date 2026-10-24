# [PiBox] - The Pi Coding Agent Sandbox

A secure, rootless sandbox for running the Pi Coding Agent isolated with Podman or Docker.

## Prerequisites
- [Podman](https://podman.io/) or [Docker](https://www.docker.com/) installed and available in your PATH.
- API Key for a local or cloud model.


## Quick Start

Run the init script from Git Bash for Windows or Bash on Linux to build the container image and generate your PiBox runner scripts:
   ```bash
   ./init.sh
   ```

This will build the Debian Trixie Slim container image containing the Pi Coding Agent and a set of useful tools for you and the agent.
The image can be adjusted in the `Containerfile`.
You can add tools there or even use another Linux distribution.

Add the following snippet to your `~/.bashrc` on Windows or Linux to make the scripts in the bin directory globally available.
This also adds the alias `pibox` as a shortcut to `pibox-workspace-directory.sh`. 
Adjust this to your preferred sandboxing variant.

```bash
if [ -d "your/absolute/path/to/pibox/bin" ]; then
export PATH="your/absolute/path/to/pibox/bin:$PATH"
fi

alias pibox="pibox-workspace-directory.sh"
```


The init script will also create the following files in the `bin` directory located in this project:
- `pibox-current-directory.sh`
- `pibox-workspace-directory.sh`
- `pibox-enter-container.sh`

To specify a permanent sandbox workspace for the `pibox-workspace-directory.sh` script, enter the workspace path in `workspace.txt` located in your PiBox directory.

## How-To
- Run Pi Coding Agent sandboxed to your workspace directory specified in `workspace.txt` using the alias `pibox` or by directly executing `pibox-workspace-directory.sh`.
- Run Pi Coding Agent in the current directory using `pibox-current-directory.sh`
- Debug your running PiBox container using `pibox-enter-container.sh`
- Configure API keys manually in `pi_agent_home/auth.json`, see `examples/auth.json`
- Configure default models manually in `pi_agent_home/models.json`, see `examples/models.json`

## Next Steps
- [ ] Add user mapping when using `docker` engine on Linux.
- [ ] Allow multiple workspace paths for `workspace.txt`
- [ ] Optional: Add Network Sandboxing