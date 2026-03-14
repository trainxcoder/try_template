# GitHub Copilot Instructions

## Project Overview
- **Type**: Next.js 16 web application (web-first, no React Native)
- **Purpose**: Vietnamese real-time news monitoring dashboard
- **Stack**: Next.js, React, TypeScript, Tailwind CSS / custom CSS, Firebase Cloud Functions
- **Architecture**: App Router, client-side SPA dashboard, external Firebase proxy API

## Development Guidelines

### Code Style
- Use TypeScript for all files
- Prefer functional components with hooks
- Use the existing globals.css class conventions for styling (avoid CSS modules or styled-components)
- Write clean, readable code with meaningful names
- Add comments for complex logic and educational purposes
- **Avoid Magic Strings**: Use TypeScript enums, const assertions, or union types instead of string literals
- **Type-Safe Constants**: Define enums or const objects for repeated string values (category keys, statuses, etc.)
- **Avoid Unnecessary Assignments**: Don't create intermediate variables for simple pass-through values
- **Direct Property Access**: Use `prop={result.data}` instead of `const data = result.data; prop={data}`
- Use strict TypeScript interfaces for component props and API responses to ensure type safety and clarity for beginners.
- For internal variables within component implementations, you may use less strict typing or type inference to keep code readable and maintainable, but still follow industry standard and modern trending practices.
- Always document the purpose of interfaces and variables with comments, especially when type flexibility is used for readability.

### Component Patterns
- **Server/Client Separation**: Use server components for data fetching, client components for interactivity
- Use `'use client'` directive only for components that need React hooks or event handlers
- Keep components small and focused (single responsibility)
- Use proper TypeScript interfaces for props with educational comments
- Implement proper error boundaries and loading states
- Prefer server-side data fetching with async/await over client-side useEffect

### API Integration
- **Server-side First**: Prefer server components with async/await for data fetching
- Use client-side fetching only when necessary (user interactions, real-time updates)
- Implement proper error handling with user-friendly messages
- Add loading states with Next.js streaming (loading.tsx files)
- Use TypeScript for API response types

### API-First Development
- **No Mock Data Fallbacks**: Avoid try-catch patterns that fall back to mock data when APIs fail
- **Fail Fast**: Let API errors propagate naturally to provide authentic error handling
- **Production Parity**: Development environment should behave like production
- **Real Error Messages**: Users and developers should see actual API problems, not fake success
- **Error Propagation**: Use proper error boundaries instead of silent fallbacks
- **Authentic Testing**: Test with real API failures, not mock data that masks problems

### File Structure
```
frontend/src/
├── app/           # App Router pages and layouts
│   ├── page.tsx   # Dashboard page ('use client' SPA entry)
│   ├── layout.tsx # Root HTML shell + metadata
│   └── globals.css
├── components/    # Reusable UI components
├── config/        # Feed list + category definitions
├── hooks/         # Custom React hooks (polling, state)
├── types/         # TypeScript type definitions
└── utils/         # RSS parser, sanitize, date helpers
```

### Common Patterns to Suggest
- React functional components with TypeScript
- Server components with async/await for data fetching
- Client components with useState and useEffect hooks only when needed
- Proper error handling with try/catch and user-friendly messages
- Next.js streaming with loading.tsx files
- Responsive design with Tailwind / utility classes
- Clean, semantic HTML structure
- Educational comments explaining React/Next.js patterns for beginners
- **Type-safe enums and constants**: Use `enum` or `const` assertions for string literals

#### Production-Ready Patterns
- **API-First Architecture**: Direct API calls without mock data fallbacks
- **Authentic Error Handling**: Let real errors surface instead of masking with fake data
- **Separation of Concerns**: User-friendly error messages + comprehensive developer logging
- **Consistent Error Design**: Same error page patterns across all routes
- **Context-Aware Actions**: Error pages with relevant retry actions and parameters
- **Performance Optimization**: Remove unnecessary try-catch overhead from fallback logic

#### Type-Safe Constants Pattern
```tsx
// ❌ Avoid: Magic strings scattered throughout code
const activeCategory = 'all'
if (activeCategory === 'politics') { ... }

// ✅ Preferred: Const assertion with union type
const CATEGORY_KEYS = {
  ALL: 'all',
  POLITICS: 'politics',
  BUSINESS: 'business',
} as const

type CategoryKey = typeof CATEGORY_KEYS[keyof typeof CATEGORY_KEYS]

// ✅ Alternative: TypeScript enum for type safety
enum CategoryKey {
  ALL = 'all',
  POLITICS = 'politics',
  BUSINESS = 'business',
}

// Usage examples:
const active = CategoryKey.ALL
if (active === CategoryKey.POLITICS) { ... }

// Props interface with typed constraint
interface CategoryTabsProps {
  active: CategoryKey;  // Type-safe, autocomplete-friendly
}
```

#### Direct Property Access Pattern
```tsx
// ❌ Avoid: Unnecessary intermediate assignments
const feedState = useFeeds()
const articles = feedState.articles
const errors = feedState.errors

return <Header errorCount={errors.length} />

// ✅ Preferred: Destructure directly
const { articles, lastUpdated, isLoading, errors } = useFeeds()

return <Header errorCount={errors.length} />
```
