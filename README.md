# El-Mostashar (المستشار) — Legal Case Management System

> **Flutter Desktop (Windows)** application for managing legal cases, court hearings, and user roles in an Arabic-language legal workflow. Built as a graduation project.

---

## Table of Contents

- [Quick Facts](#quick-facts)
- [Tech Stack](#tech-stack)
- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Feature Modules](#feature-modules)
- [State Management & Dependency Injection](#state-management--dependency-injection)
- [Networking & API Layer](#networking--api-layer)
- [API Endpoints Reference](#api-endpoints-reference)
- [Domain Models](#domain-models)
- [Theming & Design System](#theming--design-system)
- [Role-Based Access Control (RBAC)](#role-based-access-control-rbac)
- [Navigation & App Shell](#navigation--app-shell)
- [Authentication Flow](#authentication-flow)
- [Assets](#assets)
- [Getting Started](#getting-started)
- [Key Conventions & Patterns](#key-conventions--patterns)
- [Known Limitations & TODOs](#known-limitations--todos)

---

## Quick Facts

| Item | Value |
|---|---|
| **App Name** | El-Mostashar (المستشار) |
| **Package name** | `graduation_project` |
| **Root widget** | `ElMostasharApp` (`lib/app/el_mostashar_app.dart`) |
| **Platform** | Windows Desktop (Flutter) |
| **Language** | Dart 3.11+ |
| **UI Toolkit** | `fluent_ui` (Microsoft Fluent Design) |
| **State Management** | `flutter_riverpod` 2.x |
| **HTTP Client** | `dio` 5.x |
| **Responsive Scaling** | `flutter_screenutil` (design size: 1440×1024) |
| **Text Direction** | RTL (Arabic) |
| **Font** | Amiri (Regular, Bold, Italic, BoldItalic) |
| **Backend Base URL** | `http://localhost:8080/api` (configurable in `lib/app/config/env.dart`) |
| **Auth** | JWT Bearer tokens (access + refresh) |
| **Version** | 1.0.0+1 |

---

## Tech Stack

| Dependency | Version | Purpose |
|---|---|---|
| `fluent_ui` | ^4.14.0 | Windows-native Fluent Design widgets (replaces Material) |
| `flutter_riverpod` | ^2.6.1 | State management & DI |
| `dio` | ^5.9.1 | HTTP networking |
| `go_router` | ^17.1.0 | Routing (declared but not actively used; navigation is widget-based) |
| `flutter_screenutil` | ^5.9.3 | Responsive scaling for desktop |
| `intl` | ^0.20.2 | Arabic date formatting |
| `build_runner` | ^2.11.1 | Code generation (dev) |

---

## Architecture Overview

The project follows a **feature-first Clean Architecture** variant with three layers per feature:

```
feature/
├── data/              ← Data layer
│   ├── sources/       ← Remote data sources (Dio HTTP calls)
│   └── repositories/  ← Repository interfaces + implementations
├── domain/            ← Domain models / entities / enums
└── presentation/      ← UI layer
    ├── view/          ← Page widgets
    ├── viewmodel/     ← Riverpod state notifiers (ViewModels)
    ├── widgets/       ← Feature-specific reusable widgets
    └── validation/    ← Input validators (auth only)
```

**Data flow:** `View → ViewModel (Notifier) → Repository → RemoteDataSource (Dio) → Backend API`

Each feature has a `*_providers.dart` file at its root that wires up DI (Dio → DataSource → Repository → Provider).

---

## Project Structure

```
lib/
├── main.dart                          # Entry point: initializes Arabic locale, runs ProviderScope
├── app/
│   ├── el_mostashar_app.dart          # Root widget: ScreenUtilInit + FluentApp
│   ├── root_decider.dart              # Auth gate: shows HomeShell or AuthShell
│   ├── home_nav_provider.dart         # StateProvider<int> for sidebar selected index
│   ├── config/
│   │   └── env.dart                   # Env.baseUrl = 'http://localhost:8080/api'
│   ├── theme/
│   │   ├── app_theme.dart             # FluentThemeData configuration
│   │   └── design_tokens.dart         # Color palette, radius constants
│   └── shell/
│       ├── home_shell.dart            # Main layout: TopBar + SideMenu + page content
│       ├── side_menu.dart             # RTL sidebar with role-filtered menu items
│       ├── top_bar.dart               # Page title + notification bell
│       └── menu_items.dart            # Menu item definitions with role permissions
├── core/
│   └── network/
│       └── dio_provider.dart          # Global Dio provider with auth interceptor
├── shared/
│   └── widgets/
│       └── app_card.dart              # Reusable styled card container
└── features/
    ├── auth/                          # Authentication feature
    ├── cases/                         # Case management feature
    ├── dashboard/                     # Dashboard feature (admin + judge variants)
    ├── users/                         # User management feature (admin only)
    └── access_requests/               # Access requests feature (admin only)
```

---

## Feature Modules

### 1. Auth (`lib/features/auth/`)

**Purpose:** Login, signup, OTP verification, forgot password, and session management.

| Layer | Files | Description |
|---|---|---|
| **Providers** | `auth_providers.dart` | Wires `AuthRepo` via `authRepoProvider` |
| **Domain** | `domain/user_role.dart` | `UserRole` enum: `admin`, `lawyer`, `judge`, `unknown` + `parseRole()` |
| **Data** | `data/sources/auth_remote_ds.dart` | HTTP calls: login, signup, verifyOtp, getUserProfile |
| **Data** | `data/repositories/auth_repo.dart` | Abstract `AuthRepo` + `AuthResult` DTO |
| **Data** | `data/repositories/auth_repo_impl.dart` | Parses API responses, fetches profile after login |
| **Presentation** | `presentation/view/auth_shell.dart` | Auth page container with `AnimatedSwitcher` between login/signup/otp/forgot |
| **Presentation** | `presentation/view/login_view.dart` | Login form UI |
| **Presentation** | `presentation/view/signup_view.dart` | Signup form UI |
| **Presentation** | `presentation/view/otp_view.dart` | OTP verification screen |
| **Presentation** | `presentation/view/forgot_password_view.dart` | Forgot password screen |
| **Presentation** | `presentation/viewmodel/auth_session.dart` | `AuthSession` Notifier + `AuthSessionState` (tokens, role, userId, userName) |
| **Presentation** | `presentation/viewmodel/login_vm.dart` | `LoginVm` — form state, validation, submit |
| **Presentation** | `presentation/viewmodel/signup_vm.dart` | `SignupVm` — signup form state |
| **Presentation** | `presentation/viewmodel/otp_vm.dart` | `OtpVm` — OTP verification logic |
| **Presentation** | `presentation/viewmodel/user_role_provider.dart` | Derived `Provider<UserRole>` from session |
| **Presentation** | `presentation/validation/auth_validators.dart` | Email, password, nationalId, confirmPassword validators |
| **Presentation** | `presentation/widgets/auth_input.dart` | Styled text input for auth forms |
| **Presentation** | `presentation/widgets/password_input.dart` | Password input with toggle visibility |

**Auth Session State:**
```dart
class AuthSessionState {
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? role;       // "ADMIN", "LAWYER", "JUDGE"
  final String? userName;
  bool get isAuthed => accessToken != null && accessToken!.isNotEmpty;
}
```

### 2. Cases (`lib/features/cases/`)

**Purpose:** CRUD for legal cases with pagination, search, status management, and file attachments.

| Layer | Files | Description |
|---|---|---|
| **Providers** | `cases_providers.dart` | `casesRepoProvider`, `caseDetailsRepoProvider`, `caseStatusRepoProvider` |
| **Domain** | `domain/case_model.dart` | `CaseModel`: id, caseNumber, title, status, createdAt, judgeName, lawyerName, courtRuling |
| **Domain** | `domain/case_details_model.dart` | `CaseDetailsModel` + `CaseFile`: extended info with caseFiles, defenseFiles |
| **Domain** | `domain/case_status.dart` | `CaseStatus` enum: `pending`, `inProgress`, `completed` + helpers |
| **Domain** | `domain/page_info.dart` | `PageInfo`: pagination metadata (currentPage, totalPages, hasNext, etc.) |
| **Data** | `data/sources/cases_remote_ds.dart` | `fetchCases()` with role-based path routing |
| **Data** | `data/sources/case_remote_details_ds.dart` | `fetchDetails()` for single case |
| **Data** | `data/sources/case_status_remote_ds.dart` | `updateStatus()` via PATCH |
| **Data** | `data/repositories/cases_repo.dart` | Abstract `CasesRepo` + `CasesResult` |
| **Data** | `data/repositories/cases_repo_impl.dart` | Parses paginated response `{data: [...], pageInfo: {...}}` |
| **Data** | `data/repositories/case_details_repo.dart` | Abstract `CaseDetailsRepo` |
| **Data** | `data/repositories/case_details_repo_impl.dart` | Parses detail response |
| **Data** | `data/repositories/case_status_repo.dart` | Abstract `CaseStatusRepo` |
| **Data** | `data/repositories/case_status_repo_impl.dart` | Status update with error mapping |
| **Presentation** | `presentation/view/cases_page.dart` | Cases list with table, search, pagination |
| **Presentation** | `presentation/view/case_details_page.dart` | Single case detail view with files |
| **Presentation** | `presentation/view/widgets/add_case_dialog.dart` | Dialog for adding new cases |
| **Presentation** | `presentation/viewmodel/cases_vm.dart` | `CasesVm` — list state, pagination, search, status filter |
| **Presentation** | `presentation/viewmodel/case_details_vm.dart` | `CaseDetailsVm` — load details, change status (optimistic UI) |

**Case Status Values:** `PENDING` → `IN_PROGRESS` → `COMPLETED`

### 3. Dashboard (`lib/features/dashboard/`)

**Purpose:** Overview statistics and summary cards. Two variants: Admin and Judge dashboards.

| Layer | Files | Description |
|---|---|---|
| **Domain** | `domain/dashboard_summary.dart` | `DashboardSummary`: accessRequests, lawyerRequests, unassignedCases |
| **Data** | `data/sources/dashboard_remote_ds.dart` | Currently returns **mock data** (API not yet available) |
| **Data** | `data/repositories/dashboard_repo.dart` | Abstract `DashboardRepo` |
| **Data** | `data/repositories/dashboard_repo_impl.dart` | Implementation + `dashboardRepoProvider` |
| **Presentation** | `presentation/dashboard_page.dart` | Admin dashboard with stat cards and tables |
| **Presentation** | `presentation/judge_dashboard_page.dart` | Judge-specific dashboard view |
| **Presentation** | `presentation/viewmodel/dashboard_vm.dart` | `DashboardVm` StateNotifier with `AsyncValue<DashboardSummary>` |

> **Note:** Dashboard data source currently uses mock data. Replace `DashboardRemoteDs.fetchSummary()` with real API call.

### 4. Users (`lib/features/users/`)

**Purpose:** Admin-only user management — list, create, activate/deactivate, delete users.

| Layer | Files | Description |
|---|---|---|
| **Providers** | `users_providers.dart` | `usersRepoProvider` |
| **Domain** | `domain/user_entity.dart` | `UserEntity` with `toJsonForCreate()`, `copyWith()` |
| **Data** | `data/sources/users_remote_ds.dart` | Abstract + impl: getUsers, createUser, toggleUserStatus, deleteUser |
| **Data** | `data/repositories/users_repo.dart` | Abstract `UsersRepo` |
| **Data** | `data/repositories/users_repo_impl.dart` | Delegates to remote data source |
| **Presentation** | `presentation/view/users_management_page.dart` | Users table with actions |
| **Presentation** | `presentation/view/add_user_dialog.dart` | Dialog for creating new users |
| **Presentation** | `presentation/viewmodel/users_viewmodel.dart` | `UsersViewModel` AsyncNotifier — CRUD operations with optimistic deletion |

### 5. Access Requests (`lib/features/access_requests/`)

**Purpose:** Admin-only module for managing access requests. Currently **presentation-only** (no data/domain layers).

| Layer | Files | Description |
|---|---|---|
| **Presentation** | `presentation/view/access_requests_page.dart` | Access requests table UI |

> **Note:** This feature has no data or domain layer yet — it needs a backend API integration.

---

## State Management & Dependency Injection

All state management uses **Riverpod 2.x** with the following provider types:

| Provider Type | Used For | Examples |
|---|---|---|
| `Provider<T>` | Singletons / repositories / derived values | `dioProvider`, `authRepoProvider`, `userRoleProvider` |
| `StateProvider<T>` | Simple mutable state | `homeNavIndexProvider` (sidebar index) |
| `NotifierProvider` | Complex state with methods | `authSessionProvider`, `loginVmProvider`, `casesVmProvider`, `caseDetailsVmProvider` |
| `AsyncNotifierProvider` | Async state with loading/error | `usersViewModelProvider` |
| `StateNotifierProvider` | Legacy async state | `dashboardVmProvider` |

**DI Wiring Pattern** (per feature):
```
feature_providers.dart:
  dioProvider → DataSource(dio) → RepoImpl(dataSource) → Provider<Repo>
```

---

## Networking & API Layer

### Dio Configuration (`lib/core/network/dio_provider.dart`)

- **Base URL:** `http://localhost:8080/api` (from `Env.baseUrl`)
- **Timeouts:** connect=15s, receive=30s
- **Headers:** `Accept: application/json`
- **Auth Interceptor:** Automatically attaches `Authorization: Bearer <token>` when session is authenticated
- **Logging:** Logs all requests, responses, and errors to console

### Standard API Response Format

The backend uses a consistent wrapper:
```json
{
  "success": true,
  "message": "...",
  "data": { ... }
}
```

For paginated lists:
```json
{
  "data": [ ... ],
  "pageInfo": {
    "currentPage": 0,
    "totalPages": 5,
    "totalElements": 50,
    "pageSize": 10,
    "hasNext": true,
    "hasPrevious": false
  }
}
```

---

## API Endpoints Reference

### Auth
| Method | Path | Description |
|---|---|---|
| POST | `/auth/login` | Login with email + password |
| POST | `/auth/register` | Register new account |
| POST | `/auth/verify-otp` | Verify OTP after registration |
| GET | `/v1/admin/users/users/{userId}` | Admin profile |
| GET | `/v1/lawyer/profile` | Lawyer profile |
| GET | `/v1/judges/profile` | Judge profile |

### Cases (role-based paths)
| Method | Admin Path | Judge Path | Lawyer Path | Description |
|---|---|---|---|---|
| GET | `/v1/admin/cases` | `/v1/judges/all-cases` | `/v1/lawyer/cases` | List cases (paginated) |
| GET | `/v1/admin/cases/{id}` | `/v1/judges/case/{id}` | `/v1/lawyer/cases/{id}` | Get case details |
| PATCH | `/v1/admin/cases/{id}/status` | `/v1/judges/case/{id}/status` | — | Update case status |

**Query params for list:** `page`, `pageSize`, `q` (search), `status` (filter)

### Users (admin only)
| Method | Path | Description |
|---|---|---|
| GET | `/v1/admin/users/users` | List all users |
| POST | `/v1/admin/users/users` | Create user |
| PUT | `/v1/admin/users/{userId}/activate` | Activate user |
| PUT | `/v1/admin/users/{userId}/deactivate` | Deactivate user |
| DELETE | `/v1/admin/users/{userId}` | Delete user |

---

## Domain Models

### UserRole (enum)
```dart
enum UserRole { admin, lawyer, judge, unknown }
```
Parsed from string via `parseRole()` — matches "ADMIN", "LAWYER", "JUDGE" (case-insensitive).

### AuthSessionState
Fields: `accessToken`, `refreshToken`, `userId`, `role`, `userName`. `isAuthed` checks for non-empty access token.

### CaseModel
Fields: `id`, `caseNumber`, `title`, `status`, `createdAt`, `judgeName?`, `lawyerName?`, `courtRuling`.

### CaseDetailsModel
Extends case info with: `description`, `caseFiles: List<CaseFile>`, `defenseFiles: List<CaseFile>`.

### CaseFile
Fields: `id`, `fileName`, `fileUrl`, `fileType`.

### CaseStatus (enum)
```dart
enum CaseStatus { pending, inProgress, completed }
// API values: "PENDING", "IN_PROGRESS", "COMPLETED"
// Arabic labels: "لم يبدأ التحليل", "قيد التحليل", "مكتملة"
```

### PageInfo
Fields: `currentPage`, `totalPages`, `totalElements`, `pageSize`, `hasNext`, `hasPrevious`.

### DashboardSummary
Fields: `accessRequests`, `lawyerRequests`, `unassignedCases`.

### UserEntity
Fields: `id`, `firstName`, `lastName`, `email`, `age`, `role`, `isActive`, `assignedCasesCount`, `court`, `isApproved`, `nationalId?`, `password?`. Has `toJsonForCreate()` and `copyWith()`.

---

## Theming & Design System

### Design Tokens (`lib/app/theme/design_tokens.dart`)

| Token | Hex | Usage |
|---|---|---|
| `brown` | `#905B3E` | Primary/Brand, accents, borders |
| `beige` | `#EAC179` | App background, scaffold |
| `white` | `#F9F7F2` | Cards, surfaces |
| `gray` | `#616161` | Secondary text |
| `black` | `#242425` | Primary text |
| `green` | `#39621F` | Success states |
| `red` | `#9D3205` | Error/danger states |
| `lightGray` | `#DFDFDF` | Dividers, borders |
| `r20` | `20.0` | Standard border radius |

### App Theme (`lib/app/theme/app_theme.dart`)

- Uses `FluentThemeData` (not Material)
- Accent color: brown
- Background: beige
- Font family: `Amiri`
- Brightness: light

### Responsive Scaling

`ScreenUtilInit` with design size **1440×1024**. Use `.w`, `.h`, `.sp`, `.r` extensions throughout.

---

## Role-Based Access Control (RBAC)

### Menu Visibility

Defined in `lib/app/shell/menu_items.dart`:

| Menu Item (Arabic) | Key | Admin | Lawyer | Judge |
|---|---|---|---|---|
| لوحة التحكم الرئيسية | `dashboard` | ✅ | ✅ | ✅ |
| إدارة القضايا | `cases` | ✅ | ✅ | ❌ |
| إدارة طلبات الوصول | `access_requests` | ✅ | ❌ | ❌ |
| الجلسات | `hearings` | ❌ | ❌ | ✅ |
| إدارة المستخدمين | `users` | ✅ | ❌ | ❌ |
| الحساب الشخصي | `profile` | ✅ | ✅ | ✅ |
| الإعدادات | `settings` | ✅ | ✅ | ✅ |

### Dashboard Variant

`HomeShell.buildPage()` checks role: Judge gets `JudgeDashboardPage`, others get `DashboardPage`.

### API Path Routing

Data sources select different API paths based on user role (admin/lawyer/judge).

---

## Navigation & App Shell

### Flow

```
main.dart
  └── ProviderScope
       └── ElMostasharApp (ScreenUtilInit + FluentApp)
            └── RootDecider
                 ├── (not authed) → AuthShell
                 │    └── AnimatedSwitcher: LoginView / SignupView / OtpView / ForgotPasswordView
                 └── (authed) → HomeShell
                      ├── TopBar (page title + notification bell)
                      ├── Content area (switches by menu selection)
                      └── SideMenu (right side, RTL)
```

### HomeShell Layout

- **LTR Directionality wrapper** (because sidebar is on the right in RTL)
- `Row`: [Expanded content area] + [SideMenu on the right]
- Content area: `Column` with TopBar + page body
- Page switching via `homeNavIndexProvider` (int index into filtered menu items)

---

## Authentication Flow

1. User enters email + password on `LoginView`
2. `LoginVm.submitLogin()` validates → calls `AuthRepo.login()`
3. `AuthRepoImpl` POSTs to `/auth/login`, then fetches user profile for the name
4. On success, `AuthSession.setSession()` stores tokens + role
5. `RootDecider` reactively switches from `AuthShell` to `HomeShell`
6. Dio interceptor auto-attaches Bearer token to all subsequent requests
7. Logout: `AuthSession.clear()` → `RootDecider` switches back to `AuthShell`

**Signup flow:** Signup → OTP verification → success dialog → back to login.

---

## Assets

### Images (`assets/images/`)
- `logo.png` — App logo (displayed in sidebar)
- `court_image.png` — Background image for auth screens
- `home_icon.png`, `cases_icon.png`, `archive_icon.png`, `profile_icon.png`, `setting_icon.png` — Navigation icons

### Fonts (`assets/fonts/`)
- Amiri (Regular, Bold, Italic, BoldItalic) — Arabic serif font, OFL licensed

---

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.11.0
- Windows development environment
- Backend server running at `http://localhost:8080/api`

### Run

```bash
flutter pub get
flutter run -d windows
```

### Change Backend URL

Edit `lib/app/config/env.dart`:
```dart
class Env {
  static const String baseUrl = 'http://your-server:port/api';
}
```

---

## Key Conventions & Patterns

1. **Feature-first organization** — each feature is self-contained under `lib/features/`
2. **Provider wiring files** — `*_providers.dart` at feature root wires DI for that feature
3. **Role-based API paths** — data sources use `_pathForRole(role)` to select endpoints
4. **Optimistic UI** — `CaseDetailsVm.changeStatus()` and `UsersViewModel.deleteUser()` update UI before server confirms
5. **RTL-first** — all UI uses `TextDirection.rtl`; Arabic labels and validators throughout
6. **Fluent UI** — uses `fluent_ui` package (NOT Material); widgets: `ScaffoldPage`, `FluentApp`, `ContentDialog`, `Button`, etc.
7. **Immutable state** — all state classes use `copyWith()` pattern
8. **Error mapping** — `DioException` errors are mapped to Arabic-language user messages

---

## Known Limitations & TODOs

- **Dashboard data source** uses mock data — needs real API integration
- **Access Requests** feature has no data/domain layer — presentation only
- **Hearings** page is commented out in `HomeShell` — not yet implemented
- **Profile** and **Settings** pages are placeholder text only
- **No local persistence** — auth session is in-memory only (lost on app restart)
- **No refresh token logic** — tokens are stored but refresh flow is not implemented
- **`go_router`** is declared as a dependency but navigation is done via widget switching, not routing
- **`build_runner`** is listed as a regular dependency (should be dev_dependencies)
- **Debug prints** throughout the codebase (marked with `// ignore: avoid_print`)
