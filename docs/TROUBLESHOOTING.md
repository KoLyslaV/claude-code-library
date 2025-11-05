# Troubleshooting Guide

**Claude Code Library v1.0.0**
**Last Updated:** 2025-11-05

## 📖 Table of Contents

- [Quick Diagnostics](#-quick-diagnostics)
- [Installation Issues](#-installation-issues)
- [Boilerplate Issues](#-boilerplate-issues)
- [Script Execution Issues](#-script-execution-issues)
- [Project-Specific Issues](#-project-specific-issues)
- [Tool Integration Issues](#-tool-integration-issues)
- [Performance Issues](#-performance-issues)

---

## 🩺 Quick Diagnostics

### Run Health Check

**First step for any issue - run the health check:**

```bash
claude-lib doctor
```

This will verify:
- ✅ Library installation
- ✅ All scripts present and executable
- ✅ All boilerplates present
- ✅ Modern CLI tools (fd, rg, eza, bat)
- ✅ Development tools (Node.js, Python, Git)

**Expected output:**
```
🏥 Claude Code Library Health Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Library directory exists: /home/user/.claude-library
✅ Scripts directory exists
  ✅ init-project.sh
  ✅ morning-setup.sh
  ...
✅ Boilerplates directory exists
  ✅ webapp-boilerplate
  ✅ website-boilerplate
  ✅ python-cli-boilerplate

✨ All checks passed! Library is healthy.
```

---

## 🛠️ Installation Issues

### Issue: `claude-lib: command not found`

**Symptoms:**
```bash
$ claude-lib help
bash: claude-lib: command not found
```

**Causes:**
1. Scripts directory not in PATH
2. Script not executable
3. Library not installed

**Solutions:**

**Option 1: Add to PATH (Recommended)**
```bash
# Add to ~/.zshrc or ~/.bashrc
echo 'export PATH="$HOME/.claude-library/scripts:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify
claude-lib version
```

**Option 2: Use full path**
```bash
~/.claude-library/scripts/claude-lib help
```

**Option 3: Create symlink**
```bash
sudo ln -s ~/.claude-library/scripts/claude-lib /usr/local/bin/claude-lib
```

---

### Issue: `Permission denied` when running scripts

**Symptoms:**
```bash
$ ./init-project.sh my-app webapp
-bash: ./init-project.sh: Permission denied
```

**Cause:**
Scripts not executable

**Solution:**
```bash
# Make all scripts executable
chmod +x ~/.claude-library/scripts/*.sh
chmod +x ~/.claude-library/scripts/claude-lib

# Or fix specific script
chmod +x ~/.claude-library/scripts/init-project.sh
```

---

### Issue: Library directory not found

**Symptoms:**
```bash
$ claude-lib doctor
❌ Error: Library directory not found: /home/user/.claude-library
```

**Cause:**
Library not installed or installed in wrong location

**Solution:**
```bash
# Check if exists elsewhere
find ~ -name ".claude-library" -type d 2>/dev/null

# If not found, library needs to be installed
# Contact for installation instructions
```

---

## 📦 Boilerplate Issues

### Issue: `init-project.sh` fails with "Boilerplate not found"

**Symptoms:**
```bash
$ claude-lib init my-app webapp
❌ Boilerplate not found: webapp
```

**Cause:**
Boilerplate directory missing or incorrect name

**Solution:**
```bash
# List available boilerplates
claude-lib list

# Check boilerplate exists
ls ~/.claude-library/boilerplates/

# Valid types: webapp, website, python-cli (case-sensitive)
claude-lib init my-app webapp  # ✅ correct
claude-lib init my-app WebApp  # ❌ wrong case
```

---

### Issue: Template variables not replaced

**Symptoms:**
After init, files still contain `{{PROJECT_NAME}}` or `{{DATE}}`

**Cause:**
`sed` replacement failed (rare)

**Solution:**
```bash
# Manual replacement
cd my-project
find . -type f -name "*.json" -o -name "*.md" -o -name "*.toml" | \
  xargs sed -i "s/{{PROJECT_NAME}}/my-project/g"
find . -type f -name "*.json" -o -name "*.md" -o -name "*.toml" | \
  xargs sed -i "s/{{DATE}}/$(date +%Y-%m-%d)/g"
```

---

### Issue: `npm install` fails after init (webapp/website)

**Symptoms:**
```bash
$ npm install
npm ERR! code ERESOLVE
npm ERR! ERESOLVE unable to resolve dependency tree
```

**Causes:**
1. Node.js version too old
2. npm version too old
3. Network issues
4. Package conflicts

**Solutions:**

**Check versions:**
```bash
node --version  # Should be v18+ (v20+ recommended)
npm --version   # Should be v9+ (v10+ recommended)
```

**Update Node.js if needed:**
```bash
# Using nvm (recommended)
nvm install 20
nvm use 20

# Or using apt (Ubuntu)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**Try clean install:**
```bash
rm -rf node_modules package-lock.json
npm install
```

**Use legacy peer deps (last resort):**
```bash
npm install --legacy-peer-deps
```

---

### Issue: `poetry install` fails (python-cli)

**Symptoms:**
```bash
$ poetry install
Poetry could not find a pyproject.toml file
```

**Causes:**
1. Not in project directory
2. pyproject.toml missing or invalid
3. Poetry not installed

**Solutions:**

**Check you're in project directory:**
```bash
pwd
ls pyproject.toml  # Should exist
```

**Install Poetry if missing:**
```bash
curl -sSL https://install.python-poetry.org | python3 -
```

**Verify Python version:**
```bash
python3 --version  # Should be 3.11+
```

**Try:**
```bash
poetry env use python3.11
poetry install
```

---

## ⚙️ Script Execution Issues

### Issue: `morning-setup.sh` shows no recent commits

**Symptoms:**
```bash
$ claude-lib morning
Recent commits:
  No commits in last 7 days
```

**Causes:**
1. New repository with no commits
2. Not in git repository
3. Working in detached HEAD

**Solutions:**

**Check git status:**
```bash
git status
git log --oneline -10
```

**If new repo, create initial commit:**
```bash
git add .
git commit -m "Initial commit"
```

---

### Issue: `feature-workflow.sh` can't create branch

**Symptoms:**
```bash
$ claude-lib feature my-feature
fatal: Not a valid object name: 'main'
```

**Cause:**
No commits in repository yet

**Solution:**
```bash
# Create initial commit first
git add .
git commit -m "Initial commit"

# Then run feature workflow
claude-lib feature my-feature
```

---

### Issue: `bug-hunter.sh` reports false positives

**Symptoms:**
Many "errors" that aren't actually bugs

**Solutions:**

**For TypeScript errors:**
```bash
# Check tsconfig.json is correct
npx tsc --showConfig

# Update tsconfig.json if needed
```

**For ESLint errors:**
```bash
# Check .eslintrc.js or .eslintrc.json
npx eslint --print-config .

# Adjust rules in .eslintrc.js:
module.exports = {
  rules: {
    '@typescript-eslint/no-unused-vars': 'warn', // Change to warn
    'no-console': 'off', // Disable rule
  }
}
```

**For Python errors:**
```bash
# Check mypy config in pyproject.toml
[tool.mypy]
ignore_missing_imports = true  # If needed
strict = false  # Less strict checking

# Or disable specific files
# mypy.ini
[mypy-tests.*]
ignore_errors = True
```

---

### Issue: `validate-structure.sh` fails on valid project

**Symptoms:**
```bash
❌ Missing required file: .claude/CLAUDE.md
```

**Cause:**
File actually missing or wrong location

**Solution:**
```bash
# Check file exists
ls -la .claude/CLAUDE.md

# If missing, create from boilerplate
cp ~/.claude-library/boilerplates/webapp-boilerplate/.claude/CLAUDE.md \
   .claude/CLAUDE.md

# Or use --fix flag
claude-lib validate --fix
```

---

## 🔧 Project-Specific Issues

### Issue: Next.js 15 build fails

**Symptoms:**
```bash
$ npm run build
Error: Cannot find module 'next/dist/...'
```

**Solutions:**

**Clear Next.js cache:**
```bash
rm -rf .next node_modules/.cache
npm install
npm run build
```

**Check Next.js version:**
```bash
npm list next
# Should be 15.0.0 or later
```

**Update Next.js:**
```bash
npm install next@latest react@latest react-dom@latest
```

---

### Issue: Astro build fails

**Symptoms:**
```bash
$ npm run build
Error: Cannot load @astrojs/...
```

**Solutions:**

**Clear Astro cache:**
```bash
rm -rf .astro node_modules/.cache dist
npm install
npm run build
```

**Check Astro version:**
```bash
npm list astro
# Should be 5.0.0 or later
```

**Reinstall Astro integrations:**
```bash
npm uninstall @astrojs/mdx @astrojs/tailwind
npm install @astrojs/mdx@latest @astrojs/tailwind@latest
```

---

### Issue: Python CLI tool not in PATH

**Symptoms:**
```bash
$ my-tool hello
-bash: my-tool: command not found
```

**Cause:**
Tool not installed or Poetry virtualenv not activated

**Solutions:**

**Option 1: Use `poetry run`**
```bash
poetry run my-tool hello
```

**Option 2: Activate virtualenv**
```bash
poetry shell
my-tool hello
```

**Option 3: Install globally (not recommended)**
```bash
poetry build
pip install dist/my_tool-0.1.0-py3-none-any.whl
```

---

## 🔗 Tool Integration Issues

### Issue: Serena not finding symbols

**Symptoms:**
```bash
mcp__serena__find_symbol not returning results
```

**Solutions:**

**Check project is indexed:**
```bash
# Check for .serena/cache directory
ls -la .serena/

# If missing, index project
uvx serena project index

# Or use alias
sindex
```

**Verify you're in correct directory:**
```bash
pwd
# Should be project root with .git/
```

**Check Serena is configured:**
```bash
claude mcp list
# Should show: serena: ✓ Connected
```

---

### Issue: Context7 not returning docs

**Symptoms:**
```
"use context7" not returning library documentation
```

**Solutions:**

**Check Context7 is configured:**
```bash
claude mcp list
# Should show: context7: ✓ Connected
```

**Check API key is set:**
```bash
echo $CONTEXT7_API_KEY
# Should print: ctx7sk-...
```

**Try explicit library ID:**
```
Instead of: "How to use React?"
Try: "How to use React? use context7"
Or: mcp__context7__get-library-docs(context7CompatibleLibraryID="/facebook/react")
```

---

### Issue: Modern CLI tools not found

**Symptoms:**
```bash
$ fd test
-bash: fd: command not found
```

**Solutions:**

**Install fd:**
```bash
# Ubuntu/Debian
sudo apt install fd-find
ln -s $(which fdfind) ~/.local/bin/fd

# macOS
brew install fd

# Manual install
cargo install fd-find
```

**Install ripgrep (rg):**
```bash
# Ubuntu/Debian
sudo apt install ripgrep

# macOS
brew install ripgrep
```

**Install eza:**
```bash
# Ubuntu/Debian (add repository)
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
  sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
  sudo tee /etc/apt/sources.list.d/gierens.list
sudo apt update && sudo apt install eza

# macOS
brew install eza
```

**Install bat:**
```bash
# Ubuntu/Debian
sudo apt install bat
ln -s $(which batcat) ~/.local/bin/bat

# macOS
brew install bat
```

---

## ⚡ Performance Issues

### Issue: Scripts running slow

**Symptoms:**
- `morning-setup.sh` takes >30 seconds
- `bug-hunter.sh` takes >5 minutes
- `feature-workflow.sh` discovery phase slow

**Solutions:**

**Check disk I/O:**
```bash
# Check if node_modules is huge
du -sh node_modules/
# Should be < 1GB typically

# Check if lots of files
fd --type f | wc -l
# > 100k files can be slow
```

**Skip heavy checks:**
```bash
# Use quick mode
claude-lib bug-hunt --quick

# Skip node_modules in searches
fd --exclude node_modules pattern
rg --glob '!node_modules/' pattern
```

**Consider SSD:**
- Mechanical HDDs are 10-100x slower
- Move project to SSD if available

---

### Issue: Git operations slow

**Symptoms:**
```bash
$ git status
# Takes 10+ seconds
```

**Solutions:**

**Enable fsmonitor (Git 2.37+):**
```bash
git config core.fsmonitor true
git config core.untrackedcache true
```

**Exclude large directories:**
```bash
# Add to .gitignore
node_modules/
.next/
dist/
build/
.astro/
```

**Check git version:**
```bash
git --version
# Should be 2.30+ (2.40+ recommended)
```

---

## 🆘 Getting Help

### Still having issues?

**1. Check documentation:**
- [README.md](../README.md) - Overview
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Command reference
- Script-specific help: `claude-lib help <command>`

**2. Run diagnostics:**
```bash
claude-lib doctor
```

**3. Check logs:**
```bash
# Check recent script output
ls ~/.claude-library/.logs/  # If logging enabled

# Check git for recent changes
git log --oneline -10
git status
```

**4. Try minimal reproduction:**
```bash
# Create fresh test project
cd /tmp
claude-lib init test-project webapp
cd test-project
npm install
claude-lib morning
```

**5. Report issue:**
- Describe problem clearly
- Include error messages
- Include output of `claude-lib doctor`
- Include steps to reproduce

---

## 📝 Common Error Messages

### Error: `ENOENT: no such file or directory`

**Meaning:** File or directory not found

**Check:**
```bash
# Verify you're in correct directory
pwd

# Check file exists
ls -la <filename>
```

---

### Error: `EACCES: permission denied`

**Meaning:** Permission error

**Solutions:**
```bash
# For files you own
chmod +x <file>

# For scripts
chmod +x ~/.claude-library/scripts/*.sh

# NEVER use sudo with npm/scripts
# (except for global installs)
```

---

### Error: `MODULE_NOT_FOUND`

**Meaning:** Missing npm/Python package

**Solutions:**

**For npm:**
```bash
npm install
# Or specific package
npm install <package-name>
```

**For Python:**
```bash
poetry install
# Or specific package
poetry add <package-name>
```

---

### Error: `Cannot find module 'next/dist/...'`

**Meaning:** Next.js cache corruption

**Solution:**
```bash
rm -rf .next node_modules/.cache
npm install
```

---

### Error: `Unable to resolve dependency tree`

**Meaning:** npm package conflicts

**Solutions:**
```bash
# Try clean install
rm -rf node_modules package-lock.json
npm install

# Or use --legacy-peer-deps
npm install --legacy-peer-deps

# Or update packages
npm update
```

---

## 🔧 Maintenance Commands

### Clean caches
```bash
# npm cache
npm cache clean --force

# Next.js cache
rm -rf .next node_modules/.cache

# Astro cache
rm -rf .astro dist

# Git cache
git gc --aggressive

# Poetry cache
poetry cache clear pypi --all
```

### Reinstall dependencies
```bash
# npm
rm -rf node_modules package-lock.json
npm install

# Poetry
poetry env remove python
poetry install
```

### Reset git state
```bash
# Discard all changes (DANGEROUS!)
git reset --hard HEAD
git clean -fd

# Or stash instead (safer)
git stash save "backup before reset"
```

---

**Last Updated:** 2025-11-05
**Version:** 1.0.0
**For more help:** Run `claude-lib help` or `claude-lib doctor`
