abstract class AppConstants {
  // ── API config ──────────────────────────────────────────────────────────────
  static const String openAiBaseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String openAiModel = 'gpt-4o';
  static const int openAiMaxTokens = 4096;
  static const int requestTimeoutSeconds = 90;

  // ── Shared preferences ──────────────────────────────────────────────────────
  static const String prefsApiKey = 'openai_api_key';

  // ── System prompt ───────────────────────────────────────────────────────────
  static const String systemPrompt = '''
You are a senior software requirements analyst. Parse the client brief and return a structured developer-ready JSON output.

STRICT RULES — NEVER BREAK THESE:
1. DO NOT ASSUME: Never invent details, features, technologies, or behaviors not explicitly written in the brief.
2. NEEDS CLARIFICATION: If any value cannot be determined from the brief, write exactly "Needs Clarification" as the field value. Add a matching entry in the "clarifications" array explaining what is missing.
3. DO NOT HALLUCINATE: Only describe what is present in the brief. Do not add extras, suggestions, or best practices.
4. PRESERVE INTENT: Restate the client's goals faithfully using their language. Do not reinterpret, enhance, or rephrase their meaning.
5. JSON ONLY: Return ONLY a valid JSON object. No markdown, no code fences, no explanation text outside the JSON.

OUTPUT SCHEMA — return exactly this structure, no extra keys:
{
  "summary": "One paragraph. A faithful restatement of what the client wants, using only information from the brief.",
  "requirements": [
    {
      "id": "REQ-001",
      "category": "Category name derived from the brief (e.g. UI, Data, Integration)",
      "description": "Factual description taken directly from the brief. Write 'Needs Clarification' if the requirement is ambiguous.",
      "priority": "high"
    }
  ],
  "tickets": [
    {
      "id": "TICKET-001",
      "title": "Short imperative phrase (e.g. 'Implement task creation flow')",
      "description": "As a [role from brief], I want [feature from brief], so that [benefit from brief]. Write 'Needs Clarification' for any part that is not stated.",
      "acceptance_criteria": [
        "Specific, testable criterion derived only from the brief. Write 'Needs Clarification' if no testable criteria can be formed."
      ],
      "priority": "medium",
      "category": "Must exactly match a category used in requirements"
    }
  ],
  "clarifications": [
    "Needs Clarification: [specific question about a gap or ambiguity found in the brief]"
  ]
}

FIELD CONSTRAINTS:
- priority: must be exactly one of these strings — "high", "medium", or "low"
- Every requirement must produce at least one ticket
- Every use of "Needs Clarification" in any field must have a corresponding entry in the clarifications array
- clarifications must also flag missing critical areas not mentioned in the brief: error handling, performance targets, and user roles
''';

  // ── Error messages ───────────────────────────────────────────────────────────
  static const String errApiKeyRequired =
      'API key is required. Please add your OpenAI API key in settings.';
  static const String errBriefEmpty = 'Brief content cannot be empty.';
  static const String errTimeout = 'Request timed out. Please try again.';
  static const String errInvalidApiKey =
      'Invalid API key. Please check your OpenAI API key in settings.';
  static const String errRateLimit =
      'Rate limit exceeded. Please wait a moment and try again.';
  static const String errInsufficientCredits =
      'Insufficient credits. Please check your OpenAI account billing.';
  static const String errInvalidResponse =
      'The model returned an invalid response. Please try again.';
  static const String errUnexpected = 'An unexpected error occurred: ';
  static const String errBriefRequired =
      'Please enter or paste a client brief before analyzing.';

  // ── App labels ───────────────────────────────────────────────────────────────
  static const String appTitle = 'Brief Analyzer';
  static const String homeHeadline = 'Transform briefs into\ndeveloper tickets';
  static const String homeSubtitle =
      'Paste your client brief and get structured requirements, dev tickets, and flagged clarifications — powered by GPT-4o.';
  static const String inputCardLabel = 'Client Brief';
  static const String inputHintText =
      '# Client Brief\n\n## Overview\nPaste your client brief here in Markdown format...\n\n## Requirements\n- Feature 1\n- Feature 2\n\n## Goals\n...';
  static const String loadFileButton = 'Load .md file';
  static const String wordCountSuffix = 'words';
  static const String exampleBannerText =
      'Try the example brief to see how the analyzer works';
  static const String useExampleButton = 'Use example';
  static const String analyzeButton = 'Analyze Brief';
  static const String analyzingButton = 'Analyzing brief...';

  // ── Tooltips ──────────────────────────────────────────────────────────────────
  static const String tooltipApiKeySet = 'API Key configured';
  static const String tooltipApiKeyMissing = 'Add API Key';
  static const String tooltipAnalyzeAgain = 'Analyze again';

  // ── Result screen labels ──────────────────────────────────────────────────────
  static const String resultsTitle = 'Analysis Results';
  static const String tabSummary = 'Summary';
  static const String tabRequirements = 'Requirements';
  static const String tabTickets = 'Tickets';
  static const String tabClarifications = 'Clarifications';

  static const String summaryTitle = 'Executive Summary';
  static const String summarySubtitle = 'AI-generated overview of the brief';

  static const String requirementsTitle = 'Requirements Breakdown';
  static const String requirementsSubtitle = 'Extracted from the client brief';

  static const String ticketsTitle = 'Developer Tickets';
  static const String ticketsSubtitle = 'Ready to import into your project tracker';
  static const String ticketsHint = 'Tap a ticket to expand details and acceptance criteria';
  static const String ticketsCopyAll = 'Copy all';
  static const String ticketsCopied = 'tickets copied to clipboard';

  static const String clarificationsTitle = 'Clarifications Needed';
  static const String clarificationsSubtitle =
      'Questions to ask the client before development';
  static const String clarificationsInfo =
      'These are gaps or ambiguities in the brief that must be resolved before development begins.';

  static const String categoriesLabel = 'CATEGORIES';
  static const String statRequirements = 'Requirements';
  static const String statTickets = 'Dev Tickets';
  static const String statClarifications = 'Clarifications';

  static const String emptyRequirements = 'No requirements were extracted from the brief.';
  static const String emptyTickets = 'No tickets were generated from the brief.';
  static const String emptyClarifications =
      'No clarifications needed — the brief was complete and clear.';
  static const String noResults = 'No results available.';

  // ── API key dialog ────────────────────────────────────────────────────────────
  static const String apiKeyDialogTitle = 'OpenAI API Key';
  static const String apiKeyDialogBody =
      'Your API key is stored locally on your device and never sent anywhere except OpenAI.';
  static const String apiKeyHint = 'sk-...';
  static const String apiKeyGetLink = 'Get your API key →';
  static const String apiKeyGetSnackbar =
      'Get your API key at platform.openai.com/api-keys';
  static const String dialogCancel = 'Cancel';
  static const String dialogSave = 'Save';

  // ── Example brief ─────────────────────────────────────────────────────────────
  static const String exampleBrief = '''# Client Brief: Task Management App

## Overview
We need a mobile app to help small teams (2–10 people) manage daily tasks and projects.

## Target Users
Small business owners and their teams who need simple task coordination.

## Core Features
- Create, edit, and delete tasks
- Assign tasks to team members
- Set due dates and priorities
- Simple dashboard with task summary

## Tech Preferences
- Mobile app (iOS and Android)

## Timeline
MVP in 8 weeks.

## Budget
Not specified.
''';
}
