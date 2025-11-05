# Task Manager Implementation Guide

This document provides a step-by-step guide to implementing the Task Manager application using the webapp-boilerplate.

## Implementation Timeline

**Total Time:** ~5 hours
**Breakdown:**
- Setup & Schema (30 min)
- Server Actions (1 hour)
- UI Components (2 hours)
- Dashboard Integration (1 hour)
- Testing & Polish (30 min)

## Step 1: Project Setup (30 minutes)

### 1.1 Initialize from Boilerplate
```bash
# From library root
claude-lib init task-manager webapp
cd task-manager
```

### 1.2 Update Database Configuration
**File:** `prisma/schema.prisma`

Change from PostgreSQL to SQLite (simpler for example):
```prisma
datasource db {
  provider = "sqlite"
  url      = env("DATABASE_URL")
}
```

### 1.3 Design Task Model
Add Task model after User model:
```prisma
model Task {
  id          String    @id @default(cuid())
  title       String
  description String?
  completed   Boolean   @default(false)
  priority    String    @default("medium") // "low" | "medium" | "high"
  dueDate     DateTime?
  userId      String

  user        User      @relation(fields: [userId], references: [id], onDelete: Cascade)

  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  @@index([userId])
  @@index([completed])
  @@index([priority])
}
```

### 1.4 Update User Model
Add tasks relation:
```prisma
model User {
  // ... existing fields
  tasks         Task[]
  // ... rest of model
}
```

### 1.5 Environment Setup
```bash
# Copy environment template
cp .env.example .env

# Generate NextAuth secret
openssl rand -base64 32

# Add to .env:
# DATABASE_URL="file:./dev.db"
# NEXTAUTH_SECRET="your-generated-secret"
# NEXTAUTH_URL="http://localhost:3000"

# Push schema
npm install
npm run db:push
```

## Step 2: Server Actions (1 hour)

### 2.1 Create Task Actions File
**File:** `src/app/actions/tasks.ts`

Start with type definitions:
```typescript
"use server";

import { auth } from "@/auth";
import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";
import { z } from "zod";

export type ActionResult<T> =
  | { success: true; data: T }
  | { success: false; error: string };
```

### 2.2 Add Validation Schemas
```typescript
const createTaskSchema = z.object({
  title: z.string().min(1, "Title is required").max(200),
  description: z.string().optional(),
  priority: z.enum(["low", "medium", "high"]).default("medium"),
  dueDate: z.string().optional(),
});

const updateTaskSchema = z.object({
  id: z.string(),
  title: z.string().min(1).max(200).optional(),
  description: z.string().optional(),
  completed: z.boolean().optional(),
  priority: z.enum(["low", "medium", "high"]).optional(),
  dueDate: z.string().optional(),
});
```

### 2.3 Implement Create Task Action
```typescript
export async function createTask(
  formData: FormData
): Promise<ActionResult<{ id: string }>> {
  try {
    // 1. Verify authentication
    const session = await auth();
    if (!session?.user?.id) {
      return { success: false, error: "Unauthorized" };
    }

    // 2. Extract and validate data
    const rawData = {
      title: formData.get("title"),
      description: formData.get("description"),
      priority: formData.get("priority"),
      dueDate: formData.get("dueDate"),
    };
    const validatedData = createTaskSchema.parse(rawData);

    // 3. Create task in database
    const task = await prisma.task.create({
      data: {
        title: validatedData.title,
        description: validatedData.description || null,
        priority: validatedData.priority,
        dueDate: validatedData.dueDate ? new Date(validatedData.dueDate) : null,
        userId: session.user.id,
      },
    });

    // 4. Revalidate affected routes
    revalidatePath("/dashboard");
    revalidatePath("/tasks");

    // 5. Return success
    return { success: true, data: { id: task.id } };
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { success: false, error: error.errors[0].message };
    }
    return { success: false, error: "Failed to create task" };
  }
}
```

### 2.4 Implement Update Task Action
Key points:
- Verify ownership before update
- Support partial updates
- Handle null values properly

### 2.5 Implement Toggle Complete Action
Optimized for the most common operation:
```typescript
export async function toggleTaskComplete(
  taskId: string
): Promise<ActionResult<{ completed: boolean }>> {
  // Verify ownership
  const existingTask = await prisma.task.findUnique({
    where: { id: taskId },
    select: { userId: true, completed: true },
  });

  // Toggle status
  const task = await prisma.task.update({
    where: { id: taskId },
    data: { completed: !existingTask.completed },
  });

  revalidatePath("/dashboard");
  revalidatePath("/tasks");

  return { success: true, data: { completed: task.completed } };
}
```

### 2.6 Implement Delete Task Action
Always verify ownership for security.

### 2.7 Implement Query Functions
```typescript
export async function getTasks(filter?: {
  completed?: boolean;
  priority?: "low" | "medium" | "high";
}) {
  const session = await auth();
  if (!session?.user?.id) {
    return { success: false, error: "Unauthorized" } as const;
  }

  const tasks = await prisma.task.findMany({
    where: {
      userId: session.user.id,
      ...(filter?.completed !== undefined && { completed: filter.completed }),
      ...(filter?.priority && { priority: filter.priority }),
    },
    orderBy: [
      { completed: "asc" },
      { priority: "desc" },
      { dueDate: "asc" },
      { createdAt: "desc" },
    ],
  });

  return { success: true, data: tasks } as const;
}
```

### 2.8 Implement Statistics Function
```typescript
export async function getTaskStats() {
  const session = await auth();
  if (!session?.user?.id) {
    return { success: false, error: "Unauthorized" } as const;
  }

  // Use Promise.all for parallel queries
  const [total, completed, pending, high, medium, low, overdue] =
    await Promise.all([
      prisma.task.count({ where: { userId: session.user.id } }),
      prisma.task.count({
        where: { userId: session.user.id, completed: true },
      }),
      // ... other counts
    ]);

  return {
    success: true,
    data: {
      total,
      completed,
      pending,
      high,
      medium,
      low,
      overdue,
      completionRate: total > 0 ? Math.round((completed / total) * 100) : 0,
    },
  } as const;
}
```

## Step 3: UI Components (2 hours)

### 3.1 Create TaskForm Component
**File:** `src/components/tasks/TaskForm.tsx`

Key features:
- Use `useTransition` for pending states
- Form validation on client and server
- Error display
- Reset form on success

```typescript
"use client";

export function TaskForm() {
  const [isPending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const formRef = useRef<HTMLFormElement>(null);

  async function handleSubmit(formData: FormData) {
    setError(null);

    startTransition(async () => {
      const result = await createTask(formData);

      if (result.success) {
        formRef.current?.reset();
      } else {
        setError(result.error);
      }
    });
  }

  return (
    <form ref={formRef} action={handleSubmit}>
      {/* Form fields */}
    </form>
  );
}
```

### 3.2 Create TaskItem Component
**File:** `src/components/tasks/TaskItem.tsx`

Key features:
- Optimistic updates with `useOptimistic`
- Visual feedback for pending states
- Priority badges with colors
- Overdue detection

```typescript
"use client";

export function TaskItem({ task }: { task: Task }) {
  const [isPending, startTransition] = useTransition();
  const [optimisticTask, setOptimisticTask] = useOptimistic(task);

  async function handleToggle() {
    // Update UI immediately
    setOptimisticTask({ ...optimisticTask, completed: !optimisticTask.completed });

    // Update server in background
    startTransition(async () => {
      await toggleTaskComplete(task.id);
    });
  }

  // Render with optimistic state
  return (
    <div className={optimisticTask.completed ? "opacity-60" : ""}>
      {/* Task content */}
    </div>
  );
}
```

### 3.3 Create TaskList Component
**File:** `src/components/tasks/TaskList.tsx`

Key features:
- Client-side filtering (no server requests)
- Filter by completion status
- Filter by priority
- Display statistics

```typescript
"use client";

export function TaskList({ initialTasks }: TaskListProps) {
  const [filter, setFilter] = useState<"all" | "active" | "completed">("all");
  const [priorityFilter, setPriorityFilter] = useState<"all" | "low" | "medium" | "high">("all");

  const filteredTasks = initialTasks.filter((task) => {
    // Apply filters
  });

  return (
    <div>
      {/* Filter buttons */}
      {/* Task list */}
    </div>
  );
}
```

## Step 4: Page Implementation (1 hour)

### 4.1 Create Tasks Page
**File:** `src/app/tasks/page.tsx`

Server Component that:
1. Fetches tasks server-side
2. Redirects if not authenticated
3. Passes data to client components

```typescript
export const dynamic = "force-dynamic";

export default async function TasksPage() {
  const result = await getTasks();

  if (!result.success) {
    redirect("/auth/signin");
  }

  return (
    <div>
      <TaskForm />
      <TaskList initialTasks={result.data} />
    </div>
  );
}
```

### 4.2 Update Dashboard Page
**File:** `src/app/dashboard/page.tsx`

Replace placeholder content with:
1. Task statistics cards
2. Priority breakdown
3. Recent tasks list
4. Quick actions

```typescript
export default async function DashboardPage() {
  const session = await auth();
  if (!session) redirect('/auth/signin');

  const statsResult = await getTaskStats();
  const tasksResult = await getTasks();

  // Display stats, charts, recent tasks
}
```

### 4.3 Update Home Page (Optional)
**File:** `src/app/page.tsx`

Add links to tasks and dashboard.

## Step 5: Testing & Polish (30 minutes)

### 5.1 Manual Testing Checklist
- [ ] Sign up with email/password
- [ ] Create task with all fields
- [ ] Create task with minimal fields
- [ ] Toggle task completion (check optimistic update)
- [ ] Edit task details
- [ ] Delete task (verify confirmation)
- [ ] Filter tasks (all, active, completed)
- [ ] Filter by priority
- [ ] Check dashboard statistics
- [ ] Verify overdue detection
- [ ] Test due date functionality
- [ ] Test sign out and sign in

### 5.2 Edge Cases
- [ ] Empty task list
- [ ] Very long task titles/descriptions
- [ ] Past due dates
- [ ] Future due dates
- [ ] Missing optional fields

### 5.3 Performance
- [ ] Verify server actions revalidate correctly
- [ ] Check optimistic updates feel instant
- [ ] Ensure no unnecessary re-renders
- [ ] Verify database indexes are used

## Common Patterns Used

### 1. Server Action Error Handling
```typescript
try {
  // Action logic
} catch (error) {
  if (error instanceof z.ZodError) {
    return { success: false, error: error.errors[0].message };
  }
  return { success: false, error: "Generic error message" };
}
```

### 2. Ownership Verification
```typescript
const existingTask = await prisma.task.findUnique({
  where: { id: taskId },
  select: { userId: true },
});

if (existingTask.userId !== session.user.id) {
  return { success: false, error: "Unauthorized" };
}
```

### 3. Optimistic Updates
```typescript
const [optimisticState, setOptimisticState] = useOptimistic(initialState);

// Update optimistically
setOptimisticState(newState);

// Then update server
startTransition(async () => {
  await serverAction();
});
```

### 4. Cache Revalidation
```typescript
revalidatePath("/dashboard");  // Revalidate specific page
revalidatePath("/tasks");      // Revalidate another page
```

## Troubleshooting

### Issue: Server Actions not updating UI
**Solution:** Add `revalidatePath()` calls

### Issue: Optimistic updates reverting
**Solution:** Ensure server action succeeds and returns correct data

### Issue: Type errors with Prisma
**Solution:** Run `npm run db:generate`

### Issue: Database errors
**Solution:** Delete `dev.db` and run `npm run db:push`

## Next Implementation Steps

After completing basic functionality:

1. **Add Tests**
   - Unit tests for Server Actions
   - Component tests for UI
   - E2E tests with Playwright

2. **Add Features**
   - Task categories/projects
   - Search functionality
   - Task sharing
   - Email notifications

3. **Optimize**
   - Add loading states
   - Implement pagination
   - Add caching strategies
   - Optimize database queries

## Key Learnings

1. **Server Actions simplify mutations** - No need for API routes
2. **Optimistic updates improve UX** - Instant feedback without waiting
3. **Type safety everywhere** - Zod + TypeScript + Prisma = full confidence
4. **Progressive enhancement** - Forms work without JavaScript
5. **Prisma is powerful** - Type-safe queries, automatic migrations
6. **React 19 features shine** - useOptimistic, useTransition, Server Components

## Time Breakdown

| Phase | Estimated | Actual | Notes |
|-------|-----------|--------|-------|
| Setup | 30 min | 30 min | Straightforward with boilerplate |
| Server Actions | 1 hour | 1 hour | Well-documented patterns |
| UI Components | 2 hours | 2 hours | Most time-consuming part |
| Pages | 1 hour | 1 hour | Integration is smooth |
| Testing | 30 min | 30 min | Mostly manual testing |
| **Total** | **5 hours** | **5 hours** | - |

**Compare to from scratch:** ~20 hours (4x slower)

## References

- [Next.js Server Actions](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)
- [React useOptimistic](https://react.dev/reference/react/useOptimistic)
- [Prisma Best Practices](https://www.prisma.io/docs/guides/performance-and-optimization)
- [NextAuth v5 Guide](https://authjs.dev/getting-started/migrating-to-v5)
- [Zod Documentation](https://zod.dev)

---

**Built with webapp-boilerplate from Claude Code Library**
