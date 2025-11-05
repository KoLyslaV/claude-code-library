import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { auth } from '@/auth'

// Server Component by default (no "use client")
export default async function HomePage() {
  const session = await auth()

  return (
    <div className="flex min-h-screen flex-col">
      <header className="border-b">
        <div className="container mx-auto flex h-16 items-center justify-between px-4">
          <h1 className="text-2xl font-bold">{{PROJECT_NAME_PASCAL}}</h1>
          <nav className="flex gap-4">
            {session ? (
              <>
                <Button variant="ghost" asChild>
                  <Link href="/dashboard">Dashboard</Link>
                </Button>
                <Button variant="outline" asChild>
                  <Link href="/api/auth/signout">Sign Out</Link>
                </Button>
              </>
            ) : (
              <>
                <Button variant="ghost" asChild>
                  <Link href="/auth/signin">Sign In</Link>
                </Button>
                <Button asChild>
                  <Link href="/auth/signup">Get Started</Link>
                </Button>
              </>
            )}
          </nav>
        </div>
      </header>

      <main className="flex-1">
        <section className="container mx-auto px-4 py-24 text-center">
          <h2 className="mb-6 text-5xl font-bold">
            Welcome to {{PROJECT_NAME_PASCAL}}
          </h2>
          <p className="mx-auto mb-8 max-w-2xl text-xl text-muted-foreground">
            A modern Next.js 15 application with Server Components, TypeScript,
            Prisma, and NextAuth. Built with Claude Code best practices.
          </p>
          <div className="flex justify-center gap-4">
            {!session && (
              <>
                <Button size="lg" asChild>
                  <Link href="/auth/signup">Get Started</Link>
                </Button>
                <Button size="lg" variant="outline" asChild>
                  <Link href="/auth/signin">Sign In</Link>
                </Button>
              </>
            )}
            {session && (
              <Button size="lg" asChild>
                <Link href="/dashboard">Go to Dashboard</Link>
              </Button>
            )}
          </div>
        </section>

        <section className="border-t bg-muted/50 py-24">
          <div className="container mx-auto px-4">
            <h3 className="mb-12 text-center text-3xl font-bold">
              Features
            </h3>
            <div className="grid gap-8 md:grid-cols-3">
              <div className="rounded-lg border bg-card p-6">
                <h4 className="mb-2 text-xl font-semibold">
                  Server Components
                </h4>
                <p className="text-muted-foreground">
                  Fast initial load, smaller JavaScript bundle, better SEO with
                  React Server Components.
                </p>
              </div>
              <div className="rounded-lg border bg-card p-6">
                <h4 className="mb-2 text-xl font-semibold">Type-Safe</h4>
                <p className="text-muted-foreground">
                  End-to-end type safety with TypeScript, Prisma, and Zod
                  validation.
                </p>
              </div>
              <div className="rounded-lg border bg-card p-6">
                <h4 className="mb-2 text-xl font-semibold">Authentication</h4>
                <p className="text-muted-foreground">
                  Secure authentication with NextAuth v5, supporting multiple
                  providers.
                </p>
              </div>
            </div>
          </div>
        </section>
      </main>

      <footer className="border-t py-8">
        <div className="container mx-auto px-4 text-center text-sm text-muted-foreground">
          <p>
            Built with{' '}
            <a
              href="https://nextjs.org"
              className="underline hover:text-foreground"
            >
              Next.js 15
            </a>{' '}
            and{' '}
            <a
              href="https://claude.ai/code"
              className="underline hover:text-foreground"
            >
              Claude Code
            </a>
          </p>
        </div>
      </footer>
    </div>
  )
}
