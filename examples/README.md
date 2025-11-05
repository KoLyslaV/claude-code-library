# Claude Code Library - Example Projects

**Version:** 1.0.0

## 📋 Overview

Example projects demonstrating each boilerplate's capabilities and best practices.

Each example includes:
- ✅ Complete project structure
- ✅ README with setup instructions
- ✅ Implementation walkthrough
- ✅ Common patterns & solutions
- ✅ Testing examples
- ✅ Deployment guide

## 📦 Available Examples

### 1. webapp-example (Task Manager)

**Boilerplate:** webapp-boilerplate (Next.js 15 + React 19)

**What it demonstrates:**
- Server Actions for mutations
- React Server Components
- Type-safe database operations with Prisma
- Authentication with NextAuth v5
- Form handling with Server Actions
- Optimistic UI updates
- Route handlers for API endpoints

**Features:**
- User authentication (email/password)
- Create, read, update, delete tasks
- Task filtering and search
- Real-time updates
- Protected routes
- Dashboard with statistics

**Directory:** `webapp-example/`

**Tech Stack:**
- Next.js 15.0
- React 19
- TypeScript 5.7
- Prisma (SQLite for demo)
- NextAuth v5
- Tailwind CSS 4.0

**Time to implement:** ~5 hours (vs ~20 hours from scratch)

---

### 2. website-example (Tech Blog)

**Boilerplate:** website-boilerplate (Astro 5.0)

**What it demonstrates:**
- Content Collections for type-safe content
- MDX for interactive content
- Static site generation
- RSS feed generation
- Sitemap generation
- SEO optimization
- Responsive design
- Dark mode toggle

**Features:**
- Blog post listing with pagination
- Individual post pages
- Tag filtering
- Search functionality
- About page
- RSS feed
- Sitemap
- Social media meta tags

**Directory:** `website-example/`

**Tech Stack:**
- Astro 5.0
- TypeScript 5.7
- MDX
- Tailwind CSS 4.0
- Content Collections

**Time to implement:** ~3 hours (vs ~15 hours from scratch)

---

### 3. python-cli-example (Todo CLI)

**Boilerplate:** python-cli-boilerplate

**What it demonstrates:**
- Click CLI framework
- Sub-commands with groups
- Type hints throughout
- pytest with fixtures
- Rich terminal output
- JSON data persistence
- Configuration management
- Poetry dependency management

**Features:**
- Add, list, complete, delete todos
- Priority levels (high, medium, low)
- Categories/tags
- Due dates
- Statistics
- Export to JSON/CSV
- Configuration file

**Directory:** `python-cli-example/`

**Tech Stack:**
- Python 3.11+
- Click 8.1+
- Rich (terminal formatting)
- Poetry
- pytest

**Time to implement:** ~4 hours (vs ~12 hours from scratch)

---

## 🚀 Using the Examples

### Quick Start

```bash
# Navigate to examples directory
cd ~/.claude-library/examples

# Choose an example
cd webapp-example
# OR
cd website-example
# OR
cd python-cli-example

# Follow the README in that directory
```

### Learning from Examples

Each example includes:

1. **README.md** - Overview, setup, usage
2. **IMPLEMENTATION.md** - Step-by-step implementation guide
3. **PATTERNS.md** - Common patterns and solutions
4. **TESTING.md** - Testing strategies and examples
5. **DEPLOYMENT.md** - Deployment instructions

### Implementing Your Own

**Step 1: Initialize from boilerplate**
```bash
claude-lib init my-project webapp
cd my-project
```

**Step 2: Review example**
```bash
# Open example for reference
code ~/.claude-library/examples/webapp-example

# Read implementation guide
cat ~/.claude-library/examples/webapp-example/IMPLEMENTATION.md
```

**Step 3: Implement features**
```bash
# Start Claude Code with loaded context
claude-lib morning
claude

# In Claude:
> "Read CLAUDE.md and TODO.md. Let's implement [feature] following the patterns from the webapp-example. use context7"
```

**Step 4: Test & deploy**
```bash
claude-lib bug-hunt --quick
claude-lib docs --quick
# Deploy following example's DEPLOYMENT.md
```

## 📚 Example Comparisons

### Complexity Levels

| Example | Lines of Code | Files | Complexity | Best For |
|---------|---------------|-------|------------|----------|
| webapp-example | ~2,000 | 25 | Medium | Learning full-stack patterns |
| website-example | ~800 | 15 | Low | Learning Astro & content |
| python-cli-example | ~1,200 | 18 | Medium | Learning CLI patterns |

### Feature Matrix

| Feature | webapp-example | website-example | python-cli-example |
|---------|----------------|-----------------|-------------------|
| Authentication | ✅ NextAuth | ❌ | ❌ |
| Database | ✅ Prisma | ❌ | ✅ JSON files |
| API Endpoints | ✅ Route handlers | ❌ | ❌ |
| Server Actions | ✅ Forms & mutations | ❌ | ❌ |
| Content Collections | ❌ | ✅ Blog posts | ❌ |
| MDX | ❌ | ✅ Interactive content | ❌ |
| CLI Interface | ❌ | ❌ | ✅ Click framework |
| Testing | ✅ Jest/Vitest | ✅ Vitest | ✅ pytest |
| Type Safety | ✅ TypeScript | ✅ TypeScript | ✅ Type hints |

## 🎓 Learning Path

### For Beginners

1. **Start with:** website-example (simplest)
2. **Then:** python-cli-example (medium complexity)
3. **Finally:** webapp-example (most complex)

### For Intermediate

1. **Start with:** webapp-example (most features)
2. **Use patterns from:** All examples
3. **Build:** Your own project combining patterns

### For Advanced

1. **Review:** All examples for best practices
2. **Customize:** Extend examples with new features
3. **Contribute:** Submit improved examples

## 💡 Common Patterns

### Pattern 1: Discovery Before Action

**All examples follow:**
```bash
# 1. Find relevant files
fd "auth" src/

# 2. Search for implementations
rg "authentication" src/

# 3. Explore with Serena
mcp__serena__get_symbols_overview("src/auth.ts")
mcp__serena__find_symbol("/AuthProvider")
```

### Pattern 2: Implementation Levels (L0-L2)

**webapp-example authentication:**
- L0: Users can sign up/login, access protected pages
- L1: Email verification, password reset, session management
- L2: OAuth providers, 2FA, rate limiting

**website-example blog:**
- L0: List posts, view individual posts
- L1: Tags, search, pagination, RSS
- L2: Related posts, reading time, comments

**python-cli-example:**
- L0: Add, list, complete todos
- L1: Priorities, categories, due dates
- L2: Recurring tasks, reminders, sync

### Pattern 3: Use Context7

**All examples use Context7 for library docs:**

```
# webapp-example
"How does NextAuth v5 session callback work? use context7"

# website-example
"How do Astro Content Collections work? use context7"

# python-cli-example
"How does Click's group decorator work? use context7"
```

## 🔄 Example Workflows

### Workflow 1: Implement Feature from Example

```bash
# 1. Study example
cd ~/.claude-library/examples/webapp-example
cat IMPLEMENTATION.md | grep -A 20 "## Authentication"

# 2. Initialize your project
cd ~/projects
claude-lib init my-app webapp
cd my-app

# 3. Start Claude with context
claude-lib morning
claude

# 4. Implement with guidance
> "Read CLAUDE.md. Implement authentication following webapp-example patterns. use context7"
```

### Workflow 2: Debug with Example

```bash
# 1. Find similar code in example
cd ~/.claude-library/examples/webapp-example
rg "useOptimistic" src/

# 2. Compare with your code
cd ~/projects/my-app
rg "useOptimistic" src/

# 3. Use Claude to debug
> "Compare my useOptimistic usage with webapp-example at ~/.claude-library/examples/webapp-example/src/components/TaskList.tsx"
```

### Workflow 3: Extend Example

```bash
# 1. Copy example as starting point
claude-lib init my-project webapp
cd my-project

# 2. Copy relevant code from example
cp ~/.claude-library/examples/webapp-example/src/app/auth/* src/app/auth/

# 3. Customize and extend
claude

> "Review copied auth code. Adapt it to use [your requirements]. use context7"
```

## 📈 Success Metrics

### Time Savings

| Task | From Scratch | With Example | Savings |
|------|--------------|--------------|---------|
| Authentication | 4 hours | 30 min | 88% |
| CRUD operations | 6 hours | 1 hour | 83% |
| Testing setup | 3 hours | 30 min | 83% |
| Deployment | 2 hours | 20 min | 83% |

### Learning Curve

| Concept | Without Example | With Example | Improvement |
|---------|-----------------|--------------|-------------|
| Server Actions | 2 days | 4 hours | 75% |
| Content Collections | 1 day | 2 hours | 75% |
| Click CLI | 1 day | 3 hours | 70% |

## 🤝 Contributing Examples

Want to add an example? Follow these steps:

1. **Create example directory**
   ```bash
   mkdir ~/.claude-library/examples/my-example
   ```

2. **Required files**
   - README.md (overview, setup, usage)
   - IMPLEMENTATION.md (step-by-step guide)
   - PATTERNS.md (common patterns)
   - TESTING.md (testing strategies)
   - DEPLOYMENT.md (deployment guide)

3. **Submit PR**
   - Follow existing example structure
   - Include all required documentation
   - Test thoroughly

## 🐛 Troubleshooting

### Example won't run

**Check dependencies:**
```bash
cd webapp-example
npm install
# OR
cd python-cli-example
poetry install
```

### Code doesn't match boilerplate

**Examples may be ahead of boilerplates.**
```bash
# Check example version
cat webapp-example/package.json | grep version

# Check boilerplate version
cat ../boilerplates/webapp-boilerplate/package.json | grep version
```

### Can't find specific pattern

**Search across all examples:**
```bash
cd ~/.claude-library/examples
rg "pattern-name"
```

## 📞 Support

- **Questions:** GitHub Discussions
- **Bugs:** GitHub Issues
- **Examples:** Submit PR with your example

---

**Last Updated:** 2025-11-05
**Version:** 1.0.0
**Total Examples:** 3
