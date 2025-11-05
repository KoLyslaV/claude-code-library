import { Metadata } from 'next'
import Link from 'next/link'
import { LoginForm } from '@/components/auth/LoginForm'

export const metadata: Metadata = {
  title: 'Sign In',
  description: 'Sign in to your account',
}

// Server Component by default
export default function SignInPage() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-muted/50 px-4">
      <div className="w-full max-w-md space-y-6">
        <div className="text-center">
          <h1 className="text-3xl font-bold">Sign In</h1>
          <p className="mt-2 text-muted-foreground">
            Enter your credentials to access your account
          </p>
        </div>

        <div className="rounded-lg border bg-card p-6 shadow-sm">
          <LoginForm />

          <div className="mt-4 text-center text-sm">
            <span className="text-muted-foreground">
              Don't have an account?{' '}
            </span>
            <Link
              href="/auth/signup"
              className="font-medium text-primary hover:underline"
            >
              Sign up
            </Link>
          </div>
        </div>

        <div className="text-center">
          <Link
            href="/"
            className="text-sm text-muted-foreground hover:text-foreground"
          >
            ← Back to home
          </Link>
        </div>
      </div>
    </div>
  )
}
