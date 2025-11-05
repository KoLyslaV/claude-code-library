# Bugs Fixed

Document bugs here to extract patterns and prevent recurrence.

---

## Template for New Bug Entries

```
## YYYY-MM-DD - [Bug Title]

**Symptom:** [What user observed]

**Root Cause:** [Technical reason]

**Solution:** [How we fixed it]

**Prevention:** [How to avoid in future]

**Pattern:** [Link to CODE_PATTERNS.md if applicable]

**Files Changed:**
- [List of files]

**Time to Resolution:** [Hours spent]

**Recurrence:** [First time / Nth occurrence]
```

---

## Example Entry

## 2025-01-15 - Form Validation Not Working on Submit

**Symptom:** User could submit empty form, no validation errors shown

**Root Cause:** Forgot to add Zod validation in Server Action, only client-side validation

**Solution:**
- Added `safeParse` validation in `updateUser` Server Action
- Return validation errors to client
- Display errors below form fields

**Prevention:**
- ALWAYS validate in Server Actions (client validation can be bypassed)
- Use Pattern 1 (Type-Safe Server Action) from CODE_PATTERNS.md

**Pattern:** See CODE_PATTERNS.md - Pattern 1

**Files Changed:**
- `src/lib/actions/user.actions.ts`
- `src/components/features/ProfileForm.tsx`

**Time to Resolution:** 1 hour

**Recurrence:** First time

---

_No bugs fixed yet! This section will grow as you document fixes._
