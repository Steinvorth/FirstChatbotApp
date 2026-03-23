# firstChatAppFrontend – Implementation Docs

## Overview
- Goal: Build a responsive Flutter chat frontend that connects to the FastAPI backend at `localhost:8000`, with a collapsible sidebar for conversation history and a scrollable chat area.
- Scope:
  - In-scope: Full UI architecture (Theme, API client, Services, UI components, Widgets, Pages), responsive layout (desktop sidebar + mobile drawer), send button wired to `/chat/send`.
  - Out-of-scope: Backend implementation, authentication, persistent storage, model parsing from real API responses.

## What Was Built
- **Theme system**: Dark theme with custom color palette (`AppColors`), typography (`AppTypography`), and Material ThemeData (`Style.dart`).
- **API layer**: Centralized `APIClient` with base URL config, GET/POST/DELETE methods, and JSON response handling.
- **Service layer**: `ChatService` wrapping all chat endpoints (`send`, `history`, `conversations`, `delete`).
- **Reusable UI components**: `ChatBubble`, `ChatInput`, `SendButton`, `SidebarTile` — all atomic and stateless.
- **Composite Widgets**: `ChatMessageList` (scrollable messages), `ChatInputBar` (input + send), `ConversationSidebar` (scrollable conversation list + new chat button).
- **ChatPage**: Responsive layout — desktop uses animated collapsible sidebar, mobile uses Drawer.
- **AGENTS.md**: Flutter project template standard saved for all future projects.

## Key Files & Structure
```
first_chat_app/lib/
├── main.dart                          ← App entry, applies theme, loads ChatPage
├── API/
│   ├── APIClient.dart                 ← HTTP client (base URL: localhost:8000)
│   └── index.dart
├── Services/
│   ├── ChatService.dart               ← SendMessage, GetHistory, GetConversations, DeleteConversation
│   └── index.dart
├── UI/
│   ├── ChatBubble.dart                ← User/AI message bubble with alignment + styling
│   ├── ChatInput.dart                 ← Text field with submit-on-enter
│   ├── SendButton.dart                ← Arrow button with loading spinner
│   ├── SidebarTile.dart               ← Conversation tile with select/delete
│   └── index.dart
├── Widgets/
│   ├── ChatMessageList.dart           ← Scrollable message list + empty state
│   ├── ChatInputBar.dart              ← Input + send button, pinned to bottom
│   ├── ConversationSidebar.dart       ← Scrollable sidebar + new chat button
│   └── index.dart
├── Pages/
│   ├── ChatPage.dart                  ← Responsive layout (sidebar vs drawer)
│   └── index.dart
├── Theme/
│   ├── AppColors.dart                 ← Color constants
│   ├── AppTypography.dart             ← TextStyle definitions
│   ├── Style.dart                     ← ThemeData
│   └── index.dart
```

## How It Works
- **Data flow**: User types message → `ChatInputBar` → `ChatPage._HandleSendMessage()` → `ChatService.SendMessage()` → `APIClient.Post('/chat/send')` → response parsed → AI bubble added to `_messages` list → UI rebuilds.
- **Responsive behavior**: `ChatPage` checks `MediaQuery.of(context).size.width >= 768` to decide between desktop (Row with AnimatedContainer sidebar) and mobile (Scaffold + Drawer).
- **Scroll management**: Both sidebar and chat area have independent `ScrollController`s. Chat auto-scrolls to bottom on new messages.

## Setup & Usage
- Prerequisites: Flutter SDK 3.10+, `http` package (already in pubspec).
- Run: `cd first_chat_app && flutter run`
- API must be running at `localhost:8000` for chat to work.

## Testing
- `flutter analyze` — 0 issues.
- `flutter build ios --no-codesign` — builds successfully.
- Widget test at `test/widget_test.dart` verifies app renders.

## Extensibility Notes
- **Adding new pages**: Create in `Pages/`, export in `Pages/index.dart`, add route in `main.dart`.
- **Adding new API endpoints**: Add method to `APIClient`, create/extend service in `Services/`.
- **Theming**: All colors and typography are centralized — change `AppColors.dart` and `AppTypography.dart` to retheme.
- **Real API integration**: When backend is implemented, update response parsing in `ChatPage._HandleSendMessage()` to match actual payload structure.

## Changelog (summary)
- Phase 1: Created project structure with all folders and barrel exports.
- Phase 2: Built Theme system (AppColors, AppTypography, Style).
- Phase 3: Built API client and ChatService layer.
- Phase 4: Built atomic UI components (ChatBubble, ChatInput, SendButton, SidebarTile).
- Phase 5: Built composite Widgets (ChatMessageList, ChatInputBar, ConversationSidebar).
- Phase 6: Built ChatPage with responsive desktop/mobile layout.
- Phase 7: Wired main.dart, fixed lints, verified build. Created AGENTS.md template.
