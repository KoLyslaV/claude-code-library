import { Metadata } from 'next'
import { redirect } from 'next/navigation'
import { auth } from '@/auth'
import { Button } from '@/components/ui/button'
import Link from 'next/link'

export const metadata: Metadata = {
  title: 'Dashboard',
  description: 'Your dashboard',
}

// Server Component - demonstrates protected route pattern
export default async function DashboardPage() {
  const session = await auth()

  // Server-side auth check (middleware also protects this route)
  if (!session) {
    redirect('/auth/signin')
  }

  return (
    <div className="flex min-h-screen flex-col">
      <header className="border-b">
        <div className="container mx-auto flex h-16 items-center justify-between px-4">
          <Link href="/" className="text-2xl font-bold">
            {{PROJECT_NAME_PASCAL}}
          </Link>
          <nav className="flex items-center gap-4">
            <span className="text-sm text-muted-foreground">
              {session.user?.email}
            </span>
            <Button variant="ghost" asChild>
              <Link href="/profile">Profile</Link>
            </Button>
            <form action="/api/auth/signout" method="POST">
              <Button variant="outline" type="submit">
                Sign Out
              </Button>
            </form>
          </nav>
        </div>
      </header>

      <main className="flex-1 bg-muted/50">
        <div className="container mx-auto px-4 py-8">
          <div className="mb-8">
            <h1 className="text-3xl font-bold">Dashboard</h1>
            <p className="mt-2 text-muted-foreground">
              Welcome back, {session.user?.name || 'there'}!
            </p>
          </div>

          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            {/* Stats Cards */}
            <div className="rounded-lg border bg-card p-6">
              <h3 className="text-sm font-medium text-muted-foreground">
                Total Posts
              </h3>
              <p className="mt-2 text-3xl font-bold">0</p>
            </div>

            <div className="rounded-lg border bg-card p-6">
              <h3 className="text-sm font-medium text-muted-foreground">
                Published
              </h3>
              <p className="mt-2 text-3xl font-bold">0</p>
            </div>

            <div className="rounded-lg border bg-card p-6">
              <h3 className="text-sm font-medium text-muted-foreground">
                Drafts
              </h3>
              <p className="mt-2 text-3xl font-bold">0</p>
            </div>
          </div>

          {/* Quick Actions */}
          <div className="mt-8 rounded-lg border bg-card p-6">
            <h2 className="mb-4 text-xl font-semibold">Quick Actions</h2>
            <div className="flex flex-wrap gap-3">
              <Button asChild>
                <Link href="/posts/new">Create New Post</Link>
              </Button>
              <Button variant="outline" asChild>
                <Link href="/profile">Edit Profile</Link>
              </Button>
              <Button variant="outline" asChild>
                <Link href="/settings">Settings</Link>
              </Button>
            </div>
          </div>

          {/* Recent Activity */}
          <div className="mt-8 rounded-lg border bg-card p-6">
            <h2 className="mb-4 text-xl font-semibold">Recent Activity</h2>
            <p className="text-muted-foreground">
              No recent activity to display.
            </p>
          </div>
        </div>
      </main>
    </div>
  )
}
