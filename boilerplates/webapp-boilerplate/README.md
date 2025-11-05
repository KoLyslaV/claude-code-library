# {{PROJECT_NAME}}

A modern full-stack web application built with Next.js 15, React 19, and the latest web technologies.

## Tech Stack

- **Framework**: Next.js 15 with App Router
- **UI**: React 19 with Server Components
- **Styling**: Tailwind CSS 4.0
- **Database**: Prisma ORM (configurable)
- **Authentication**: NextAuth v5
- **Forms**: React Hook Form + Zod validation
- **TypeScript**: Full type safety

## Quick Start

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your database and auth credentials

# Set up database
npx prisma generate
npx prisma db push

# Run development server
npm run dev
```

Visit [http://localhost:3000](http://localhost:3000)

## Project Structure

```
{{PROJECT_NAME}}/
├── src/
│   ├── app/              # Next.js App Router pages
│   │   ├── (auth)/       # Authentication routes
│   │   ├── dashboard/    # Protected dashboard
│   │   └── api/          # API routes
│   ├── components/       # React components
│   │   ├── ui/           # Reusable UI components
│   │   └── forms/        # Form components
│   ├── lib/              # Utilities and configurations
│   │   ├── prisma.ts     # Prisma client
│   │   └── utils.ts      # Helper functions
│   └── styles/           # Global styles
├── prisma/
│   └── schema.prisma     # Database schema
├── public/               # Static assets
└── .claude/              # Claude Code configuration
```

## Available Scripts

```bash
npm run dev       # Start development server
npm run build     # Build for production
npm run start     # Start production server
npm run lint      # Lint code with ESLint
npm run type-check # Check TypeScript types
```

## Features

- 🔐 Authentication with NextAuth v5
- 🎨 Modern UI with Tailwind CSS 4.0
- 📱 Fully responsive design
- ⚡ Server Components for better performance
- 🔄 Server Actions for mutations
- 🛡️ Type-safe API with TypeScript
- 📊 Database integration with Prisma
- 🎯 Form validation with Zod

## Environment Variables

Create a `.env` file based on `.env.example`:

```env
# Database
DATABASE_URL="postgresql://..."

# NextAuth
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="your-secret-here"

# OAuth Providers (optional)
GITHUB_ID=""
GITHUB_SECRET=""
```

## Database Setup

```bash
# Generate Prisma Client
npx prisma generate

# Push schema to database
npx prisma db push

# Open Prisma Studio
npx prisma studio
```

## Deployment

### Vercel (Recommended)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

### Docker

```bash
# Build image
docker build -t {{PROJECT_NAME}} .

# Run container
docker run -p 3000:3000 {{PROJECT_NAME}}
```

## Development Workflow

1. **Feature Development**
   - Create new components in `src/components/`
   - Add pages in `src/app/`
   - Use Server Actions for data mutations

2. **Database Changes**
   - Update `prisma/schema.prisma`
   - Run `npx prisma db push`
   - Regenerate client: `npx prisma generate`

3. **Testing**
   - Write tests for components and utilities
   - Run tests with your preferred test runner

## Best Practices

- Use Server Components by default
- Add `"use client"` only when needed
- Keep Server Actions in separate files
- Use TypeScript for type safety
- Follow the established folder structure
- Use Prisma for database operations

## Learn More

- [Next.js Documentation](https://nextjs.org/docs)
- [React Documentation](https://react.dev)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Prisma Documentation](https://www.prisma.io/docs)
- [NextAuth Documentation](https://authjs.dev)

## License

MIT
