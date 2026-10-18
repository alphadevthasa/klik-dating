# KLiK Dating App Prototype Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an interactive Flutter dating-app prototype matching the supplied three-screen KLiK reference, using local sample data and Lottie effects.

**Architecture:** A small stateful app shell owns session-only profile, like, filter, tab, and chat state. Focused screens receive data and callbacks; Flutter navigation opens the full-screen match view, while conversation detail stays inside Chat tab. Local fixtures keep all behavior deterministic without a backend.

**Tech Stack:** Flutter/Dart, Material widgets, `flutter_card_swiper`, `lottie`, `flutter_test`.

## Global Constraints

- Use Flutter Material widgets as the foundation, `flutter_card_swiper` for the Discover stack, and local `lottie` animations for like feedback and match celebration.
- Keep local sample data and UI state in memory; app restart resets state.
- Use Indonesian UI copy and the approved cream/blush, coral-pink, and deep-navy palette.
- Include Temukan, Likes, Chat, and Profil tabs; Match opens full-screen, while an open Chat conversation keeps bottom navigation visible.
- Keep login, backend, durable storage, real matching service, and production moderation out of scope.
- Respect reduced-motion settings, label icon-only actions, and keep touch targets and photo contrast accessible.

---

## File map

- `pubspec.yaml` — Flutter package metadata, `flutter_card_swiper` and `lottie` dependencies, and animation asset declaration.
- `lib/main.dart` — app entry point.
- `lib/app.dart` — theme, bottom-tab shell, shared local session state, and navigation callbacks.
- `lib/widgets/klik_brand.dart` — shared KLiK wordmark/tagline header.
- `lib/models/dating_profile.dart` — profile fixture shape.
- `lib/models/chat_message.dart` — local message shape.
- `lib/data/mock_data.dart` — deterministic candidate, incoming-like, current-profile, and conversation fixtures.
- `lib/features/discover/discover_screen.dart` — `CardSwiper` profile stack, action buttons, and filter sheet.
- `lib/features/likes/likes_screen.dart` — blurred incoming-like grid and local information sheet.
- `lib/features/chat/chat_screen.dart` — conversation list, conversation view, and message composer.
- `lib/features/profile/profile_screen.dart` — current demo profile.
- `lib/features/match/match_screen.dart` — mutual-match celebration and next actions.
- `assets/animations/like_burst.json` — local finite heart feedback for a non-match like.
- `assets/animations/match.json` — local finite heart-burst celebration around matched profiles.
- `test/widget_test.dart` — app shell smoke check.
- `test/discover_flow_test.dart` — pass, like, and filter behavior.
- `test/chat_flow_test.dart` — local message send behavior.
- `test/match_flow_test.dart` — mutual-match and send-message transition.

## Task 1: Scaffold app shell and local fixtures

**Files:** `pubspec.yaml`, `lib/main.dart`, `lib/app.dart`, `lib/models/dating_profile.dart`, `lib/models/chat_message.dart`, `lib/data/mock_data.dart`, `test/widget_test.dart`

**Interfaces:**
- `DatingProfile`: `id`, `name`, `age`, `city`, `bio`, `imageUrl`, `distanceKm`, `interests`, and `mutualMatch` fields.
- `ChatMessage`: `text`, `isMine`, and `timeLabel` fields.
- `mockProfiles`: deterministic demo list with Nadia, 27, as the first `mutualMatch: true` fixture; include distinct ages/distances for filter assertions.
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
- `LikesScreen({required List<DatingProfile> incomingLikes, required VoidCallback onUnlockLikes})`.
- `ChatScreen({required List<DatingProfile> profiles, required String? conversationId, required Map<String, List<ChatMessage>> messagesByProfile, required ValueChanged<String> onOpenConversation, required VoidCallback onBack, required void Function(String profileId, String text) onSendMessage})`; conversation detail stays within Chat tab.
- `ProfileScreen({required DatingProfile profile})`.

- [ ] **Step 1: Write message-send test**

Create `test/chat_flow_test.dart`. Pump `KliKApp`, open a sample chat, enter `Hai!`, tap `chat-send`, and verify `Hai!` appears as an outgoing bubble. Verify empty composer does not add a bubble. Run `flutter test test/chat_flow_test.dart`; expect failure before implementation.

- [ ] **Step 2: Implement Like and Profil tabs**

Show a basic local incoming-Likes preview with its lock action. Show the current demo profile, interests, and photo in Profil. Task 10 applies final reference styling to both tabs.

- [ ] **Step 3: Implement conversation list, messages, and composer**

Display fixture conversations in Chat. Selecting a row displays its message history; back returns to the conversation list. Append non-empty sent messages to `messagesByProfile` in app state. Keep the composer keyboard-safe and provide semantic labels for send and back controls.

- [ ] **Step 4: Verify tabs and local messaging**

Run `flutter test test/chat_flow_test.dart` and `flutter analyze`. Expected: message appears immediately, blank send is ignored, and tab navigation remains usable.

## Task 4: Add Lottie match flow

**Files:** `assets/animations/match.json`, `pubspec.yaml`, `lib/features/match/match_screen.dart`, `lib/app.dart`, `test/match_flow_test.dart`

**Interfaces:**
- `MatchScreen({required DatingProfile currentProfile, required DatingProfile profile, required VoidCallback onSendMessage, required VoidCallback onContinue})` uses editable current-profile data.
- Like action adds profile ID to Like state. For the first fixture, configured with `mutualMatch == true`, app opens Match; other likes stay in the Like tab.
- `onSendMessage` opens Chat focused on the matched profile while retaining its bottom navigation; `onContinue` returns to Discover.

- [ ] **Step 1: Write match transition test**

Create `test/match_flow_test.dart`. Pump `KliKApp`, like the first configured mutual-match fixture, and verify the match headline and `match-animation` are visible. Tap `Kirim pesan` and verify Chat opens on that profile with bottom navigation visible. Run `flutter test test/match_flow_test.dart`; expect failure before implementation.

- [ ] **Step 2: Bundle finite Lottie animation**

Add an original heart-and-sparkles Lottie JSON at `assets/animations/match.json`; declare it under Flutter assets in `pubspec.yaml`. Keep animation finite and local, with no runtime network fetch.

- [ ] **Step 3: Implement match screen and route callbacks**

Use `Lottie.asset('assets/animations/match.json', repeat: false)` with overlapping profile photos, KLiK match copy, `Kirim pesan`, and `Lanjut lihat profil lain`. Add reduced-motion handling so the screen remains complete when decorative animation is skipped.

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

## Task 7: Match Discover and app shell to reference

**Files:** `pubspec.yaml`, `assets/animations/like_burst.json`, `lib/app.dart`, `lib/features/discover/discover_screen.dart`, `lib/features/chat/chat_screen.dart`, `lib/widgets/klik_brand.dart`, `lib/data/mock_data.dart`, `test/widget_test.dart`, `test/discover_flow_test.dart`, `test/chat_flow_test.dart`

**Interfaces:**
- `KliKBrand({double logoSize = 34, bool showTagline = true, Color? color, Alignment alignment = Alignment.center})` uses the exact tagline `Temukan koneksi yang klik`, centered navy on Discover/Match and left-aligned coral on Likes/Profil.
- First `mockProfiles` fixture is Nadia, 27, Bandung, with coffee/book/travel/sunset interests and deterministic mutual-match behavior.
- `DiscoverScreen` retains `CardSwiperController`, filter callbacks, and existing left/pass, right/like, up/super-like behavior.
- A non-match right swipe displays local `like_burst.json`; reduced motion uses a static heart.
- Opening a conversation sets `selectedConversationId` and Chat tab index without pushing a route; bottom navigation remains visible.

- [ ] **Step 1: Write Discover visual assertions**

Update widget tests to assert KLiK brand/tagline, first profile name/location/interests, profile-count badge, verification badge, three action controls, and persistent tabs labelled Temukan, Likes, Chat, Profil. Add tests that a non-match like shows its Lottie feedback and an open Chat conversation retains the tab bar. Run focused Discover/Chat tests; confirm new assertions fail before implementation.

- [ ] **Step 2: Update local demo fixtures**

Set first Discover fixture to Nadia, 27, Bandung, with the approved reference copy/interests and `mutualMatch: true`. Set current demo profile to Alya, 26, Jakarta, as shown in Profil reference. Preserve at least five profiles and distinct ages/distances for filtering and card count.

- [ ] **Step 3: Rebuild Discover shell and profile card**

Remove the generic global AppBar. Add the reusable KLiK brand header with profile/filter actions. Let the profile photo fill remaining height in a rounded card; overlay its count badge, bottom scrim, verified name, location, bio, and interest chips. Use three large circular pass/super-like/like controls and a compact persistent bottom bar matching the reference. Keep Chat conversation detail inside its tab. Preserve image-error fallback and contrast.

- [ ] **Step 4: Verify Discover screen**

Run `flutter test test/widget_test.dart test/discover_flow_test.dart` and `flutter analyze`. Expected: all prior interactions pass and reference-specific content is present.

## Task 8: Refine Lottie match effect

**Files:** `assets/animations/match.json`, `pubspec.yaml`, `lib/features/match/match_screen.dart`, `lib/app.dart`, `test/match_flow_test.dart`

**Interfaces:**
- `match.json` is a finite coral heart burst with rays/sparkles between the two profile photos.
- The match effect is local and honors reduced motion; static UI remains complete without animation.

- [ ] **Step 1: Write Lottie flow assertions**

Update `test/match_flow_test.dart` to verify Nadia's like opens the match screen with both profile photos, `Kalian cocok!`, the match animation, and both actions. Run the focused file and confirm the new visual assertions fail before screen/asset changes.

- [ ] **Step 2: Bundle local animations**

Add a finite heart-burst Lottie JSON asset and register it in `pubspec.yaml`; do not fetch animation files at runtime.

- [ ] **Step 3: Rebuild the Match composition**

Use the centered navy KLiK wordmark/tagline, blush backdrop, decorative coral heart/ray shapes, overlapping circular photos, centered Lottie heart, “Kalian cocok!” headline, concise supporting copy, full-width coral `Kirim pesan`, and lighter `Lanjut lihat profil lain` action.

- [ ] **Step 4: Verify animation and reduced motion**

Run `flutter test test/match_flow_test.dart` and `flutter analyze`. Expected: local assets load, routes remain correct, and reduced-motion assertions keep copy/actions visible.

## Task 9: Rebuild Chat to match reference

**Files:** `lib/app.dart`, `lib/features/chat/chat_screen.dart`, `lib/data/mock_data.dart`, `test/chat_flow_test.dart`

**Interfaces:**
- Opening a conversation sets `selectedConversationId` and Chat tab index without pushing a route; bottom navigation remains visible.
- Chat header displays profile avatar, name/age, online status, back, call, and more controls.
- Existing message-send callback remains local and rejects blank messages.

- [ ] **Step 1: Write Chat visual/layout assertions**

Update `test/chat_flow_test.dart` to verify Nadia, 27 header/online state, timestamp, incoming and outgoing bubbles, composer icons, send behavior, and bottom navigation visible in conversation detail. Run the focused file and confirm new assertions fail before implementation.

- [ ] **Step 2: Seed reference-style local conversation**

Use short Indonesian sample messages with 09:12–09:17 labels, avatar on incoming messages, coral outgoing bubbles, and warm neutral incoming bubbles. Keep names and profile IDs consistent with Nadia fixture.

- [ ] **Step 3: Rebuild conversation detail**

Create a compact custom header with avatar/name/age/online status, call and overflow buttons. Use a scrolling message list with date separator, left/right bubbles, timestamps and read checks. Pin plus/composer/emoji/send controls above persistent bottom navigation; preserve keyboard resizing and accessible labels.

- [ ] **Step 4: Verify Chat interactions and layout**

Run `flutter test test/chat_flow_test.dart` and `flutter analyze`. Expected: visual assertions, local send, empty-send handling, back-to-list, and keyboard layout pass.

## Task 10: Fix Discover overflow at phone width

**Files:** `lib/features/discover/discover_screen.dart`, `test/widget_test.dart`

**Interfaces:**
- Location and distance copy wraps or ellipsizes within profile card width.
- Discover layout must produce no render exception at a 390×844 logical-pixel viewport.

- [ ] **Step 1: Add the compact-width regression test**

Pump `KliKApp` at 390×844 logical pixels, settle layout, and assert `tester.takeException()` is null. Run `flutter test test/widget_test.dart --plain-name 'Discover layout fits a 390x844 viewport'`; confirm the current location row overflows.

- [ ] **Step 2: Constrain location copy**

Place the combined city/distance text in `Expanded` or `Flexible`, cap it at two lines, and use ellipsis for overflow. Keep the location icon and scrim styling intact.

- [ ] **Step 3: Verify phone-width layout**

Run the focused widget test, `flutter test test/widget_test.dart`, and `flutter analyze`. Expected: no RenderFlex overflow at 390×844 and no regression to brand/profile assertions.

## Task 11: Rebuild Likes and Profil tabs to reference

**Files:** `lib/app.dart`, `lib/data/mock_data.dart`, `lib/features/likes/likes_screen.dart`, `lib/features/profile/profile_screen.dart`, `lib/features/match/match_screen.dart`, `lib/widgets/klik_brand.dart`, `test/widget_test.dart`, `test/chat_flow_test.dart`

**Interfaces:**
- Likes receives deterministic incoming-like fixtures, separate from profiles the user liked.
- Profil receives editable current-user state and callbacks for profile editing and demo-photo selection; current edits also flow into Match.
- `KliKBrand` exposes alignment, color, and tagline visibility so these tabs match their coral left-aligned header.
- Bottom navigation labels are Temukan, Likes, Chat, Profil and remains visible on both tabs.

- [ ] **Step 1: Write Likes/Profile visual and interaction tests**

Add widget tests for Likes heading/subtitle, a two-column blurred locked-photo grid with age/distance, lock CTA and information sheet; and Profil header, circular photo/camera control, verified Alya 26, city/bio/interests, 80% progress, and Edit profil action. Verify edit/photo choices update local state. Run focused tests and confirm new assertions fail before implementation.

- [ ] **Step 2: Add incoming-like fixtures and editable local profile state**

Create four incoming-like fixtures with distinct ages/distances and photos. Keep them separate from `likedProfileIds`. Store profile edits and selected demo photo in app memory; add `copyWith` only if needed for immutable profile updates.

- [ ] **Step 3: Build reference Likes and Profil screens**

Likes uses a two-column grid; blur photo tiles, overlay a centered lock, and show age/distance at the bottom. Lock/CTA taps open a simple informational sheet without billing. Profil uses a large circular photo with camera action, verified name/age, city, bio, interest chips, 80% progress card, and coral Edit profil button. Edit opens a local form; photo action offers existing demo photos.

- [ ] **Step 4: Verify local edits and navigation**

Run `flutter test test/widget_test.dart test/chat_flow_test.dart` and `flutter analyze`. Expected: both reference screens render, local edit/photo choices update state, and bottom navigation remains persistent.

## Task 12: Align brand lockup and Match header

**Files:** `lib/widgets/klik_brand.dart`, `lib/features/discover/discover_screen.dart`, `lib/features/match/match_screen.dart`, `test/widget_test.dart`, `test/match_flow_test.dart`

**Interfaces:**
- KLiK tagline is exactly `Temukan koneksi yang klik`.
- Discover/Match wordmark color is deep navy; Likes/Profil wordmark color is coral.
- Match screen starts with centered wordmark/tagline above the two-photo Lottie composition.

- [ ] **Step 1: Write brand-reference assertions**

Update widget tests to assert the exact tagline and brand colors on Discover, Likes, and Profil. Update Match test to assert tagline and navy KLiK wordmark above the match visual. Run focused files and confirm reference assertions fail before implementation.

- [ ] **Step 2: Align shared wordmark and screen placement**

Use deep navy as `KliKBrand` default, keep explicit coral on Likes/Profil, replace old tagline text, and add the centered brand/tagline header to Match. Preserve current screen flow, Lottie timing, and reduced-motion behavior.

- [ ] **Step 3: Verify brand and Match visuals**

Run `flutter test test/widget_test.dart test/match_flow_test.dart` and `flutter analyze`. Expected: color/tagline assertions pass and all existing interactions remain intact.

## Task 13: Run full visual and functional acceptance

**Files:** all app and test files above.

- [ ] **Step 1: Run full static and widget checks**

Run `flutter analyze` and `flutter test`. Expected: no analyzer issues and all widget tests pass.

- [ ] **Step 2: Run on an available simulator or device**

Run `flutter devices`, then `flutter run -d <device-id>`. Capture simulator screenshots for Discover, Likes, Profil, Match, and Chat; verify screen hierarchy, all bottom tabs, swipe/filter behavior, profile edit/photo flow, match animation, chat bubbles/composer, keyboard fit, and image fallback.

- [ ] **Step 3: Fix only observed acceptance failures**

For each issue found, add or update the smallest relevant widget test, fix the behavior, and rerun the affected test plus `flutter analyze`.
