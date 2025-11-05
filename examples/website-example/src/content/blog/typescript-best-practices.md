---
title: "TypeScript Best Practices for Modern Web Apps"
description: "Essential TypeScript patterns and practices to write safer, more maintainable code"
publishDate: 2025-01-05
author: "Tech Blog"
tags: ["typescript", "best-practices", "javascript", "web-development"]
image: "/images/typescript.jpg"
---

# TypeScript Best Practices for Modern Web Apps

TypeScript has become the de facto standard for large-scale JavaScript applications. Here are essential best practices to write better TypeScript code.

## Use Strict Mode

Always enable strict mode in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

## Type Inference Over Explicit Types

Let TypeScript infer types when obvious:

```typescript
// ❌ Avoid
const count: number = 5;
const name: string = "John";

// ✅ Better
const count = 5;
const name = "John";
```

But be explicit when helpful:

```typescript
// ✅ Good - Intent is clear
function getUser(id: string): Promise<User> {
  return fetch(`/api/users/${id}`).then(r => r.json());
}
```

## Avoid `any`

Use proper types instead of `any`:

```typescript
// ❌ Avoid
function processData(data: any) {
  return data.value;
}

// ✅ Better - Use generics
function processData<T extends { value: unknown }>(data: T) {
  return data.value;
}

// ✅ Best - Define specific type
interface DataWithValue {
  value: string;
}

function processData(data: DataWithValue) {
  return data.value;
}
```

## Use Union Types

Model your data accurately:

```typescript
// ✅ Good
type Status = 'loading' | 'success' | 'error';

interface ApiState {
  status: Status;
  data?: User;
  error?: Error;
}
```

## Discriminated Unions

Perfect for state management:

```typescript
type LoadingState = { status: 'loading' };
type SuccessState = { status: 'success'; data: User };
type ErrorState = { status: 'error'; error: Error };

type ApiState = LoadingState | SuccessState | ErrorState;

function handleState(state: ApiState) {
  switch (state.status) {
    case 'loading':
      return <Spinner />;
    case 'success':
      return <UserProfile user={state.data} />;
    case 'error':
      return <ErrorMessage error={state.error} />;
  }
}
```

## Utility Types

Leverage built-in utilities:

```typescript
interface User {
  id: string;
  name: string;
  email: string;
  age: number;
}

// Make all properties optional
type PartialUser = Partial<User>;

// Make all properties required
type RequiredUser = Required<User>;

// Pick specific properties
type UserPreview = Pick<User, 'id' | 'name'>;

// Omit specific properties
type UserWithoutEmail = Omit<User, 'email'>;

// Make all properties readonly
type ReadonlyUser = Readonly<User>;
```

## Type Guards

Safely narrow types:

```typescript
function isError(value: unknown): value is Error {
  return value instanceof Error;
}

function handleResponse(response: unknown) {
  if (isError(response)) {
    console.error(response.message); // Type is Error
    return;
  }
  // Type is unknown, but not Error
}
```

## Never Use `null` and `undefined` Inconsistently

Pick one and stick with it:

```typescript
// ✅ Good - Consistent use of undefined
interface User {
  name: string;
  email?: string;  // undefined when not present
  age?: number;
}

// ❌ Avoid - Mixing null and undefined
interface User {
  name: string;
  email: string | null;
  age?: number | null;
}
```

## Generic Constraints

Make generics more specific:

```typescript
// ❌ Too broad
function getProperty<T>(obj: T, key: string) {
  return obj[key];  // Error: string can't index T
}

// ✅ Better
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const user = { name: "John", age: 30 };
const name = getProperty(user, "name");  // Type is string
const age = getProperty(user, "age");    // Type is number
```

## Const Assertions

Create more specific types:

```typescript
// ❌ Type is string[]
const colors = ['red', 'green', 'blue'];

// ✅ Type is readonly ['red', 'green', 'blue']
const colors = ['red', 'green', 'blue'] as const;
```

## Template Literal Types

Build string types:

```typescript
type Direction = 'top' | 'bottom' | 'left' | 'right';
type Alignment = 'start' | 'center' | 'end';

// Creates: 'top-start' | 'top-center' | ... (12 types)
type Position = `${Direction}-${Alignment}`;
```

## Avoid Type Assertions

Let TypeScript infer:

```typescript
// ❌ Avoid type assertions
const data = JSON.parse(jsonString) as User;

// ✅ Better - Validate at runtime
import { z } from 'zod';

const UserSchema = z.object({
  name: z.string(),
  email: z.string().email(),
  age: z.number(),
});

const data = UserSchema.parse(JSON.parse(jsonString));
```

## Function Overloads

Provide better types for different use cases:

```typescript
function createElement(tag: 'a'): HTMLAnchorElement;
function createElement(tag: 'div'): HTMLDivElement;
function createElement(tag: string): HTMLElement;
function createElement(tag: string): HTMLElement {
  return document.createElement(tag);
}

const link = createElement('a');  // Type: HTMLAnchorElement
```

## Organize Types

Keep types close to usage:

```typescript
// user.types.ts
export interface User {
  id: string;
  name: string;
  email: string;
}

export type UserRole = 'admin' | 'user' | 'guest';

// api.types.ts
import { User } from './user.types';

export interface ApiResponse<T> {
  data: T;
  error?: string;
}

export type UserResponse = ApiResponse<User>;
```

## Mapped Types

Transform existing types:

```typescript
// Make all properties mutable
type Mutable<T> = {
  -readonly [K in keyof T]: T[K];
};

// Make all properties nullable
type Nullable<T> = {
  [K in keyof T]: T[K] | null;
};

// Add prefixes to keys
type Prefixed<T, P extends string> = {
  [K in keyof T as `${P}${string & K}`]: T[K];
};
```

## Conclusion

TypeScript is a powerful tool that helps us write safer, more maintainable code. By following these best practices, you'll catch bugs earlier and make your codebase more robust.

Remember:
- Enable strict mode
- Let TypeScript infer when possible
- Use union types for state
- Leverage utility types
- Validate runtime data
- Keep types organized

Happy typing! 🎉

## Resources

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [TypeScript Deep Dive](https://basarat.gitbook.io/typescript/)
- [Type Challenges](https://github.com/type-challenges/type-challenges)
