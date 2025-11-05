# {{PROJECT_NAME}}

A modern static website built with Astro 5.0 for blazing-fast performance and excellent developer experience.

## Tech Stack

- **Framework**: Astro 5.0
- **Content**: Content Collections with type safety
- **Styling**: Tailwind CSS 4.0
- **MDX**: For interactive content
- **TypeScript**: Full type safety
- **RSS**: Auto-generated RSS feed
- **Sitemap**: Auto-generated sitemap

## Quick Start

```bash
# Install dependencies
npm install

# Run development server
npm run dev
```

Visit [http://localhost:4321](http://localhost:4321)

## Project Structure

```
{{PROJECT_NAME}}/
├── src/
│   ├── pages/            # Routes and pages
│   │   ├── index.astro   # Homepage
│   │   ├── blog/         # Blog pages
│   │   └── [...slug].astro # Dynamic routes
│   ├── layouts/          # Layout components
│   │   └── BaseLayout.astro
│   ├── components/       # Reusable components
│   │   ├── Header.astro
│   │   ├── Footer.astro
│   │   └── BlogCard.astro
│   ├── content/          # Content Collections
│   │   ├── config.ts     # Collection schemas
│   │   └── blog/         # Blog posts (MDX)
│   └── styles/           # Global styles
├── public/               # Static assets
└── .claude/              # Claude Code configuration
```

## Available Scripts

```bash
npm run dev       # Start development server
npm run build     # Build for production
npm run preview   # Preview production build
npm run astro     # Run Astro CLI commands
```

## Features

- ⚡ Lightning-fast static site generation
- 📝 Type-safe Content Collections
- 🎨 Modern UI with Tailwind CSS 4.0
- 📱 Fully responsive design
- 🔍 SEO optimized
- 📰 Auto-generated RSS feed
- 🗺️ Auto-generated sitemap
- 🎯 MDX support for interactive content
- 🌐 Multiple layout support

## Content Management

### Adding Blog Posts

Create a new `.md` or `.mdx` file in `src/content/blog/`:

```markdown
---
title: "My Blog Post"
description: "A short description"
publishDate: 2025-01-15
author: "Your Name"
tags: ["astro", "web-development"]
---

# Your Content Here

Write your blog post content using Markdown or MDX.
```

### Content Collections

All content is managed through Astro's Content Collections for type safety:

```typescript
import { getCollection } from 'astro:content';

// Get all blog posts
const posts = await getCollection('blog');

// Get a specific post
const post = await getEntry('blog', 'my-post');
```

## Styling

Tailwind CSS 4.0 is pre-configured. Use utility classes in your components:

```astro
<div class="container mx-auto px-4">
  <h1 class="text-4xl font-bold text-gray-900">
    Welcome
  </h1>
</div>
```

## Deployment

### Vercel (Recommended)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

### Netlify

```bash
# Install Netlify CLI
npm i -g netlify-cli

# Deploy
netlify deploy --prod
```

### Static Hosting

```bash
# Build static site
npm run build

# Upload dist/ folder to your hosting provider
```

## Configuration

### SEO Settings

Edit `astro.config.mjs` to configure site settings:

```javascript
export default defineConfig({
  site: 'https://your-domain.com',
  // ... other options
});
```

### RSS Feed

RSS feed is automatically generated at `/rss.xml` from your blog posts.

### Sitemap

Sitemap is automatically generated at `/sitemap.xml` for all pages.

## Development Workflow

1. **Adding Content**
   - Create new posts in `src/content/blog/`
   - Follow the frontmatter schema
   - Use MDX for interactive content

2. **Styling**
   - Use Tailwind utility classes
   - Add custom styles in `src/styles/global.css`

3. **Components**
   - Create reusable components in `src/components/`
   - Use TypeScript for type safety
   - Follow Astro component conventions

## Best Practices

- Use Content Collections for all content
- Leverage Astro's partial hydration
- Keep components simple and reusable
- Optimize images with Astro's built-in optimizer
- Use semantic HTML
- Follow accessibility guidelines

## Performance

Astro generates static HTML by default, resulting in:
- ⚡ Near-instant page loads
- 🎯 Perfect Lighthouse scores
- 📦 Minimal JavaScript shipped
- 🚀 Excellent SEO

## Learn More

- [Astro Documentation](https://docs.astro.build)
- [Content Collections Guide](https://docs.astro.build/en/guides/content-collections/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [MDX Documentation](https://mdxjs.com/)

## License

MIT
