#!/bin/bash
# install-completions.sh - Install shell completions for claude-lib
# Usage: ./install-completions.sh [bash|zsh|all]

set -e

VERSION="1.0.0"
COMPLETIONS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
    cat << EOF
${BLUE}Install Shell Completions for claude-lib${NC}

${YELLOW}USAGE:${NC}
  $0 [shell]

${YELLOW}SHELLS:${NC}
  bash    Install bash completion only
  zsh     Install zsh completion only
  all     Install for all detected shells (default)

${YELLOW}EXAMPLES:${NC}
  $0         # Auto-detect and install
  $0 zsh     # Install zsh completion only
  $0 all     # Install all completions

EOF
    exit 0
}

# Detect shell
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        # Check default shell
        basename "$SHELL"
    fi
}

# Install bash completion
install_bash() {
    echo -e "${CYAN}Installing bash completion...${NC}"

    # Try system completion directory first
    if [ -d /usr/share/bash-completion/completions ]; then
        BASH_COMP_DIR="/usr/share/bash-completion/completions"
        echo -e "${YELLOW}Requires sudo for system install${NC}"
        sudo cp "$COMPLETIONS_DIR/claude-lib-completion.bash" \
             "$BASH_COMP_DIR/claude-lib"
        echo -e "${GREEN}✅ Installed to: $BASH_COMP_DIR/claude-lib${NC}"
    # Try user completion directory
    elif [ -d ~/.local/share/bash-completion/completions ]; then
        BASH_COMP_DIR="$HOME/.local/share/bash-completion/completions"
        cp "$COMPLETIONS_DIR/claude-lib-completion.bash" \
           "$BASH_COMP_DIR/claude-lib"
        echo -e "${GREEN}✅ Installed to: $BASH_COMP_DIR/claude-lib${NC}"
    else
        # Create user directory
        BASH_COMP_DIR="$HOME/.local/share/bash-completion/completions"
        mkdir -p "$BASH_COMP_DIR"
        cp "$COMPLETIONS_DIR/claude-lib-completion.bash" \
           "$BASH_COMP_DIR/claude-lib"
        echo -e "${GREEN}✅ Created and installed to: $BASH_COMP_DIR/claude-lib${NC}"

        # Add to bashrc if not already there
        if ! grep -q "bash-completion" ~/.bashrc 2>/dev/null; then
            echo "" >> ~/.bashrc
            echo "# Enable bash completion" >> ~/.bashrc
            echo "[[ -r ~/.local/share/bash-completion/bash_completion ]] && . ~/.local/share/bash-completion/bash_completion" >> ~/.bashrc
            echo -e "${YELLOW}Added bash-completion source to ~/.bashrc${NC}"
        fi
    fi

    echo -e "${CYAN}To activate now:${NC}"
    echo "  source ~/.bashrc"
    echo "  # OR"
    echo "  source $BASH_COMP_DIR/claude-lib"
}

# Install zsh completion
install_zsh() {
    echo -e "${CYAN}Installing zsh completion...${NC}"

    # Check for oh-my-zsh
    if [ -d ~/.oh-my-zsh/completions ]; then
        ZSH_COMP_DIR="$HOME/.oh-my-zsh/completions"
        cp "$COMPLETIONS_DIR/claude-lib-completion.zsh" \
           "$ZSH_COMP_DIR/_claude-lib"
        echo -e "${GREEN}✅ Installed to: $ZSH_COMP_DIR/_claude-lib${NC}"

    # Use custom completion directory
    else
        ZSH_COMP_DIR="$HOME/.zsh/completions"
        mkdir -p "$ZSH_COMP_DIR"
        cp "$COMPLETIONS_DIR/claude-lib-completion.zsh" \
           "$ZSH_COMP_DIR/_claude-lib"
        echo -e "${GREEN}✅ Installed to: $ZSH_COMP_DIR/_claude-lib${NC}"

        # Add to zshrc if not already there
        if ! grep -q "$ZSH_COMP_DIR" ~/.zshrc 2>/dev/null; then
            echo "" >> ~/.zshrc
            echo "# Enable claude-lib completion" >> ~/.zshrc
            echo "fpath=($ZSH_COMP_DIR \$fpath)" >> ~/.zshrc
            echo "autoload -U compinit && compinit" >> ~/.zshrc
            echo -e "${YELLOW}Added completion directory to ~/.zshrc${NC}"
        fi
    fi

    echo -e "${CYAN}To activate now:${NC}"
    echo "  source ~/.zshrc"
    echo "  # OR"
    echo "  autoload -U compinit && compinit"
}

# Main installation
main() {
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        usage
    fi

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  Shell Completion Installer${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    SHELL_ARG="${1:-all}"

    case "$SHELL_ARG" in
        bash)
            install_bash
            ;;
        zsh)
            install_zsh
            ;;
        all)
            # Detect current shell
            CURRENT_SHELL=$(detect_shell)
            echo -e "${CYAN}Detected shell: $CURRENT_SHELL${NC}"
            echo ""

            if [ "$CURRENT_SHELL" = "zsh" ]; then
                install_zsh
            elif [ "$CURRENT_SHELL" = "bash" ]; then
                install_bash
            else
                echo -e "${YELLOW}Unknown shell: $CURRENT_SHELL${NC}"
                echo -e "${YELLOW}Installing for both bash and zsh...${NC}"
                echo ""
                install_bash
                echo ""
                install_zsh
            fi
            ;;
        *)
            echo -e "${RED}Unknown shell: $SHELL_ARG${NC}"
            echo -e "${CYAN}Use: bash, zsh, or all${NC}"
            exit 1
            ;;
    esac

    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✨ Installation complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Test completion:${NC}"
    echo "  1. Start new shell or source config"
    echo "  2. Type: claude-lib <TAB>"
    echo "  3. Should show available commands"
    echo ""
}

main "$@"
