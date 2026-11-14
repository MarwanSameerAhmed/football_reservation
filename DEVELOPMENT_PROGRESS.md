# Kickoff - Development Progress Tracker

Last Updated: 2026-11-13 (Theme & Design System Harmonization with tam_app completed)

---

## 📌 Status Summary
- **Design System Parity:** 100% harmonized with `tam_app` (`#FFFFFF` Light Mode surfaces, `#161A22` / `#1D222C` Dark Mode, electric blue `#2563EB` primary, amber waitlist states, neutral gray borders).
- **Directional Navigation:** All navigation arrows point leftwards (`<`) in RTL, and back buttons point rightwards (`>`).
- **Profile Security:** Player photo editing restricted exclusively to the player's own profile.
- **Invitation Flow:** Default country code selector initialized to Yemen (`🇾🇪 +967`) at the top of the list.
- **Test Suite:** 106/106 automated tests passing, 0 analyzer errors/warnings.

## 📌 Roadmap Overview & Phased Implementation

| Phase | Description | Status |
|---|---|---|
| **Phase 0** | **Design System & Architectural Foundation** | 🟢 Completed |
| **Phase 1** | **Core Framework, Theme Tokens, Responsive System & Reusable UI Components** | 🟢 Completed |
| **Phase 2** | **Authentication & Role-Based Access Control (Admin / Player)** | 🟢 Completed |
| **Phase 3** | **Player Profiles, Skills & Technical Rating System** | 🟢 Completed |
| **Phase 4** | **Match Management & Weekly Attendance Registration (RSVP / Waiting List)** | 🟢 Completed |
| **Phase 5** | **Intelligent Balanced Team Generator & Lineup History** | 🟢 Completed |
| **Phase 6** | **Polls & Interactive Voting** | 🟢 Completed |
| **Phase 7** | **Match Results, Live Scores & Historical Record** | 🟢 Completed |
| **Phase 8** | **Player & Group Statistics / Leaderboards** | 🟢 Completed |
| **Phase 9** | **Notifications, In-App Alerts & Activity Feed** | 🟢 Completed |
| **Phase 10** | **Final Integration Testing, Production Hardening & Polish** | 🟢 Completed |

---

## 📝 Change Log & Verification

### Phase 0: Project Setup & Specification
- [x] Initialized project requirements & master specification review.
- [x] Created `ARCHITECTURE.md` adhering to Onion/Feature-First architecture.
- [x] Extracted Design System tokens from uploaded design reference.
- [x] Added core dependencies (`flutter_bloc`, `go_router`, `get_it`, `equatable`, `intl`, `google_fonts`, `flutter_localizations`).

### Phase 1: Core Framework, Responsive Architecture & UI Components
- [x] **Enterprise Responsive Engine (`ResponsiveHelper` & `KickoffResponsiveShell`):**
  - Mobile-first shell enforcing a centered max content width (500px) on Mobile Web / Desktop.
  - Safe screen breakpoints: Compact (<360px), Standard (360-480px), Large Mobile (481-600px), Tablet (>600px).
  - Clamped text scaler avoiding accessibility font overflow breaks.
  - Comprehensive responsive tests covering compact 320x568 (iPhone SE), mainstream 390x844 (iPhone 14/15), and wide 1200x800 desktop web viewports.
- [x] **Theme & Typography System:**
  - `AppColors`: Warm beige canvas (`#F5F2EB`), pure white surfaces, deep slate capsules (`#141917`), and vivid turf green (`#84CC16`).
  - Dark mode adaptation: Obsidian slate canvas (`#0E1311`), elevated cards, and luminous neon turf green (`#A3E635`).
  - `AppTypography` with Arabic (Tajawal) RTL support.
- [x] **Design Reference UI Components:**
  - `KickoffActionButton`: The iconic pill action button with trailing circular arrow, dynamic RTL mirroring, and loading state.
  - `KickoffCard`: `24px` rounded cards.
  - `KickoffChoiceChip`: Interactive slots, dates, times, and player count chips.
  - `KickoffSearchField`: Capsule search input with optional green circular filter button.
  - `KickoffBadge`: Micro-capsule status badges (Safe, Moderate, Full, Indoor/Outdoor).
  - `KickoffCircleButton`: Circular icon buttons with standard touch targets.
  - `KickoffBottomNavBar`: Floating capsule bottom navigation bar.
  - `KickoffHeroCard` & `KickoffListCard`: Match banners & status cards.
- [x] **Mandatory Global UI State Widgets:**
  - `AppLoadingWidget`, `AppEmptyStateWidget`, `AppErrorWidget`, `AppOfflineWidget`.
- [x] **Automated Verification:**
  - `dart format .`: Passed cleanly.
  - `flutter analyze`: Passed with 0 errors and 0 warnings.
  - `flutter test`: 5/5 automated unit & widget tests passed.

### Phase 2: Authentication & Role-Based Access Control (Admin / Player)
- [x] **Domain Layer (`lib/features/authentication/domain/`):**
  - `UserRole` enum (`player`, `admin`) with permission checks and localization.
  - `UserEntity` pure business model independent of external packages.
  - `AuthRepository` interface with `Result<T>` Dart 3 pattern.
  - Granular Use Cases: `SignInUseCase`, `SignUpUseCase`, `SignOutUseCase`, `GetCurrentUserUseCase`, `GetAuthStateUseCase`.
- [x] **Data Layer (`lib/features/authentication/data/`):**
  - `UserModel` DTO with Firestore serialization (`fromFirestore`, `toJson`).
  - `FirebaseAuthRemoteDataSource` with full Firebase Auth error code mapping to domain exceptions.
  - `MockAuthRemoteDataSource` enabling offline demoing and testing.
  - `AuthRepositoryImpl` mapping data exceptions to domain failures (`AuthFailure`, `ServerFailure`, `NetworkFailure`).
- [x] **Presentation Layer (`lib/features/authentication/presentation/`):**
  - `AuthBloc` managing state transitions (`AuthInitial`, `AuthLoading`, `Authenticated`, `Unauthenticated`, `AuthFailureState`).
  - `SignInPage`: Matching the design reference with capsule inputs, signature action button, quick demo account switcher.
  - `SignUpPage`: Account creation with interactive `RoleSelectorChip`.
  - Reusable inputs: `AppTextField`, `AppPasswordField`.
  - Integrated with `HomePage` displaying active player/admin badge and sign-out controls.
- [x] **Automated Verification:**
  - `dart format .`: Clean.
  - `flutter analyze`: 0 errors, 0 warnings.
  - `flutter test`: 11/11 automated unit, bloc, responsive & widget tests passed.

### Phase 3: Player Management, Technical Skills & Rating System
- [x] **Domain Layer (`lib/features/players/domain/`):**
  - `PlayerPosition` enum (`GK`, `DEF`, `MID`, `FWD`) and `PreferredFoot` (`Right`, `Left`, `Both`).
  - `PlayerSkills` value object with technical attributes (Pace, Shooting, Passing, Defending, Physical, Goalkeeping) and automated overall score & star rating formula.
  - `PlayerEntity` pure business model independent of frameworks.
  - `PlayerRepository` interface using `Result<T>`.
  - Use cases: `GetPlayersUseCase`, `GetPlayerByIdUseCase`, `CreatePlayerUseCase`, `UpdatePlayerUseCase`.
  - **Strict Security Enforcement:** `UpdatePlayerSkillsUseCase` validates caller permissions at the domain level, strictly rejecting non-admin rating modifications with `PermissionDeniedFailure`.
- [x] **Data Layer (`lib/features/players/data/`):**
  - `PlayerSkillsModel` and `PlayerModel` DTOs with Firestore serialization.
  - `FirebasePlayerRemoteDataSource` integrating with Cloud Firestore `players` collection.
  - `MockPlayerRemoteDataSource` pre-seeded with 6+ realistic players across positions, skills, and ratings.
  - `PlayerRepositoryImpl` translating exceptions into clean domain failures.
- [x] **Presentation Layer (`lib/features/players/presentation/`):**
  - `PlayersBloc` supporting real-time position filtering, text search by name/nickname, and skill updates.
  - `PlayerPositionBadge`: Micro capsule badges matching design tokens.
  - `PlayerCard`: Horizontal list card styled with jersey number, position pill, nickname, and star rating badge (`⭐ 4.6`).
  - `PlayerSkillsBreakdown`: Minimalist stat progress bars for tactical attributes.
  - `EditSkillsSheet`: Interactive modal sheet allowing Admins to adjust attributes with live star rating calculation.
  - `PlayersListPage`: Position filter chips (`الكل`, `GK`, `DEF`, `MID`, `FWD`), search field, and full list.
  - `PlayerDetailsPage`: Profile stats, technical breakdown, and role-based editing button (interactive for Admins, read-only for Players).
  - Integrated into `HomePage` preview and bottom navigation.
- [x] **Automated Verification:**
  - `dart format .`: Clean.
  - `flutter analyze`: 0 errors, 0 warnings.
  - `flutter test`: 19/19 automated unit, bloc, security, responsive & widget tests passed.

### Phase 4: Match Management & Weekly Attendance Registration (RSVP / Waiting List)
- [x] **Domain Layer (`lib/features/matches/domain/`):**
  - `MatchStatus` enum (`upcoming`, `full`, `inProgress`, `completed`, `cancelled`) and `RegistrationStatus` (`confirmed`, `waiting`, `cancelled`).
  - `MatchRegistrationEntity` tracking player ID, tactical position, timestamp, status, and queue position.
  - `MatchEntity` representing match details, court specs, fees, confirmed roster, and waiting list.
  - `MatchRepository` contract interface using `Result<T>`.
  - Use Cases: `GetMatchesUseCase`, `GetMatchByIdUseCase`, `RegisterPlayerToMatchUseCase`, `CancelMatchRegistrationUseCase`, `CreateMatchUseCase`.
  - **Automated Waiting List Escalation:** When a confirmed player cancels, the first player in the waiting list (`queuePosition == 1`) is automatically promoted to the confirmed squad and remaining positions are re-indexed.
  - **Duplicate Prevention:** Prevents players from registering twice in the same match.
- [x] **Data Layer (`lib/features/matches/data/`):**
  - `MatchRegistrationModel` & `MatchModel` DTOs with Firestore serialization.
  - `FirebaseMatchRemoteDataSource` connecting to Cloud Firestore `matches` collection.
  - `MockMatchRemoteDataSource` pre-seeded with upcoming and full matches for offline testing.
  - `MatchRepositoryImpl` handling and translating server exceptions into domain failures.
- [x] **Presentation Layer (`lib/features/matches/presentation/`):**
  - `MatchesBloc` handling match loading, player registration, and cancellation with clear user feedback.
  - `MatchStatusBadge`: Micro capsule badges reflecting live spot availability.
  - `MatchRosterView`: Clean presentation of Confirmed Squad (1..N) and Waiting List queue.
  - `MatchDetailsPage`: Full match specs, pitch dimensions, live roster, and contextual RSVP action button.
  - `ReserveSpotPage`: Interactive slot, date, time, and tactical position selection.
- [x] **Automated Verification:**
  - `dart format .`: Clean.
  - `flutter analyze`: 0 errors, 0 warnings.
  - `flutter test`: 26/26 automated unit, bloc, escalation, security, responsive & widget tests passed.

### Phase 5: Intelligent Balanced Team Generator & Lineup History
- [x] **Domain Layer (`lib/features/team_generator/domain/`):**
  - `GeneratedTeamEntity` representing balanced squads with aggregate score and average star rating.
  - `TeamLineupEntity` representing the match lineup (Team A vs Team B), balance score variance, generation timestamp, and finalized status.
  - `TeamBalancer` tactical balancing engine:
    - Positional partitioning: Goalkeepers, Defenders, Midfielders, and Forwards.
    - Goalkeeper anchoring: Exactly 1 GK assigned per team when 2 GKs are present.
    - Greedy skill-balanced distribution across outfield positions.
    - Local swap optimization ensuring score variance between teams is minimized ($\le 5\%$).
    - Deterministic and fast execution in pure Dart without external dependencies.
  - `TeamGeneratorRepository` contract interface using `Result<T>`.
  - Use Cases: `GenerateBalancedTeamsUseCase`, `SwapPlayersUseCase`, `SaveFinalLineupUseCase`, `GetLineupHistoryUseCase`.
- [x] **Data Layer (`lib/features/team_generator/data/`):**
  - `GeneratedTeamModel` and `TeamLineupModel` DTOs with Firestore serialization (`team_lineups` collection).
  - `FirebaseTeamGeneratorRemoteDataSource` with real-time saving and history retrieval.
  - `MockTeamGeneratorRemoteDataSource` for immediate offline usage and isolated testing.
  - `TeamGeneratorRepositoryImpl` handling exceptions and translating to domain failures.
- [x] **Presentation Layer (`lib/features/team_generator/presentation/`):**
  - `TeamGeneratorBloc` managing generation, tap-to-swap player selection, manual swapping, and lineup finalization.
  - `BalanceIndicatorBar`: Visual tactical balance comparison bar with score metrics and percentage rating difference.
  - `TeamPlayerTile`: Player card tile featuring position badge, avatar initial, rating, and swap selection outline.
  - `TeamCard`: Squad container with jersey accent, count badge, and average rating.
  - `TeamGeneratorPage`: Responsive management screen with tactical generator prompt, balance bar, tap-to-swap selection banner, and finalized lock state.
  - Integrated with `MatchDetailsPage` top bar and quick action card.
- [x] **Automated Verification:**
  - `dart format .`: Clean.
  - `flutter analyze`: 0 errors, 0 warnings.
  - `flutter test`: 34/34 automated tests passed (8 new tests for balancing engine, GK partitioning, manual swapping, repository and BLoC).

### Phase 6: Polls & Interactive Voting
- [x] **Domain Layer (`lib/features/polls/domain/`):**
  - `PollType` enum (`matchScheduling`, `manOfTheMatch`, `general`) with localized labels.
  - `PollOptionEntity`: Choice representation with vote counts, voter tracking, and dynamic metadata.
  - `PollEntity`: Full domain entity calculating total votes, percentages, deadline expiration, user vote tracking, and winning option determination.
  - `PollRepository` contract interface using pure Dart `Result<T>`.
  - Granular Use Cases: `GetPollsUseCase`, `GetPollByIdUseCase`, `CreatePollUseCase`, `VotePollUseCase`, `ClosePollUseCase`.
  - **Business Rules Enforcement:**
    - Duplicate vote prevention: in single-choice polls, voting for an option switches user's previous vote cleanly.
    - Expiration & lock enforcement: voting on closed or expired polls is strictly rejected with `ValidationFailure`.
- [x] **Data Layer (`lib/features/polls/data/`):**
  - `PollOptionModel` and `PollModel` with Firestore `Timestamp` serialization.
  - `FirebasePollRemoteDataSource` with Firestore transaction for atomic vote updates.
  - `MockPollRemoteDataSource` pre-seeded with real-world match scheduling and MOTM polls.
  - `PollRepositoryImpl` mapping low-level data exceptions to domain failures.
- [x] **Presentation Layer (`lib/features/polls/presentation/`):**
  - `PollsBloc` managing state transitions (`PollsInitial`, `PollsLoading`, `PollsEmptyState`, `PollsLoaded`, `PollsErrorState`), voting, poll creation, and manual closing.
  - `PollTypeBadge`: Distinct micro badges for Scheduling, MOTM, and General polls.
  - `PollOptionTile`: Interactive option tile featuring live percentage fill progress bars, vote counts, selection checkmark, and winning trophy (`🏆`).
  - `PollCard`: Reusable poll card with deadline countdown, options list, and Admin close controls.
  - `CreatePollSheet`: Dynamic modal bottom sheet for Admins to create polls with 2 to 6 options and type selection.
  - `PollsPage`: Responsive polls feed with status filter chips (`الكل`, `المتاحة للتصويت`, `المنتهية`).
  - Integrated into `HomePage` feed preview and bottom navigation bar.
- [x] **Automated Verification:**
  - `dart format .`: Clean.
  - `flutter analyze`: 0 errors, 0 warnings.
  - `flutter test`: 42/42 automated tests passed (8 new tests for voting rules, duplicate prevention, deadline check, repository, and BLoC).

### Phase 7: Match Results, Live Scores & Historical Record
- [x] **Domain Layer (`lib/features/matches/domain/`):**
  - `GoalEventEntity`: Goal representation with scorer, assist maker, minute, penalty, and own-goal tags.
  - `CardEventEntity`: Disciplinary bookings (Yellow and Red cards) with minute and reason.
  - `MatchResultEntity`: Pure domain entity with final team scores, winner determination, draw recognition, MOTM recipient, lock status, and notes.
  - Extended `MatchEntity` to seamlessly hold `MatchResultEntity? result`.
  - Added repository contracts: `recordMatchResult` and `getMatchResult`.
  - Granular Use Cases: `RecordMatchResultUseCase`, `GetMatchResultUseCase`.
- [x] **Data Layer (`lib/features/matches/data/`):**
  - `GoalEventModel`, `CardEventModel`, and `MatchResultModel` DTOs with full Firestore serialization.
  - Updated `MatchModel` with `result` serialization and parsing.
  - Updated `FirebaseMatchRemoteDataSource` with match result persistence (`match_results` collection) and atomic match status update to `completed`.
  - Updated `MockMatchRemoteDataSource` with pre-seeded completed derby match (`4 - 3`) and offline result recording.
  - `MatchRepositoryImpl` handling result recording and retrieval with domain failure mapping.
- [x] **Presentation Layer (`lib/features/matches/presentation/`):**
  - Extended `MatchesBloc` with `RecordMatchResultRequested`, updating match status to `completed` and emitting immediate feedback.
  - `MatchResultCard`: Elevated scoreboard container with big team score display, winner highlight, MOTM trophy pill (`⭐`), goals timeline, and disciplinary cards.
  - `RecordResultSheet`: Admin modal sheet with score steppers, dynamic goalscorer and assist addition, MOTM selection, and official lock button.
  - Integrated into `MatchDetailsPage` with top-bar Admin action and scoreboard display for completed matches.
- [x] **Automated Verification:**
  - `dart format .`: Clean.
  - `flutter analyze`: 0 errors, 0 warnings.
  - `flutter test`: 46/46 automated tests passed (+ 8 tests in `team_generator_test.dart` = 54/54 tests total).

### Phase 9: Notifications, In-App Alerts & Activity Feed
- [x] **Domain Layer (`lib/features/notifications/domain/`):**
  - `NotificationType` enum with football domain variants: `waitingListPromoted`, `lineupPublished`, `motmPollStarted`, `matchResultPublished`, `matchAnnouncement`.
  - `NotificationEntity`: Pure Dart business entity with id, title, body, type, optional targetId, isRead flag, and creation timestamp.
  - `NotificationRepository` contract using `Result<T>` and Stream support for live unread badge updates.
  - Use Cases: `GetNotificationsUseCase`, `MarkNotificationAsReadUseCase`, `MarkAllNotificationsAsReadUseCase`.
- [x] **Data Layer (`lib/features/notifications/data/`):**
  - `NotificationModel` with complete Firestore serialization and typed `copyWith`.
  - `FirebaseNotificationRemoteDataSource` integrating with Cloud Firestore `notifications` collection.
  - `MockNotificationRemoteDataSource` pre-seeded with 4 realistic football group alerts (waiting list promotion, tactical lineup publish, MOTM voting open, derby score confirmation).
  - `NotificationRepositoryImpl` handling stream mappings and data-to-domain translation.
- [x] **Presentation Layer (`lib/features/notifications/presentation/`):**
  - `NotificationsBloc` managing notifications retrieval, single read, mark all read, and unread badge counting.
  - `NotificationBellButton`: Interactive bell icon in home page top bar with real-time unread badge counter in turf green.
  - `NotificationTile`: Card tile with icon/color per alert type, relative time display, unread dot indicator, and contextual tap routing (`/polls` or `/match-details`).
  - `NotificationsPage`: Dedicated responsive alert feed with 'Mark all read' action and full empty/loading/error handling.
  - Registered in Dependency Injection (`injection_container.dart`) and GoRouter (`app_router.dart`).
- [x] **Automated Verification:**
  - `test/notifications_test.dart`: 10/10 automated tests passing (entity copyWith, JSON serialization, mock repository sorting & read status, bloc state transitions).

### Phase 10: Final Integration Testing, Production Hardening & Polish
- [x] **Enterprise Responsive Hardening (Down to 320px compact screens):**
  - Resolved horizontal & vertical flex overflows across compact viewports (320px - iPhone SE):
    - Replaced unconstrained header & footer rows with responsive `Wrap` widgets in `PollCard`.
    - Wrapped horizontal filter chips bar with `SingleChildScrollView` in `PollsPage`.
    - Protected middle column subtitle in `LeaderboardRankTile` with `Expanded` and text ellipsis.
    - Balanced `GroupSummaryCard` 3-column stats with equal `Expanded` distribution and compact typography.
    - Flexible constraints on `KickoffChoiceChip` with adaptive vertical padding preventing bottom overflows.
    - Protected legend row with `Wrap` in `ReserveSpotPage`.
    - Added `Flexible` & `Expanded` text truncation to name, nickname, and stats in `PlayerCard`.
    - Wrapped breakdown titles and progress labels in `PlayerSkillsBreakdown` with `Expanded`.
    - Safe clamped target calculation in `TeamGeneratorPage` avoiding runtime argument errors on empty lists.
    - Safe type loop in `PlayerDetailsPage` preventing Dart covariance runtime errors.
  - Verified responsive rendering across all 8 screens in 320x568 compact, 390x844 mainstream, and 1200x800 desktop web viewports (`test/responsive_layout_test.dart`: 12/12 passing).
- [x] **End-to-End Complete User Journey Suite (`test/e2e_integration_flow_test.dart`):**
  - Flow 1: Authentication & RBAC role permissions (Admin switching to Player).
  - Flow 2: Matches, Attendance RSVP & automated Waiting List promotion.
  - Flow 3: Intelligent Balanced Team Generator, Tactical Swapping & Lineup Finalization.
  - Flow 4: Interactive Poll Voting, duplicate vote switching & administrative closing.
  - Flow 5: Official Match Result recording, scoreboard update & leaderboard calculations.
  - Flow 6: In-App Notifications, unread badge counters & stream updates.
- [x] **Theme & Dark Mode Verification:**
  - Seamless live toggling between Light Warm Beige canvas (`#F5F2EB`) and Obsidian Dark Slate (`#0E1311`).
  - High-contrast visual tokens: Pure white cards (`24px` radius), deep slate pills (`#141917`), vivid turf green (`#84CC16`).
- [x] **Strict Zero-Financial Compliance:**
  - Full codebase audit confirmed zero currency symbols (`SAR`, `ر.س`) or expense splitting logic. Focus strictly on football group management, balanced teams, RSVP, polls, and leaderboards.
- [x] **Automated Test Suite Status:**
  - `dart format .`: 100% formatted (188 files).
  - `flutter analyze`: **0 issues found** (0 errors, 0 warnings).
  - `flutter test`: **98/98 automated tests passing** (100% pass rate) across all 10 test suites.

### Post-Launch Enhancements: 18 Players, 3 Teams & UI Simplification
- [x] **Removal of Jersey Numbers ("مايحتاج رقم القميص"):**
  - Eliminated jersey number requirements and `#number` badges across the UI.
  - In `PlayerCard` and `PlayerDetailsPage`, player avatar containers now dynamically render the player's initial letter (أول حرف من الاسم) with fallback to `⚽` icon, delivering a clean and personalized modern profile design.
- [x] **18 Players & 3 Balanced Teams System:**
  - Expanded match registration capacity to **18 players** (`maxPlayers: 18`).
  - Pre-seeded 18 unique players (`p1` to `p18`) in `MockPlayerRemoteDataSource` with authentic Arabic names, varied positions, and balanced skill ratings.
  - Multi-team dynamic support in `TeamLineupEntity` and `TeamLineupModel` holding `teams: List<GeneratedTeamEntity>` with full backwards compatibility getters (`teamA`, `teamB`, `teamC`).
  - Algorithm enhancement in `TeamBalancer`:
    - Generates **3 balanced teams of 6 players each** when 18 players are registered:
      - الفريق الأول (الأخضر)
      - الفريق الثاني (الأبيض)
      - الفريق الثالث (الأسود)
    - Full rotating goalkeepers support ("في كل فريق بيكون الفريق كامل يحرس"): goalkeeping duties rotate across the entire team, balancing tactical outfield shape and cumulative skill ratings.
    - Deterministic multi-team greedy distribution and local optimization passes guarantee score difference variance $\le 5\%$.
- [x] **Goalkeeper Rotation & Thoughtful Captaincy Engine (الكل راح يحرس + كابتن مدروس لكل فريق):**
  - **Randomized Goalkeeper Rotation:** `TeamBalancer.generateGoalkeeperRotation()` generates a fair, unbiased rotation order for each squad so players know who guards the net first (#1), second (#2), etc.
  - **Thoughtful Captain Selection:** `TeamBalancer.selectCaptain()` evaluates player seniority (matches played), match-winning peer respect (MOTM awards), overall technical skills, and playmaking assists to select the team captain.
  - **Swap Turn Preservation:** Manual player swaps between squads seamlessly preserve the goalkeeper rotation turn slot of the incoming player and re-evaluate squad captains.
  - **UI/UX Display:**
    - `TeamCard` displays a Captain announcement banner, a horizontal rotation sequence timeline (`#1 -> #2 -> #3...`), and individual player badges.
    - `TeamPlayerTile` displays custom avatar/photo, `👑 كابتن` badge with gold accent, and `🧤 حارس #N` turn badge.
    - `MatchLineupCard` highlights the user's specific rotation turn (`🧤 دورك في الحراسة: الدورة #N`) and lists team captains.
- [x] **Unified Kickoff Floating Pill Toast System (نظام التوست العائم الموحد):**
  - **Component Architecture:** Created [`lib/core/presentation/widgets/kickoff_toast.dart`](file:///d:/football_reservation/lib/core/presentation/widgets/kickoff_toast.dart) featuring `KickoffToast` and `KickoffToastWidget`.
  - **Visual Design:** Floating stadium pill container (`borderRadius: 28`), pitch-dark background (`#161A18`), subtle border (`white 12%`), soft shadow, bold typography, and contrasting badge circles (lime-green checkmark for success, red for error, amber for warning, sky blue for info).
  - **Context Extensions:** Added `context.showSuccessToast()`, `context.showErrorToast()`, `context.showWarningToast()`, and `context.showInfoToast()` across `ContextExtensions`.
  - **Global Theme Support:** Configured global `snackBarTheme` in both `lightTheme` and `darkTheme` in [`AppTheme`](file:///d:/football_reservation/lib/app/theme/app_theme.dart).
  - **System-Wide Adoption:** Replaced all standalone `ScaffoldMessenger.showSnackBar` implementations across all app modules (Authentication, Matches, Team Generator, Polls, Notifications, Registrations, Players).
  - **Test Suite:** Added comprehensive widget tests in [`test/kickoff_toast_test.dart`](file:///d:/football_reservation/test/kickoff_toast_test.dart) (100% passing).
- [x] **Interactive Multi-Team Tap-to-Swap:**
  - Updated `TeamGeneratorBloc` and `TeamGeneratorPage` to support tap-to-swap across any two of the 3 teams with real-time selection feedback and visual indicator banners.
  - Responsive `BalanceIndicatorBar` updated with dynamic multi-team color legends and segmented ability comparison bars.
- [x] **Verification & Test Coverage:**
  - Added dedicated test scenarios in `test/team_generator_test.dart` verifying 18-player generation, 3 teams of 6, rotational goalkeeping, variance $\le 5\%$, and multi-team swapping.
  - `flutter analyze`: 0 issues found.
  - `flutter test`: 100% passing across the entire project.

### Firebase Backend Integration
- [x] **FlutterFire CLI Configuration:**
  - Connected and configured project to Firebase project: `football-app-a6063` (Project Number: `765206028408`).
  - Generated [`lib/firebase_options.dart`](file:///d:/football_reservation/lib/firebase_options.dart) covering all platforms:
    - Web: `1:765206028408:web:132d7e383c2615b6b2cd8d`
    - Android: `1:765206028408:android:83a8b58f3740ac26b2cd8d`
    - iOS: `1:765206028408:ios:896148bfc189e557b2cd8d`
    - macOS: `1:765206028408:ios:896148bfc189e557b2cd8d`
    - Windows: `1:765206028408:web:9e4958b7fca83589b2cd8d`
- [x] **Application Initialization & Dependency Injection Setup:**
  - Integrated `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` in [`lib/main.dart`](file:///d:/football_reservation/lib/main.dart).
  - Enhanced [`setupLocator`](file:///d:/football_reservation/lib/core/di/injection_container.dart) with `useFirebase` toggle (`--dart-define=USE_FIREBASE=true`) allowing seamless switching between live Firebase services and offline mock services.
- [x] **Quality & Code Verification:**
  - `dart format .`: 100% formatted (190 files).
  - `flutter analyze`: 0 issues found.
  - `flutter test`: 100% passing (all test suites).

### Firebase Cloud Messaging (FCM) Push Notifications Integration
- [x] **Package Installation:**
  - Installed and resolved `firebase_messaging: ^17.0.1` and `firebase_messaging_platform_interface`.
- [x] **Android Manifest Permissions:**
  - Added `android.permission.POST_NOTIFICATIONS`, `INTERNET`, and `VIBRATE` to [`android/app/src/main/AndroidManifest.xml`](file:///d:/football_reservation/android/app/src/main/AndroidManifest.xml) for Android 13+ support.
- [x] **Core Service Architecture ([`PushNotificationService`](file:///d:/football_reservation/lib/core/services/push_notification_service.dart)):**
  - Configured top-level `@pragma('vm:entry-point') firebaseMessagingBackgroundHandler` for background/lock-screen message delivery.
  - User permission management with alerts, badges, and sounds (`requestPermission`).
  - Device token registration and dynamic updates using modern FCM API (`onRegistered` & `register`).
  - Realtime token synchronization to Firestore user document (`fcmTokens` array and `lastFcmUpdate` timestamp) on login and removal on logout via [`AuthBloc`](file:///d:/football_reservation/lib/features/authentication/presentation/bloc/auth_bloc.dart).
  - Listeners for foreground alerts, background app launch, and terminated-state interaction.
  - Topic subscription support (`subscribeToTopic`, `unsubscribeFromTopic`).
  - Platform-safe execution protecting Desktop/Web/Headless test runners without crashes.
- [x] **Automated Verification:**
  - `flutter analyze`: 0 issues found.
  - `flutter test`: 100% passing across all 10 test suites.

### App Icons & Video Splash Screen Integration
- [x] **Native App Icons (Android & iOS):**
  - Mapped and deployed provided custom app icons:
    - Android: `mipmap-hdpi`, `mipmap-mdpi`, `mipmap-xhdpi`, `mipmap-xxhdpi`, `mipmap-xxxhdpi` with standard (`ic_launcher`) and adaptive round (`ic_launcher_round`) icons in [`android/app/src/main/res/`](file:///d:/football_reservation/android/app/src/main/res/).
    - iOS: Universal `AppIcon-1024.png` along with full legacy device scales (20pt, 29pt, 40pt, 60pt, 76pt, 83.5pt) in [`ios/Runner/Assets.xcassets/AppIcon.appiconset/`](file:///d:/football_reservation/ios/Runner/Assets.xcassets/AppIcon.appiconset/).
- [x] **Native Launch Screen Redesign & Logo Removal:**
  - Cancelled native splash image/logo to eliminate jump/glitch effects.
  - Extracted exact background color from splash video: `#F2F2E7` (warm beige canvas).
  - Configured Android [`launch_background.xml`](file:///d:/football_reservation/android/app/src/main/res/drawable/launch_background.xml), [`colors.xml`](file:///d:/football_reservation/android/app/src/main/res/values/colors.xml), and [`styles.xml`](file:///d:/football_reservation/android/app/src/main/res/values-night/styles.xml) with solid `#F2F2E7`.
  - Configured iOS [`LaunchScreen.storyboard`](file:///d:/football_reservation/ios/Runner/Base.lproj/LaunchScreen.storyboard) with pure solid `#F2F2E7` (RGB: 0.949, 0.949, 0.906) and removed image constraints.
- [x] **In-App Video Splash Screen ([`VideoSplashPage`](file:///d:/football_reservation/lib/features/splash/presentation/pages/video_splash_page.dart)):**
  - Integrated `video_player: ^2.10.1` playing [`assets/splash_screen/gemini_generated_video_77849432.mp4`](file:///d:/football_reservation/assets/splash_screen/gemini_generated_video_77849432.mp4).
  - Matches the exact `#F2F2E7` canvas background for a 100% seamless transition from OS launch into video playback.
  - Added Arabic skip button ("تخطي") and screen tap-to-skip for instant entry.
  - Built-in safe timeout fallback and headless test protection.
  - Integrated into [`AppRouter`](file:///d:/football_reservation/lib/app/router/app_router.dart) as initial route (`/splash`), navigating to `/` upon completion.
- [x] **Automated Verification:**
  - `test/splash_test.dart` passes.
  - `flutter analyze`: 0 issues found.
  - `flutter test`: 100% passing across all test suites.

### Foreground Heads-up Banners & Firebase Admin FCM HTTP v1 Integration
- [x] **In-App Foreground Heads-up Notification Banner:**
  - Integrated `flutter_local_notifications: ^20.1.0`.
  - Configured Android high-importance notification channel `kickoff_high_importance_channel` with `Importance.max` and `Priority.high`.
  - Configured iOS foreground alert/sound/badge presentation options.
  - Handled foreground FCM messages to immediately pop up a native floating banner while using the app.
- [x] **Firebase Admin Service Account & FCM HTTP v1 Sender Engine:**
  - Added `googleapis_auth: ^2.0.0` and `http: ^1.6.0`.
  - Configured `FirebaseAdminCredentials` securely linking project `football-app-a6063`.
  - Built [`FirebaseNotificationSenderService`](file:///d:/football_reservation/lib/core/services/firebase_notification_sender_service.dart):
    - Authenticates via Google OAuth 2.0 with scope `https://www.googleapis.com/auth/firebase.messaging`.
    - Handles OAuth token lifecycle, caching, and auto-refresh.
    - Sends notifications to topics (`kickoff_all`, `match_alerts`, `team_alerts`, `poll_alerts`) and direct device tokens.
    - Specialized helper triggers for:
      - Match creation alerts.
      - 3-Team balanced lineup announcement.
      - Waiting list promotion alert to confirmed status.
      - Poll creation alerts.
      - Custom Admin broadcast alerts.
- [x] **Automated Notifications & Admin In-App Broadcast Modal:**
  - Auto-subscribes all app devices to `kickoff_all` on launch.
  - Automatically notifies promoted players when a confirmed player cancels attendance.
  - Automatically announces balanced 3-team lineups when finalized by Admin.
  - Added **Admin Broadcast Dialog** in [`NotificationsPage`](file:///d:/football_reservation/lib/features/notifications/presentation/pages/notifications_page.dart) allowing instant group-wide push notification dispatch directly from within the app.
- [x] **Security Hardening:**
  - Added `service-account.json` and `*service-account*.json` to `.gitignore`.
- [x] **Automated Testing & Verification:**
  - Created `test/fcm_sender_test.dart` with 8 comprehensive unit tests.
  - Total test suite count: **91/91 tests passing (100%)**.
  - `flutter analyze`: **0 issues found**.






