#compdef claude-lib
# Zsh completion for claude-lib command
# Installation:
#   1. Copy to: ~/.oh-my-zsh/completions/_claude-lib
#   OR
#   2. Add to fpath and autoload:
#      fpath=(~/.claude-library/completions $fpath)
#      autoload -U compinit && compinit
#   OR
#   3. Source in ~/.zshrc: source ~/.claude-library/completions/claude-lib-completion.zsh

_claude-lib() {
    local -a commands
    local -a global_options
    local -a boilerplates

    # Main commands with descriptions
    commands=(
        'init:Initialize new project from boilerplate'
        'morning:Run morning setup for current project'
        'validate:Validate project structure'
        'feature:Start feature development workflow'
        'bug-hunt:Run bug hunting and detection'
        'docs:Generate/update documentation'
        'crisis:Emergency debugging mode'
        'check:Run all quality checks'
        'anti-patterns:Detect anti-patterns'
        'fix:Auto-fix common issues'
        'list:List available boilerplates and scripts'
        'version:Show version information'
        'doctor:Check library installation health'
        'help:Show help for specific command'
    )

    # Global options
    global_options=(
        '--help:Show help message'
        '--version:Show version'
        '--verbose:Verbose output'
    )

    # Boilerplate types
    boilerplates=(
        'webapp:Next.js 15 + React 19 (full-stack web apps)'
        'website:Astro 5.0 (static sites, blogs)'
        'python-cli:Python CLI tool (Click + Poetry)'
    )

    case ${words[2]} in
        init)
            case ${CURRENT} in
                3)
                    # Project name - no completion, user types
                    _message 'project-name'
                    ;;
                4)
                    # Boilerplate type
                    _describe 'boilerplate type' boilerplates
                    ;;
                *)
                    ;;
            esac
            ;;

        feature)
            case ${CURRENT} in
                3)
                    # Feature name - no completion
                    _message 'feature-name'
                    ;;
                *)
                    # Feature flags
                    local -a feature_options
                    feature_options=(
                        '--skip-branch:Skip branch creation'
                        '--skip-tests:Skip test generation'
                        '--help:Show help'
                    )
                    _describe 'feature options' feature_options
                    ;;
            esac
            ;;

        bug-hunt)
            local -a bug_options
            bug_options=(
                '--quick:Quick scan (skip heavy checks)'
                '--fix:Auto-fix common issues'
                '--report:Generate bug report'
                '--help:Show help'
            )
            _describe 'bug-hunt options' bug_options
            ;;

        docs)
            local -a docs_options
            docs_options=(
                '--quick:Update HANDOFF + TODO only'
                '--full:Generate all documentation'
                '--help:Show help'
            )
            _describe 'docs options' docs_options
            ;;

        crisis)
            local -a crisis_options
            crisis_options=(
                '--auto-fix:Attempt automatic fixes'
                '--save-state:Save to BUGS_FIXED.md'
                '--help:Show help'
            )
            if [[ ${CURRENT} -eq 3 ]]; then
                _message 'issue-description'
            else
                _describe 'crisis options' crisis_options
            fi
            ;;

        validate)
            local -a validate_options
            validate_options=(
                '--fix:Auto-fix common issues'
                '--help:Show help'
            )
            _describe 'validate options' validate_options
            ;;

        anti-patterns)
            local -a ap_options
            ap_options=(
                '--json:Output JSON format'
                '--ci:Exit with error code if issues found'
                '--help:Show help'
            )
            _describe 'anti-patterns options' ap_options
            ;;

        help)
            # Complete with command names for help
            _describe 'command' commands
            ;;

        morning|check|fix|list|version|doctor)
            # These commands don't take arguments
            _message 'no more arguments'
            ;;

        *)
            # First argument - complete with commands
            if [[ ${CURRENT} -eq 2 ]]; then
                _describe 'command' commands
                _describe 'global option' global_options
            fi
            ;;
    esac
}

_claude-lib "$@"
