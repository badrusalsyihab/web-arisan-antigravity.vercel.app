---
name: senior-software-engineer-workflow
description: Standard workflow for end-to-end system/application development following Senior Software Engineer principles. Covers Planning & Business Research, UI/UX Wireframing, Tech Stack & Database Selection, and Execution.
---

# Senior Software Engineer - System & Application Development Standard Workflow

As a Senior Software Engineer, every system or application development follows a structured, robust, and scalable engineering lifecycle divided into three main preparation phases prior to execution.

---

## Phase 1: Planning & Business Flow Research

### Objectives
- Define the system core goals, business requirements, and target users.
- Map out the complete business workflow and user interaction steps.

### Deliverables & Checklist
1. **Business Flow & Process Mapping**:
   - Primary user roles (e.g., Admin, Member, Treasury, Visitor).
   - Core domain business logic (e.g., Registration -> Group Creation -> Contribution Period -> Random Winner Selection -> Payout -> Cycle Reset).
   - Activity & Sequence flow.
2. **Feature Breakdown (MVP vs Next Phase)**:
   - Must-have features for Minimum Viable Product (MVP).
   - Optional/Nice-to-have features for future iterations.
3. **Domain & Data Requirements**:
   - Key entities and data lifecycle (Status changes, audit logs, transactions).

---

## Phase 2: Wireframing & UI/UX Design

### Objectives
- Transform abstract business requirements into visual, intuitive, and modern UI/UX designs.
- Validate user experience and visual layouts prior to heavy coding.

### Deliverables & Checklist
1. **Visual Wireframe & Prototypes**:
   - Interactive HTML/CSS prototypes, wireframe layouts, or visual AI mockups (e.g., Google Stitch / Antigravity visual mockups).
   - Page hierarchy: Landing Page, Dashboard, Detail Views, Forms, Modals.
2. **Design System & Aesthetics**:
   - Palette (Tailored HSL/Hex, Dark/Light theme, glassmorphism, accent colors).
   - Typography & Iconography.
   - Interactive states (Hover effects, animations, loading states, empty states).

---

## Phase 3: Technology Stack & Database Selection

### Objectives
- Select the best technical stack matching scalability, speed of development, team capability, and project scale.
- Design database schema and system architecture.

### Tech Stack Matrix
- **Frontend / Client App**:
  - Web: Next.js (SSR/Fullstack), React + Vite (SPA), Vue/Nuxt, Svelte.
  - Mobile / Cross-Platform: Flutter, React Native.
- **Backend / API**:
  - Fullstack: Next.js API Routes, Laravel (PHP), Ruby on Rails.
  - Microservices / High Performance API: Go (Golang), Node.js (NestJS/Express), Python (FastAPI).
- **Database**:
  - Relational: PostgreSQL, MySQL.
  - NoSQL / Real-time: Firebase Firestore, MongoDB.
  - In-Memory / Caching: Redis.

### Deliverables & Checklist
1. **Architecture Diagram & API Strategy** (RESTful API / GraphQL / Monolith / Microservices).
2. **Database Entity Relationship Diagram (ERD)** & Schema Definition.
3. **Project Setup & Folder Structure Guideline**.

---

## Phase 4: Implementation & Verification Plan

1. **Implementation Plan Creation**: Formalize step-by-step dev plan.
2. **Clean Code & Architecture**: Follow SOLID principles, Layered Architecture (UI -> Logic -> Data).
3. **Verification & Testing**: Automated tests, manual walkthrough, performance & security checks.
