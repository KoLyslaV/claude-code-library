import { Metadata } from 'next'
import { redirect } from 'next/navigation'
import { auth } from '@/auth'
import { Button } from '@/components/ui/button'
import { getTaskStats, getTasks } from '@/app/actions/tasks'
import Link from 'next/link'
import { CheckCircle, Circle, AlertCircle, TrendingUp } from 'lucide-react'

export const metadata: Metadata = {
  title: 'Dashboard - Task Manager',
  description: 'Your task management dashboard',
}

export const dynamic = 'force-dynamic'

// Server Component - demonstrates protected route pattern
export default async function DashboardPage() {
  const session = await auth()

  // Server-side auth check (middleware also protects this route)
  if (!session) {
    redirect('/auth/signin')
  }

  const statsResult = await getTaskStats()
  const tasksResult = await getTasks()

  if (!statsResult.success || !tasksResult.success) {
    return <div>Error loading dashboard</div>
  }

  const stats = statsResult.data
  const recentTasks = tasksResult.data.slice(0, 5)

  return (
    <div className="flex min-h-screen flex-col">
      <header className="border-b bg-white">
        <div className="container mx-auto flex h-16 items-center justify-between px-4">
          <Link href="/" className="text-2xl font-bold text-blue-600">
            TaskManager
          </Link>
          <nav className="flex items-center gap-4">
            <Button variant="ghost" asChild>
              <Link href="/tasks">Tasks</Link>
            </Button>
            <span className="text-sm text-gray-600">
              {session.user?.email}
            </span>
            <form action="/api/auth/signout" method="POST">
              <Button variant="outline" type="submit">
                Sign Out
              </Button>
            </form>
          </nav>
        </div>
      </header>

      <main className="flex-1 bg-gray-50">
        <div className="container mx-auto px-4 py-8">
          <div className="mb-8">
            <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
            <p className="mt-2 text-gray-600">
              Welcome back, {session.user?.name || session.user?.email || 'there'}!
            </p>
          </div>

          {/* Stats Cards */}
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
            <div className="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-sm font-medium text-gray-600">
                    Total Tasks
                  </h3>
                  <p className="mt-2 text-3xl font-bold text-gray-900">{stats.total}</p>
                </div>
                <Circle className="h-10 w-10 text-blue-500" />
              </div>
            </div>

            <div className="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-sm font-medium text-gray-600">
                    Completed
                  </h3>
                  <p className="mt-2 text-3xl font-bold text-green-600">{stats.completed}</p>
                </div>
                <CheckCircle className="h-10 w-10 text-green-500" />
              </div>
            </div>

            <div className="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-sm font-medium text-gray-600">
                    Pending
                  </h3>
                  <p className="mt-2 text-3xl font-bold text-yellow-600">{stats.pending}</p>
                </div>
                <AlertCircle className="h-10 w-10 text-yellow-500" />
              </div>
            </div>

            <div className="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-sm font-medium text-gray-600">
                    Completion Rate
                  </h3>
                  <p className="mt-2 text-3xl font-bold text-purple-600">{stats.completionRate}%</p>
                </div>
                <TrendingUp className="h-10 w-10 text-purple-500" />
              </div>
            </div>
          </div>

          {/* Priority Breakdown */}
          <div className="mt-8 rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
            <h2 className="mb-4 text-xl font-semibold text-gray-900">Priority Breakdown</h2>
            <div className="grid gap-4 md:grid-cols-3">
              <div className="flex items-center justify-between rounded-lg bg-red-50 p-4">
                <span className="text-sm font-medium text-red-900">High Priority</span>
                <span className="text-2xl font-bold text-red-600">{stats.high}</span>
              </div>
              <div className="flex items-center justify-between rounded-lg bg-yellow-50 p-4">
                <span className="text-sm font-medium text-yellow-900">Medium Priority</span>
                <span className="text-2xl font-bold text-yellow-600">{stats.medium}</span>
              </div>
              <div className="flex items-center justify-between rounded-lg bg-green-50 p-4">
                <span className="text-sm font-medium text-green-900">Low Priority</span>
                <span className="text-2xl font-bold text-green-600">{stats.low}</span>
              </div>
            </div>
            {stats.overdue > 0 && (
              <div className="mt-4 rounded-lg bg-red-100 p-4 text-red-800">
                <strong>{stats.overdue}</strong> task{stats.overdue > 1 ? 's are' : ' is'} overdue!
              </div>
            )}
          </div>

          {/* Quick Actions */}
          <div className="mt-8 rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
            <h2 className="mb-4 text-xl font-semibold text-gray-900">Quick Actions</h2>
            <div className="flex flex-wrap gap-3">
              <Button asChild>
                <Link href="/tasks">View All Tasks</Link>
              </Button>
              <Button variant="outline" asChild>
                <Link href="/tasks#create">Create New Task</Link>
              </Button>
            </div>
          </div>

          {/* Recent Tasks */}
          <div className="mt-8 rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
            <h2 className="mb-4 text-xl font-semibold text-gray-900">Recent Tasks</h2>
            {recentTasks.length > 0 ? (
              <div className="space-y-3">
                {recentTasks.map((task) => (
                  <div key={task.id} className="flex items-center justify-between border-b border-gray-100 pb-3 last:border-0">
                    <div className="flex items-center gap-3">
                      {task.completed ? (
                        <CheckCircle className="h-5 w-5 text-green-600" />
                      ) : (
                        <Circle className="h-5 w-5 text-gray-400" />
                      )}
                      <div>
                        <p className={`font-medium ${task.completed ? 'text-gray-500 line-through' : 'text-gray-900'}`}>
                          {task.title}
                        </p>
                        {task.dueDate && (
                          <p className="text-xs text-gray-500">
                            Due: {new Date(task.dueDate).toLocaleDateString()}
                          </p>
                        )}
                      </div>
                    </div>
                    <span className={`rounded-full px-3 py-1 text-xs font-medium ${
                      task.priority === 'high' ? 'bg-red-100 text-red-800' :
                      task.priority === 'medium' ? 'bg-yellow-100 text-yellow-800' :
                      'bg-green-100 text-green-800'
                    }`}>
                      {task.priority}
                    </span>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-gray-600">
                No tasks yet. <Link href="/tasks" className="text-blue-600 hover:underline">Create your first task</Link>!
              </p>
            )}
          </div>
        </div>
      </main>
    </div>
  )
}
