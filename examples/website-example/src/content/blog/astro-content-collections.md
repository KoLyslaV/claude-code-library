---
title: "Mastering Astro Content Collections"
description: "A comprehensive guide to using Astro's Content Collections API for type-safe, organized content management"
publishDate: 2025-01-10
author: "Tech Blog"
tags: ["astro", "content-collections", "typescript", "web-development"]
image: "/images/astro-collections.jpg"
---

# Mastering Astro Content Collections

Astro's Content Collections provide a powerful, type-safe way to manage your content. Whether you're building a blog, documentation site, or any content-driven website, Content Collections make it easy and maintainable.

## What Are Content Collections?

Content Collections are Astro's built-in solution for organizing and querying local content with full TypeScript support.

### Key Benefits

- 🔒 **Type Safety** - Full TypeScript support for frontmatter
- 📁 **Organization** - Structured content in `/src/content/`
- ⚡ **Performance** - Optimized build-time processing
- ✅ **Validation** - Automatic schema validation with Zod

## Setting Up Collections

### 1. Define Your Schema

Create a schema in `src/content/config.ts`:

```typescript
import { defineCollection, z } from 'astro:content';

const blogCollection = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    publishDate: z.date(),
    author: z.string(),
    tags: z.array(z.string()),
    image: z.string().optional(),
    draft: z.boolean().default(false),
  }),
});

export const collections = {
  'blog': blogCollection,
};
```

### 2. Add Content Files

Create Markdown files in `src/content/blog/`:

```markdown
---
title: "My First Post"
description: "Welcome to my blog"
publishDate: 2025-01-01
author: "John Doe"
tags: ["astro", "blogging"]
---

# My First Post

Content goes here...
```

### 3. Query Your Content

Use the `getCollection` API to fetch content:

```typescript
---
import { getCollection } from 'astro:content';

// Get all blog posts
const posts = await getCollection('blog');

// Filter published posts
const published = posts.filter(post => !post.data.draft);

// Sort by date
const sorted = published.sort((a, b) =>
  b.data.publishDate.valueOf() - a.data.publishDate.valueOf()
);
---

<ul>
  {sorted.map(post => (
    <li>
      <a href={`/blog/${post.slug}`}>
        {post.data.title}
      </a>
    </li>
  ))}
</ul>
```

## Advanced Patterns

### Filtering by Tag

```typescript
const webDevPosts = await getCollection('blog', ({ data }) => {
  return data.tags.includes('web-development');
});
```

### Pagination

```typescript
import { getCollection } from 'astro:content';

export async function getStaticPaths({ paginate }) {
  const posts = await getCollection('blog');
  return paginate(posts, { pageSize: 10 });
}

const { page } = Astro.props;
```

### Related Posts

```typescript
function getRelatedPosts(currentPost, allPosts) {
  return allPosts
    .filter(post => post.slug !== currentPost.slug)
    .filter(post => {
      // Find posts with similar tags
      return post.data.tags.some(tag =>
        currentPost.data.tags.includes(tag)
      );
    })
    .slice(0, 3);
}
```

## Multiple Collections

You can have multiple collections for different content types:

```typescript
const blogCollection = defineCollection({ /* ... */ });
const docsCollection = defineCollection({ /* ... */ });
const authorsCollection = defineCollection({ /* ... */ });

export const collections = {
  'blog': blogCollection,
  'docs': docsCollection,
  'authors': authorsCollection,
};
```

## Dynamic Routes

Create dynamic routes for individual posts:

```typescript
// src/pages/blog/[...slug].astro
---
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const posts = await getCollection('blog');
  return posts.map(post => ({
    params: { slug: post.slug },
    props: { post },
  }));
}

const { post } = Astro.props;
const { Content } = await post.render();
---

<article>
  <h1>{post.data.title}</h1>
  <Content />
</article>
```

## MDX Support

Content Collections work seamlessly with MDX:

```mdx
---
title: "Interactive Post"
---

import { Chart } from '../components/Chart.astro';

# Interactive Content

<Chart data={myData} />

Regular markdown content works too!
```

## Best Practices

### 1. Use Descriptive Slugs

```markdown
good-example-slug.md
2025-01-15-another-great-post.md
```

### 2. Consistent Frontmatter

Always include required fields:

```yaml
---
title: "Required"
description: "Required"
publishDate: 2025-01-01
author: "Required"
tags: ["required"]
---
```

### 3. Image Optimization

Use Astro's Image component:

```astro
---
import { Image } from 'astro:assets';
import heroImage from '../images/hero.jpg';
---

<Image src={heroImage} alt="Hero" />
```

### 4. Draft Workflow

Use the `draft` field for work-in-progress content:

```typescript
const published = await getCollection('blog', ({ data }) => {
  return import.meta.env.PROD ? !data.draft : true;
});
```

## Performance Tips

- Content is processed at build time (zero runtime cost)
- Astro automatically generates types for your collections
- Use `getEntry` for single posts (faster than `getCollection`)
- Lazy load heavy content with dynamic imports

## Conclusion

Content Collections are one of Astro's killer features. They provide the structure and type safety of a CMS while maintaining the simplicity of local Markdown files.

Start using Content Collections today and experience the joy of organized, type-safe content management!

## Resources

- [Astro Content Collections Docs](https://docs.astro.build/en/guides/content-collections/)
- [Zod Schema Validation](https://zod.dev)
- [MDX in Astro](https://docs.astro.build/en/guides/markdown-content/)
