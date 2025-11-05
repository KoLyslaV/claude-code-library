# Task Manager Example

**Boilerplate:** webapp-boilerplate (Next.js 15 + React 19)

A complete task management application demonstrating modern Next.js patterns including Server Actions, React Server Components, authentication, and database operations.

## Features

- ✅ User authentication with NextAuth v5 (email/password)
- ✅ Create, read, update, delete tasks
- ✅ Task priorities (low, medium, high)
- ✅ Due dates with overdue detection
- ✅ Task filtering (all, active, completed, by priority)
- ✅ Real-time updates with React 19 features
- ✅ Protected routes with middleware
- ✅ Dashboard with statistics
- ✅ Optimistic UI updates

## Tech Stack

- **Framework:** Next.js 15.1
- **React:** React 19
- **TypeScript:** 5.7
- **Database:** SQLite (via Prisma)
- **Authentication:** NextAuth v5
- **Styling:** Tailwind CSS 4.0
- **Icons:** Lucide React
- **Validation:** Zod

## Quick Start

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Generate a NextAuth secret
openssl rand -base64 32
# Add to .env as NEXTAUTH_SECRET

# Push database schema
npm run db:push

# Run development server
npm run dev
```

Visit http://localhost:3000 and create an account to get started!

## What This Example Demonstrates

### 1. Server Actions
- **File:** `src/app/actions/tasks.ts`
- Creates, updates, deletes tasks using Server Actions
- Form validation with Zod
- Error handling and success/error responses
- `revalidatePath` for cache invalidation

### 2. React Server Components
- **File:** `src/app/dashboard/page.tsx`
- Server-side data fetching
- Statistics aggregation
- Protected routes with auth checks
- Metadata for SEO

### 3. Type-Safe Database Operations
- **File:** `prisma/schema.prisma`
- Task model with relationships
- User authentication models
- Indexes for performance
- SQLite for easy development

### 4. Authentication with NextAuth v5
- **File:** `src/auth.ts`
- Credentials provider (email/password)
- Session management
- Protected routes
- Password hashing with bcryptjs

### 5. Form Handling with Server Actions
- **File:** `src/components/tasks/TaskForm.tsx`
- Uses `useTransition` for pending states
- Progressive enhancement (works without JS)
- Error display
- Form reset on success

### 6. Optimistic UI Updates
- **File:** `src/components/tasks/TaskItem.tsx`
- Uses `useOptimistic` for instant feedback
- Toggle completion without waiting
- Visual feedback during pending states

### 7. Client-Side Filtering
- **File:** `src/components/tasks/TaskList.tsx`
- Filter by completion status
- Filter by priority
- Pure client-side (no server requests)

## Key Patterns

### Server Action Pattern
```typescript
// src/app/actions/tasks.ts
export async function createTask(formData: FormData) {
  // 1. Validate user session
  const session = await auth();
  if (!session?.user?.id) return { success: false, error: "Unauthorized" };

  // 2. Validate input with Zod
  const validatedData = createTaskSchema.parse(rawData);

  // 3. Database operation
  const task = await prisma.task.create({ data: {...} });

  // 4. Revalidate cache
  revalidatePath("/tasks");

  // 5. Return result
  return { success: true, data: { id: task.id } };
}
```

### Optimistic Updates Pattern
```typescript
// src/components/tasks/TaskItem.tsx
const [optimisticTask, setOptimisticTask] = useOptimistic(task);

async function handleToggle() {
  // Update UI immediately
  setOptimisticTask({ ...optimisticTask, completed: !optimisticTask.completed });

  // Then update server
  startTransition(async () => {
    await toggleTaskComplete(task.id);
  });
}
```

### Protected Route Pattern
```typescript
// src/app/dashboard/page.tsx
export default async function DashboardPage() {
  const session = await auth();

  if (!session) {
    redirect('/auth/signin');
  }

  // Fetch data server-side
  const stats = await getTaskStats();
  // ...
}
```

## Project Structure

```
src/
├── app/
│   ├── actions/
│   │   ├── auth.ts          # Authentication actions
│   │   └── tasks.ts         # Task CRUD actions
│   ├── api/
│   │   └── auth/
│   │       └── [...nextauth]/ # NextAuth API route
│   ├── auth/
│   │   └── signin/          # Sign-in page
│   ├── dashboard/
│   │   └── page.tsx         # Dashboard with stats
│   ├── tasks/
│   │   └── page.tsx         # Tasks list page
│   ├── layout.tsx           # Root layout
│   └── page.tsx             # Landing page
├── components/
│   ├── auth/
│   │   └── LoginForm.tsx    # Login form component
│   ├── tasks/
│   │   ├── TaskForm.tsx     # Create task form
│   │   ├── TaskItem.tsx     # Individual task
│   │   └── TaskList.tsx     # Tasks list with filters
│   └── ui/                  # Reusable UI components
├── lib/
│   └── prisma.ts            # Prisma client singleton
├── auth.ts                  # NextAuth configuration
└── middleware.ts            # Route protection
```

## Database Schema

```prisma
model Task {
  id          String    @id @default(cuid())
  title       String
  description String?
  completed   Boolean   @default(false)
  priority    String    @default("medium")
  dueDate     DateTime?
  userId      String
  user        User      @relation(...)
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
}
```

## Development

```bash
# Run development server
npm run dev

# Type checking
npm run type-check

# Linting
npm run lint

# Formatting
npm run format

# Database management
npm run db:studio  # Open Prisma Studio
npm run db:push    # Push schema changes
```

## Testing

```bash
# Run all tests
npm test

# Watch mode
npm run test:watch

# Coverage
npm run test:coverage

# E2E tests
npm run test:e2e
```

## Deployment

### Vercel (Recommended)
1. Push to GitHub
2. Import project in Vercel
3. Add environment variables:
   - `DATABASE_URL` (use PostgreSQL or PlanetScale)
   - `NEXTAUTH_SECRET`
   - `NEXTAUTH_URL`
4. Deploy!

### Docker
```bash
docker build -t task-manager .
docker run -p 3000:3000 task-manager
```

## Learning Objectives

After studying this example, you should understand:

1. **Server Actions** - How to mutate data without API routes
2. **React Server Components** - Server-side rendering and data fetching
3. **NextAuth v5** - Modern authentication patterns
4. **Prisma** - Type-safe database operations
5. **Optimistic Updates** - Instant UI feedback
6. **Form Handling** - Progressive enhancement with Server Actions
7. **Protected Routes** - Authentication middleware
8. **TypeScript** - Full type safety across frontend and backend

## Time to Implement

**With webapp-boilerplate:** ~5 hours
**From scratch:** ~20 hours

**Time saved:** 75% (15 hours)

## Next Steps

1. **Add OAuth** - Google/GitHub sign-in
2. **Add Categories** - Organize tasks into projects
3. **Add Search** - Full-text search for tasks
4. **Add Sharing** - Collaborate on tasks
5. **Add Notifications** - Email reminders for due dates
6. **Add API** - REST API for mobile apps
7. **Add Tests** - Unit and E2E tests

## Related Documentation

- [Next.js 15 Documentation](https://nextjs.org/docs)
- [React 19 Documentation](https://react.dev)
- [NextAuth v5 Documentation](https://authjs.dev)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

## Troubleshooting

### Database issues
```bash
# Reset database
rm -f prisma/dev.db
npm run db:push
```

### Type errors
```bash
# Regenerate Prisma Client
npm run db:generate
```

### Authentication not working
- Check `NEXTAUTH_SECRET` is set in `.env`
- Verify `NEXTAUTH_URL` matches your domain

## License

MIT

## Support

For issues or questions:
- Check [TROUBLESHOOTING.md](../../docs/TROUBLESHOOTING.md)
- Review [QUICK_REFERENCE.md](../../docs/QUICK_REFERENCE.md)
- File an issue on GitHub

---

**Built with the webapp-boilerplate from Claude Code Library**
**Time to implement:** ~5 hours vs ~20 hours from scratch
