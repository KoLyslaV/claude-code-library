# {{PROJECT_NAME}} - Next.js 15 Web App

**Tech Stack:** Next.js 15 (App Router) | React 19 | TypeScript | Tailwind CSS | Prisma | NextAuth v5

**Created:** {{DATE}}
**Last Updated:** {{DATE}}

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
mcp__serena__get_symbols_overview("src/components/FeatureX.tsx")
mcp__serena__find_symbol("/ComponentName", include_body=false)

# Step 4: Read specific symbols only
mcp__serena__find_symbol("/ComponentName/method", include_body=true)
```

**NEVER:**
- Read entire files (`cat`, `mcp__serena__read_file`) without checking symbols first
- Implement without understanding existing patterns
- Skip discovery phase

**Why:** 70% token savings, 10× faster navigation, avoid conflicts

---

### 2. **Server Components by Default** 🔴

NEVER: Use `"use client"` without reason
ALWAYS: Start with Server Component (RSC)

**Add `"use client"` ONLY for:**
- `useState`, `useEffect`, `useContext`, React hooks
- Event handlers (`onClick`, `onChange`, etc.)
- Browser-only APIs (`window`, `localStorage`, etc.)
- Third-party libraries requiring client (e.g., charts)

**Examples:**

```tsx
// ✅ CORRECT: Server Component (default)
// src/app/profile/page.tsx
export default async function ProfilePage({ params }: Props) {
  // Can fetch directly in Server Component!
  const user = await prisma.user.findUnique({
    where: { id: params.id }
  })

  return <ProfileCard user={user} />
}

// ✅ CORRECT: Client Component (when needed)
// src/components/features/ProfileForm.tsx
'use client'

import { useState } from 'react'

export function ProfileForm({ user }: Props) {
  const [name, setName] = useState(user.name)

  return (
    <form>
      <input
        value={name}
        onChange={(e) => setName(e.target.value)}
      />
    </form>
  )
}

// ❌ WRONG: Unnecessary "use client"
'use client'  // ← Not needed!

export function Header() {
  return <header>Static Header</header>
}
```

**Checklist:**
- [ ] Does component need state? → Client
- [ ] Does component need effects? → Client
- [ ] Does component need event handlers? → Client
- [ ] Otherwise → Server (default)

---

### 3. **Type-Safe Server Actions** 🔴

NEVER: Unvalidated form submissions
ALWAYS: Zod schema → Server Action → `useFormState`

**Pattern:**

**Step 1: Schema (`src/schemas/user.schema.ts`)**
```ts
import { z } from 'zod'

export const userUpdateSchema = z.object({
  name: z.string().min(2).max(50),
  email: z.string().email(),
  avatar: z.string().url().optional()
})

export type UserUpdate = z.infer<typeof userUpdateSchema>
```

**Step 2: Server Action (`src/lib/actions/user.actions.ts`)**
```ts
'use server'

import { userUpdateSchema } from '@/schemas/user.schema'
import { revalidatePath } from 'next/cache'

export async function updateUser(prevState: any, formData: FormData) {
  // 1. Parse
  const rawData = {
    name: formData.get('name'),
    email: formData.get('email'),
    avatar: formData.get('avatar')
  }

  // 2. Validate with Zod
  const validated = userUpdateSchema.safeParse(rawData)

  if (!validated.success) {
    return {
      error: validated.error.flatten().fieldErrors,
      message: 'Validation failed'
    }
  }

  // 3. Execute
  try {
    const user = await prisma.user.update({
      where: { id: 'current-user-id' },
      data: validated.data
    })

    // 4. Revalidate cache
    revalidatePath('/profile')

    return { success: true, message: 'Profile updated', user }
  } catch (error) {
    return { error: 'Database error', message: 'Failed to update' }
  }
}
```

**Step 3: Client Component (`src/components/features/ProfileForm.tsx`)**
```tsx
'use client'

import { useFormState } from 'react-dom'
import { updateUser } from '@/lib/actions/user.actions'

export function ProfileForm({ user }: Props) {
  const [state, formAction] = useFormState(updateUser, null)

  return (
    <form action={formAction}>
      <input name="name" defaultValue={user.name} />
      {state?.error?.name && <p className="text-red-500">{state.error.name}</p>}

      <button type="submit">Save</button>
      {state?.message && <p>{state.message}</p>}
    </form>
  )
}
```

**Checklist:**
- [ ] Zod schema defined in `src/schemas/`
- [ ] Server Action in `src/lib/actions/`
- [ ] `safeParse` for validation
- [ ] Database error handling
- [ ] `revalidatePath` after mutations
- [ ] `useFormState` in client component

---

### 4. **Use Context7 for Library APIs** 🔴

NEVER: Guess API from memory
ALWAYS: Fetch current docs with `use context7`

**Examples:**

```
User: "How does NextAuth v5 session callback work? use context7"
User: "Implement Prisma transaction, use context7"
User: "React 19 useOptimistic hook, use context7"
```

**Why:** 0% hallucinations, always up-to-date APIs

---

## File Organization 🔴

**NEVER** create files outside these directories:

| Content | Directory | Example |
|---------|-----------|---------|
| Pages | `src/app/[route]/page.tsx` | `src/app/dashboard/page.tsx` |
| Layouts | `src/app/[route]/layout.tsx` | `src/app/dashboard/layout.tsx` |
| API Routes | `src/app/api/[route]/route.ts` | `src/app/api/users/route.ts` |
| Components (UI) | `src/components/ui/` | `src/components/ui/Button.tsx` |
| Components (Features) | `src/components/features/` | `src/components/features/LoginForm.tsx` |
| Server Actions | `src/lib/actions/` | `src/lib/actions/user.actions.ts` |
| API Clients | `src/lib/api/` | `src/lib/api/users.api.ts` |
| Custom Hooks | `src/lib/hooks/` | `src/lib/hooks/useUser.ts` |
| Utils | `src/lib/utils/` | `src/lib/utils/format.ts` |
| Stores | `src/store/` | `src/store/authStore.ts` |
| Schemas | `src/schemas/` | `src/schemas/user.schema.ts` |
| Types | `src/types/` | `src/types/user.ts` |
| Tests | `tests/` | `tests/components/Button.test.tsx` |

**Details:** See `.claude/docs/ARCHITECTURE.md`

---

## Tech Stack

### Core
- **Framework:** Next.js 15.1 (App Router)
- **Language:** TypeScript 5.7
- **React:** 19.0
- **Node:** 20+

### UI
- **Styling:** Tailwind CSS 4.0
- **Components:** shadcn/ui
- **Icons:** Lucide React

### State Management
- **Global:** Zustand 5.0
- **Server:** TanStack Query 5.0
- **Forms:** React Hook Form 7.53

### Database
- **ORM:** Prisma 6.2
- **Database:** PostgreSQL 16

### Authentication
- **Library:** NextAuth v5 (Auth.js)
- **Strategy:** JWT tokens

### Validation
- **Schema:** Zod 3.23

### Testing
- **Unit:** Jest 29 + React Testing Library
- **E2E:** Playwright
- **Type:** TypeScript strict mode

---

## Development Workflow

### Feature Development (ACI Pattern)

When implementing features, use L0-L3 decomposition:

**Example: User Authentication**

```
L0: Users can sign up, log in, and access protected dashboard

L1: Core Requirements
- Registration (email/password)
- Login (session management)
- Protected routes (middleware)
- Logout

L2: Implementation Components
- LoginForm component
- RegisterForm component
- auth.ts (NextAuth config)
- middleware.ts (route protection)
- login/page.tsx, register/page.tsx
- login action, register action

──────────────── SHIP L0-L2 ────────────────

L3: Enhancements (Post-MVP)
- OAuth providers (Google, GitHub)
- Email verification
- Password reset flow
- 2FA (optional)
```

**Workflow:**
1. Define L0 (user-facing goal)
2. Break down to L1 (requirements)
3. Implement L2 (components/files)
4. **Ship MVP here** ✅
5. Iterate on L3+ (enhancements)

---

## Patterns

**All detailed patterns:** See `.claude/docs/patterns/CODE_PATTERNS.md`

### Quick Reference:

1. **Type-Safe Server Action** - Form submission with Zod validation
2. **Route Protection** - Middleware-based auth guard
3. **Error Boundaries** - Per-route error handling
4. **Loading States** - Suspense + `loading.tsx`
5. **API Route** - Type-safe endpoint with validation
6. **Custom Hook** - Reusable logic extraction
7. **Zustand Store** - Global state management
8. **TanStack Query** - Server state caching

---

## Architecture

**System overview:** See `.claude/docs/ARCHITECTURE.md`

### Key Concepts:

**App Router Structure:**
```
src/app/
├── (auth)/           ← Route group (shared layout, no URL segment)
│   ├── login/
│   │   └── page.tsx
│   └── register/
│       └── page.tsx
├── (dashboard)/      ← Protected routes
│   ├── layout.tsx    ← Dashboard layout with sidebar
│   ├── page.tsx      ← Dashboard home
│   └── profile/
│       └── page.tsx
├── api/              ← API routes
│   ├── auth/
│   │   └── [...nextauth]/
│   │       └── route.ts
│   └── users/
│       └── route.ts
├── layout.tsx        ← Root layout
└── page.tsx          ← Homepage
```

**Authentication Flow:**
1. User visits `/dashboard` (protected)
2. `middleware.ts` checks session
3. If no session → redirect to `/login`
4. After login → NextAuth creates session
5. middleware allows access to `/dashboard`

**Data Fetching:**
- **Server Components:** `await fetch()` or `await prisma.x.find()`
- **Client Components:** TanStack Query (`useQuery`, `useMutation`)

---

## Commands

### Development
```bash
npm run dev           # Start dev server (localhost:3000)
npm run build         # Production build
npm run start         # Start production server
npm run lint          # ESLint check
npm run format        # Prettier format
npm run type-check    # TypeScript check
```

### Database
```bash
npx prisma generate   # Generate Prisma Client
npx prisma db push    # Push schema changes (dev)
npx prisma migrate dev # Create migration (dev)
npx prisma studio     # Open Prisma Studio GUI
```

### Testing
```bash
npm run test          # Run Jest tests
npm run test:watch    # Jest watch mode
npm run test:e2e      # Playwright E2E tests
npm run test:coverage # Coverage report
```

---

## Current Priorities

See: `.claude/docs/TODO.md`

---

## Documentation

- **Architecture:** `.claude/docs/ARCHITECTURE.md` - System design, data flow
- **Patterns:** `.claude/docs/patterns/CODE_PATTERNS.md` - Reusable code patterns
- **Bugs Fixed:** `.claude/docs/patterns/BUGS_FIXED.md` - Bug history + prevention
- **Handoff:** `.claude/docs/HANDOFF.md` - Session context
- **TODO:** `.claude/docs/TODO.md` - Current priorities

---

## Tips

### Performance
- Use Server Components for data fetching (no waterfall requests)
- Use `<Image>` for optimized images
- Use `loading.tsx` for instant loading states
- Use route groups to reduce layout re-renders

### Security
- NEVER expose API keys in client code
- Always validate with Zod in Server Actions
- Use middleware for route protection
- Enable CSRF protection (NextAuth default)

### Best Practices
- Keep Server Components async for data fetching
- Minimize "use client" usage
- Use `revalidatePath` after mutations
- Follow type-safe patterns everywhere

---

**Version:** 1.0.0
**Framework:** Next.js 15.1
**Last Updated:** {{DATE}}
