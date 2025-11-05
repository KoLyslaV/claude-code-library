#!/bin/bash
# init-project.sh - Initialize new project with Claude Code best practices
# Usage: init-project.sh <project-type> <project-name>

set -e

VERSION="1.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo -e "${BLUE}Claude Code Library - Project Initializer${NC}"
    echo "Version: $VERSION"
    echo ""
    echo "Usage: $0 <project-type> <project-name> [project-description]"
    echo ""
    echo "Project types:"
    echo "  webapp      - Interactive web app (Next.js 15)"
    echo "  website     - Static/content website (Astro 5.0) [TODO]"
    echo "  game-2d     - 2D isometric browser game (Phaser) [TODO]"
    echo "  game-unity  - Unity game [TODO]"
    echo "  python-cli  - Python CLI tool [TODO]"
    echo "  python-api  - FastAPI backend [TODO]"
    echo ""
    echo "Example: $0 webapp my-awesome-app \"My Awesome App\""
    echo ""
    echo "Options:"
    echo "  --version      Show version"
    echo "  --help         Show this help"
    echo "  --skip-deps    Skip dependency installation (for testing)"
    exit 1
}

# Parse arguments
if [ $# -eq 0 ]; then
    usage
fi

if [ "$1" = "--version" ]; then
    echo "init-project.sh version $VERSION"
    exit 0
fi

if [ "$1" = "--help" ]; then
    usage
fi

# Parse optional flags
SKIP_DEPS=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        --version|--help)
            # Already handled above
            shift
            ;;
        *)
            break
            ;;
    esac
done

echo "DEBUG: After flag parsing: \$#=$#, \$1=$1, \$2=$2" >&2

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "DEBUG: Argument count check failed: $# args" >&2
    usage
fi

PROJECT_TYPE=$1
PROJECT_PATH=$2
# Third parameter (description) is accepted but not currently used in templates

echo "DEBUG: PROJECT_TYPE=$PROJECT_TYPE, PROJECT_PATH=$PROJECT_PATH" >&2

# Detect library path (auto-discovery)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIBRARY_DIR="$(dirname "$SCRIPT_DIR")"
BOILERPLATES_DIR="$LIBRARY_DIR/boilerplates"

# Extract project name from path (for validation)
PROJECT_NAME=$(basename "$PROJECT_PATH")

echo -e "${BLUE}🚀 Initializing ${GREEN}$PROJECT_TYPE${BLUE} project: ${GREEN}$PROJECT_NAME${NC}"
echo ""

# Validate project name (basename only)
if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9-]+$ ]]; then
    echo -e "${RED}❌ Invalid project name: $PROJECT_NAME${NC}"
    echo "Project name must contain only lowercase letters, numbers, and hyphens"
    exit 1
fi

# Check if directory already exists
if [ -d "$PROJECT_PATH" ]; then
    echo -e "${RED}❌ Directory $PROJECT_PATH already exists!${NC}"
    exit 1
fi

# Create parent directory if it doesn't exist
PARENT_DIR=$(dirname "$PROJECT_PATH")
if [ ! -d "$PARENT_DIR" ]; then
    mkdir -p "$PARENT_DIR"
fi

# Step 1: Create base directory structure
echo -e "${YELLOW}📁 Creating directory structure...${NC}"
mkdir -p "$PROJECT_PATH/.claude/docs/patterns"

# Step 2: Copy boilerplate based on type
echo -e "${YELLOW}📋 Copying boilerplate...${NC}"

case $PROJECT_TYPE in
    webapp)
        if [ ! -d "$BOILERPLATES_DIR/webapp-boilerplate" ]; then
            echo -e "${RED}❌ webapp-boilerplate not found at $BOILERPLATES_DIR/webapp-boilerplate${NC}"
            echo "Please ensure Claude Code Library is properly installed."
            rm -rf "$PROJECT_PATH"
            exit 1
        fi
        cp -r "$BOILERPLATES_DIR/webapp-boilerplate/"* "$PROJECT_PATH/"
        cp -r "$BOILERPLATES_DIR/webapp-boilerplate/".* "$PROJECT_PATH/" 2>/dev/null || true
        ;;
    website)
        echo -e "${RED}❌ website boilerplate not yet implemented${NC}"
        echo "Coming soon! Use 'webapp' for now."
        rm -rf "$PROJECT_NAME"
        exit 1
        ;;
    game-2d)
        echo -e "${RED}❌ game-2d boilerplate not yet implemented${NC}"
        echo "Coming soon! Check back later."
        rm -rf "$PROJECT_NAME"
        exit 1
        ;;
    game-unity)
        echo -e "${RED}⚠️  Unity projects must be created in Unity Editor first.${NC}"
        echo ""
        echo "After creating Unity project, run:"
        echo "  cp -r $BOILERPLATES_DIR/unity-game-boilerplate/.claude <your-unity-project>/"
        rm -rf "$PROJECT_NAME"
        exit 0
        ;;
    python-cli|python-api)
        echo -e "${RED}❌ $PROJECT_TYPE boilerplate not yet implemented${NC}"
        echo "Coming soon! Check back later."
        rm -rf "$PROJECT_NAME"
        exit 1
        ;;
    *)
        echo -e "${RED}❌ Unknown project type: $PROJECT_TYPE${NC}"
        usage
        ;;
esac

# Step 3: Replace template variables
echo -e "${YELLOW}🔧 Customizing templates...${NC}"

# Convert project-name to PascalCase for PROJECT_NAME_PASCAL
PROJECT_NAME_PASCAL=$(echo "$PROJECT_NAME" | sed -E 's/(^|-)([a-z])/\U\2/g')
CURRENT_DATE=$(date +%Y-%m-%d)

# Find and replace in all markdown, json, and config files
find "$PROJECT_PATH" -type f \( -name "*.md" -o -name "*.json" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) -exec sed -i "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" {} \;
find "$PROJECT_PATH" -type f \( -name "*.md" -o -name "*.json" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) -exec sed -i "s|{{PROJECT_NAME_PASCAL}}|$PROJECT_NAME_PASCAL|g" {} \;
find "$PROJECT_PATH" -type f \( -name "*.md" -o -name "*.json" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) -exec sed -i "s|{{DATE}}|$CURRENT_DATE|g" {} \;

# Step 4: Initialize Git (if not already)
if [ ! -d "$PROJECT_PATH/.git" ]; then
    echo -e "${YELLOW}🔗 Initializing Git repository...${NC}"
    cd "$PROJECT_PATH"
    git init -q
    git add .
    git commit -q -m "chore: initial project setup

Initialized $PROJECT_TYPE project with Claude Code Library boilerplate.

Includes:
- Complete .claude/ documentation (CLAUDE.md, ARCHITECTURE.md, patterns)
- Pre-configured tech stack with best practices
- Type-safe patterns and examples

🤖 Generated with Claude Code Library v$VERSION
"
    cd - > /dev/null
fi

# Step 5: Install dependencies (if applicable)
if [ "$SKIP_DEPS" = true ]; then
    echo -e "${YELLOW}📦 Skipping dependency installation (--skip-deps flag)${NC}"
else
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    cd "$PROJECT_PATH"

    case $PROJECT_TYPE in
        webapp|website|game-2d)
            if command -v pnpm &> /dev/null; then
                echo "Using pnpm..."
                pnpm install --silent
            elif command -v npm &> /dev/null; then
                echo "Using npm..."
                npm install --silent --no-progress
            else
                echo -e "${RED}⚠️  No package manager found (npm/pnpm)${NC}"
                echo "Please install dependencies manually: npm install"
            fi
            ;;
        python-cli|python-api)
            if command -v poetry &> /dev/null; then
                echo "Using Poetry..."
                poetry install
            else
                echo -e "${RED}⚠️  Poetry not found${NC}"
                echo "Please install Poetry: curl -sSL https://install.python-poetry.org | python3 -"
            fi
            ;;
    esac

    cd - > /dev/null
fi

# Step 6: Run initial validation (if validate-structure.sh exists)
if [ -f "$SCRIPT_DIR/validate-structure.sh" ]; then
    echo -e "${YELLOW}✅ Validating structure...${NC}"
    "$SCRIPT_DIR/validate-structure.sh" "$PROJECT_PATH" || true
else
    echo -e "${YELLOW}⚠️  validate-structure.sh not found, skipping validation${NC}"
fi

# Success!
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Project initialized successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. ${YELLOW}cd $PROJECT_NAME${NC}"
echo -e "  2. ${YELLOW}Review .claude/CLAUDE.md${NC} and customize for your project"
echo -e "  3. ${YELLOW}Run morning-setup.sh${NC} to load context (or it will run automatically on cd)"
echo -e "  4. ${YELLOW}Start development!${NC}"
echo ""
echo -e "${BLUE}Quick commands:${NC}"

case $PROJECT_TYPE in
    webapp)
        echo "  - Dev server: ${YELLOW}npm run dev${NC}"
        echo "  - Database setup: ${YELLOW}npx prisma migrate dev${NC}"
        echo "  - Tests: ${YELLOW}npm test${NC}"
        ;;
    website)
        echo "  - Dev server: ${YELLOW}npm run dev${NC}"
        echo "  - Build: ${YELLOW}npm run build${NC}"
        ;;
    game-2d)
        echo "  - Dev server: ${YELLOW}npm run dev${NC}"
        echo "  - Build: ${YELLOW}npm run build${NC}"
        ;;
    python-cli|python-api)
        echo "  - Run: ${YELLOW}poetry run python src/main.py${NC}"
        echo "  - Tests: ${YELLOW}poetry run pytest${NC}"
        ;;
esac

echo ""
echo -e "${BLUE}📚 Documentation:${NC} .claude/docs/"
echo -e "${BLUE}🔧 Patterns:${NC} .claude/docs/patterns/CODE_PATTERNS.md"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
