# {{PROJECT_NAME}} - Astro 5.0 Static Site

**Tech Stack:** Astro 5.0, TypeScript, Tailwind CSS, Content Collections, Markdown/MDX

---

## **CRITICAL RULES - READ FIRST!** 🚨

### 1. **ALWAYS Discovery Before Action** 🔴

BEFORE any code change:

```bash
# Step 1: Find files
fd "pattern" src/

# Step 2: Search content
rg "search-term" src/

# Step 3: Understand structure (use Serena)
mcp__serena__get_symbols_overview("src/components/Feature.astro")
```

**WHY:** Prevents breaking existing code, saves 70% tokens vs reading full files.

### 2. **Use Astro Islands for Interactivity** 🔴

NEVER: Import React/Vue components without `client:` directive
ALWAYS: Use `client:load`, `client:visible`, or `client:idle`

```astro
<!-- ✅ GOOD: Explicit hydration strategy -->
<Counter client:load />
<Gallery client:visible />
<Newsletter client:idle />

<!-- ❌ BAD: No client directive (won't be interactive) -->
<Counter />
```

**WHY:** Astro ships zero JavaScript by default. Client directives enable partial hydration.

### 3. **Content Collections for Content** 🔴

NEVER: Store blog posts/docs as regular .astro files
ALWAYS: Use Content Collections in `src/content/`

```typescript
// src/content/config.ts
import { defineCollection, z } from 'astro:content'

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    publishDate: z.date(),
  })
})

export const collections = { blog }
```

**WHY:** Type-safe content, automatic frontmatter validation, better DX.

### 4. **Use Context7 for Libraries** 🔴

When working with external libraries (Astro, React, Vue, etc.):

```bash
# Ask about Astro features
"How does Astro view transitions work? use context7"

# Ask about integrations
"How to set up Astro with React? use context7"
```

**WHY:** Always get up-to-date library documentation, zero hallucinations.

### 5. **Static by Default, Hybrid When Needed** 🔴

NEVER: Use `output: 'server'` without reason
ALWAYS: Start with `output: 'static'`, opt-in to SSR per route

```typescript
// astro.config.mjs
export default defineConfig({
  output: 'hybrid', // or 'static'
  adapter: vercel(), // only if using SSR
})
```

```astro
---
// Opt-in to SSR per route
export const prerender = false // This route uses SSR
---
```

**WHY:** Static sites are faster, cheaper, more secure. Use SSR only when needed.

---

## Project Overview

{{PROJECT_NAME}} is a static site built with Astro 5.0, focusing on performance and developer experience.

### Key Features
- ⚡ **Zero JavaScript by default** - Astro Islands for partial hydration
- 📝 **Content Collections** - Type-safe content management
- 🎨 **Tailwind CSS** - Utility-first styling
- 🔍 **SEO Optimized** - Meta tags, sitemaps, RSS feeds
- 📱 **Responsive** - Mobile-first design
- 🚀 **Fast** - 100/100 Lighthouse scores

---

## Directory Structure

```
src/
├── components/       # Reusable Astro components
│   ├── Header.astro
│   ├── Footer.astro
│   └── Card.astro
├── layouts/          # Page layouts
│   ├── BaseLayout.astro
│   └── BlogLayout.astro
├── pages/            # File-based routing
│   ├── index.astro   # Homepage (/)
│   ├── about.astro   # About page (/about)
│   └── blog/
│       ├── index.astro        # Blog list (/blog)
│       └── [...slug].astro    # Blog posts (/blog/*)
├── content/          # Content Collections
│   ├── config.ts     # Collection schemas
│   ├── blog/         # Blog posts (.md or .mdx)
│   └── docs/         # Documentation (.md)
└── styles/
    └── global.css    # Global styles

public/               # Static assets
├── favicon.svg
└── images/

.claude/              # Claude Code documentation
├── CLAUDE.md         # This file
├── docs/
│   ├── ARCHITECTURE.md
│   ├── TODO.md
│   ├── HANDOFF.md
│   └── patterns/
│       ├── CODE_PATTERNS.md
│       └── BUGS_FIXED.md
```

---

## Development Workflow

### Discovery Phase (ALWAYS FIRST)
```bash
# 1. Find relevant files
fd "BlogPost" src/

# 2. Search for patterns
rg "getCollection" src/

# 3. Get file overview (use Serena)
mcp__serena__get_symbols_overview("src/pages/blog/[...slug].astro")
```

### Development Commands
```bash
# Development server
npm run dev          # http://localhost:4321

# Build for production
npm run build        # Output: dist/

# Preview production build
npm run preview

# Type checking
npm run check        # Astro check + TypeScript
```

### Adding New Content
```bash
# 1. Create markdown file in content collection
touch src/content/blog/my-new-post.md

# 2. Add frontmatter (validated by schema)
---
title: "My New Post"
description: "Post description"
publishDate: 2025-11-05
tags: ["astro", "web"]
---

# 3. Content automatically available via getCollection()
```

---

## Code Patterns

### Pattern 1: Content Collection Page
```astro
---
// src/pages/blog/[...slug].astro
import { getCollection } from 'astro:content'
import BlogLayout from '@/layouts/BlogLayout.astro'

// Get all blog posts
export async function getStaticPaths() {
  const posts = await getCollection('blog')
  return posts.map((post) => ({
    params: { slug: post.slug },
    props: { post },
  }))
}

const { post } = Astro.props
const { Content } = await post.render()
---

<BlogLayout title={post.data.title}>
  <article>
    <h1>{post.data.title}</h1>
    <time>{post.data.publishDate.toLocaleDateString()}</time>
    <Content />
  </article>
</BlogLayout>
```

### Pattern 2: Interactive Island
```astro
---
// src/components/Counter.tsx (React component)
import { useState } from 'react'

export default function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(count + 1)}>Count: {count}</button>
}
---

<!-- src/pages/demo.astro -->
---
import Counter from '@/components/Counter'
---

<html>
  <body>
    <!-- Only this component ships JavaScript -->
    <Counter client:load />
  </body>
</html>
```

### Pattern 3: Type-Safe API Route (SSR)
```typescript
// src/pages/api/contact.ts
import type { APIRoute } from 'astro'
import { z } from 'zod'

const contactSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  message: z.string().min(10),
})

export const POST: APIRoute = async ({ request }) => {
  const body = await request.json()
  const validated = contactSchema.safeParse(body)

  if (!validated.success) {
    return new Response(JSON.stringify({ error: validated.error }), {
      status: 400,
    })
  }

  // Process contact form...
  return new Response(JSON.stringify({ success: true }))
}
```

---

## SEO & Performance

### Meta Tags (in layouts)
```astro
---
// src/layouts/BaseLayout.astro
interface Props {
  title: string
  description: string
}

const { title, description } = Astro.props
---

<head>
  <title>{title}</title>
  <meta name="description" content={description} />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <link rel="sitemap" href="/sitemap-index.xml" />
</head>
```

### Image Optimization
```astro
---
import { Image } from 'astro:assets'
import heroImage from '@/assets/hero.jpg'
---

<!-- ✅ GOOD: Optimized with Astro Image -->
<Image src={heroImage} alt="Hero" width={800} height={600} />

<!-- ❌ BAD: Unoptimized -->
<img src="/images/hero.jpg" alt="Hero" />
```

---

## Anti-Patterns to Avoid

### AP1: No Discovery Before Changes
❌ **DON'T:** Edit files without understanding structure
✅ **DO:** Use fd, rg, Serena to explore first

### AP2: Client-Side Everything
❌ **DON'T:** Add `client:load` to all components
✅ **DO:** Use Astro components, add client directives only when needed

### AP3: Content Outside Collections
❌ **DON'T:** Store blog posts as .astro files in pages/
✅ **DO:** Use Content Collections in src/content/

### AP4: No Type Safety
❌ **DON'T:** Skip Content Collection schemas
✅ **DO:** Define Zod schemas for all content types

### AP5: Unoptimized Images
❌ **DON'T:** Use <img> tags with public/ images
✅ **DO:** Use Astro's <Image> component

---

## Testing & Quality

### Type Checking
```bash
# Run Astro check (includes TypeScript)
npm run check

# TypeScript only
npx tsc --noEmit
```

### Link Checking
```bash
# Check for broken links (production build)
npm run build
# Use link checker tool on dist/
```

### Lighthouse Scores
```bash
# Build and preview
npm run build && npm run preview

# Run Lighthouse (Chrome DevTools)
# Target: 100/100 on all metrics
```

---

## Deployment

### Static Hosting (Vercel, Netlify, Cloudflare)
```bash
# Build command
npm run build

# Output directory
dist/

# Automatic deploys on git push
```

### Environment Variables
```bash
# .env (local only, gitignored)
PUBLIC_SITE_URL=https://example.com
SECRET_API_KEY=secret123

# Access in code
import.meta.env.PUBLIC_SITE_URL  # Available client-side
import.meta.env.SECRET_API_KEY    # Server-side only
```

---

## Resources

- [Astro Docs](https://docs.astro.build) - Official documentation
- [Content Collections](https://docs.astro.build/en/guides/content-collections/) - Type-safe content
- [Astro Islands](https://docs.astro.build/en/concepts/islands/) - Partial hydration
- [Integrations](https://astro.build/integrations/) - React, Vue, Svelte, etc.

---

**Last Updated:** {{DATE}}
**Astro Version:** 5.0+
**Node Version:** 18.17+ or 20.3+
