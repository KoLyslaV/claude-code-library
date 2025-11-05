"use client";

import { TaskItem } from "./TaskItem";
import { useState } from "react";

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

type TaskListProps = {
  initialTasks: Task[];
};

export function TaskList({ initialTasks }: TaskListProps) {
  const [filter, setFilter] = useState<"all" | "active" | "completed">("all");
  const [priorityFilter, setPriorityFilter] = useState<
    "all" | "low" | "medium" | "high"
  >("all");

  const filteredTasks = initialTasks.filter((task) => {
    const matchesCompletionFilter =
      filter === "all" ||
      (filter === "active" && !task.completed) ||
      (filter === "completed" && task.completed);

    const matchesPriorityFilter =
      priorityFilter === "all" || task.priority === priorityFilter;

    return matchesCompletionFilter && matchesPriorityFilter;
  });

  const stats = {
    total: initialTasks.length,
    active: initialTasks.filter((t) => !t.completed).length,
    completed: initialTasks.filter((t) => t.completed).length,
  };

  return (
    <div className="space-y-4">
      {/* Header with Stats */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold text-gray-900">Your Tasks</h2>
          <p className="text-sm text-gray-600">
            {stats.active} active • {stats.completed} completed • {stats.total}{" "}
            total
          </p>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-4">
        {/* Completion Filter */}
        <div className="flex gap-2">
          <button
            onClick={() => setFilter("all")}
            className={`rounded-full px-4 py-1.5 text-sm font-medium transition-colors ${
              filter === "all"
                ? "bg-blue-600 text-white"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
          >
            All
          </button>
          <button
            onClick={() => setFilter("active")}
            className={`rounded-full px-4 py-1.5 text-sm font-medium transition-colors ${
              filter === "active"
                ? "bg-blue-600 text-white"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
          >
            Active
          </button>
          <button
            onClick={() => setFilter("completed")}
            className={`rounded-full px-4 py-1.5 text-sm font-medium transition-colors ${
              filter === "completed"
                ? "bg-blue-600 text-white"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
          >
            Completed
          </button>
        </div>

        {/* Priority Filter */}
        <div className="flex gap-2">
          <button
            onClick={() => setPriorityFilter("all")}
            className={`rounded-full px-4 py-1.5 text-sm font-medium transition-colors ${
              priorityFilter === "all"
                ? "bg-purple-600 text-white"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
          >
            All Priorities
          </button>
          <button
            onClick={() => setPriorityFilter("high")}
            className={`rounded-full px-4 py-1.5 text-sm font-medium transition-colors ${
              priorityFilter === "high"
                ? "bg-red-600 text-white"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
          >
            High
          </button>
          <button
            onClick={() => setPriorityFilter("medium")}
            className={`rounded-full px-4 py-1.5 text-sm font-medium transition-colors ${
              priorityFilter === "medium"
                ? "bg-yellow-600 text-white"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
          >
            Medium
          </button>
          <button
            onClick={() => setPriorityFilter("low")}
            className={`rounded-full px-4 py-1.5 text-sm font-medium transition-colors ${
              priorityFilter === "low"
                ? "bg-green-600 text-white"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
          >
            Low
          </button>
        </div>
      </div>

      {/* Task List */}
      <div className="space-y-3">
        {filteredTasks.length === 0 ? (
          <div className="rounded-lg border border-dashed border-gray-300 bg-gray-50 p-8 text-center">
            <p className="text-sm text-gray-600">
              {filter === "all"
                ? "No tasks yet. Create your first task above!"
                : filter === "active"
                  ? "No active tasks. Great job!"
                  : "No completed tasks yet."}
            </p>
          </div>
        ) : (
          filteredTasks.map((task) => <TaskItem key={task.id} task={task} />)
        )}
      </div>
    </div>
  );
}
