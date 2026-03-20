---
allowed-tools: Read, Grep, Glob, Bash, TodoWrite
description: "Produces an exhaustive, structured list of all business features from the codebase"
category: documentation
version: 1.0
schema: aitt/commands/cmd.md
input:
  expects: "Path to codebase or description of what to inventory"
  required: false
  format: free-text
---

# Exhaustive Business Feature Inventory for Complex Apps (Mobile, SPA, Stateful Web, Multi-Tier)

## Goal

From the full codebase(s)—including **frontends, backends, services, and databases**—produce an **exhaustive, structured list of all business features** implemented.
**Only list and categorize features** (no descriptions, rules, or UX details). Emphasize **coverage and completeness**.

---

## What counts as a “feature”

A **business feature** is any user- or business-facing capability exposed via **UI, API, background workflow, or data contract** that delivers product value.

### ✅ Include

* User-visible capabilities (e.g., onboarding, auth/SSO, profile, search, content, messaging, notifications).
* Commercial flows (checkout, subscriptions, billing, invoices, coupons, trials, entitlements).
* Growth & re-engagement (referrals, invites, rewards, email/SMS/push campaigns, paywalls).
* Admin/agent/staff consoles and moderation tools.
* Data rights & compliance (export/delete account, consents, age-gating).
* Multi-tenancy, roles/permissions, regional/locale variants.
* Integrations that surface to users (payments, shipping, ID verification, maps, social, support chat).
* API-only or backend-only business workflows (e.g., order lifecycle, KYC, ticketing) even if not directly surfaced in UI.

### 🚫 Exclude

* Pure infra/library code without a direct business capability (e.g. ORM adapters, DI, logging, generic caching, etc.), unless it **implements** a named product capability (e.g., “In-App Purchases”, “Subscriptions”).

---

## Inputs available

* Source code (frontend/mobile + backend/services), configs, environment templates, migrations, seeders, CI/CD files.
* Static assets/templates, i18n resources, email/SMS templates, push payloads.
* API definitions (OpenAPI/Swagger, GraphQL schemas), job/workflow definitions, queue/topic names.
* Tests (unit/integration/E2E), READMEs, architectural docs found in repos.

**Assume static analysis only** (no live systems).

---

## Discovery strategy (be systematic & exhaustive)

### A. Clients

* **Routing & navigation**

  * Views/screens, navigation structure (stacks/graphs/routes), deep/external linking handlers, home screen widgets/extensions, platform-specific integrations (wearables, automotive, TV).
* **State & capability markers**

  * Redux/MobX/Zustand/NgRx/Pinia, feature slices/modules.
  * Feature flag clients (LaunchDarkly, Unleash, custom), A/B framework hooks.
  * UI text (`i18n`, `strings`, menus), component directories named for product surfaces.
* **Channels**

  * Push/in-app messaging renderers, notifications center, inbox, banners, tooltips, NPS/rating prompts.
* **Growth surfaces**

  * Referral screens, invite flows, paywalls/upsells, trials, “rate this app”, sharing.

### B. Backends (PHP, Python, Node.js; monoliths & services)

* **Endpoints & resolvers**

  * REST (controllers/routes/middleware), GraphQL (queries/mutations), RPC/gRPC handlers.
  * Auth providers (email/phone/OAuth/SSO/SAML), session & token flows; RBAC/ABAC policy files.
* **Workflows & jobs**

  * Queue/worker systems: Celery/RQ (Python), Bull/BullMQ/Agenda/bee-queue (Node), Laravel Queues (PHP); job names that encode business processes.
  * Schedulers/CRON, orchestrations (Temporal, Airflow).
* **Integrations**

  * Payment gateways, tax/VAT, invoicing; IDV/KYC; shipping; maps/geocoding; communications (email/SMS/push); analytics/events.
* **Growth & compliance**

  * Promo/coupon services, referral services; GDPR/CCPA endpoints (export/delete), consent registries.
* **Multi-tenancy & regionalization**

  * Tenant resolution, per-tenant configs, regional toggles, entitlement checks.

### C. Data layer (SQL/NoSQL/Graph)

* **Schemas & migrations**

  * Tables/collections/indices whose names imply features (e.g., `subscriptions`, `orders`, `messages`, `rewards`, `consents`, `feature_flags`, `entitlements`).
* **Events & contracts**

  * Kafka/RabbitMQ/SNS/SQS topics; event types indicating business flows (e.g., `OrderPaid`, `UserVerified`, `TrialStarted`).
* **Stored procedures / views**

  * Anything implementing business logic (e.g., statements assembling invoices, fraud signals).
* **Seed data**

  * Default roles, feature toggles, sample plans/tiers.

### D. Cross-cutting signals

* **Feature flags / remote config**
* **Experiment frameworks** (experiment keys, cohorting).
* **Access control** (roles, permissions, scopes).
* **Region/locale/product tier branching** (Pro/Enterprise/Geo).

---

## Deduplication & naming

* Merge duplicates across repos/services/clients; choose **product-facing** names (prefer UI text/menu labels over internal class names).
* If a capability is gated (flag/plan/region), **keep it** and tag with the gate(s).

---

## Output format

### JSON (authoritative)

```json
[
  {
    "feature_name": "string",
    "category": "Acquisition | Account | Discovery | Creation | Consumption | Commerce | Engagement | Support | Admin/Moderation | Platform Integration | Data & Compliance | Roles & Access | Localization & Accessibility | Other",
    "surface": ["ClientUI", "API", "BackgroundJob", "Workflow", "AdminPanel", "Integration", "Notification", "DataContract"],
    "platform": ["<client>", "<server>", "service:<name>", "db"],
    "actors": ["Guest", "EndUser", "Admin", "Agent", "Moderator", "Merchant", "Tenant"],
    "channels": ["Push", "Email", "SMS", "InApp", "Webhook", "Widget"],
    "flags_or_variants": ["flag:<key>", "experiment:<key>", "plan:<tier>", "region:<code>", "tenant:<id>"],
    "evidence": [
      "repo/path/file:LineOrSymbol",
      "route:POST /v1/orders",
      "graphql:mutation createSubscription",
      "migration:2024_10_01_add_subscriptions.sql",
      "queue:orders.created",
      "cron:invoice_generation"
    ]
  }
]
```

**Rules:** no descriptions; 1–5 high-signal evidence entries per feature; unique `feature_name`s.

---

## Coverage checklist (must satisfy before finishing)

* [ ] **Frontends:** all routes/pages/screens/components mapped; deep links/app links/web routes included; state slices/modules scanned; i18n/menu labels covered.
* [ ] **Backends:** all REST/GraphQL endpoints and handlers scanned; background jobs/CRON/workflows enumerated; integrations (payments, IDV, comms, maps) captured.
* [ ] **Auth/Access:** signup/login/SSO/2FA flows; roles/permissions/scopes; multi-tenant resolution.
* [ ] **Commerce:** carts/checkout/payments/subscriptions/invoices/refunds/coupons/trials/entitlements.
* [ ] **Engagement & Growth:** notifications (push/email/SMS/in-app), referrals/invites/rewards, ratings/reviews prompts.
* [ ] **Data & Compliance:** data export/delete, consents, age gates, regional restrictions.
* [ ] **Experiments & Flags:** feature flags, remote config keys, experiment IDs; plan/tier/region gates.
* [ ] **Databases & Events:** business tables/collections, migrations, stored procedures/views, event topics and webhooks.
* [ ] **Admin/Moderation:** consoles, reports, case management, content moderation.
* [ ] **Localization & Accessibility:** locales, RTL, a11y toggles.
* [ ] **Cross-platform parity:** same feature appearing on mobile/web/backend tagged appropriately.

---

## Constraints

* **No feature descriptions** or implementation details.
* Prefer **product terminology** extracted from UI text, route names, email/SMS templates.
* If uncertain but plausible, include with `"category": "Other"` and tag `"candidate": true` in `flags_or_variants`.

---

## Deliverables

1. **JSON** file (authoritative feature list).
2. Final line: `Coverage checklist completed: YES/NO`.

