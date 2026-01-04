# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NOCOLOR='\033[0m'

# Function to print step
print_step() {
    echo -e "${CYAN}▶ $1${NOCOLOR}"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NOCOLOR}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ $1${NOCOLOR}"
}

clear

echo -e "${MAGENTA}"
cat << "EOF"

                __                      __
 _      _______/ /     ____ ___________/ /_
| | /| / / ___/ /_____/ __ `/ ___/ ___/ __ \
| |/ |/ (__  ) /_____/ /_/ / /  / /__/ / / /
|__/|__/____/_/      \__,_/_/   \___/_/ /_/

EOF
echo -e "${NOCOLOR}"

# Set en_US.UTF-8 locale
sed -i 's/^#\s*\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
localectl set-locale LANG=en_US.UTF-8

pacman -Syu --noconfirm sudo nano xdg-utils

# Set root password
echo
print_step "Set a password for the root user"
if passwd; then
    print_success "Root password set successfully"
else
    print_error "Failed to set root password"
    exit 1
fi

# Interactive user creation
echo
print_step "Enter username for new non-root user"
echo

# Prompt for username
while true; do
    read -p "Username: " NEW_USERNAME
    if [ -z "$NEW_USERNAME" ]; then
        print_error "Username cannot be empty"
        continue
    fi
    if id "$NEW_USERNAME" &>/dev/null; then
        print_error "User $NEW_USERNAME already exists"
        continue
    fi
    if ! [[ "$NEW_USERNAME" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
        print_error "Invalid username. Must start with lowercase letter or underscore, contain only lowercase letters, numbers, hyphens, and underscores"
        continue
    fi
    break
done

# Create the user
print_step "Creating user $NEW_USERNAME..."
if useradd -m -G wheel -s /bin/bash "$NEW_USERNAME"; then
    print_success "User $NEW_USERNAME created"
else
    print_error "Failed to create user"
    exit 1
fi

# Set password
echo
print_step "Set password for $NEW_USERNAME"
if passwd "$NEW_USERNAME"; then
    print_success "Password set successfully"
else
    print_error "Failed to set password"
    exit 1
fi

# Configure WSL default user
print_step "Configuring WSL default user..."
if grep -q "^\[user\]" /etc/wsl.conf 2>/dev/null; then
    # [user] section exists, update or add default line
    if grep -q "^default=" /etc/wsl.conf; then
        sed -i "s/^default=.*/default=$NEW_USERNAME/" /etc/wsl.conf
    else
        sed -i "/^\[user\]/a default=$NEW_USERNAME" /etc/wsl.conf
    fi
else
    # [user] section doesn't exist, append it
    echo "" >> /etc/wsl.conf
    echo "[user]" >> /etc/wsl.conf
    echo "default=$NEW_USERNAME" >> /etc/wsl.conf
fi
print_success "WSL configured to use $NEW_USERNAME as default user"

# Configure passwordless sudo for wheel group
print_step "Configuring passwordless sudo..."
if sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL$/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers; then
    print_success "Passwordless sudo enabled for wheel group"
else
    print_error "Failed to configure passwordless sudo"
fi

echo
print_success "User account setup complete"

echo -e "${MAGENTA}"
cat << "EOF"

                __                      __
 _      _______/ /     ____ ___________/ /_
| | /| / / ___/ /_____/ __ `/ ___/ ___/ __ \
| |/ |/ (__  ) /_____/ /_/ / /  / /__/ / / /
|__/|__/____/_/      \__,_/_/   \___/_/ /_/

EOF
echo -e "${NOCOLOR}"

print_step "Shutting down virtual environment"
print_success "Reattach via 'wsl -d archlinux' to take effect"

poweroff
