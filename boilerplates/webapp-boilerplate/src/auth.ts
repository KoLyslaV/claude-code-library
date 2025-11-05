import NextAuth from 'next-auth'
import { PrismaAdapter } from '@auth/prisma-adapter'
import Credentials from 'next-auth/providers/credentials'
import Google from 'next-auth/providers/google'
import GitHub from 'next-auth/providers/github'
import { prisma } from '@/lib/prisma'
import { compare } from 'bcryptjs'
import { z } from 'zod'

// Credential validation schema
const credentialsSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
})

export const { handlers, signIn, signOut, auth } = NextAuth({
  adapter: PrismaAdapter(prisma),
  session: {
    strategy: 'jwt',
  },
  pages: {
    signIn: '/auth/signin',
    error: '/auth/error',
  },
  providers: [
    // Credentials Provider (Email + Password)
    Credentials({
      name: 'credentials',
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        // Validate credentials with Zod
        const validated = credentialsSchema.safeParse(credentials)
        if (!validated.success) {
          return null
        }

        const { email, password } = validated.data

        // Find user by email
        const user = await prisma.user.findUnique({
          where: { email },
        })

        if (!user || !user.password) {
          return null
        }

        // Verify password
        const isValid = await compare(password, user.password)
        if (!isValid) {
          return null
        }

        // Return user object
        return {
          id: user.id,
          email: user.email,
          name: user.name,
          image: user.image,
          role: user.role,
        }
      },
    }),

    // OAuth Providers (optional - enable in .env)
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    }),
    GitHub({
      clientId: process.env.GITHUB_CLIENT_ID,
      clientSecret: process.env.GITHUB_CLIENT_SECRET,
    }),
  ],

  callbacks: {
    // Add user role to session
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.sub as string
        session.user.role = token.role as string
      }
      return session
    },

    // Add user role to token
    async jwt({ token, user }) {
      if (user) {
        token.role = user.role
      }
      return token
    },
  },

  // Enable debug in development
  debug: process.env.NODE_ENV === 'development',
})
