import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: {
    default: '{{PROJECT_NAME_PASCAL}}',
    template: '%s | {{PROJECT_NAME_PASCAL}}',
  },
  description: 'Built with Next.js 15, TypeScript, Prisma, and NextAuth',
  keywords: ['Next.js', 'React', 'TypeScript', 'Prisma', 'NextAuth'],
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>{children}</body>
    </html>
  )
}
