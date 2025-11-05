import { auth } from '@/auth'
import { NextResponse } from 'next/server'

// Protected routes that require authentication
const protectedRoutes = ['/dashboard', '/profile', '/settings']

// Admin-only routes
const adminRoutes = ['/admin']

// Public routes (explicitly allowed without auth)
const publicRoutes = ['/', '/auth/signin', '/auth/signup', '/auth/error']

export default auth((req) => {
  const { pathname } = req.nextUrl
  const isLoggedIn = !!req.auth

  // Check if route is protected
  const isProtectedRoute = protectedRoutes.some((route) =>
    pathname.startsWith(route)
  )

  // Check if route is admin-only
  const isAdminRoute = adminRoutes.some((route) => pathname.startsWith(route))

  // Check if route is public
  const isPublicRoute = publicRoutes.some((route) => pathname === route)

  // Redirect to signin if trying to access protected route without auth
  if (isProtectedRoute && !isLoggedIn) {
    const signInUrl = new URL('/auth/signin', req.url)
    signInUrl.searchParams.set('callbackUrl', pathname)
    return NextResponse.redirect(signInUrl)
  }

  // Redirect to dashboard if logged in and trying to access public auth pages
  if (isLoggedIn && pathname.startsWith('/auth/')) {
    return NextResponse.redirect(new URL('/dashboard', req.url))
  }

  // Check admin role for admin routes
  if (isAdminRoute) {
    if (!isLoggedIn) {
      const signInUrl = new URL('/auth/signin', req.url)
      signInUrl.searchParams.set('callbackUrl', pathname)
      return NextResponse.redirect(signInUrl)
    }

    if (req.auth?.user?.role !== 'admin') {
      return NextResponse.redirect(new URL('/dashboard', req.url))
    }
  }

  return NextResponse.next()
})

// Specify which routes to run middleware on
export const config = {
  matcher: [
    /*
     * Match all request paths except:
     * - _next/static (static files)
     * - _next/image (image optimization)
     * - favicon.ico (favicon)
     * - public folder
     * - API routes that handle their own auth
     */
    '/((?!_next/static|_next/image|favicon.ico|public/).*)',
  ],
}
