"use server";

import { auth } from "@/auth";
import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";
import { z } from "zod";

// Validation schemas
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

export type ActionResult<T> =
  | { success: true; data: T }
  | { success: false; error: string };

/**
 * Create a new task
 * Demonstrates: Server Actions, Prisma create, validation with Zod
 */
export async function createTask(
  formData: FormData
): Promise<ActionResult<{ id: string }>> {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return { success: false, error: "Unauthorized" };
    }

    const rawData = {
      title: formData.get("title"),
      description: formData.get("description"),
      priority: formData.get("priority"),
      dueDate: formData.get("dueDate"),
    };

    const validatedData = createTaskSchema.parse(rawData);

    const task = await prisma.task.create({
      data: {
        title: validatedData.title,
        description: validatedData.description || null,
        priority: validatedData.priority,
        dueDate: validatedData.dueDate ? new Date(validatedData.dueDate) : null,
        userId: session.user.id,
      },
    });

    revalidatePath("/dashboard");
    revalidatePath("/tasks");

    return { success: true, data: { id: task.id } };
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { success: false, error: error.errors[0].message };
    }
    return { success: false, error: "Failed to create task" };
  }
}

/**
 * Update an existing task
 * Demonstrates: Partial updates, ownership validation
 */
export async function updateTask(
  data: z.infer<typeof updateTaskSchema>
): Promise<ActionResult<{ id: string }>> {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return { success: false, error: "Unauthorized" };
    }

    const validatedData = updateTaskSchema.parse(data);

    // Verify ownership
    const existingTask = await prisma.task.findUnique({
      where: { id: validatedData.id },
      select: { userId: true },
    });

    if (!existingTask) {
      return { success: false, error: "Task not found" };
    }

    if (existingTask.userId !== session.user.id) {
      return { success: false, error: "Unauthorized" };
    }

    const task = await prisma.task.update({
      where: { id: validatedData.id },
      data: {
        ...(validatedData.title && { title: validatedData.title }),
        ...(validatedData.description !== undefined && {
          description: validatedData.description || null,
        }),
        ...(validatedData.completed !== undefined && {
          completed: validatedData.completed,
        }),
        ...(validatedData.priority && { priority: validatedData.priority }),
        ...(validatedData.dueDate !== undefined && {
          dueDate: validatedData.dueDate ? new Date(validatedData.dueDate) : null,
        }),
      },
    });

    revalidatePath("/dashboard");
    revalidatePath("/tasks");

    return { success: true, data: { id: task.id } };
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { success: false, error: error.errors[0].message };
    }
    return { success: false, error: "Failed to update task" };
  }
}

/**
 * Toggle task completion status
 * Demonstrates: Optimistic updates pattern
 */
export async function toggleTaskComplete(
  taskId: string
): Promise<ActionResult<{ completed: boolean }>> {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return { success: false, error: "Unauthorized" };
    }

    // Verify ownership
    const existingTask = await prisma.task.findUnique({
      where: { id: taskId },
      select: { userId: true, completed: true },
    });

    if (!existingTask) {
      return { success: false, error: "Task not found" };
    }

    if (existingTask.userId !== session.user.id) {
      return { success: false, error: "Unauthorized" };
    }

    const task = await prisma.task.update({
      where: { id: taskId },
      data: { completed: !existingTask.completed },
    });

    revalidatePath("/dashboard");
    revalidatePath("/tasks");

    return { success: true, data: { completed: task.completed } };
  } catch (error) {
    return { success: false, error: "Failed to toggle task" };
  }
}

/**
 * Delete a task
 * Demonstrates: Cascade delete, ownership validation
 */
export async function deleteTask(
  taskId: string
): Promise<ActionResult<{ id: string }>> {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return { success: false, error: "Unauthorized" };
    }

    // Verify ownership
    const existingTask = await prisma.task.findUnique({
      where: { id: taskId },
      select: { userId: true },
    });

    if (!existingTask) {
      return { success: false, error: "Task not found" };
    }

    if (existingTask.userId !== session.user.id) {
      return { success: false, error: "Unauthorized" };
    }

    await prisma.task.delete({
      where: { id: taskId },
    });

    revalidatePath("/dashboard");
    revalidatePath("/tasks");

    return { success: true, data: { id: taskId } };
  } catch (error) {
    return { success: false, error: "Failed to delete task" };
  }
}

/**
 * Get all tasks for the current user
 * Demonstrates: Server-side data fetching with filters
 */
export async function getTasks(filter?: {
  completed?: boolean;
  priority?: "low" | "medium" | "high";
}) {
  try {
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
  } catch (error) {
    return { success: false, error: "Failed to fetch tasks" } as const;
  }
}

/**
 * Get task statistics for dashboard
 * Demonstrates: Aggregation queries, multiple counts
 */
export async function getTaskStats() {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return { success: false, error: "Unauthorized" } as const;
    }

    const [total, completed, pending, high, medium, low, overdue] =
      await Promise.all([
        prisma.task.count({ where: { userId: session.user.id } }),
        prisma.task.count({
          where: { userId: session.user.id, completed: true },
        }),
        prisma.task.count({
          where: { userId: session.user.id, completed: false },
        }),
        prisma.task.count({
          where: { userId: session.user.id, priority: "high", completed: false },
        }),
        prisma.task.count({
          where: { userId: session.user.id, priority: "medium", completed: false },
        }),
        prisma.task.count({
          where: { userId: session.user.id, priority: "low", completed: false },
        }),
        prisma.task.count({
          where: {
            userId: session.user.id,
            completed: false,
            dueDate: { lt: new Date() },
          },
        }),
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
  } catch (error) {
    return { success: false, error: "Failed to fetch stats" } as const;
  }
}
