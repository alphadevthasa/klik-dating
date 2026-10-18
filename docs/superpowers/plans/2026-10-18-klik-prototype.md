# KLiK Dating App Prototype Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an interactive Flutter dating-app prototype based on the approved KLiK design, using local sample data and Lottie match animation.

**Architecture:** A small stateful app shell owns session-only profile, like, filter, tab, and chat state. Focused screens receive data and callbacks; Flutter navigation opens match and conversation views. Local fixtures keep all behavior deterministic without a backend.

**Tech Stack:** Flutter/Dart, Material widgets, `flutter_card_swiper`, `lottie`, `flutter_test`.

## Global Constraints

- Use Flutter Material widgets as the foundation, `flutter_card_swiper` for the Discover stack, and `lottie` for one bundled match animation.
- Keep local sample data and UI state in memory; app restart resets state.
- Use Indonesian UI copy and the approved cream/blush, coral-pink, and deep-navy palette.
- Include Discover, Like, Chat, and Profil tabs; match and conversation views open above the tab shell.
- Keep login, backend, durable storage, real matching service, and production moderation out of scope.
- Respect reduced-motion settings, label icon-only actions, and keep touch targets and photo contrast accessible.

---

## File map

- `pubspec.yaml` — Flutter package metadata, `flutter_card_swiper` and `lottie` dependencies, and animation asset declaration.
- `lib/main.dart` — app entry point.
- `lib/app.dart` — theme, bottom-tab shell, shared local session state, and navigation callbacks.
- `lib/models/dating_profile.dart` — profile fixture shape.
- `lib/models/chat_message.dart` — local message shape.
- `lib/data/mock_data.dart` — deterministic sample profiles and conversations.
- `lib/features/discover/discover_screen.dart` — `CardSwiper` profile stack, action buttons, and filter sheet.
- `lib/features/likes/likes_screen.dart` — liked-profile list and conversation shortcut.
- `lib/features/chat/chat_screen.dart` — conversation list, conversation view, and message composer.
- `lib/features/profile/profile_screen.dart` — current demo profile.
- `lib/features/match/match_screen.dart` — mutual-match celebration and next actions.
- `assets/animations/match.json` — local finite heart celebration Lottie animation.
- `test/widget_test.dart` — app shell smoke check.
- `test/discover_flow_test.dart` — pass, like, and filter behavior.
- `test/chat_flow_test.dart` — local message send behavior.
- `test/match_flow_test.dart` — mutual-match and send-message transition.

## Task 1: Scaffold app shell and local fixtures

**Files:** `pubspec.yaml`, `lib/main.dart`, `lib/app.dart`, `lib/models/dating_profile.dart`, `lib/models/chat_message.dart`, `lib/data/mock_data.dart`, `test/widget_test.dart`

**Interfaces:**
- `DatingProfile`: `id`, `name`, `age`, `city`, `bio`, `imageUrl`, `distanceKm`, `interests`, and `mutualMatch` fields.
- `ChatMessage`: `text`, `isMine`, and `timeLabel` fields.
- `mockProfiles`: deterministic demo list ordered with non-match profiles before one `mutualMatch: true` fixture; include fixture ages/distances that make filter assertions deterministic.
- `mockMessagesByProfile`: deterministic local message history keyed by profile ID.
- `KliKApp`: root `StatefulWidget` with four tabs and session state; later screens plug into its tab destinations.

- [ ] **Step 1: Create Flutter project and add Lottie dependency**

Run from `/Users/thasafarian/Development/KLiK`:

```bash
flutter create --project-name klik --platforms=android,ios .
flutter pub add lottie
```

- [ ] **Step 2: Replace starter smoke test with app-shell expectation**

In `test/widget_test.dart`, pump `KliKApp` and assert the KLiK brand and four tab labels are present. Run `flutter test test/widget_test.dart`; expect failure until `KliKApp` exists.

- [ ] **Step 3: Add models, fixtures, app entry, theme, and tab shell**

Use the approved palette, Indonesian labels, and Material navigation. Keep profile and chat fixtures in `mock_data.dart`; include enough profiles to exercise pass, like, filter, and exhausted-list states. Store active tab, current profile index, liked IDs, selected conversation ID, and messages in `_KliKAppState`.

- [ ] **Step 4: Verify app shell**

Run `flutter test test/widget_test.dart` and `flutter analyze`. Expected: test passes and analyzer reports no issues.

## Task 2: Build Discover interactions and filters

**Files:** `lib/features/discover/discover_screen.dart`, `lib/app.dart`, `test/discover_flow_test.dart`

**Interfaces:**
- `DiscoverScreen({required List<DatingProfile> profiles, required ValueChanged<DatingProfile> onPass, required ValueChanged<DatingProfile> onLike, required ValueChanged<DatingProfile> onSuperLike, required ValueChanged<ProfileFilter> onFilter})`.
- `ProfileFilter({required RangeValues ageRange, required double maxDistanceKm})`: returned by the filter bottom sheet.
- `ProfileCard`: displays one profile inside the `CardSwiper` stack; swipe outcomes are handled by the parent screen.

- [ ] **Step 1: Write Discover behavior tests**

Create `test/discover_flow_test.dart`. Pump `KliKApp`; verify tapping `discover-pass` advances to the next non-match profile, dragging that card right records a like, and `discover-filter` opens the age/distance sheet. Apply values that match exactly one fixture and verify only that fixture remains. Run `flutter test test/discover_flow_test.dart`; expect failures before implementation.

- [ ] **Step 2: Implement profile card and local filtering**

Add left/right horizontal drag handling and X/star/heart buttons. Use the same callbacks for gesture and button actions. Render profile photos with `Image.network`, a loading placeholder, and `errorBuilder` fallback. Apply the selected age range and distance to `mockProfiles` in the app shell; reset card index when filter changes.

- [ ] **Step 3: Implement empty discovery state and filter sheet**

Show an Indonesian empty state when filtered profiles are exhausted and provide a restart action. The filter bottom sheet exposes age range, maximum distance, Cancel, and Apply controls.

- [ ] **Step 4: Verify Discover behavior**

Run `flutter test test/discover_flow_test.dart` and `flutter analyze`. Expected: swipe, buttons, and filtering pass without analyzer errors.

## Task 3: Build Like, Chat, and Profil tabs

**Files:** `lib/features/likes/likes_screen.dart`, `lib/features/chat/chat_screen.dart`, `lib/features/profile/profile_screen.dart`, `lib/app.dart`, `test/chat_flow_test.dart`

**Interfaces:**
- `LikesScreen({required List<DatingProfile> profiles, required ValueChanged<String> onOpenConversation})`.
- `ChatScreen({required List<DatingProfile> profiles, required String? conversationId, required Map<String, List<ChatMessage>> messagesByProfile, required ValueChanged<String> onOpenConversation, required VoidCallback onBack, required void Function(String profileId, String text) onSendMessage})`.
- `ProfileScreen({required DatingProfile profile})`.

- [ ] **Step 1: Write message-send test**

Create `test/chat_flow_test.dart`. Pump `KliKApp`, open a sample chat, enter `Hai!`, tap `chat-send`, and verify `Hai!` appears as an outgoing bubble. Verify empty composer does not add a bubble. Run `flutter test test/chat_flow_test.dart`; expect failure before implementation.

- [ ] **Step 2: Implement Like and Profil tabs**

Show liked fixtures in Like, with an action to open that profile's conversation. Show the current demo profile, interests, and photo in Profil. Add empty state for an empty Like list.

- [ ] **Step 3: Implement conversation list, messages, and composer**

Display fixture conversations in Chat. Selecting a row displays its message history; back returns to the conversation list. Append non-empty sent messages to `messagesByProfile` in app state. Keep the composer keyboard-safe and provide semantic labels for send and back controls.

- [ ] **Step 4: Verify tabs and local messaging**

Run `flutter test test/chat_flow_test.dart` and `flutter analyze`. Expected: message appears immediately, blank send is ignored, and tab navigation remains usable.

## Task 4: Add Lottie match flow

**Files:** `assets/animations/match.json`, `pubspec.yaml`, `lib/features/match/match_screen.dart`, `lib/app.dart`, `test/match_flow_test.dart`

**Interfaces:**
- `MatchScreen({required DatingProfile profile, required VoidCallback onSendMessage, required VoidCallback onContinue})`.
- Like action adds profile ID to Like state. For a fixture with `mutualMatch == true`, app opens Match; other likes stay in the Like tab.
- `onSendMessage` opens Chat focused on the matched profile; `onContinue` returns to Discover.

- [ ] **Step 1: Write match transition test**

Create `test/match_flow_test.dart`. Pump `KliKApp`, pass the preceding non-match profiles, like the configured mutual-match fixture, and verify the match headline and `match-animation` are visible. Tap `Kirim pesan` and verify Chat opens on that profile. Run `flutter test test/match_flow_test.dart`; expect failure before implementation.

- [ ] **Step 2: Bundle finite Lottie animation**

Add an original heart-and-sparkles Lottie JSON at `assets/animations/match.json`; declare it under Flutter assets in `pubspec.yaml`. Keep animation finite and local, with no runtime network fetch.

- [ ] **Step 3: Implement match screen and route callbacks**

Use `Lottie.asset('assets/animations/match.json', repeat: false)` with profile photos, KLiK match copy, `Kirim pesan`, and `Lanjut lihat profil lain`. Add reduced-motion handling so the screen remains complete when decorative animation is skipped.

- [ ] **Step 4: Verify match-to-chat flow**

Run `flutter test test/match_flow_test.dart` and `flutter analyze`. Expected: Lottie loads from the bundled asset, the match fixture routes to Match, and its message action opens the right conversation.

## Task 5: Adopt flutter_card_swiper for Discover

**Files:** `pubspec.yaml`, `lib/features/discover/discover_screen.dart`, `test/discover_flow_test.dart`

**Interfaces:**
- `CardSwiperController` drives the existing pass / super-like / like buttons.
- `CardSwiper.onSwipe(previousIndex, currentIndex, direction)` maps left to pass, right to like, and up to super-like.
- Configure `isLoop: false`; after the last card, `onEnd` reveals the existing empty state.

- [ ] **Step 1: Add the package**

Run `flutter pub add flutter_card_swiper` in the project worktree. The package supports controller-triggered swipes and configurable left/right/up directions.

- [ ] **Step 2: Add package-backed Discover tests**

Update `test/discover_flow_test.dart` to assert that `CardSwiper` is used, left/right drags still pass/like the correct fixture, the star action triggers super-like, and exhausting the non-looping stack shows the empty state. Run `flutter test test/discover_flow_test.dart`; the `CardSwiper` assertion must fail before production changes.

- [ ] **Step 3: Replace custom drag handling with CardSwiper**

Create and dispose one `CardSwiperController` in `DiscoverScreen`. Render profile content through `CardSwiper.cardBuilder`; use the package `onSwipe` callback for left/pass, right/like, and up/super-like. Route the existing X/star/heart controls through `controller.swipe(...)`. Set `isLoop: false` and allow only left, right, and up directions. Keep filter changes resetting the stack index.

- [ ] **Step 4: Verify package-backed swipe behavior**

Run `flutter test test/discover_flow_test.dart` and `flutter analyze`. Expected: button and gesture outcomes agree, the package stack ends, and existing profile/filter behavior remains intact.

## Task 6: Run full acceptance checks

**Files:** all app and test files above.

- [ ] **Step 1: Run full static and widget checks**

Run `flutter analyze` and `flutter test`. Expected: no analyzer issues and all widget tests pass.

- [ ] **Step 2: Run on an available simulator or device**

Run `flutter devices`, then `flutter run -d <device-id>`. Manually verify all four tabs, gesture/button parity, filter updates, empty state restart, match animation, message sending, safe keyboard layout, and image fallback.

- [ ] **Step 3: Fix only observed acceptance failures**

For each issue found, add or update the smallest relevant widget test, fix the behavior, and rerun the affected test plus `flutter analyze`.
