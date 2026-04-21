
# Vision Career



## Table of Contents

* [Overview](#overview)
* [How to Start](#how-to-start)
* [Why This Project Exists](#why-this-project-exists)
* [Core Idea](#core-idea)
* [Main User Flow](#main-user-flow)
* [Key Features](#key-features)
* [Tech Stack](#tech-stack)
* [Project Structure](#project-structure)
* [Current Architecture Direction](#current-architecture-direction)
* [Data Model Overview](#data-model-overview)
* [Screens and Modules](#screens-and-modules)
* [Learning Resource Strategy](#learning-resource-strategy)
* [Assessment Philosophy](#assessment-philosophy)
* [Roadmap](#roadmap)
* [Getting Started](#getting-started)
* [Repository Goals](#repository-goals)
* [Status](#status)
* [Contribution Note](#contribution-note)




---


## overview


**AI-guided academic and career path planning for university students.**

Vision Career is a Flutter mobile application that helps students move from **uncertainty** to a **structured, guided path**.

Instead of randomly choosing courses, the app routes the user through:

- **Phase 0** — discover the right major/specialization
- **Phase 1** — complete foundation subjects
- **Phase 2** — complete specialization subjects
- **Phase 3** — become more job-ready with targeted final learning nodes

The current system is dataset-driven and uses a prerequisite graph to build the learning tree, while AI is used where it adds value: discovery, recommendation, quiz generation, and final career preparation. fileciteturn4file2L1-L9 fileciteturn4file3L1-L12 fileciteturn4file0L1-L10

---

## How to Start

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd vision_career_mobile
```

---

### 2. Install Dependencies

```bash
flutter pub get
```

---

### 3. Configure Required API Keys

Before running the project, you must add your API keys manually.

#### Gemini API Key

Open:

`lib/core/constants/gemini_quiz_config.dart`

Add your Gemini API key there.

---

#### Vertex / Discovery Engine / Custom Search Configuration

Open:

`lib/core/constants/vertex_search_config.dart`

Add your:

* Custom Search API / Search configuration
* Discovery Engine / Vertex AI Search configuration

---

### 4. Run the App

```bash
flutter run
```

---

### 5. Recommended Setup Notes

* Use a physical device or emulator.
* Ensure Flutter SDK is installed and configured.
* Make sure your APIs are enabled in Google Cloud / Vertex AI before testing.
* If learning resources or AI recommendations fail, verify your API keys/config first.

---

## Important Security Note

Do **NOT** commit real API keys to public repositories.
Use placeholder values before pushing to GitHub if the repository is public.



## Why this project exists

Many students know they want a strong future, but they do **not** know:

- which college direction fits them best
- which specialization to choose
- what to learn first
- how subjects connect together
- how to prepare for a real job after graduation

Vision Career turns that confusion into a **clear path**.

The app is designed to guide the student from exploration to specialization to career readiness through one connected system. The intended journey is: **Student → Structured Learning → Skill Development → Career Preparation → Job Readiness**. fileciteturn4file1L1-L11 fileciteturn4file1L42-L67

---

## Core idea

Vision Career is built around a simple product promise:

> Help the user choose the right direction, enter the correct specialization tree, follow subjects in the right order, and finish with a stronger job-ready profile.

The app combines:

- **local structured datasets** for colleges, specializations, and subjects
- **prerequisite-based path generation** for stable learning trees
- **AI recommendation flows** for Phase 0 and Phase 3
- **quiz and integrity systems** for progress validation
- **learning resource retrieval** for subject support

The mobile app currently centers on a rule-based prerequisite graph and local JSON datasets, with AI layered on top for the experience that benefits from interpretation and personalization. fileciteturn4file2L1-L9 fileciteturn4file2L47-L76

---

## Main user flow

### 1. Phase 0 — discovery

Phase 0 replaces the old college/specialization entry flow with two smart entry points:

- **I Know What I Want**
- **I Don't Know Where I Fit**

Both routes end the same way: the user receives **valid specialty suggestions that already exist in the app**, selects one, and enters the specialization tree directly. The design rule is:

> **AI may suggest; the app must map and control all final logic.** fileciteturn4file3L1-L12

#### Flow A — I Know What I Want

The user writes a short free-text description of what they want to study, build, or become. Gemini receives that text plus the allowed specialty list and returns ranked recommendations from the supported specialties only. The app validates them locally before showing them to the user. fileciteturn4file3L13-L41

#### Flow B — I Don't Know Where I Fit

This is the main guided discovery flow:

1. **Preference Questions**
2. **AI Chat Follow-up**
3. **Fundamentals Quiz**
4. **Gemini analysis**
5. **Specialty recommendations**
6. **User chooses one and opens the tree**

Phase 0 is meant to feel intelligent but still deterministic: Gemini interprets and ranks, while the app validates, maps, stores, and navigates. fileciteturn4file3L42-L98 fileciteturn4file3L99-L135

---

### 2. Phase 1 — foundation

Once a specialty is selected, the app loads the **college foundation subjects** required before deeper specialization work. These subjects are ordered according to prerequisite relationships so the user learns in the right sequence. fileciteturn4file2L10-L18 fileciteturn4file2L47-L76

---

### 3. Phase 2 — specialization

After the foundation layer, the user continues through **specialization-specific subjects**. These are still represented as nodes in the same prerequisite-controlled structure, so the user progresses through a guided skill tree rather than a flat list. fileciteturn4file1L12-L31 fileciteturn4file2L47-L76

---

### 4. Phase 3 — final phase / career readiness

After completing Phase 1 and Phase 2, the user unlocks **FINAL PHASE**.

In this stage:

1. The app sends the user’s college, specialization, and completed subjects to an LLM.
2. The LLM returns a list of possible job roles.
3. The user selects up to 3 roles.
4. The LLM then returns 3–5 final learning topics.
5. The app builds those as final nodes, fetches learning resources, and reuses the quiz system.

Important design rule:

> **LLM suggests → App controls execution** fileciteturn4file0L11-L45 fileciteturn4file0L46-L76

Phase 3 exists to help the user move from “I finished the tree” to “I am more ready for internships, projects, and job applications.” fileciteturn4file0L1-L10 fileciteturn4file1L24-L40

---

## Key features

### AI-guided entry into the correct path

Instead of forcing the user to manually guess the right specialization first, Phase 0 helps them discover or confirm the correct direction. The app only shows specialties that exist in the local dataset. fileciteturn4file3L13-L41

### Dataset-driven skill trees

The real learning path is built from local structured subject data and prerequisites. This keeps the path deterministic, stable, and compatible with app-side validation. fileciteturn4file2L47-L76

### Prerequisite-based progression

Subjects are not just displayed — they are ordered by dependency logic so the user moves through the path in the correct academic sequence. fileciteturn4file2L47-L76

### Subject details + learning resources

Each node can include a description, skills gained, estimated learning value, and learning resources retrieved by the app. The broader student journey documentation describes this as each node containing topic description, learning time, skill explanation, and source support. fileciteturn4file1L32-L41

### Quizzes before completion

A node is not just checked off visually. The project reuses quiz flows to validate learning before completion and unlocking. In Phase 3, the documented rule is 20 MCQs, pass score at least 60%, and zero integrity flags. fileciteturn4file0L52-L76

### Integrity / anti-cheat support

The system includes quiz security ideas such as screenshot blocking, copy/paste restrictions, and abnormal quiz-session monitoring to protect assessment integrity. fileciteturn4file1L46-L56

### Progress tracking

The user can track completed nodes, remaining work, and overall progression across the path. fileciteturn4file1L57-L67

---

## Tech stack

### Frontend

- **Flutter**
- **Dart**

### Local data / app-side logic

- **Local JSON dataset** for MVP
- **Rule-based prerequisite graph**
- Local persistence/services inside the mobile app architecture

### AI / service layer used in the project

- **Gemini** for Phase 0 recommendation logic and quiz generation flows
- **Vertex AI Search** for learning resource retrieval and ranking support

### Planned / optional backend direction

The technical documentation notes a future backend direction using **Python FastAPI**, moving from MVP-style local behavior toward a fuller service architecture later. fileciteturn4file2L19-L23 fileciteturn4file2L36-L46

---

## Project structure

Current project skeleton provided in the repo materials: fileciteturn4file5L1-L66

```text
vision_career_mobile/
|-- assets/
|   |-- data/
|   |   `-- vision_career_phase1_phase2_master_dataset_rebuilt.json
|   `-- json/
|       |-- it_subject_graph.xlsx
|       |-- vision_career_phase1_phase2_dataset.json
|       `-- vision_career_phase1_phase2_dataset.xlsx
`-- lib/
    |-- app/
    |   |-- app.dart
    |   |-- routes.dart
    |   `-- theme.dart
    |-- core/
    |   |-- constants/
    |   |-- services/
    |   `-- utils/
    |-- data/
    |   |-- datasources/
    |   |-- models/
    |   `-- repositories/
    |-- features/
    |   |-- auth/
    |   |-- career/
    |   |-- college_selection/
    |   |-- common/
    |   |-- path_view/
    |   |-- phase0/
    |   |-- profile/
    |   |-- quiz/
    |   |-- specialization_selection/
    |   `-- subject_details/
    `-- main.dart
```

### Important folders

- `lib/features/phase0/` — AI-guided entry flow
- `lib/features/path_view/` — learning tree screen
- `lib/features/subject_details/` — node details
- `lib/features/quiz/` — quiz widgets and completion flows
- `lib/features/career/` — Phase 3 career readiness flow
- `lib/core/services/` — app services for auth, Phase 0, Phase 3, quiz, progress, profile, security, and resource retrieval fileciteturn4file5L16-L66

---

## Current architecture direction

The project has evolved beyond a simple college/specialization picker.

### What is already part of the product direction

- AI-guided Phase 0 entry
- Tree-based subject progression
- Local specialty mapping and validation
- Dynamic resource support
- Quiz-based completion logic
- Career-focused Phase 3 generation
- Auth/profile foundation inside the mobile project structure fileciteturn4file3L136-L191 fileciteturn4file0L77-L96 fileciteturn4file5L16-L66

### Product principle

The project consistently follows this split:

- **AI handles interpretation and ranking**
- **The app handles validation, mapping, persistence, and navigation** fileciteturn4file3L99-L135

That principle is what keeps the system impressive for demos while still safe enough to build and debug in production-minded steps. fileciteturn4file3L192-L195

---

## Data model overview

The mobile technical documentation describes the MVP around these core entities:

- `colleges`
- `specializations`
- `subjects`
- `prerequisites`
- `user_progress` fileciteturn4file2L24-L35

At the path level, the app takes:

- selected college
- selected specialization

Then it:

- loads subjects
- loads prerequisites
- performs graph traversal
- outputs ordered Phase 1 and Phase 2 subjects fileciteturn4file2L47-L76

---

## Screens and modules

Documented MVP and current project skeleton together indicate these important application areas:

### Entry and account
- Splash / onboarding
- Login / register
- Profile

### Discovery and path selection
- Phase 0 home
- “I Know What I Want”
- “I Don’t Know Where I Fit” stages
- Specialty recommendation

### Learning flow
- Path view screen
- Subject details screen
- Quiz components
- Progress logic

### Final career flow
- Career selection / summary
- Job selection
- Phase 3 path screen fileciteturn4file2L24-L35 fileciteturn4file5L35-L66

---

## Learning resource strategy

Phase 3 documentation states that learning resources reuse the existing retrieval system with these rules:

- maximum 4 resources
- maximum 2 Coursera resources
- priority order: **Coursera → Udemy → YouTube** fileciteturn4file0L46-L51

This keeps the AI focused on recommending **what** the user should learn, while the app stays responsible for fetching suitable resources. fileciteturn4file0L88-L96

---

## Assessment philosophy

Vision Career is not meant to be only a path visualizer. It is meant to verify progress.

The student journey and Phase 3 documents describe a system where:

- the user studies a node
- the user completes a quiz
- successful completion unlocks the next step
- integrity rules help protect fairness during assessment fileciteturn4file1L42-L56 fileciteturn4file0L52-L76

This makes the path feel more like guided progression and less like a static checklist.

---

## Roadmap

Based on the uploaded documentation, the broader roadmap includes:

### Near-term / implemented direction
- AI-guided Phase 0
- Phase 1 + Phase 2 learning trees
- subject details and progress tracking
- quiz generation and validation flows
- learning resource integration
- Phase 3 job-readiness generation

### Later evolution
- stronger backend/API support
- richer user accounts and persistence
- broader college coverage
- more advanced AI assistance inside the app fileciteturn4file2L77-L91 fileciteturn4file0L77-L96

---

## Getting started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- A connected emulator or physical device

### Run locally

```bash
flutter pub get
flutter run
```

### Build release APK

```bash
flutter build apk
```

If your local setup uses API keys or service configs for Gemini or Vertex, keep them out of the public repo and move them to secure configuration before publishing.

---

## Repository goals

This repo is a strong fit for anyone interested in:

- Flutter product development
- AI-assisted UX flows
- academic planning systems
- guided learning-tree products
- quiz and assessment design
- career-readiness tooling for students

---

## Status

Vision Career is an evolving product prototype / student-built system with a clear architecture direction:

- **Phase 0** for intelligent entry
- **Phase 1 + Phase 2** for structured academic progression
- **Phase 3** for job readiness

The project is designed to grow from a local-data MVP into a more complete AI-powered education and career platform over time. fileciteturn4file2L77-L91 fileciteturn4file0L1-L10

---

## Contribution note

This repository reflects an actively evolving academic/product build. If you fork or extend it, keep the core system rule intact:

> **AI suggests. The app validates and decides.** fileciteturn4file3L99-L135

That rule is the backbone of the whole project.
