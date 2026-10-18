# KLiK Dating App Prototype — Design

## Goal

Build an interactive Flutter dating-app prototype inspired by the supplied KLiK reference. The prototype uses local sample data, has no backend or authentication, and keeps changes in memory for the current app session.

## Product and visual direction

- App name: **KLiK**.
- Indonesian-language consumer mobile app.
- Warm cream and blush surfaces, coral-pink actions, and deep navy text, following the reference.
- Profile photography anchors the Discover screen; generous rounded shapes and restrained motion keep the UI warm and readable.
- Flutter Material widgets provide the foundation. Add `lottie` for the bundled match animation; avoid a state-management or UI-kit dependency for this local prototype.

## Screens and navigation

Four bottom tabs:

1. **Discover** — profile cards, filter control, and pass / super-like / like actions.
2. **Like** — profiles liked during the current session.
3. **Chat** — sample conversations and a message composer.
4. **Profil** — current demo profile.

Match success and an individual conversation open as focused screens above the tab shell. The match screen includes the two profile photos, a heart celebration animation, and actions to start a conversation or return to Discover.

## Interaction behavior

- Drag a profile left to pass and right to like; X, star, and heart controls perform the same actions.
- Likes are added to the Like tab. A fixture marked as a mutual match opens the match screen, making the success flow repeatable without random behavior.
- Filters use a bottom sheet for age and distance and update the local profile list when applied.
- Chat rows open a conversation. Sending non-empty text appends a local message; empty text is ignored.
- When no profiles remain, show a clear empty state with an action to restart discovery.
- Profile and image loading failures use readable fallback UI rather than blocking navigation.

## State and data

Keep the small prototype state in the app shell: active tab, current profile index, liked profile IDs, active conversation, and conversation messages. Use a small set of explicitly demo-labeled profile and chat fixtures. State is in memory only and resets on app restart; persistence and remote APIs are out of scope.

## Motion and accessibility

- Bundle one license-compatible Lottie JSON animation for match celebration and render it through `lottie`.
- Use Flutter-native transitions for profile swipe feedback and screen changes; avoid unrelated perpetual animation.
- Respect reduced-motion settings by keeping navigation and content usable without decorative motion.
- Keep touch targets clear, provide semantic labels for icon-only actions, and maintain readable contrast over profile photos using a scrim.

## Verification and acceptance

- `flutter analyze` reports no issues.
- A widget test covers the key local flow: like a profile, reach the match flow for the configured fixture, open chat, and send a message.
- Manual check confirms all four tabs work, filters affect visible profiles, swipe and buttons agree, and profile/image failures remain usable.
- No login, backend, durable storage, real matching service, or production moderation is included.
