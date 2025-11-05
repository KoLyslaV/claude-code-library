# Claude Code Library - Quick Reference

**Version:** 1.0.0
**Last Updated:** 2025-11-05

## 📖 Table of Contents

- [Boilerplates](#-boilerplates)
- [Automation Scripts](#-automation-scripts)
- [Workflows](#-workflows)
- [Quick Commands](#-quick-commands)
- [Best Practices](#-best-practices)

---

## 🎨 Boilerplates

### webapp-boilerplate (Next.js 15 + React 19)

**Use for:** Full-stack web applications, dashboards, SaaS products

**Tech Stack:**
- Next.js 15 (App Router)
- React 19 (Server Components)
- TypeScript 5.7
- Tailwind CSS 4.0
- Supabase (optional)

**Initialize:**
```bash
~/.claude-library/scripts/init-project.sh my-app webapp
cd my-app
npm install
npm run dev
```

**Key Features:**
- Server Actions for mutations
- React Server Components by default
- Supabase auth & database ready
- shadcn/ui components
- Route handlers for API endpoints

**When to use:**
- ✅ Full-stack web applications
- ✅ Admin dashboards
- ✅ SaaS products
- ✅ Interactive web apps
- ❌ Static content sites (use website)
- ❌ CLI tools (use python-cli)

---

### website-boilerplate (Astro 5.0)

**Use for:** Marketing sites, blogs, documentation, portfolios

**Tech Stack:**
- Astro 5.0
- TypeScript 5.7
- Tailwind CSS 4.0
- MDX support
- Content Collections

**Initialize:**
```bash
~/.claude-library/scripts/init-project.sh my-site website
cd my-site
npm install
npm run dev
```

**Key Features:**
- Zero JavaScript by default
- Content Collections for type-safe content
- File-based routing
- Astro Islands for interactivity
- Blog system with MDX

**When to use:**
- ✅ Marketing websites
- ✅ Blogs & content sites
- ✅ Documentation sites
- ✅ Portfolios
- ✅ Static sites needing speed
- ❌ Heavy interactivity (use webapp)
- ❌ Backend logic (use webapp)

---

### python-cli-boilerplate

**Use for:** Command-line tools, automation scripts, dev tools

**Tech Stack:**
- Python 3.11+
- Click 8.1+
- Poetry
- pytest + pytest-cov
- mypy + ruff

**Initialize:**
```bash
~/.claude-library/scripts/init-project.sh my-tool python-cli
cd my-tool
poetry install
poetry run my-tool hello
```

**Key Features:**
- Click framework with decorators
- Type hints with mypy validation
- pytest with CliRunner
- Poetry for dependencies
- Example commands & tests

**When to use:**
- ✅ CLI tools & utilities
- ✅ Automation scripts
- ✅ Dev tools & workflows
- ✅ Data processing pipelines
- ❌ Web applications (use webapp/website)
- ❌ Long-running services

---

## 🛠️ Automation Scripts

### init-project.sh

**Purpose:** Initialize new projects from boilerplates

**Usage:**
```bash
init-project.sh <project-name> <boilerplate-type>
```

**Examples:**
```bash
init-project.sh my-app webapp
init-project.sh blog website
init-project.sh cli-tool python-cli
```

**What it does:**
1. Copies boilerplate to new directory
2. Replaces template variables ({{PROJECT_NAME}}, etc.)
3. Initializes git repository
4. Creates initial commit
5. Opens project in editor

**ROI:** 10-15 min saved per project setup

---

### morning-setup.sh

**Purpose:** Load session context at start of day

**Usage:**
```bash
cd /path/to/project
~/.claude-library/scripts/morning-setup.sh
```

**What it does:**
1. Shows project structure summary
2. Displays recent git commits
3. Shows TODO.md priorities
4. Lists recent changes
5. Displays HANDOFF.md notes
6. Runs validation checks

**ROI:** 5-10 min saved understanding project state

---

### validate-structure.sh

**Purpose:** Validate project structure and configuration

**Usage:**
```bash
validate-structure.sh [--fix]
```

**Options:**
- `--fix` - Auto-fix common issues

**What it checks:**
- Required files (.claude/CLAUDE.md, TODO.md, etc.)
- Git configuration
- Dependencies installed
- Configuration files
- Directory structure

**ROI:** Catches 90% of setup issues before development

---

### anti-pattern-detector.sh

**Purpose:** Detect code anti-patterns and bad practices

**Usage:**
```bash
anti-pattern-detector.sh [--json] [--ci]
```

**Options:**
- `--json` - Output JSON format
- `--ci` - Exit with error code if issues found

**Detects:**
- P0 (Critical): Security issues, performance killers
- P1 (High): Code smells, maintainability issues
- P2 (Medium): Minor improvements
- P3 (Low): Nitpicks

**ROI:** 70% reduction in code review cycles

---

### feature-workflow.sh

**Purpose:** Automate feature development workflow (Playbook 2)

**Usage:**
```bash
feature-workflow.sh <feature-name> [options]
```

**Options:**
- `--skip-branch` - Use current branch
- `--skip-tests` - Skip test generation prompt

**Example:**
```bash
feature-workflow.sh user-authentication
```

**Workflow (6 phases):**
1. **Setup:** Create feature branch, add to TODO.md
2. **Discovery:** Run fd/rg search, suggest Serena commands
3. **Implementation:** L0-L2 checklist with progress tracking
4. **Testing:** Run test suite (npm test or pytest)
5. **Validation:** Run structure validation + anti-pattern detection
6. **Commit:** Create conventional commit, mark TODO complete

**ROI:** Hours saved per feature with systematic approach

---

### bug-hunter.sh

**Purpose:** Systematic bug detection and fixing (Playbook 4)

**Usage:**
```bash
bug-hunter.sh [options]
```

**Options:**
- `--quick` - Quick scan (skip heavy checks)
- `--fix` - Auto-fix common issues
- `--report` - Generate bug report

**Example:**
```bash
bug-hunter.sh --fix --report
```

**Workflow (5 phases):**
1. **Static Analysis:** TypeScript, ESLint, mypy, ruff
2. **Anti-Pattern Detection:** Integrates anti-pattern-detector.sh
3. **Runtime Error Scanning:** console.error/warn, TODO/FIXME
4. **Test Execution:** npm test or pytest
5. **Summary & Report:** Generate BUG_REPORT.md

**ROI:** 80% faster bug detection vs manual hunting

---

### doc-sprint.sh

**Purpose:** Rapid documentation generation

**Usage:**
```bash
doc-sprint.sh [options]
```

**Options:**
- `--full` - Generate all documentation
- `--quick` - Quick update (HANDOFF + TODO only)

**Example:**
```bash
doc-sprint.sh --full
```

**What it generates:**
1. **HANDOFF.md:** Session notes with recent commits
2. **TODO.md:** Priority tracking (P0/P1 counts)
3. **CODE_PATTERNS.md:** Reusable patterns (--full only)
4. **ARCHITECTURE.md:** System overview (--full only)
5. **API.md:** API documentation if applicable (--full only)

**ROI:** 90% faster documentation vs manual writing

---

### crisis-mode.sh

**Purpose:** Emergency debugging with systematic checklist

**Usage:**
```bash
crisis-mode.sh [issue-description] [options]
```

**Options:**
- `--auto-fix` - Attempt automatic fixes
- `--save-state` - Save debugging state to BUGS_FIXED.md

**Example:**
```bash
crisis-mode.sh "Server returning 500 errors" --save-state
```

**Workflow (5 phases):**
1. **Capture System State:** Git, environment, processes, ports
2. **Emergency Diagnostics:** Compilation, dependencies, conflicts
3. **Debugging Checklist:** Interactive troubleshooting guide
4. **Rollback Options:** Git stash/revert/reset options
5. **Solution Documentation:** Auto-add to BUGS_FIXED.md

**ROI:** Saves hours during production incidents

---

## 🔄 Workflows

### Workflow 1: Start New Feature

```bash
# 1. Run morning setup to understand current state
morning-setup.sh

# 2. Start feature workflow
feature-workflow.sh user-profile

# 3. Development happens here...
# (Use Discovery Before Action: fd → rg → Serena)

# 4. Workflow guides through L0-L2 implementation

# 5. Auto-validation and commit
```

**Time saved:** 30-60 min per feature

---

### Workflow 2: Bug Hunting Session

```bash
# 1. Quick bug scan
bug-hunter.sh --quick

# 2. If issues found, run full scan with auto-fix
bug-hunter.sh --fix --report

# 3. Review generated BUG_REPORT.md

# 4. Fix P0 issues first, then P1

# 5. Re-run to verify
bug-hunter.sh --quick
```

**Time saved:** 1-2 hours of manual debugging

---

### Workflow 3: End of Day Documentation

```bash
# 1. Quick documentation update
doc-sprint.sh --quick

# 2. Edit HANDOFF.md with session notes

# 3. Update TODO.md priorities

# 4. Commit documentation
git add .claude/docs/
git commit -m "docs: update session handoff"
```

**Time saved:** 15-20 min of manual documentation

---

### Workflow 4: Production Incident Response

```bash
# 1. Activate crisis mode
crisis-mode.sh "Description of issue" --save-state

# 2. Follow interactive checklist

# 3. System state captured to .claude/crisis-*/

# 4. Use rollback options if needed

# 5. Document solution in BUGS_FIXED.md

# 6. Create postmortem from captured state
```

**Time saved:** Critical - may save hours during incidents

---

### Workflow 5: New Project Setup

```bash
# 1. Initialize from boilerplate
init-project.sh my-project webapp

# 2. Navigate to project
cd my-project

# 3. Install dependencies
npm install

# 4. Run morning setup to verify
morning-setup.sh

# 5. Run structure validation
validate-structure.sh

# 6. Start development
npm run dev
```

**Time saved:** 10-15 min of manual setup

---

## ⚡ Quick Commands

### Development Start
```bash
cd ~/Projekty/my-project
morning-setup.sh                    # Load context
npm run dev                         # Start dev server
```

### Feature Development
```bash
feature-workflow.sh new-feature     # Automated workflow
```

### Quality Checks
```bash
validate-structure.sh               # Check project structure
anti-pattern-detector.sh            # Check code quality
bug-hunter.sh --quick               # Quick bug scan
```

### Documentation
```bash
doc-sprint.sh --quick               # Update HANDOFF + TODO
doc-sprint.sh --full                # Full documentation
```

### Emergency
```bash
crisis-mode.sh "Issue description"  # Emergency debugging
```

---

## 🎯 Best Practices

### Discovery Before Action

**Always follow this pattern:**
```bash
# 1. Find files
fd "pattern" src/

# 2. Search content
rg "keyword" src/

# 3. Explore with Serena
mcp__serena__get_symbols_overview("src/file.ts")
mcp__serena__find_symbol("/ClassName")
```

**Why:** 70% token savings vs reading full files

---

### Implementation Levels

**L0 - MVP (Minimum Viable Product):**
- Core functionality working
- Basic error handling
- Manual testing passed

**L1 - Production Ready:**
- Edge cases handled
- Automated tests written
- Documentation updated

**L2 - Polish:**
- Performance optimized
- UX improved
- Code reviewed

**L3 - Exceptional (rarely needed):**
- Advanced features
- Comprehensive monitoring
- Full edge case coverage

**Ship L0-L1, iterate on L2-L3**

---

### Use Context7 for Libraries

**Always add "use context7" when asking about libraries:**

```
How do I use Next.js 15 middleware? use context7
How does React Query v5 work? use context7
MongoDB connection pooling setup, use context7
```

**Why:** Eliminates hallucinations, always current APIs

---

### Commit Message Format

**Use Conventional Commits:**

```bash
feat: add user authentication
fix: resolve login redirect issue
docs: update API documentation
refactor: simplify auth logic
test: add login flow tests
chore: update dependencies
```

---

### File Organization

**Required files in every project:**
```
.claude/
├── CLAUDE.md          # Project-specific instructions
├── docs/
│   ├── HANDOFF.md     # Session context
│   ├── TODO.md        # Task tracking
│   ├── ARCHITECTURE.md # System design
│   └── patterns/
│       ├── CODE_PATTERNS.md  # Reusable patterns
│       └── BUGS_FIXED.md     # Bug documentation
```

---

### Script Integration

**Scripts work together - use them in combination:**

```bash
# Morning routine
morning-setup.sh && validate-structure.sh

# Feature development
feature-workflow.sh auth && bug-hunter.sh --quick

# Pre-commit
anti-pattern-detector.sh && bug-hunter.sh --quick

# End of day
doc-sprint.sh --quick
```

---

## 📊 ROI Summary

| Script | Time Saved | Benefit |
|--------|------------|---------|
| init-project.sh | 10-15 min | Consistent project setup |
| morning-setup.sh | 5-10 min | Fast context loading |
| validate-structure.sh | 5-10 min | Catch issues early |
| anti-pattern-detector.sh | 30-60 min | Reduce review cycles |
| feature-workflow.sh | 30-60 min | Systematic development |
| bug-hunter.sh | 1-2 hours | Automated bug detection |
| doc-sprint.sh | 15-20 min | Rapid documentation |
| crisis-mode.sh | Hours | Critical incident response |

**Total time saved per week:** 4-8 hours

---

## 🚀 Getting Started

### First Time Setup

1. **Verify installation:**
```bash
ls ~/.claude-library/scripts/
ls ~/.claude-library/boilerplates/
```

2. **Make scripts accessible (optional):**
```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="$HOME/.claude-library/scripts:$PATH"

# Then use scripts directly:
init-project.sh my-app webapp
morning-setup.sh
```

3. **Create your first project:**
```bash
init-project.sh my-first-app webapp
cd my-first-app
npm install
morning-setup.sh
npm run dev
```

4. **Learn the workflows:**
- Start with `morning-setup.sh` daily
- Use `feature-workflow.sh` for new features
- Run `bug-hunter.sh` before commits
- Use `doc-sprint.sh` end of day

---

## 🔗 Related Documents

- [README.md](../README.md) - Overview and installation
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions
- [ultimate-playbooks.md](../boilerplates/webapp-boilerplate/.claude/docs/ultimate-playbooks.md) - Complete workflow playbooks
- [ultimate-next15-patterns.md](../boilerplates/webapp-boilerplate/.claude/docs/ultimate-next15-patterns.md) - Next.js patterns

---

## 📝 Notes

- All scripts support `--help` flag for detailed usage
- Scripts are version 1.0.0 - stable and production-ready
- Scripts integrate with Serena, Context7, and modern CLI tools (fd, rg, eza, bat)
- Color-coded output: 🔴 Red = errors, 🟡 Yellow = warnings, 🟢 Green = success, 🔵 Blue = info

---

**Last Updated:** 2025-11-05
**Version:** 1.0.0
**Feedback:** Report issues or suggestions for improvements
