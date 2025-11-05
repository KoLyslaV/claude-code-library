'use server'

import { z } from 'zod'
import { signIn, signOut } from '@/auth'
import { AuthError } from 'next-auth'
import { redirect } from 'next/navigation'
import { prisma } from '@/lib/prisma'
import { hash } from 'bcryptjs'

// ============================================================================
// SCHEMA DEFINITIONS (Step 1 of Type-Safe Server Action pattern)
// ============================================================================

const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
})

const registerSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
})

// ============================================================================
// SERVER ACTIONS (Step 2 of Type-Safe Server Action pattern)
// ============================================================================

export async function loginUser(prevState: any, formData: FormData) {
  // Parse and validate form data
  const rawData = {
    email: formData.get('email'),
    password: formData.get('password'),
  }

  const validated = loginSchema.safeParse(rawData)

  if (!validated.success) {
    return {
      error: validated.error.errors[0].message,
    }
  }

  const { email, password } = validated.data

  try {
    // Attempt sign in with NextAuth
    await signIn('credentials', {
      email,
      password,
      redirect: false,
    })
  } catch (error) {
    if (error instanceof AuthError) {
      switch (error.type) {
        case 'CredentialsSignin':
          return { error: 'Invalid email or password' }
        default:
          return { error: 'Something went wrong. Please try again.' }
      }
    }
    throw error
  }

  // Redirect on success
  redirect('/dashboard')
}

export async function registerUser(prevState: any, formData: FormData) {
  // Parse and validate form data
  const rawData = {
    name: formData.get('name'),
    email: formData.get('email'),
    password: formData.get('password'),
  }

  const validated = registerSchema.safeParse(rawData)

  if (!validated.success) {
    return {
      error: validated.error.errors[0].message,
    }
  }

  const { name, email, password } = validated.data

  try {
    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { email },
    })

    if (existingUser) {
      return { error: 'Email already registered' }
    }

    // Hash password
    const hashedPassword = await hash(password, 12)

    // Create user
    await prisma.user.create({
      data: {
        name,
        email,
        password: hashedPassword,
      },
    })

    // Auto sign in after registration
    await signIn('credentials', {
      email,
      password,
      redirect: false,
    })
  } catch (error) {
    return {
      error: 'Failed to create account. Please try again.',
    }
  }

  // Redirect on success
  redirect('/dashboard')
}

export async function logoutUser() {
  await signOut({ redirectTo: '/' })
}
