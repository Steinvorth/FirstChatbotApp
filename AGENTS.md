# AGENTS.md — Flutter Project Template Standard

## Flutter Project Structure

All Flutter projects in this repository **must** follow this folder structure under `lib/`:

```
lib/
├── main.dart                    ← App entry point (MaterialApp, theme, initial route)
├── API/
│   ├── APIClient.dart           ← Centralized HTTP client with base URL, headers, GET/POST/DELETE
│   └── index.dart               ← Barrel export
├── UI/
│   ├── <ComponentName>.dart     ← Reusable, atomic UI elements (buttons, inputs, tiles, bubbles)
│   └── index.dart               ← Barrel export
├── Widgets/
│   ├── <WidgetName>.dart        ← Composite widgets combining multiple UI elements into functionality
│   └── index.dart               ← Barrel export
├── Pages/
│   ├── <PageName>.dart          ← Full-screen navigation destinations (use Widgets + UI)
│   └── index.dart               ← Barrel export
├── Services/
│   ├── <ServiceName>.dart       ← Uses APIClient to perform CRUD operations (no direct HTTP)
│   └── index.dart               ← Barrel export
├── Theme/
│   ├── AppColors.dart           ← Color palette constants
│   ├── AppTypography.dart       ← TextStyle definitions
│   ├── Style.dart               ← ThemeData configuration
│   └── index.dart               ← Barrel export
```

## Layer Rules

| Layer | Responsibility | Can Import |
|-------|---------------|------------|
| **API** | HTTP client, base URL, headers, response handling | Nothing app-specific |
| **Services** | CRUD operations using APIClient | API |
| **UI** | Atomic, reusable visual elements | Theme |
| **Widgets** | Composite functionality (forms, lists, bars) | UI, Theme |
| **Pages** | Full screens, state management, layout | Widgets, UI, Services, Theme |
| **Theme** | Colors, typography, ThemeData | Nothing |

## Naming Conventions

- **Files**: `PascalCase.dart` (e.g., `ChatBubble.dart`, `ChatService.dart`)
- **Classes**: `PascalCase` (e.g., `ChatBubble`, `APIClient`)
- **Functions/Methods**: `PascalCase` (e.g., `SendMessage`, `HandleSubmit`)
- **Variables**: `camelCase` (e.g., `isLoading`, `messageController`)
- **Private members**: `_camelCase` for variables, `_PascalCase` for methods
- **Barrel exports**: Always `index.dart`

## Key Constraints

- **UI files**: max 600 lines
- **Services**: max 500 lines
- **Pages**: max 600 lines
- **No networking in UI or Widgets** — only Services call APIClient
- **No business logic in Pages** — delegate to Services
- **Every folder gets a barrel export** (`index.dart`)
- Lint rules `non_constant_identifier_names` and `file_names` are disabled in `analysis_options.yaml` to support PascalCase conventions

## Responsive Design

- Use `MediaQuery.of(context).size.width` for breakpoints
- Desktop (>= 768px): Side-by-side layouts
- Mobile (< 768px): Drawer-based navigation, stacked layouts
- Always wrap bottom inputs with `SafeArea`
