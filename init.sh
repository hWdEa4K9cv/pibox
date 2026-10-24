#!/bin/bash

set -e

CONTAINER_NAME="pibox"
IMAGE_NAME="my/pi-coding-agent:1.0.0"
AGENT_HOME="pi_agent_home"
AUTH_FILE="$AGENT_HOME/auth.json"
MODEL_FILE="$AGENT_HOME/models.json"
BIN="bin"
WORKSPACE_CONFIG="workspace.txt"

echo ""
echo "Initializing PiBox - The Pi Coding Agent Sandbox..."
echo ""

mkdir -p "$AGENT_HOME"
mkdir -p "$BIN"
touch "$WORKSPACE_CONFIG"

echo "Building the PiBox Container Image..."
echo ""

echo "Select your container engine:"
echo "1) Podman"
echo "2) Docker"
read -p "Choose 1 or 2: " engine_choice
echo ""

if [ "$engine_choice" = "1" ]; then
    if ! command -v podman &> /dev/null; then
        echo "Error: Podman was selected, but it is not installed or available in PATH."
        exit 1
    fi
    ENGINE="podman"
    echo "Building image with Podman..."
    echo ""
    podman build -t "$IMAGE_NAME" .
elif [ "$engine_choice" = "2" ]; then
    if ! command -v docker &> /dev/null; then
        echo "Error: Docker was selected, but it is not installed or available in PATH."
        exit 1
    fi
    ENGINE="docker"
    echo "Building image with Docker..."
    echo ""
    docker build -f Containerfile -t "$IMAGE_NAME" .
else
    echo "Error: Invalid selection. Please choose 1 for Podman or 2 for Docker."
    exit 1
fi

echo "Creating run scripts..."
echo ""

# Create script to enter the PiBox container for debugging
PIBOX_ENTER_CONTAINER_SCRIPT="${BIN}/pibox-enter-container.sh"
cat << EOF > "${PIBOX_ENTER_CONTAINER_SCRIPT}"
#!/bin/bash
echo ""

if [ -z "\$($ENGINE ps -q -f name=^${CONTAINER_NAME}\$)" ]; then
    echo "Error: Pi Coding Agent container '${CONTAINER_NAME}' is not running."
    echo "Please start it first using one of the PiBox scripts."
    exit 1
fi

$ENGINE exec -it $CONTAINER_NAME bash
EOF
chmod +x "${PIBOX_ENTER_CONTAINER_SCRIPT}"

# Create script for running Pi Coding Agent sandboxed to the current directory
PIBOX_CURRENT_DIRECTORY_SCRIPT="${BIN}/pibox-current-directory.sh"
cat << EOF > "${PIBOX_CURRENT_DIRECTORY_SCRIPT}"
#!/bin/bash
echo ""

echo "Run Pi Coding Agent sandboxed to your current directory:"
echo ""
echo "[\$(pwd)]"
echo ""
read -p "Press [Enter] to continue..."

$ENGINE run --rm -it \\
  --name "$CONTAINER_NAME" \\
  -v "$(pwd)/$AGENT_HOME:/root/.pi/agent:z" \\
  -v "\$(pwd):/workspace:z" \\
  $IMAGE_NAME "\$@"
EOF

chmod +x "${PIBOX_CURRENT_DIRECTORY_SCRIPT}"

# Create script for running Pi Coding Agent sandboxed to the directory specified in $WORKSPACE_CONFIG
PIBOX_WORKSPACE_DIRECTORY_SCRIPT="${BIN}/pibox-workspace-directory.sh"
cat << EOF > "${PIBOX_WORKSPACE_DIRECTORY_SCRIPT}"
#!/bin/bash
echo ""

WORKSPACE_PATH=\$(cat $(pwd)/$WORKSPACE_CONFIG | xargs)

if [ -z "\$WORKSPACE_PATH" ]; then
    echo "Error: Path [\$WORKSPACE_PATH] not found or does not contain a valid path. Please create it and specify your workspace directory where Pi Coding Agent should be sandboxed to."
    exit 1
fi

echo "Run Pi Coding Agent sandboxed to your workspace directory:"
echo ""
echo "[\$WORKSPACE_PATH]"
echo ""
read -p "Press [Enter] to continue..."

$ENGINE run --rm -it \\
  --name "$CONTAINER_NAME" \\
  -v "$(pwd)/$AGENT_HOME:/root/.pi/agent:z" \\
  -v "\$WORKSPACE_PATH:/workspace:z" \\
  $IMAGE_NAME "\$@"
EOF

chmod +x ${PIBOX_WORKSPACE_DIRECTORY_SCRIPT}

echo "Initialization complete! See the README.md How-To for details."