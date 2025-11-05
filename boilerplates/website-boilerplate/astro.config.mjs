import { defineConfig } from 'astro/config'
import mdx from '@astrojs/mdx'
import sitemap from '@astrojs/sitemap'
import tailwind from '@astrojs/tailwind'

// https://astro.build/config
export default defineConfig({
  site: 'https://example.com', // Replace with your domain
  integrations: [
    mdx(),
    sitemap(),
    tailwind({
      applyBaseStyles: false, // Use custom base styles
    }),
  ],
  output: 'static', // 'static' | 'hybrid' | 'server'
  markdown: {
    shikiConfig: {
      theme: 'github-dark',
      wrap: true,
    },
  },
})
