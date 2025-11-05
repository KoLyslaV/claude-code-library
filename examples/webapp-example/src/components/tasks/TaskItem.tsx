"use client";

import { deleteTask, toggleTaskComplete } from "@/app/actions/tasks";
import { Button } from "@/components/ui/button";
import { Trash2, Check, X } from "lucide-react";
import { useOptimistic, useTransition } from "react";

type Task = {
  id: string;
  title: string;
  description: string | null;
  completed: boolean;
  priority: string;
  dueDate: Date | null;
  createdAt: Date;
  updatedAt: Date;
};

export function TaskItem({ task }: { task: Task }) {
  const [isPending, startTransition] = useTransition();
  const [optimisticTask, setOptimisticTask] = useOptimistic(task);

  async function handleToggle() {
    // Optimistically update UI before server action completes
    setOptimisticTask({ ...optimisticTask, completed: !optimisticTask.completed });

    startTransition(async () => {
      await toggleTaskComplete(task.id);
    });
  }

  async function handleDelete() {
    if (!confirm("Are you sure you want to delete this task?")) {
      return;
    }

    startTransition(async () => {
      await deleteTask(task.id);
    });
  }

  const priorityColors = {
    low: "bg-green-100 text-green-800 border-green-200",
    medium: "bg-yellow-100 text-yellow-800 border-yellow-200",
    high: "bg-red-100 text-red-800 border-red-200",
  };

  const priorityColor =
    priorityColors[optimisticTask.priority as keyof typeof priorityColors] ||
    priorityColors.medium;

  const isOverdue =
    optimisticTask.dueDate &&
    new Date(optimisticTask.dueDate) < new Date() &&
    !optimisticTask.completed;

  return (
    <div
      className={`flex items-start gap-4 rounded-lg border p-4 transition-all ${
        optimisticTask.completed
          ? "border-gray-200 bg-gray-50 opacity-60"
          : "border-gray-300 bg-white"
      } ${isPending ? "opacity-50" : ""}`}
    >
      {/* Checkbox */}
      <button
        type="button"
        onClick={handleToggle}
        disabled={isPending}
        className={`mt-0.5 flex h-5 w-5 flex-shrink-0 items-center justify-center rounded border-2 transition-colors ${
          optimisticTask.completed
            ? "border-green-600 bg-green-600"
            : "border-gray-300 hover:border-green-600"
        } disabled:cursor-not-allowed`}
      >
        {optimisticTask.completed && <Check className="h-3 w-3 text-white" />}
      </button>

      {/* Task Content */}
      <div className="flex-1 space-y-2">
        <div className="flex items-start justify-between gap-2">
          <h3
            className={`text-base font-medium ${
              optimisticTask.completed
                ? "text-gray-500 line-through"
                : "text-gray-900"
            }`}
          >
            {optimisticTask.title}
          </h3>

          <div className="flex items-center gap-2">
            {/* Priority Badge */}
            <span
              className={`rounded-full border px-2 py-0.5 text-xs font-medium ${priorityColor}`}
            >
              {optimisticTask.priority}
            </span>

            {/* Delete Button */}
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={handleDelete}
              disabled={isPending}
              className="h-8 w-8 p-0 text-red-600 hover:bg-red-50 hover:text-red-700"
            >
              <Trash2 className="h-4 w-4" />
            </Button>
          </div>
        </div>

        {optimisticTask.description && (
          <p
            className={`text-sm ${
              optimisticTask.completed ? "text-gray-400" : "text-gray-600"
            }`}
          >
            {optimisticTask.description}
          </p>
        )}

        {/* Due Date */}
        {optimisticTask.dueDate && (
          <div
            className={`flex items-center gap-1 text-xs ${
              isOverdue
                ? "font-semibold text-red-600"
                : optimisticTask.completed
                  ? "text-gray-400"
                  : "text-gray-500"
            }`}
          >
            {isOverdue && <X className="h-3 w-3" />}
            Due: {new Date(optimisticTask.dueDate).toLocaleDateString()}
            {isOverdue && " (Overdue)"}
          </div>
        )}

        <div className="text-xs text-gray-400">
          Created {new Date(optimisticTask.createdAt).toLocaleDateString()}
        </div>
      </div>
    </div>
  );
}
