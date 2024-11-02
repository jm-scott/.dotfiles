#!/bin/zsh

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

function ensure_ed25519() {
    local key_path="$HOME/.ssh/id_ed25519"

    if [[ ! -f $key_path ]]; then
        echo "Generating a new ed25519 SSH key at $key_path..."
        ssh-keygen -t ed25519 -f "$key_path" -N ""
        echo "SSH key generated successfully."
    else
        echo "SSH key already exists at $key_path."
        echo "Key Fingerprint: $(ssh-keygen -lf $key_path)"
    fi
}

function add_key_to_ssh_agent() {
    echo "Restarting ssh-agent."
    eval "$(ssh-agent -s)"
    echo "ssh-agent restarted successfully."
}

function prompt_yes_no() {
    local prompt_message="$1"
    echo -n "$prompt_message (y/n): "
    read response
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        return 0
    else
        return 1
    fi
}

function file_or_symlink_exists() {
    local file_path="$1"
    if [[ -e $file_path || -L $file_path ]]; then
        return 0  # true
    else
        return 1  # false
    fi
}

function link_ssh_config() {
    local source_file="$SCRIPT_DIR/ssh_config"
    local destination_dir="$HOME/.ssh"
    local destination_file="$destination_dir/ssh_config"

    echo "Linking SSH Config."
    if [[ -f $source_file ]]; then
        mkdir -p "$destination_dir"

        if file_or_symlink_exists "$destination_file"; then
            if prompt_yes_no "A file or symlink named ssh_config already exists in $destination_dir. Do you want to overwrite it?"; then
                rm -f "$destination_file"
                ln -s "$source_file" "$destination_file"
                echo "Symlink to ssh_config created in $destination_dir."
            else
                echo "Operation canceled. Symlink was not created."
            fi
        else
            ln -s "$source_file" "$destination_file"
            echo "Symlink to ssh_config created in $destination_dir."
        fi
    else
        echo "Error: ssh_config file not found in the current directory." && exit 1
    fi
}

function print_link_and_wait() {
    local link="$1"
    local prompt="$2"
    echo "$prompt: $link"
    
    if prompt_yes_no "Do you want to continue?"; then
        echo "Continuing..."
    else
        echo "Exited early."
        exit 1;
    fi
}

function ensure_xcode() { 
    echo "Installing xcode."
	set +e
    xcode-select --install 2>/dev/null
    local exit_code=$? 
    set -e
	#echo "Exit code: $exit_code"
    if [[ $exit_code -eq 0 ]]; then
        echo "Installed xcode."
    elif [[ $exit_code -eq 1 ]]; then
        echo "xcode already installed."
    else
        echo "Failed to install xcode."
        exit 1
    fi
}

function ensure_brew() {
    if command -v brew >/dev/null 2>&1; then
        echo "brew already installed."
    else
        echo "Installing brew."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        echo "Installed brew."
    fi
}

function ensure_fonts() {
    echo "Installing fonts."
    local fonts_dir="$SCRIPT_DIR/fonts"
    local font_prefix="MesloLGS NF"
    local fonts=("Regular" "Bold" "Italic" "Bold Italic")

    # Ensure the fonts directory exists
    if [ ! -d "$fonts_dir" ]; then
        echo "Fonts directory '$fonts_dir' does not exist."
        return 1
    fi

    installed_fonts=$(system_profiler SPFontsDataType 2>/dev/null)

    for suffix in "${fonts[@]}"; do
        local font="$font_prefix $suffix.ttf"
        local font_path="$fonts_dir/$font"

        # Check if the font file exists
        if [ ! -f "$font_path" ]; then
            echo "Font file '$font_path' does not exist."
            continue
        fi

        # Check if the font is already installed
        if ! echo $installed_fonts | grep -i "$font" >/dev/null 2>&1; then
            echo "Installing font '$font'..."
            # Use the macOS `cp` command to copy the font to the Fonts directory
            cp "$font_path" ~/Library/Fonts/
        else
            echo "Font '$font' is already installed."
        fi
    done
}

function ensure_omz() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "oh-my-zsh already installed."
    else
        echo "Installing oh-my-zsh."
	zsh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >/dev/null 2>&1
	echo "Installed oh-my-zsh. Installing plugins."
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions >/dev/null 2>&1
	echo "Installed zsh-autosuggestions."
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting >/dev/null 2>&1
	echo "Installed zsh-syntax-highlighting."
    fi
}

function ensure_p10k() {
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        echo "p10k already installed."
    else
        echo "Installing p10k."
	    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k >/dev/null 2>&1
	    echo "Installed p10k."
    fi
}

function link_dotfiles() {
    local dir="$SCRIPT_DIR/files"
    # Temporarily expand no matches to empty lists
    # setopt localoptions nullglob
    for file in "$dir"/.*; do
        filename=$(basename "$file")
        # Skip if it's a script or directory that shouldn't be linked
        if [[ -d "$file" ]]; then
            continue
        fi

        # Create a symbolic link in the home directory
        ln -sf "$file" "$HOME/$filename"
        echo "Linked $file to $HOME/$filename"
    done

    echo "All files have been symlinked to the home directory."
}

# TODO: Detect package manager based on OS
function install_software() {
	local packages=("golang" "fzf" "visual-studio-code" "shellcheck")
	echo "Installing $packages from brew."
	brew install "${packages[@]}" 2>/dev/null
	echo "Installed $packages."
}

ensure_ed25519
add_key_to_ssh_agent
link_ssh_config
print_link_and_wait "https://github.com/settings/keys" "Copy your key using pbcopy < ~/.ssh/id_ed25519.pub and upload here"
ensure_xcode
ensure_brew
ensure_fonts
ensure_omz
ensure_p10k
link_dotfiles
install_software

exit 0
