import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  reactStrictMode: true,
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**.unsplash.com'
      },
      {
        protocol: 'https',
        hostname: '**.cloudinary.com'
      }
    ]
  },
  experimental: {
    typedRoutes: true
  }
}

export default nextConfig
