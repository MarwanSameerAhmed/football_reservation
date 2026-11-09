# Kickoff - Football Group Management Application
## Architecture Specification Document

---

### 1. Architectural Philosophy & Principles
Kickoff is built using a combination of **Clean Onion Architecture** and **Feature-First Architecture** to ensure high testability, maintainability, and clean separation of concerns:

- **SOLID Principles:** Every class has a single responsibility; interfaces invert dependencies.
- **Dependency Inversion:** High-level domain logic does not depend on low-level data/framework details (Flutter, Firebase).
- **Reactive State Flow:** Unidirectional data flow powered by `flutter_bloc` (Bloc for complex events, Cubit for simple state).
- **Centralized Design System:** Strict UI tokens for typography, spacing, border radii, and dynamic color palettes (Light & Dark mode, Arabic RTL).

```
                      +---------------------------------------+
                      |           Presentation Layer          |
                      |   (Pages, Widgets, BLoC, Cubit)       |
                      +---------------------------------------+
                                          |
                                          v  (calls use cases)
                      +---------------------------------------+
                      |             Domain Layer              |
                      | (Entities, Repository Interfaces,     |
                      |              Use Cases)               |
                      +---------------------------------------+
                                          ^
                                          |  (implements contracts)
                      +---------------------------------------+
                      |              Data Layer               |
                      |  (Data Sources, DTOs/Models, Repos)   |
                      +---------------------------------------+
                                          |
                                          v  (connects to)
                      +---------------------------------------+
                      |     External Services (Firebase)      |
                      +---------------------------------------+
```

---

### 2. Directory Layout

```
lib/
├── app/
│   ├── app.dart                   # Root MaterialApp with theme & router
│   ├── router/                    # GoRouter configuration & routes
│   ├── theme/                     # AppTheme, ColorPalette, AppTypography
│   └── localization/              # S / AppLocalizations, Arabic & English
│
├── core/
│   ├── constants/                 # AppConstants, AssetConstants
│   ├── errors/                    # Failures, ExceptionMapper
│   ├── exceptions/                # AppException, ServerException
│   ├── network/                   # NetworkInfo, Connectivity
│   ├── services/                  # StorageService, LogService
│   ├── di/                        # GetIt injection container
│   ├── extensions/                # ContextExtensions, StringExtensions
│   ├── helpers/                   # DateFormatter, CurrencyHelper
│   ├── utils/                     # Validators, Debouncers
│   ├── enums/                     # PlayerPosition, MatchStatus, etc.
│   └── presentation/
│       ├── widgets/               # PrimaryButton, AppCard, AppTextField, etc.
│       ├── dialogs/               # AppConfirmationDialog
│       ├── bottom_sheets/         # AppModalBottomSheet
│       └── states/                # AppLoading, AppEmptyState, AppErrorWidget
│
└── features/
    ├── authentication/            # Auth, User Profile, Roles
    ├── players/                   # Players List, Details, Ratings
    ├── registrations/             # Match RSVP, Waiting List
    ├── team_generator/            # Balanced Team Generation Algorithm
    ├── matches/                   # Match scheduling, line-ups, results
    ├── polls/                     # Voting, Match scheduling polls
    ├── statistics/                # Player stats, Leaderboard, Top Scorers
    ├── notifications/             # FCM notifications, in-app alerts
    └── expenses/                  # Match fee collection & pitch expenses
```

---

### 3. Layer Separation Rules
1. **Domain Layer:** Pure Dart. Zero dependencies on Flutter, Firebase, or external frameworks. Contains entities, repository contracts, and use cases.
2. **Data Layer:** Implements domain contracts, parses Firebase Firestore / Auth / Storage calls, handles serialization, and maps raw exceptions to Domain Failures (`Failure`).
3. **Presentation Layer:** Consumes Use Cases via BLoC/Cubit. Zero direct calls to Firebase. Listens to state changes and renders proper UI state handlers.
4. **Core Layer:** Cross-cutting concerns, reusable design system components, shared state widgets. No feature business logic.

---

### 4. UI State Standard
Every screen/feature must support standard states:
- `Initial`: Pre-fetch state.
- `Loading`: Skeleton loader or spinner.
- `Success<T>`: Data loaded or mutated.
- `Empty`: Descriptive icon, message, and call-to-action button.
- `Error`: Human-readable localized error message with a retry mechanism.
- `Special`: Offline indicator, permissions denied, registration closed/full.

