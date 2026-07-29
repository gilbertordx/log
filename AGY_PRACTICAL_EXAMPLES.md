# 🚀 Antigravity (`agy`) Ultimate Practical Examples & Prompts Cheatsheet

A comprehensive, real-world reference of prompts, workflows, and commands for all **16 specialized agents/skills** configured in your AGY ecosystem.

---

## 📚 Table of Contents
1. [🛡️ Code Reviewer & Security Auditor (`code-reviewer`)](#1-code-reviewer--security-auditor-code-reviewer)
2. [🧪 Test & Verification Specialist (`test-automation`)](#2-test--verification-specialist-test-automation)
3. [🏗️ Refactoring & Architecture Expert (`refactor-assistant`)](#3-refactoring--architecture-expert-refactor-assistant)
4. [⚙️ DevOps & Terminal Automation (`devops-assistant`)](#4-devops--terminal-automation-devops-assistant)
5. [🔀 Git & Release Manager (`git-workflow-specialist`)](#5-git--release-manager-git-workflow-specialist)
6. [📝 Documentation & API Generator (`doc-writer`)](#6-documentation--api-generator-doc-writer)
7. [⚡ Performance & Profiling Specialist (`performance-optimizer`)](#7-performance--profiling-specialist-performance-optimizer)
8. [🗄️ Database & Schema Architect (`db-migrator`)](#8-database--schema-architect-db-migrator)
9. [🎨 UI/UX & Frontend Specialist (`ui-ux-designer`)](#9-uiux--frontend-specialist-ui-ux-designer)
10. [🔒 DevSecOps & Security Auditor (`security-auditor`)](#10-devsecops--security-auditor-security-auditor)
11. [🔌 External API & Webhook Specialist (`api-integrator`)](#11-external-api--webhook-specialist-api-integrator)
12. [🤖 LLM Prompt & RAG Specialist (`ai-prompt-engineer`)](#12-llm-prompt--rag-specialist-ai-prompt-engineer)
13. [🧹 Clean Code & Code Smell Engineer (`clean-code-sanitizer`)](#13-clean-code--code-smell-engineer-clean-code-sanitizer)
14. [📐 System Design & Clean Architecture (`software-architect`)](#14-system-design--clean-architecture-software-architect)
15. [🐛 Deep Root Cause Debugger (`debug-investigator`)](#15-deep-root-cause-debugger-debug-investigator)
16. [🤖 Code Generator & Scaffold Specialist (`code-automator`)](#16-code-generator--scaffold-specialist-code-automator)
17. [🔥 Multi-Agent Orchestration Recipes](#17-multi-agent-orchestration-recipes)
18. [🎯 Slash Commands & Context `@` Mentions](#18-slash-commands--context--mentions)

---

## 1. 🛡️ Code Reviewer & Security Auditor (`code-reviewer`)
* **Prompt**: `"Run a security audit and code review on my recent git diff."`
* **Prompt**: `"Inspect @src/auth/jwt.ts for potential security vulnerabilities or unhandled exceptions."`

---

## 2. 🧪 Test & Verification Specialist (`test-automation`)
* **Prompt**: `"Run the test suite, analyze any failure output, and fix the root cause."`
* **Prompt**: `"Find all untested helper functions in @src/utils/ and generate unit tests using Jest."`

---

## 3. 🏗️ Refactoring & Architecture Expert (`refactor-assistant`)
* **Prompt**: `"Refactor @src/services/order.ts to split monolithic functions into modular helpers."`
* **Prompt**: `"Convert callbacks in @lib/db.js to clean async/await syntax."`

---

## 4. ⚙️ DevOps & Terminal Automation (`devops-assistant`)
* **Prompt**: `"Write a bash script to set up local environment dependencies and verify tool versions."`
* **Prompt**: `"Diagnose why the Docker build command failed by inspecting Dockerfile and build logs."`

---

## 5. 🔀 Git & Release Manager (`git-workflow-specialist`)
* **Prompt**: `"Inspect current git status and craft conventional commit messages for staged changes."`
* **Prompt**: `"Help me resolve merge conflict markers in @src/routes/api.ts cleanly."`

---

## 6. 📝 Documentation & API Generator (`doc-writer`)
* **Prompt**: `"Generate OpenAPI 3.0 YAML specification for all REST routes in @src/controllers/."`
* **Prompt**: `"Add JSDoc annotations to all exported functions in @src/utils/math.ts."`

---

## 7. ⚡ Performance & Profiling Specialist (`performance-optimizer`)
* **Prompt**: `"Audit @src/db/queries.ts for N+1 query bottlenecks and suggest optimized SQL JOINs."`
* **Prompt**: `"Identify memory leaks or unhandled listener cleanups in @src/events/hub.ts."`

---

## 8. 🗄️ Database & Schema Architect (`db-migrator`)
* **Prompt**: `"Design a Prisma schema for a multi-tenant subscription system."`
* **Prompt**: `"Generate a PostgreSQL migration script adding indexing to user_email and created_at."`

---

## 9. 🎨 UI/UX & Frontend Specialist (`ui-ux-designer`)
* **Prompt**: `"Design a responsive dashboard layout using Tailwind CSS with dark mode support and smooth glassmorphism transitions."`
* **Prompt**: `"Audit @src/components/Navigation.tsx for ARIA accessibility compliance and keyboard navigation."`

---

## 10. 🔒 DevSecOps & Security Auditor (`security-auditor`)
* **Prompt**: `"Run npm audit, fix safe vulnerabilities, and configure Content Security Policy (CSP) headers."`
* **Prompt**: `"Scan the codebase for leaked secrets or insecure CORS configurations."`

---

## 11. 🔌 External API & Webhook Specialist (`api-integrator`)
* **Prompt**: `"Build a Stripe webhook endpoint in Express with HMAC signature verification and exponential backoff retry."`
* **Prompt**: `"Create a TypeScript wrapper for the OpenAI API with Zod payload validation and rate limit handling."`

---

## 12. 🤖 LLM Prompt & RAG Specialist (`ai-prompt-engineer`)
* **Prompt**: `"Design a system prompt that forces JSON output matching this JSON schema: [paste schema]."`
* **Prompt**: `"Build a document chunking and embedding retrieval pipeline using pgvector and LangChain."`

---

## 13. 🧹 Clean Code & Code Smell Engineer (`clean-code-sanitizer`)
* **Prompt**: `"Audit @src/legacy/ service for SOLID/DRY/KISS violations, remove magic numbers, and flatten nested if-else statements."`
* **Prompt**: `"Clean up dead code, unused imports, and ambiguous variable names in this file."`

---

## 14. 📐 System Design & Clean Architecture (`software-architect`)
* **Prompt**: `"Structure a Clean Architecture folder layout separating Domain Entities, Use Cases, Controllers, and Repositories."`
* **Prompt**: `"Apply the Strategy pattern to replace switch-case logic in @src/payment/processor.ts."`

---

## 15. 🐛 Deep Root Cause Debugger (`debug-investigator`)
* **Prompt**: `"Investigate this stack trace [paste trace]: isolate the exact line causing the crash and write a regression test."`
* **Prompt**: `"Trace why state mutation is causing unexpected re-renders in @src/context/user.tsx."`

---

## 16. 🤖 Code Generator & Scaffold Specialist (`code-automator`)
* **Prompt**: `"Scaffold a complete CRUD module (Model, DTO, Repository, Service, Controller) for the Product entity."`
* **Prompt**: `"Generate DTO mapping functions between entity models and API response types."`

---

## 17. 🔥 Multi-Agent Orchestration Recipes

### 🧼 Clean Code & Architecture Makeover
> `"Re-architect @src/controllers/order.ts into Clean Architecture layers, apply Clean Code principles to eliminate code smells, write automated unit tests, and format conventional git commits."`
*(Triggers `software-architect` + `clean-code-sanitizer` + `test-automation` + `git-workflow-specialist`)*

### 🐛 Deep Debug & Fix Pipeline
> `"Investigate this crash log, isolate the root cause, write a regression test, clean up the surrounding code, and audit for security risks."`
*(Triggers `debug-investigator` + `test-automation` + `clean-code-sanitizer` + `security-auditor`)*

---

## 18. 🎯 Slash Commands & Context `@` Mentions

| Feature | Example | Description |
| :--- | :--- | :--- |
| **`/plan`** | `/plan Add TypeScript support` | Generates a structured implementation plan artifact before editing code |
| **`/grill-me`** | `/grill-me` | Interactive interview to align on design decisions |
| **`/schedule`** | `/schedule CronExpression="0 * * * *"` | Sets recurring background timers or tasks |
| **`@ File`** | `@src/auth/jwt.ts` | Injects exact file context into prompt |
| **`@ Terminal`**| `@Terminal 1` | Injects exact terminal output context into prompt |
