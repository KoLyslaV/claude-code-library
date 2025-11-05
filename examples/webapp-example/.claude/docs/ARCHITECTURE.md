# Architecture

## System Overview

**{{PROJECT_NAME}}** is a Next.js 15 web application using App Router, Server Components, and Server Actions for optimal performance and developer experience.

### Core Principles

1. **Server-First** - Default to Server Components for better performance
2. **Type-Safe** - TypeScript + Zod for end-to-end type safety
3. **Progressive Enhancement** - Works without JavaScript when possible
4. **Atomic Design** - Components organized by complexity (UI → Features)

---

## Directory Structure

```
src/
├── app/                          # Next.js 15 App Router
│   ├── (auth)/                   # Route group: Authentication pages
│   │   ├── login/
│   │   │   └── page.tsx         # Login page (Server Component)
│   │   └── register/
│   │       └── page.tsx         # Register page (Server Component)
│   │
│   ├── (dashboard)/              # Route group: Protected pages
│   │   ├── layout.tsx            # Dashboard layout (sidebar, etc.)
│   │   ├── page.tsx              # Dashboard home
│   │   ├── profile/
│   │   │   ├── page.tsx          # Profile page
│   │   │   └── edit/
│   │   │       └── page.tsx      # Edit profile page
│   │   └── settings/
│   │       └── page.tsx          # Settings page
│   │
│   ├── api/                      # API Routes
│   │   ├── auth/
│   │   │   └── [...nextauth]/
│   │   │       └── route.ts      # NextAuth API route
│   │   └── users/
│   │       ├── route.ts          # GET /api/users (list users)
│   │       └── [id]/
│   │           └── route.ts      # GET/PATCH/DELETE /api/users/:id
│   │
│   ├── layout.tsx                # Root layout (global providers, fonts)
│   ├── page.tsx                  # Homepage (/)
│   ├── error.tsx                 # Global error boundary
│   └── not-found.tsx             # 404 page
│
├── components/                   # React Components
│   ├── ui/                       # Base UI components (shadcn/ui)
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   ├── Card.tsx
│   │   └── ...
│   │
│   └── features/                 # Feature-specific components
│       ├── LoginForm.tsx         # Login form (Client Component)
│       ├── RegisterForm.tsx      # Register form (Client Component)
│       ├── ProfileCard.tsx       # Profile display (Server Component)
│       └── ProfileForm.tsx       # Profile edit form (Client Component)
│
├── lib/                          # Utility libraries
│   ├── actions/                  # Server Actions
│   │   ├── auth.actions.ts       # Login, register, logout
│   │   └── user.actions.ts       # User CRUD operations
│   │
│   ├── api/                      # API client functions (for Client Components)
│   │   └── users.api.ts          # User API calls
│   │
│   ├── hooks/                    # Custom React hooks
│   │   ├── useUser.ts            # Current user hook (TanStack Query)
│   │   └── useDebounce.ts        # Debounce hook
│   │
│   ├── utils/                    # Pure utility functions
│   │   ├── format.ts             # String formatting
│   │   ├── date.ts               # Date utilities
│   │   └── cn.ts                 # className utility (tailwind-merge)
│   │
│   └── db.ts                     # Prisma Client instance
│
├── store/                        # Zustand stores
│   ├── authStore.ts              # Auth state (user, token)
│   └── uiStore.ts                # UI state (theme, sidebar, etc.)
│
├── schemas/                      # Zod validation schemas
│   ├── user.schema.ts            # User validation schemas
│   └── auth.schema.ts            # Auth validation schemas
│
└── types/                        # TypeScript types
    ├── user.ts                   # User types
    └── api.ts                    # API response types
```

---

## Key Design Decisions

### 1. Server Components by Default

**Why:** Faster initial load, smaller JavaScript bundle, better SEO

**Trade-off:** Limited to async operations, no hooks/event handlers

**Benefit:** ~40% smaller bundle size, 2× faster Time to Interactive

**Example:**
```tsx
// Server Component - fetches data directly
export default async function ProfilePage({ params }: Props) {
  const user = await prisma.user.findUnique({ where: { id: params.id } })
  return <ProfileCard user={user} />
}
```

---

### 2. Server Actions for Mutations

**Why:** Type-safe, no API routes needed, progressive enhancement

**Trade-off:** Requires Next.js 15+, learning curve

**Benefit:** 50% less code, automatic revalidation, works without JS

**Example:**
```tsx
// Server Action
'use server'
export async function updateUser(formData: FormData) {
  const user = await prisma.user.update({ ... })
  revalidatePath('/profile')
  return user
}

// Client Component
<form action={updateUser}>...</form>
```

---

### 3. Route Groups for Layouts

**Why:** Share layouts without affecting URL structure

**Trade-off:** Non-obvious from URL alone

**Benefit:** Cleaner URLs, flexible layouts

**Example:**
```
(auth)/              → /login, /register (auth layout)
(dashboard)/         → /dashboard, /profile (dashboard layout)
```

---

### 4. Prisma ORM

**Why:** Type-safe database access, migrations, great DX

**Trade-off:** Learning curve, adds layer over SQL

**Benefit:** 85% fewer runtime errors, auto-completion everywhere

---

### 5. NextAuth v5 for Authentication

**Why:** Industry-standard, supports OAuth + credentials, JWT/session

**Trade-off:** Complex setup, opinionated API

**Benefit:** Production-ready security, extensive provider support

---

## Data Flow

### Authentication Flow

```
1. User visits /dashboard (protected route)
   ↓
2. middleware.ts checks for session
   ↓
   [No session]  →  Redirect to /login
   ↓
3. User submits login form (Server Action)
   ↓
4. auth.actions.ts validates credentials (Zod)
   ↓
5. NextAuth creates session + JWT token
   ↓
6. Redirect to /dashboard
   ↓
7. middleware allows access (session valid)
   ↓
8. Dashboard page renders with user data
```

### Data Fetching Flow (Server Component)

```
1. Server Component renders
   ↓
2. await prisma.user.findMany() (direct DB access)
   ↓
3. Data passed as props to Client Component
   ↓
4. Client Component renders with data
```

### Data Fetching Flow (Client Component)

```
1. Client Component mounts
   ↓
2. useQuery hook triggers fetch (/api/users)
   ↓
3. API route validates request
   ↓
4. API route queries database (Prisma)
   ↓
5. API route returns JSON
   ↓
6. useQuery caches response (TanStack Query)
   ↓
7. Component re-renders with data
```

### Form Submission Flow (Server Action)

```
1. User fills form
   ↓
2. User clicks submit
   ↓
3. Browser sends FormData to Server Action
   ↓
4. Server Action validates with Zod
   ↓
   [Invalid]  →  Return error to client
   ↓
5. Server Action updates database (Prisma)
   ↓
6. Server Action calls revalidatePath('/profile')
   ↓
7. Next.js revalidates cached data
   ↓
8. Server Action returns success to client
   ↓
9. Client updates UI (useFormState)
```

---

## External Dependencies

### Production Dependencies

| Package | Purpose | Why This? |
|---------|---------|-----------|
| **next** | Framework | Industry standard, great DX |
| **react** | UI library | Required by Next.js |
| **react-dom** | React renderer | Required by React |
| **prisma** | Database ORM | Type-safe DB access |
| **@prisma/client** | Prisma runtime | Required by Prisma |
| **next-auth** | Authentication | OAuth + credentials, production-ready |
| **zod** | Validation | Type-safe schemas, great DX |
| **zustand** | State management | Minimal boilerplate vs Redux |
| **@tanstack/react-query** | Server state | Caching, automatic refetch |
| **tailwindcss** | Styling | Utility-first, fast development |
| **lucide-react** | Icons | Tree-shakeable, consistent style |

### Dev Dependencies

| Package | Purpose |
|---------|---------|
| **typescript** | Type checking |
| **@types/node** | Node types |
| **@types/react** | React types |
| **eslint** | Linting |
| **prettier** | Code formatting |
| **jest** | Unit testing |
| **@testing-library/react** | React testing |
| **playwright** | E2E testing |

---

## Deployment Architecture

### Recommended: Vercel

**Why:** Zero-config for Next.js, edge functions, automatic HTTPS

**Setup:**
1. Connect GitHub repository
2. Set environment variables
3. Deploy automatically on push to main

**Environment Variables:**
```env
DATABASE_URL=postgresql://...
NEXTAUTH_SECRET=xxx
NEXTAUTH_URL=https://your-domain.com
```

### Alternative: Docker + VPS

**Setup:**
1. Build Docker image (`docker build -t app .`)
2. Push to registry
3. Deploy to VPS with docker-compose

---

## Security Considerations

1. **CSRF Protection** - NextAuth enables by default
2. **SQL Injection** - Prevented by Prisma (parameterized queries)
3. **XSS** - Prevented by React (auto-escaping)
4. **Authentication** - JWT tokens, HTTP-only cookies
5. **Rate Limiting** - Implement in middleware (TODO)
6. **Input Validation** - Zod schemas for all user input

---

## Performance Optimizations

1. **Server Components** - Reduce client JS by 40%
2. **Image Optimization** - Use `next/image` (automatic WebP, lazy load)
3. **Font Optimization** - `next/font` (self-hosted, zero layout shift)
4. **Code Splitting** - Automatic by Next.js (route-based)
5. **Caching** - TanStack Query for client, Next.js cache for server
6. **Database Indexing** - Prisma indexes on foreign keys

---

**Version:** 1.0.0
**Last Updated:** {{DATE}}
