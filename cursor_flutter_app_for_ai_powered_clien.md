# Flutter app for AI-powered client brief processing
_Exported on 06/05/2026 at 14:40:50 GMT+5 from Cursor (2.6.22)_

---

**User**

That is a new Flutter project structure for a minimal AI-powered app.
It must use the OpenAI API to transform raw client briefs (in Markdown .md format) into structured, developer-ready outputs.

Objective:

The app should allow users to input or paste a client brief (Markdown text) and generate:

Structured requirement breakdown
Developer-ready tickets (title, description, acceptance criteria)
List of missing or unclear requirements

Core Features
1. Input
Accept Markdown content via:
Text input field (primary)
(Optional) File picker for .md files
2. Processing
Send input to OpenAI API
Use a well-structured prompt to enforce:
No assumptions
Explicit clarification flags
Clean structured output
3. Output Display
Show results in 3 sections:
Summary
Requirements Breakdown
Developer Tickets
Clarifications Needed


---

**Cursor**

Now I have a clear picture. Let me build the full app from scratch. I'll set up the architecture, dependencies, services, models, and screens.

Now let me create the full directory structure and all the files:

Now let's build the widgets:

Now let's build the screens:

Now wire everything together in `main.dart`:

Now let's run `flutter pub get` to install dependencies:

Dependencies installed. Let me check for lint errors:

No lints. Let me do a full analysis to ensure everything compiles:

Let me fix all the issues:

Zero issues. Let me update the todos and verify the final file structure:

Clean build, zero analysis issues. Here's a complete overview of what was built:

---

## What was built

### Architecture

```
lib/
├── main.dart                    # App entry + Provider setup
├── models/
│   └── brief_analysis.dart      # BriefAnalysis, Requirement, DeveloperTicket
├── services/
│   └── openai_service.dart      # GPT-4o API caller with structured prompt
├── providers/
│   └── brief_provider.dart      # State management (idle/loading/success/error)
├── screens/
│   ├── home_screen.dart         # Input screen
│   └── result_screen.dart       # Tabbed output screen
├── widgets/
│   ├── api_key_dialog.dart      # API key entry dialog
│   ├── priority_badge.dart      # High/Medium/Low badges
│   ├── requirement_card.dart    # Requirement row card
│   ├── section_header.dart      # Reusable section header
│   └── ticket_card.dart         # Expandable developer ticket card
└── theme/
    └── app_theme.dart           # Full design system (colors, typography)
```

### Key features implemented

**Input Screen**
- Multi-line Markdown text editor with word count
- `.md` / `.txt` file picker via `file_picker`
- Built-in example brief to test immediately
- API key status indicator in the app bar (green/red key icon)

**OpenAI Service** (`gpt-4o`, JSON mode)
- System prompt enforces: no assumptions, explicit clarification flags, clean JSON output
- Handles 401 (bad key), 429 (rate limit), 402 (billing), and timeouts gracefully
- Returns typed `BriefAnalysis` model

**Result Screen** — 4 tabs:
1. **Summary** — executive summary paragraph + stats cards (counts) + category breakdown
2. **Requirements** — each `REQ-00X` card with priority badge and category tag
3. **Tickets** — expandable cards with description and acceptance criteria; "Copy all" button exports Markdown
4. **Clarifications** — numbered list of flagged questions with a warning banner

**To run the app:**
```bash
cd client_brief
flutter run
```
Then tap the key icon in the top-right to add your OpenAI API key (stored locally via `shared_preferences`).

---

**User**

Did you make sure these points:
STRICT RULES:
- Do not assume missing details
- If unclear, explicitly write "Needs Clarification"
- Do not hallucinate
- Preserve intent

API Return ONLY valid JSON 

Also keep the structure clean

---

**Cursor**

The current prompt has gaps against those four rules. It doesn't instruct the model to write `"Needs Clarification"` literally in fields, doesn't say "preserve intent", and the schema is noisy with `|` separators. Let me tighten everything.

Now lower the temperature to `0` for maximally deterministic, fact-only output, and add a safe JSON parse with a descriptive error:

Now harden the JSON parsing step — if the model ever returns malformed JSON, surface a clear error instead of a crash:

Clean. Here's the final state of the service file:

```19:86:lib/services/openai_service.dart
  static const String _systemPrompt = '''
You are a senior software requirements analyst. Parse the client brief and return a structured developer-ready JSON output.

STRICT RULES — NEVER BREAK THESE:
1. DO NOT ASSUME: Never invent details, features, technologies, or behaviors not explicitly written in the brief.
2. NEEDS CLARIFICATION: If any value cannot be determined from the brief, write exactly "Needs Clarification" as the field value. Add a matching entry in the "clarifications" array explaining what is missing.
3. DO NOT HALLUCINATE: Only describe what is present in the brief. Do not add extras, suggestions, or best practices.
4. PRESERVE INTENT: Restate the client's goals faithfully using their language. Do not reinterpret, enhance, or rephrase their meaning.
5. JSON ONLY: Return ONLY a valid JSON object. No markdown, no code fences, no explanation text outside the JSON.
...
```

Here's a summary of every change made and why:

**Prompt — 4 rule gaps fixed:**
| Rule | Before | After |
|---|---|---|
| No assumptions | Vague "don't assume" | Numbered rule 1, explicit |
| Needs Clarification | Flagged only in `clarifications` array | `"Needs Clarification"` must be the literal field value too, with a paired clarification entry |
| No hallucination | "Don't invent features" | Numbered rule 3, explicitly covers extras/suggestions/best-practices |
| Preserve intent | Not mentioned | Numbered rule 4, mandates using the client's own language |

**JSON schema — cleaned up:**
- Removed `"high|medium|low"` — now shows a real example value (`"high"`) with a separate constraint block listing the three allowed strings
- Removed angle-bracket `<placeholder>` noise — replaced with plain English descriptions inline
- Added `FIELD CONSTRAINTS` block at the bottom separating rules from the schema structure

**API call:**
- `temperature` lowered from `0.2` → `0` — fully deterministic, no creative variance
- `max_tokens` raised from `4000` → `4096` — avoids truncation on large briefs
- Added `try/catch` around the inner `jsonDecode` so a malformed model response shows a clean user-facing error instead of an unhandled crash

---

**User**

Things not required:
authentication
notifications
database (in-memory only)

Keep sstructure clean and remove unnecessory comments and put strings in Constants file.

---

**Cursor**

Let me read all the files that need changes first.

Now rewrite all consuming files to use constants with no stray comments:

Now run a final analysis across the whole project:

Zero issues.

Here's a summary of every change made:

**New file — `lib/constants/app_constants.dart`**

Single `abstract class AppConstants` with six clearly labelled sections:

| Section | Contents |
|---|---|
| API config | `openAiBaseUrl`, `openAiModel`, `openAiMaxTokens`, `requestTimeoutSeconds` |
| Shared preferences | `prefsApiKey` |
| System prompt | The full GPT-4o prompt |
| Error messages | All 9 error strings |
| App labels | Every UI string (headline, hints, buttons, tooltips, tabs, stat labels, empty states) |
| Example brief | Moved here; removed "User registration/login" and "Push notifications" since those aren't required |

**Prompt — removed from critical gaps checklist:**
- `authentication` — not required
- `notifications` — not required
- `data ownership` / database — in-memory only, not required

Remaining flagged gaps: `error handling`, `performance targets`, `user roles`.

**All 5 files updated (`openai_service`, `brief_provider`, `home_screen`, `result_screen`, `api_key_dialog`):**
- Every inline string replaced with `AppConstants.*`
- All code comments stripped — no narration comments remain
- `openai_service.dart` also gained a clean `_assertStatus()` method replacing the chain of `if` blocks, keeping the service tight

---

**User**

add build folder in git ignore

---

**Cursor**

`/build/` is already in the `.gitignore` at line 33. Nothing to add.

