'use client'

import { useFormState, useFormStatus } from 'react-dom'
import { loginUser } from '@/app/actions/auth'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

// Submit button with loading state
function SubmitButton() {
  const { pending } = useFormStatus()

  return (
    <Button type="submit" className="w-full" disabled={pending}>
      {pending ? 'Signing in...' : 'Sign In'}
    </Button>
  )
}

export function LoginForm() {
  const [state, formAction] = useFormState(loginUser, null)

  return (
    <form action={formAction} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="email">Email</Label>
        <Input
          id="email"
          name="email"
          type="email"
          placeholder="you@example.com"
          required
        />
      </div>

      <div className="space-y-2">
        <Label htmlFor="password">Password</Label>
        <Input
          id="password"
          name="password"
          type="password"
          placeholder="••••••••"
          required
        />
      </div>

      {state?.error && (
        <div className="rounded-md bg-destructive/15 p-3">
          <p className="text-sm text-destructive">{state.error}</p>
        </div>
      )}

      {state?.success && (
        <div className="rounded-md bg-green-500/15 p-3">
          <p className="text-sm text-green-700">Signed in successfully!</p>
        </div>
      )}

      <SubmitButton />
    </form>
  )
}
