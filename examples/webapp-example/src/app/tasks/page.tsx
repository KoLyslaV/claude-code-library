import { getTasks } from "@/app/actions/tasks";
import { TaskForm } from "@/components/tasks/TaskForm";
import { TaskList } from "@/components/tasks/TaskList";
import { redirect } from "next/navigation";

export const dynamic = "force-dynamic";

export default async function TasksPage() {
  const result = await getTasks();

  if (!result.success) {
    redirect("/auth/signin");
  }

  return (
    <div className="container mx-auto max-w-4xl space-y-8 py-8">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Task Manager</h1>
        <p className="mt-2 text-gray-600">
          Manage your tasks efficiently with priorities and due dates.
        </p>
      </div>

      <TaskForm />
      <TaskList initialTasks={result.data} />
    </div>
  );
}
