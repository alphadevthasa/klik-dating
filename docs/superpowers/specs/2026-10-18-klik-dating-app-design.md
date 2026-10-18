# KLiK Dating App Prototype — Design

## Goal

Build an interactive Flutter dating-app prototype inspired by the supplied KLiK reference. The prototype uses local sample data, has no backend or authentication, and keeps changes in memory for the current app session.

## Product and visual direction

- App name: **KLiK**.
- Indonesian-language consumer mobile app.
- Warm cream and blush surfaces, coral-pink actions, and deep navy text, following the reference closely.
- Profile photography anchors a nearly full-height Discover card, with a bottom scrim for legible profile details.
- KLiK wordmark uses navy on Discover/Match and coral on Likes/Profil, matching the supplied screens. Tagline reads “Temukan koneksi yang klik”.
- Flutter Material widgets provide the foundation. Use `flutter_card_swiper` for the animated Discover stack and local Lottie assets for like feedback and match celebration; avoid a state-management or UI-kit dependency.

## Screens and navigation

Four bottom tabs use the Indonesian labels **Temukan**, **Likes**, **Chat**, and **Profil**. Bottom navigation stays visible on all tabs, including an open Chat conversation. Match opens as a full-screen route without the tab bar.

1. **Temukan** — centered KLiK wordmark/tagline, filter and profile actions, full-height profile photo, profile-count badge, verified name, location, bio, interest chips, pass / super-like / like controls, and bottom navigation.
2. **Likes** — coral KLiK header with filter/notification actions, heading and subtitle, a two-column grid of blurred incoming-like photos with age/distance and lock badges, plus a coral “Lihat siapa yang menyukaimu” action.
3. **Chat** — conversation list and a reference-style detail view with avatar/name/online header, timestamped incoming/outgoing bubbles, composer controls, and bottom navigation.
4. **Profil** — coral KLiK header with filter/notification actions, circular editable profile photo, verified name/age, city, bio, interest chips, 80% completion progress, and coral “Edit profil” action.

Match success opens as a focused full-screen view. It uses a centered navy KLiK wordmark/tagline, soft blush backdrop, overlapping circular profile photos, a centered animated heart burst, “Kalian cocok!” copy, and primary/secondary actions. The Chat detail remains inside its tab so the bottom navigation stays visible as shown in the reference.

## Interaction behavior

- Drag a profile left to pass and right to like; X, star, and heart controls perform the same actions through `flutter_card_swiper`.
- Likes are added to local session state. A fixture marked as a mutual match opens the match screen, making success repeatable without random behavior.
- The first Discover fixture is Nadia, 27, and is configured as the deterministic mutual match. The current demo profile is Alya, 26; Chat sample messages use Nadia's conversation.
- Incoming Likes cards remain blurred and locked; tapping a lock or the CTA opens a local informational sheet, with no billing flow.
- Profil edit opens a local form sheet; choosing a photo uses bundled demo profile photos. Both changes remain in memory for the current session.
- Filters use a bottom sheet for age and distance and update the local profile list when applied.
- Chat rows open a conversation. Sending non-empty text appends a local message; empty text is ignored.
- When no profiles remain, show a clear empty state with an action to restart discovery.
- Profile and image loading failures use readable fallback UI rather than blocking navigation.

## State and data

Keep the small prototype state in the app shell: active tab, current profile index, liked profile IDs, active conversation, editable current profile, and conversation messages. Use explicitly demo-labeled profile, incoming-like, and chat fixtures. State is in memory only and resets on app restart; persistence, premium billing, and remote APIs are out of scope.

## Motion and accessibility

- Bundle local finite Lottie animations for like feedback and match celebration and render them through `lottie`.
- Use `flutter_card_swiper` for profile-card swipe feedback and Flutter-native transitions for screen changes; avoid unrelated perpetual animation.
- Respect reduced-motion settings by keeping navigation and content usable without decorative motion.
- Keep touch targets clear, provide semantic labels for icon-only actions, and maintain readable contrast over profile photos using a scrim.

## Verification and acceptance

- `flutter analyze` reports no issues.
- A widget test covers the key local flow: like a profile, reach the match flow for the configured fixture, open chat, and send a message.
- Manual check confirms all four tabs work, filters affect visible profiles, swipe and buttons agree, and profile/image failures remain usable.
- No login, backend, durable storage, real matching service, or production moderation is included.
