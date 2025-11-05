import { DefaultSession } from 'next-auth'

declare module 'next-auth' {
  /**
   * Extend the built-in session type with custom properties
   */
  interface Session {
    user: {
      id: string
      role: string
    } & DefaultSession['user']
  }

  /**
   * Extend the built-in user type with custom properties
   */
  interface User {
    role: string
  }
}

declare module 'next-auth/jwt' {
  /**
   * Extend the built-in JWT type with custom properties
   */
  interface JWT {
    role: string
  }
}
