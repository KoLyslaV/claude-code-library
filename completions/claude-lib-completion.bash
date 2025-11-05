#!/bin/bash
# Bash completion for claude-lib command
# Installation:
#   1. Copy to: ~/.local/share/bash-completion/completions/claude-lib
#   OR
#   2. Source in ~/.bashrc: source ~/.claude-library/completions/claude-lib-completion.bash

_claude_lib_completions() {
    local cur prev commands options

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Main commands
    commands="init morning validate feature bug-hunt docs crisis check anti-patterns fix list version doctor help"

    # Global options
    options="--help --version --verbose"

    # Command-specific completions
    case "${COMP_CWORD}" in
        1)
            # Complete main commands
            COMPREPLY=($(compgen -W "${commands} ${options}" -- "${cur}"))
            return 0
            ;;
        2)
            # Complete based on previous command
            case "${prev}" in
                init)
                    # If no project name yet, suggest nothing (user types name)
                    return 0
                    ;;
                bug-hunt)
                    COMPREPLY=($(compgen -W "--quick --fix --report --help" -- "${cur}"))
                    return 0
                    ;;
                docs)
                    COMPREPLY=($(compgen -W "--quick --full --help" -- "${cur}"))
                    return 0
                    ;;
                crisis)
                    COMPREPLY=($(compgen -W "--auto-fix --save-state --help" -- "${cur}"))
                    return 0
                    ;;
                feature)
                    # Feature name - no completion
                    return 0
                    ;;
                help)
                    COMPREPLY=($(compgen -W "${commands}" -- "${cur}"))
                    return 0
                    ;;
                validate)
                    COMPREPLY=($(compgen -W "--fix --help" -- "${cur}"))
                    return 0
                    ;;
                anti-patterns)
                    COMPREPLY=($(compgen -W "--json --ci --help" -- "${cur}"))
                    return 0
                    ;;
                *)
                    return 0
                    ;;
            esac
            ;;
        3)
            # Third argument
            case "${COMP_WORDS[1]}" in
                init)
                    # Boilerplate type
                    COMPREPLY=($(compgen -W "webapp website python-cli" -- "${cur}"))
                    return 0
                    ;;
                feature)
                    # Feature flags
                    COMPREPLY=($(compgen -W "--skip-branch --skip-tests --help" -- "${cur}"))
                    return 0
                    ;;
                *)
                    return 0
                    ;;
            esac
            ;;
        *)
            # Further arguments - mostly flags
            case "${COMP_WORDS[1]}" in
                bug-hunt|docs|crisis|feature|validate|anti-patterns)
                    # Add --help as option for any position
                    COMPREPLY=($(compgen -W "--help" -- "${cur}"))
                    return 0
                    ;;
                *)
                    return 0
                    ;;
            esac
            ;;
    esac
}

# Register completion
complete -F _claude_lib_completions claude-lib

# Also register for full path invocation
complete -F _claude_lib_completions ~/.claude-library/scripts/claude-lib
