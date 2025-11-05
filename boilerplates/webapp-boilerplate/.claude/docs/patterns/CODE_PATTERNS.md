# Code Patterns

Reusable patterns specific to this Next.js 15 project.

**Usage:** Copy-paste and adapt for your use case.

---

## Pattern 1: Type-Safe Server Action

**Problem:** Form submissions without type safety lead to runtime errors

**Pattern:** Zod schema + Server Action + useFormState

### Implementation

**Step 1: Define Schema (`src/schemas/user.schema.ts`)**
```ts
import { z } from 'zod'

export const userUpdateSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters').max(50),
  email: z.string().email('Invalid email address'),
  bio: z.string().max(500).optional(),
  avatar: z.string().url('Invalid URL').optional()
})

export type UserUpdate = z.infer<typeof userUpdateSchema>
```

**Step 2: Create Server Action (`src/lib/actions/user.actions.ts`)**
```ts
'use server'

import { revalidatePath } from 'next/cache'
import { userUpdateSchema } from '@/schemas/user.schema'
import { prisma } from '@/lib/db'

export async function updateUser(prevState: any, formData: FormData) {
  // 1. Parse form data
  const rawData = {
    name: formData.get('name'),
    email: formData.get('email'),
    bio: formData.get('bio'),
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

  // 3. Update database
  try {
    const user = await prisma.user.update({
      where: { id: 'current-user-id' }, // TODO: Get from session
      data: validated.data
    })

    // 4. Revalidate cache
    revalidatePath('/profile')

    return {
      success: true,
      message: 'Profile updated successfully',
      user
    }
  } catch (error) {
    console.error('Update user error:', error)
    return {
      error: 'Database error',
      message: 'Failed to update profile. Please try again.'
    }
  }
}
```

**Step 3: Use in Client Component (`src/components/features/ProfileForm.tsx`)**
```tsx
'use client'

import { useFormState } from 'react-dom'
import { updateUser } from '@/lib/actions/user.actions'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'

interface ProfileFormProps {
  user: {
    name: string
    email: string
    bio?: string
    avatar?: string
  }
}

export function ProfileForm({ user }: ProfileFormProps) {
  const [state, formAction] = useFormState(updateUser, null)

  return (
    <form action={formAction} className="space-y-4">
      <div>
        <label htmlFor="name" className="block text-sm font-medium">
          Name
        </label>
        <Input
          id="name"
          name="name"
          defaultValue={user.name}
          aria-describedby={state?.error?.name ? 'name-error' : undefined}
        />
        {state?.error?.name && (
          <p id="name-error" className="text-red-500 text-sm mt-1">
            {state.error.name}
          </p>
        )}
      </div>

      <div>
        <label htmlFor="email" className="block text-sm font-medium">
          Email
        </label>
        <Input
          id="email"
          name="email"
          type="email"
          defaultValue={user.email}
          aria-describedby={state?.error?.email ? 'email-error' : undefined}
        />
        {state?.error?.email && (
          <p id="email-error" className="text-red-500 text-sm mt-1">
            {state.error.email}
          </p>
        )}
      </div>

      <Button type="submit">
        Save Changes
      </Button>

      {state?.message && (
        <p className={state.success ? 'text-green-600' : 'text-red-600'}>
          {state.message}
        </p>
      )}
    </form>
  )
}
```

**Checklist:**
- [ ] Zod schema defined in `src/schemas/`
- [ ] `safeParse` used for validation
- [ ] Server Action returns error structure
- [ ] Database error handling implemented
- [ ] `revalidatePath` called after mutations
- [ ] `useFormState` used in client component
- [ ] Error messages displayed to user
- [ ] Accessibility (aria-describedby for errors)

---

## Pattern 2: Protected Route with Middleware

**Problem:** Need to protect entire route groups from unauthenticated access

**Pattern:** Next.js middleware + NextAuth session check

### Implementation

**Step 1: Configure NextAuth (`src/auth.ts`)**
```ts
import NextAuth from 'next-auth'
import CredentialsProvider from 'next-auth/providers/credentials'
import { PrismaAdapter } from '@auth/prisma-adapter'
import { prisma } from '@/lib/db'
import bcrypt from 'bcryptjs'

export const { handlers, auth, signIn, signOut } = NextAuth({
  adapter: PrismaAdapter(prisma),
  session: { strategy: 'jwt' },
  providers: [
    CredentialsProvider({
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' }
      },
      async authorize(credentials) {
        const user = await prisma.user.findUnique({
          where: { email: credentials.email as string }
        })

        if (!user) return null

        const isValid = await bcrypt.compare(
          credentials.password as string,
          user.password
        )

        if (!isValid) return null

        return { id: user.id, email: user.email, name: user.name }
      }
    })
  ]
})
```

**Step 2: Create Middleware (`src/middleware.ts`)**
```ts
export { auth as middleware } from '@/auth'

export const config = {
  // Protect all routes under /dashboard
  matcher: ['/dashboard/:path*', '/profile/:path*', '/settings/:path*']
}
```

**Step 3: Create API Route (`src/app/api/auth/[...nextauth]/route.ts`)**
```ts
export { GET, POST } from '@/auth'
```

**Checklist:**
- [ ] NextAuth configured with providers
- [ ] `middleware.ts` exports auth middleware
- [ ] Matcher pattern includes all protected routes
- [ ] API route exports GET and POST handlers
- [ ] Session strategy set (JWT or database)

---

## Pattern 3: Error Boundary per Route

**Problem:** Errors crash entire app instead of isolated routes

**Pattern:** `error.tsx` files for graceful error handling

### Implementation

**Global Error Boundary (`src/app/error.tsx`)**
```tsx
'use client'

import { useEffect } from 'react'
import { Button } from '@/components/ui/Button'

export default function Error({
  error,
  reset
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error('Global error:', error)
  }, [error])

  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-4">Something went wrong!</h1>
        <p className="text-gray-600 mb-6">
          {error.message || 'An unexpected error occurred'}
        </p>
        <Button onClick={reset}>Try again</Button>
      </div>
    </div>
  )
}
```

**Route-Specific Error (`src/app/(dashboard)/error.tsx`)**
```tsx
'use client'

import { useEffect } from 'react'
import { Button } from '@/components/ui/Button'

export default function DashboardError({
  error,
  reset
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error('Dashboard error:', error)
  }, [error])

  return (
    <div className="flex items-center justify-center p-8">
      <div className="text-center">
        <h2 className="text-2xl font-bold mb-4">Dashboard Error</h2>
        <p className="text-gray-600 mb-6">
          Failed to load dashboard. Please try again.
        </p>
        <div className="space-x-4">
          <Button onClick={reset}>Retry</Button>
          <Button variant="outline" onClick={() => window.location.href = '/'}>
            Go Home
          </Button>
        </div>
      </div>
    </div>
  )
}
```

**Checklist:**
- [ ] Global `error.tsx` at app root
- [ ] Route-specific `error.tsx` for important sections
- [ ] Error logging (console or service like Sentry)
- [ ] User-friendly error messages
- [ ] Reset functionality implemented

---

## Pattern 4: Loading States with Suspense

**Problem:** No loading feedback during async operations

**Pattern:** `loading.tsx` files for automatic Suspense boundaries

### Implementation

**Global Loading (`src/app/loading.tsx`)**
```tsx
export default function Loading() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900" />
    </div>
  )
}
```

**Route-Specific Loading (`src/app/(dashboard)/loading.tsx`)**
```tsx
export default function DashboardLoading() {
  return (
    <div className="p-8">
      <div className="animate-pulse space-y-4">
        <div className="h-8 bg-gray-200 rounded w-1/4" />
        <div className="h-64 bg-gray-200 rounded" />
        <div className="h-32 bg-gray-200 rounded" />
      </div>
    </div>
  )
}
```

**Manual Suspense (`src/components/features/UserList.tsx`)**
```tsx
import { Suspense } from 'react'

function UserListSkeleton() {
  return <div className="animate-pulse">Loading users...</div>
}

async function UserListContent() {
  const users = await prisma.user.findMany()
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>
}

export function UserList() {
  return (
    <Suspense fallback={<UserListSkeleton />}>
      <UserListContent />
    </Suspense>
  )
}
```

**Checklist:**
- [ ] `loading.tsx` at appropriate levels
- [ ] Skeleton screens for better UX
- [ ] Manual Suspense for granular loading
- [ ] Avoid spinner fatigue (use skeletons)

---

## Pattern 5: Custom Hook with TanStack Query

**Problem:** Reusing data fetching logic across components

**Pattern:** Custom hook wrapping useQuery

### Implementation

**Hook (`src/lib/hooks/useUser.ts`)**
```ts
import { useQuery } from '@tanstack/react-query'

interface User {
  id: string
  name: string
  email: string
}

async function fetchUser(userId: string): Promise<User> {
  const res = await fetch(`/api/users/${userId}`)
  if (!res.ok) throw new Error('Failed to fetch user')
  return res.json()
}

export function useUser(userId: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
    staleTime: 5 * 60 * 1000, // 5 minutes
    gcTime: 10 * 60 * 1000 // 10 minutes
  })
}
```

**Usage (`src/components/features/UserProfile.tsx`)**
```tsx
'use client'

import { useUser } from '@/lib/hooks/useUser'

export function UserProfile({ userId }: { userId: string }) {
  const { data: user, isLoading, error } = useUser(userId)

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>
  if (!user) return <div>User not found</div>

  return (
    <div>
      <h2>{user.name}</h2>
      <p>{user.email}</p>
    </div>
  )
}
```

**Checklist:**
- [ ] Query key is unique and descriptive
- [ ] Query function handles errors
- [ ] Appropriate `staleTime` set
- [ ] Hook returns loading and error states
- [ ] Components handle all states (loading, error, success)

---

## Pattern 6: Zustand Store for Global State

**Problem:** Prop drilling for app-wide state

**Pattern:** Zustand store with TypeScript

### Implementation

**Store (`src/store/authStore.ts`)**
```ts
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface User {
  id: string
  name: string
  email: string
}

interface AuthState {
  user: User | null
  isAuthenticated: boolean
  setUser: (user: User | null) => void
  logout: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      setUser: (user) => set({ user, isAuthenticated: !!user }),
      logout: () => set({ user: null, isAuthenticated: false })
    }),
    {
      name: 'auth-storage' // localStorage key
    }
  )
)
```

**Usage (`src/components/Header.tsx`)**
```tsx
'use client'

import { useAuthStore } from '@/store/authStore'
import { Button } from '@/components/ui/Button'

export function Header() {
  const { user, isAuthenticated, logout } = useAuthStore()

  return (
    <header>
      {isAuthenticated ? (
        <div>
          <span>Welcome, {user?.name}</span>
          <Button onClick={logout}>Logout</Button>
        </div>
      ) : (
        <Button href="/login">Login</Button>
      )}
    </header>
  )
}
```

**Checklist:**
- [ ] Store interface defined with TypeScript
- [ ] Persistence middleware if needed
- [ ] Actions (setters) defined in store
- [ ] Selectors used for performance (when needed)
- [ ] Store only for truly global state

---

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Overusing "use client"

**Problem:**
```tsx
// ❌ WRONG: Unnecessary client component
'use client'

export function StaticHeader() {
  return <header>My App</header>
}
```

**Solution:**
```tsx
// ✅ CORRECT: Keep as Server Component
export function StaticHeader() {
  return <header>My App</header>
}
```

---

### ❌ Anti-Pattern 2: Reading Full Files with Serena

**Problem:**
```
// ❌ WRONG: Read entire file
mcp__serena__read_file("src/components/UserProfile.tsx")
```

**Solution:**
```
// ✅ CORRECT: Use symbols
mcp__serena__get_symbols_overview("src/components/UserProfile.tsx")
mcp__serena__find_symbol("/UserProfile/render", include_body=true)
```

---

### ❌ Anti-Pattern 3: Unvalidated Server Actions

**Problem:**
```ts
// ❌ WRONG: No validation
'use server'
export async function updateUser(formData: FormData) {
  const name = formData.get('name') // What if it's null? Or 1000 chars?
  await prisma.user.update({ data: { name } })
}
```

**Solution:**
```ts
// ✅ CORRECT: Zod validation
'use server'
export async function updateUser(formData: FormData) {
  const validated = userSchema.safeParse({
    name: formData.get('name')
  })
  if (!validated.success) return { error: validated.error }
  await prisma.user.update({ data: validated.data })
}
```

---

**Version:** 1.0.0
**Last Updated:** {{DATE}}
