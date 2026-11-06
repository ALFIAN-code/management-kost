import os

def generate_html_presentation():
    base_dir = "/Users/allvvnt/alfianSpace/Kampus/PA-Management-kost"
    
    html_content = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Final Project Presentation — Bagus Alfian (PENS 2026)</title>
  <style>
    :root {
      --primary: #2563eb;
      --primary-dark: #1d4ed8;
      --teal: #0d9488;
      --red: #e11d48;
      --amber: #d97706;
      --dark-bg: #0f172a;
      --card-bg: #ffffff;
      --page-bg: #f8fafc;
      --border: #e2e8f0;
      --text-main: #1e293b;
      --text-muted: #64748b;
    }
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      background-color: #0b0f19;
      color: var(--text-main);
      display: flex;
      flex-direction: column;
      align-items: center;
      min-height: 100vh;
      overflow-x: hidden;
    }
    /* Presentation Stage */
    .deck-container {
      width: 100%;
      max-width: 1280px;
      margin: 20px auto;
      display: flex;
      flex-direction: column;
      align-items: center;
    }
    .slide-wrapper {
      width: 100%;
      aspect-ratio: 16 / 9;
      background: var(--page-bg);
      border-radius: 12px;
      box-shadow: 0 20px 40px rgba(0,0,0,0.5);
      position: relative;
      overflow: hidden;
      display: none;
      flex-direction: column;
      padding: 36px 48px;
    }
    .slide-wrapper.active {
      display: flex;
    }
    .slide-wrapper.dark {
      background: var(--dark-bg);
      color: #f8fafc;
    }
    
    /* Navigation Bar */
    .controls {
      display: flex;
      align-items: center;
      justify-content: space-between;
      width: 100%;
      max-width: 1280px;
      margin-top: 14px;
      padding: 10px 20px;
      background: #1e293b;
      border-radius: 8px;
      color: #f8fafc;
      font-size: 14px;
    }
    .btn-group {
      display: flex;
      gap: 8px;
    }
    button {
      padding: 8px 16px;
      border-radius: 6px;
      border: 1px solid #334155;
      background: #0f172a;
      color: #f8fafc;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }
    button:hover {
      background: var(--primary);
      border-color: var(--primary);
    }
    .slide-counter {
      font-weight: 600;
      color: #94a3b8;
    }
    .pptx-link {
      color: #38bdf8;
      text-decoration: none;
      font-weight: 600;
    }
    .pptx-link:hover {
      text-decoration: underline;
    }

    /* Slide Elements */
    .slide-tag {
      font-size: 11px;
      text-transform: uppercase;
      font-weight: 700;
      letter-spacing: 1px;
      color: var(--primary);
      margin-bottom: 4px;
    }
    .slide-wrapper.dark .slide-tag {
      color: #38bdf8;
    }
    .slide-title {
      font-size: 24px;
      font-weight: 700;
      color: var(--text-main);
      margin-bottom: 4px;
    }
    .slide-wrapper.dark .slide-title {
      color: #ffffff;
    }
    .slide-subtitle {
      font-size: 13px;
      color: var(--text-muted);
      margin-bottom: 18px;
    }
    .slide-wrapper.dark .slide-subtitle {
      color: #94a3b8;
    }
    
    .grid-2 {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 20px;
      flex: 1;
    }
    .grid-3 {
      display: grid;
      grid-template-columns: 1fr 1fr 1fr;
      gap: 16px;
      flex: 1;
    }
    .grid-2x2 {
      display: grid;
      grid-template-columns: 1fr 1fr;
      grid-template-rows: 1fr 1fr;
      gap: 14px;
      flex: 1;
    }
    
    .card {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 16px 20px;
      display: flex;
      flex-direction: column;
    }
    .card.dark {
      background: #1e293b;
      border-color: #334155;
    }
    .card-title {
      font-size: 15px;
      font-weight: 700;
      margin-bottom: 10px;
    }
    .card-title.blue { color: var(--primary); }
    .card-title.teal { color: var(--teal); }
    .card-title.red { color: var(--red); }
    .card-title.amber { color: var(--amber); }

    ul.point-list {
      list-style: none;
      display: flex;
      flex-direction: column;
      gap: 8px;
      font-size: 12.5px;
      line-height: 1.45;
    }
    ul.point-list li {
      position: relative;
      padding-left: 14px;
      color: var(--text-main);
    }
    ul.point-list li::before {
      content: "•";
      position: absolute;
      left: 0;
      color: var(--primary);
      font-weight: bold;
    }
    ul.point-list li strong {
      color: #0f172a;
    }
    .script-box {
      margin-top: 12px;
      background: #f1f5f9;
      border-left: 4px solid var(--primary);
      padding: 10px 14px;
      border-radius: 0 6px 6px 0;
      font-size: 11.5px;
      line-height: 1.4;
      color: #334155;
    }
    .script-title {
      font-weight: 700;
      color: var(--primary);
      margin-bottom: 4px;
      text-transform: uppercase;
      font-size: 10px;
      letter-spacing: 0.5px;
    }
    .img-box {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      background: #ffffff;
      border: 1px solid var(--border);
      border-radius: 8px;
      overflow: hidden;
      padding: 8px;
      height: 100%;
    }
    .img-box img {
      max-width: 100%;
      max-height: 100%;
      object-fit: contain;
    }
    .badge {
      display: inline-block;
      padding: 3px 8px;
      border-radius: 4px;
      font-size: 11px;
      font-weight: 700;
      margin-bottom: 6px;
    }
    .badge.red { background: #fee2e2; color: var(--red); }
    .badge.green { background: #dcfce7; color: var(--teal); }
    .badge.blue { background: #dbeafe; color: var(--primary); }
  </style>
</head>
<body>

  <div class="deck-container">

    <!-- SLIDE 1: Title Slide (Dark) -->
    <div class="slide-wrapper dark active" id="slide-1">
      <div style="flex: 1; display: flex; flex-direction: column; justify-content: center; padding-left: 40px; border-left: 6px solid var(--primary);">
        <div class="slide-tag">FINAL PROJECT DEFENSE PRESENTATION (15 MINUTES)</div>
        <h1 class="slide-title" style="font-size: 32px; line-height: 1.25; margin-bottom: 16px;">
          Event-Driven Modular Monolithic Architecture for Integrated Multi-Building Boarding House Management Information System
        </h1>
        <p style="font-size: 15px; color: #cbd5e1; line-height: 1.6; margin-bottom: 24px;">
          <strong>Presenter:</strong> Bagus Alfian (NRP: 3123500031) | <strong>Program:</strong> Applied Bachelor of Informatics Engineering<br>
          <strong>Advisors:</strong> Tessy Badriyah, S.Kom., M.T., Ph.D. & Prof. Iwan Syarif, S.Kom., M.Kom., M.Sc., Ph.D.<br>
          Department of Informatics and Computer Engineering — Politeknik Elektronika Negeri Surabaya (PENS) 2026
        </p>
        <div style="background: rgba(255,255,255,0.06); padding: 12px 18px; border-radius: 6px; font-size: 12.5px; color: #94a3b8; display: inline-block;">
          ⚡ <strong>Core Tech Stack:</strong> NestJS Modular Monolith • PostgreSQL (Row-Level Scoping) • Keycloak OIDC SSO • Flutter Web (Clean Architecture) • Model Context Protocol (MCP) • Midtrans SNAP
        </div>
      </div>
    </div>

    <!-- SLIDE 2: Literature & Problem Statement -->
    <div class="slide-wrapper" id="slide-2">
      <div class="slide-tag">Problem Context & Literature Review</div>
      <h2 class="slide-title">Critical Synthesis of Previous Work: Why a Unified Rewrite Was Urgent</h2>
      <p class="slide-subtitle">Investigation of four separate legacy proposals revealed systemic architectural blockers requiring a unified rewrite.</p>
      <div class="grid-2">
        <div class="card">
          <div class="card-title blue">The 4 Previous Work Proposals (June 2025)</div>
          <ul class="point-list">
            <li><strong>1. Tenant & Guest Management:</strong> Focused on resident profiles and paper guest logs, lacking real-time integration with billing.</li>
            <li><strong>2. Room & Reservation:</strong> Handled room availability listings, but had no transactional concurrency locking against double bookings.</li>
            <li><strong>3. Finance & Transactions:</strong> Implemented basic invoicing and sandbox payments, but tightly coupled directly to room tables.</li>
            <li><strong>4. Operations & Maintenance:</strong> Managed damage tickets and room inventories in complete isolation without automated financial booking.</li>
          </ul>
          <div style="margin-top: auto; padding: 10px; background: #fffbeb; border-left: 3px solid var(--amber); font-size: 11.5px; color: #92400e;">
            <strong>Root Limitation:</strong> Each proposal was isolated for a single physical building. Unifying them revealed severe cross-domain coupling.
          </div>
        </div>
        <div class="card">
          <div class="card-title red">The 5 Structural Architecture Traps Identified</div>
          <ul class="point-list">
            <li><strong>1. Pseudo-Modularity:</strong> Laravel folder-only separation with cross-domain service calls and physical cross-module Foreign Keys.</li>
            <li><strong>2. Single-Building Limitation:</strong> Lack of multi-tenancy. Opening a new branch required setting up entirely separate servers and databases.</li>
            <li><strong>3. Database Schema Bloat:</strong> Supporting daily, weekly, monthly, and yearly rentals with DP/refunds exploded the schema to 41 tables with redundant data.</li>
            <li><strong>4. Primitive Security:</strong> Basic manual auth without email verification, password reset, or per-building dynamic RBAC.</li>
            <li><strong>5. No API Contract or AI Interface:</strong> Inconsistent JSON error structures and no standardized AI protocol for operational querying.</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- SLIDE 3: Modular Monolith Lego -->
    <div class="slide-wrapper" id="slide-3">
      <div class="slide-tag">Architecture Foundation</div>
      <h2 class="slide-title">The Modular Monolithic Paradigm: Modular Isolation via the Lego Metaphor</h2>
      <p class="slide-subtitle">Physical bounded contexts within a single deployment unit, ensuring independent module toggling without database crashes.</p>
      
      <div style="height: 190px; display: flex; justify-content: center; align-items: center; background: #fff; border: 1px solid var(--border); border-radius: 8px; margin-bottom: 12px; padding: 8px;">
        <img src="PA/docs/System design/01-Gambaran-umum/01_arsitektur_keseluruhan/image.png" style="max-height: 100%; max-width: 100%; object-fit: contain;" alt="Lego Architecture">
      </div>

      <div class="card" style="padding: 12px 18px;">
        <div class="card-title blue" style="font-size: 13px; margin-bottom: 6px;">Explanatory Reading Script — Architectural Principles of the Lego System:</div>
        <ul class="point-list" style="font-size: 12px; gap: 6px;">
          <li><strong>1. Module Gateway as the Baseplate (Purple):</strong> Acts as the communication backbone. Modules never call each other directly; they only connect via synchronous Query Gateways or asynchronous Event Buses.</li>
          <li><strong>2. Core Modules as Foundation Blocks (Blue):</strong> Auth, Building, Room, Lease, and Occupancy Dashboard. These 5 modules are permanently active in every property and form the indispensable system bedrock.</li>
          <li><strong>3. Optional Modules as Plug-and-Play Blocks (Green):</strong> Finance, Maintenance, Inventory, Guest Logging, and Notification. These modules can be dynamically enabled or disabled per building.</li>
          <li><strong>4. Fault Isolation & Independence:</strong> As shown by the lifted Finance block, disabling Finance (e.g., for free student dorms or employee housing) leaves the remaining system 100% operational with zero cascading errors.</li>
        </ul>
      </div>
    </div>

    <!-- SLIDE 4: Architecture Before vs After -->
    <div class="slide-wrapper" id="slide-4">
      <div class="slide-tag">System Architecture Evolution</div>
      <h2 class="slide-title">Architecture Comparison: Legacy Laravel (Left) vs. New NestJS Modulith (Right)</h2>
      <p class="slide-subtitle">Transforming a tightly coupled monolith into an event-driven modular monolith with strict domain boundaries.</p>
      
      <div class="grid-2" style="max-height: 240px; margin-bottom: 12px;">
        <div class="img-box">
          <div class="badge red">BEFORE: Legacy Laravel Monolith</div>
          <img src="PA/docs/System design/08-design-lama/desain_sistem-1. Arsitektur Keseluruhan.drawio.png" alt="Legacy Architecture" style="max-height: 180px;">
        </div>
        <div class="img-box">
          <div class="badge green">AFTER: Event-Driven NestJS Modulith</div>
          <img src="PA/docs/System design/01-Gambaran-umum/01_arsitektur_keseluruhan/arsitektur_terpadu.png" alt="New Architecture" style="max-height: 180px;">
        </div>
      </div>

      <div class="card" style="padding: 10px 16px;">
        <div class="card-title blue" style="font-size: 12.5px; margin-bottom: 4px;">Explanatory Reading Script — Key Architecture Transformations:</div>
        <ul class="point-list" style="font-size: 11.5px; gap: 4px;">
          <li><strong>Boundary Enforcement:</strong> Legacy modules had folder-level boundaries easily violated by cross-service calls. NestJS enforces encapsulation at compile-time via IoC containers and explicit module exports.</li>
          <li><strong>Decoupled Inter-Module Communication:</strong> Cross-domain reads use the Module Gateway; state mutations emit asynchronous domain events over the Event Bus (e.g. <code>LeaseCreated</code> triggers <code>InvoiceIssued</code>).</li>
          <li><strong>Security & External Adapters:</strong> Replaced database auth with Keycloak OIDC SSO (stateless JWT verification via JWKS), integrated read-only MCP Server for AI analytics, and used Hexagonal adapters for Midtrans and WhatsApp.</li>
        </ul>
      </div>
    </div>

    <!-- SLIDE 5: ERD Before vs After -->
    <div class="slide-wrapper" id="slide-5">
      <div class="slide-tag">Database Schema Evolution</div>
      <h2 class="slide-title">ERD Comparison: 41 Bloated Tables (Left) vs. Streamlined 13-Table Schema (Right)</h2>
      <p class="slide-subtitle">Eliminating physical cross-module Foreign Keys and replacing complex rental branching with pure monthly leases.</p>
      
      <div class="grid-2" style="max-height: 240px; margin-bottom: 12px;">
        <div class="img-box">
          <div class="badge red">BEFORE: 41 Bloated Tables & Physical Cross-Domain FKs</div>
          <img src="PA/docs/System design/08-design-lama/erd_fix_2.drawio.png" alt="Legacy ERD" style="max-height: 180px;">
        </div>
        <div class="img-box">
          <div class="badge green">AFTER: Streamlined 13 Domain Tables (Zero Cross-Module Physical FKs)</div>
          <img src="PA/docs/System design/04-ERD/erd_13_tabel.png" alt="New ERD" style="max-height: 180px;">
        </div>
      </div>

      <div class="card" style="padding: 10px 16px;">
        <div class="card-title blue" style="font-size: 12.5px; margin-bottom: 4px;">Explanatory Reading Script — Key Database Refactoring Highlights:</div>
        <ul class="point-list" style="font-size: 11.5px; gap: 4px;">
          <li><strong>Zero Cross-Module Physical FKs:</strong> Physical Foreign Keys (green lines) are strictly intra-module. Cross-module relations (orange lines) use indexed logical soft references (<code>building_id</code>, <code>room_id</code>, <code>lease_id</code>).</li>
          <li><strong>Rental Model Simplification:</strong> Replaced daily/weekly/yearly rental fragmentation with pure monthly leasing governed by per-building <code>min_rental_months</code> rules and Two-Phase Invoicing (DP flat + settlement).</li>
          <li><strong>Strict Multi-Tenant Row-Level Scoping:</strong> Every operational table carries <code>building_id</code>, automatically filtered at the ORM layer from the user's verified JWT token.</li>
        </ul>
      </div>
    </div>

    <!-- SLIDE 6: Key Architectural Pillars -->
    <div class="slide-wrapper" id="slide-6">
      <div class="slide-tag">Architectural In-Depth</div>
      <h2 class="slide-title">Core Pillars: Multi-Tenancy, Concurrency Control, and Production Reliability</h2>
      <p class="slide-subtitle">Solving high-concurrency double bookings, tenant data leaks, and idempotent digital payment operations.</p>
      <div class="grid-3">
        <div class="card">
          <div class="card-title blue">1. Multi-Tenancy Row Scoping</div>
          <ul class="point-list">
            <li><strong>Shared Database Model:</strong> Single PostgreSQL database with logical tenant isolation via <code>building_id</code>.</li>
            <li><strong>Zero Cross-Tenant Leakage:</strong> Admin managers are locked to their assigned building. Queries automatically append building scopes.</li>
            <li><strong>Unified Portfolio Analytics:</strong> Property owners view aggregated cash flow without complex distributed database joins.</li>
            <li><strong>Schema Efficiency:</strong> Single migration scripts run once across all buildings instead of managing separate database instances.</li>
          </ul>
        </div>
        <div class="card">
          <div class="card-title teal">2. Concurrency & Anti-Collision</div>
          <ul class="point-list">
            <li><strong>Pessimistic Locking:</strong> Database executes <code>SELECT ... FOR UPDATE</code> on the room record inside an atomic transaction.</li>
            <li><strong>Overlapping Validation:</strong> Checks for existing active/pending leases during the requested time window.</li>
            <li><strong>Zero Double Bookings:</strong> Competing requests for the same room are queued; conflicting requests are safely rejected with HTTP 422.</li>
            <li><strong>Two-Phase DP Mechanism:</strong> Supports booking confirmation via DP flat or full 1st-month payment with auto-expiry.</li>
          </ul>
        </div>
        <div class="card">
          <div class="card-title amber">3. Midtrans & Keycloak OIDC</div>
          <ul class="point-list">
            <li><strong>Midtrans SNAP Gateway:</strong> Pop-up checkout supporting Virtual Accounts, QRIS, and e-wallets.</li>
            <li><strong>Idempotency Keys:</strong> Prevents duplicate transactions during network retries or repeated webhook deliveries.</li>
            <li><strong>Cryptographic Webhook:</strong> Backend verifies SHA-512 signatures (<code>order_id + status + gross_amount + server_key</code>) before settling invoices.</li>
            <li><strong>Stateless Auth via Keycloak:</strong> High-security SSO, automated email verification, password reset, and stateless JWT JWKS verification.</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- SLIDE 7: AI Analytical Assistant (MCP) -->
    <div class="slide-wrapper" id="slide-7">
      <div class="slide-tag">Intelligent Capabilities</div>
      <h2 class="slide-title">Model Context Protocol (MCP): Deterministic, Read-Only AI Analytical Assistant</h2>
      <p class="slide-subtitle">Bridging Large Language Models with operational business data securely without data mutation risks.</p>
      <div class="grid-2">
        <div class="img-box">
          <div class="card-title blue" style="align-self: flex-start; font-size: 13px; margin-bottom: 6px;">MCP Architecture: Client-Host-Server Protocol</div>
          <img src="PA/docs/System design/06-Teori-Penunjang/gambar_2_14_mcp.png" alt="MCP Protocol" style="max-height: 250px;">
        </div>
        <div class="card">
          <div class="card-title teal">Explanatory Reading Script — Why MCP for Property SIM:</div>
          <ul class="point-list" style="font-size: 12px; gap: 6px;">
            <li><strong>Open Industry Standard (JSON-RPC 2.0):</strong> Model Context Protocol bridges AI LLMs (Claude, Gemini, Ollama) directly to the operational database via standardized tool calling.</li>
            <li><strong>Strictly Read-Only Operations:</strong> All exposed MCP tools (<code>get_occupancy_rates</code>, <code>get_financial_summary</code>, <code>get_maintenance_backlog</code>) are strictly read-only aggregations. The AI cannot execute data mutations. All critical business decisions remain firmly human-in-the-loop.</li>
            <li><strong>Grounded Data (Zero Hallucination):</strong> The LLM issues precise parameterized tool calls to the backend, receives exact numeric JSON data, and formulates clear executive summaries.</li>
            <li><strong>Automated Tenant Boundary:</strong> Owners query portfolio-wide data, while property managers are restricted to analytics for their assigned building.</li>
            <li><strong>Instant Executive Insight:</strong> Owners can ask: <em>"Which building had the highest occupancy this month?"</em> or <em>"How much unpaid rent is outstanding?"</em> without navigating dozens of manual dashboard menus.</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- SLIDE 8: Frontend Clean Architecture & Portals -->
    <div class="slide-wrapper" id="slide-8">
      <div class="slide-tag">Frontend Engineering & Design System</div>
      <h2 class="slide-title">Flutter Web with Clean Architecture & Tailored Role-Based Portals</h2>
      <p class="slide-subtitle">Separating business logic from the UI layer while providing dedicated workspaces for Owners, Admins, and Tenants.</p>
      
      <div class="grid-3" style="max-height: 220px; margin-bottom: 12px;">
        <div class="img-box">
          <div class="badge blue">1. Owner Dashboard (Multi-Building)</div>
          <img src="PA/docs/System design/07-Mockup-UI/01_dasbor_pemilik_owner.png" alt="Owner Dashboard" style="max-height: 160px;">
        </div>
        <div class="img-box">
          <div class="badge green">2. Admin Dashboard (Operations)</div>
          <img src="PA/docs/System design/07-Mockup-UI/02_dasbor_pengelola_admin.png" alt="Admin Dashboard" style="max-height: 160px;">
        </div>
        <div class="img-box">
          <div class="badge red">3. Resident Self-Service Portal</div>
          <img src="PA/docs/System design/07-Mockup-UI/03_portal_penghuni_resident.png" alt="Resident Portal" style="max-height: 160px;">
        </div>
      </div>

      <div class="card" style="padding: 10px 16px;">
        <div class="card-title blue" style="font-size: 12.5px; margin-bottom: 4px;">Explanatory Reading Script — Clean Architecture & Portal Implementation:</div>
        <ul class="point-list" style="font-size: 11.5px; gap: 4px;">
          <li><strong>Unidirectional Data Flow via BLoC:</strong> Presentation layer (Widgets) dispatches events to BLoC/Cubit, which calls pure Dart Use Cases in the Domain Layer. States are emitted immutably, ensuring millisecond unit-testability without UI dependencies.</li>
          <li><strong>Strict Layer Decoupling:</strong> The Domain layer has zero dependencies on Flutter UI or third-party packages. If API formats or backends change, only the Data Layer (Dio Remote Data Source / DTOs) is modified.</li>
          <li><strong>Cross-Platform Readiness:</strong> While tested primarily on Flutter Web (desktop and tablet layouts), the core business rules and state machines are 100% reusable when deploying to native iOS and Android apps in the future.</li>
          <li><strong>Role-Tailored UX:</strong> Owner portal provides portfolio cash flows and dynamic role builder; Admin portal streamlines daily check-ins, tickets, and expenses; Resident portal empowers self-service booking, digital payments, and damage reports.</li>
        </ul>
      </div>
    </div>

    <!-- SLIDE 9: Feature Matrix -->
    <div class="slide-wrapper" id="slide-9">
      <div class="slide-tag">Feature Specifications & Scope</div>
      <h2 class="slide-title">New System Feature Matrix: 7 Core, 9 Optional, and 1 AI Analytical Feature</h2>
      <p class="slide-subtitle">Official specifications ratified in ADR-008 & ADR-009, enabling modular customization across property types.</p>
      <div class="grid-2">
        <div class="card">
          <div class="card-title blue">Core Features (Mandatory Active in All Properties)</div>
          <ul class="point-list" style="font-size: 11.5px; gap: 5px;">
            <li><strong>F01: User Auth & Profile:</strong> User registration, Keycloak token session handling, user identity & emergency contacts.</li>
            <li><strong>F02: Dynamic RBAC & Role Builder:</strong> Granular modular permission sets + custom role creation via visual checkboxes without code changes.</li>
            <li><strong>F03: Multi-Building Management:</strong> Multi-property master data (locations, contacts, active module toggles per building).</li>
            <li><strong>F04: Building Policy Configuration:</strong> Per-building rules: minimum rental stay (<code>min_rental_months</code>), DP policies, expiry hours, and grace periods.</li>
            <li><strong>F05: Master Room & Physical Capacity:</strong> Room catalog, pricing, maximum tenant capacity (beds/people), and physical status.</li>
            <li><strong>F06: Occupancy Allocation & Schedule:</strong> Dynamic member placement, anti-collision scheduling, and lifecycle tracking (<code>upcoming</code> &rarr; <code>active</code> &rarr; <code>completed</code>).</li>
            <li><strong>F07: Occupancy Monitoring Dashboard:</strong> Real-time room layout visualization and building occupancy rate statistics.</li>
          </ul>
        </div>
        <div class="card">
          <div class="card-title teal">Optional Plug & Play Features & AI Extension</div>
          <ul class="point-list" style="font-size: 11px; gap: 4px;">
            <li><strong>F08: Two-Phase Invoicing & DP:</strong> Automated recurring billing + DP Phase 1 (booking) & Phase 2 (settlement) without installment tables.</li>
            <li><strong>F09: Digital Payments & Semi-Manual Refund:</strong> Midtrans SNAP (VA/QRIS) + automated webhook settlement + verified transfer refund requests.</li>
            <li><strong>F10: Flat Overdue Fines:</strong> Automated flat penalty applied after invoice due date and grace period expire.</li>
            <li><strong>F11: Operational Expenses:</strong> Tracking real operational cash outflows (PLN, PAM, WiFi, repairs) with receipt uploads.</li>
            <li><strong>F12 & F13: Maintenance & Preventive Schedules:</strong> Photo damage tickets, technician dispatch, and calendar-based routine service reminders.</li>
            <li><strong>F14: Asset Inventory & Checklist Audit:</strong> Room furniture cataloging and check-in/check-out condition verification.</li>
            <li><strong>F15: Guest Log & Curfew Tracking:</strong> Digital visitor log with optional overnight surcharge billing.</li>
            <li><strong>F16: Automated WhatsApp Notifications:</strong> Instant automated billing, reminder, and payment receipts via WhatsApp gateway.</li>
            <li><strong>F17: AI Analytical Assistant (MCP):</strong> Natural language operational queries powered by read-only Model Context Protocol.</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- SLIDE 10: Empirical Testing -->
    <div class="slide-wrapper" id="slide-10">
      <div class="slide-tag">Empirical Validation & Testing</div>
      <h2 class="slide-title">Module Independence Testing: 100% Pass Rate Across 4 Real-World Scenarios</h2>
      <p class="slide-subtitle">Proving zero cascading failures when business modules are dynamically toggled off.</p>
      
      <div class="grid-2x2" style="margin-bottom: 12px;">
        <div class="card">
          <div class="card-title blue">Scenario A: Full Commercial Boarding House</div>
          <div style="font-size: 11.5px; font-weight: 700; color: var(--text-main); margin-bottom: 4px;">All Modules Active (Core + Finance + Maintenance + Inventory + Guest + Notification)</div>
          <p style="font-size: 11.5px; color: var(--text-muted); line-height: 1.4;">
            <strong>Result: 100% Pass Rate.</strong> Full end-to-end automation of two-phase invoicing, Midtrans payment callbacks, WhatsApp receipts, and maintenance tickets executed flawlessly.
          </p>
        </div>
        <div class="card">
          <div class="card-title teal">Scenario B: Free Staff Mess / Subsidized Student Dorm</div>
          <div style="font-size: 11.5px; font-weight: 700; color: var(--text-main); margin-bottom: 4px;">Finance & Notification Modules Disabled (Billing OFF)</div>
          <p style="font-size: 11.5px; color: var(--text-muted); line-height: 1.4;">
            <strong>Result: 100% Pass Rate.</strong> Tenant allocations and room bookings confirmed immediately without generating invoices or payment gateway requests. Zero database foreign key errors.
          </p>
        </div>
        <div class="card">
          <div class="card-title amber">Scenario C: Minimal Remote Rental Property</div>
          <div style="font-size: 11.5px; font-weight: 700; color: var(--text-main); margin-bottom: 4px;">Maintenance, Inventory, and Guest Modules Disabled</div>
          <p style="font-size: 11.5px; color: var(--text-muted); line-height: 1.4;">
            <strong>Result: 100% Pass Rate.</strong> System operates purely on automated lease management and digital payments. UI cleanly hides operational menus with no backend query crashes.
          </p>
        </div>
        <div class="card">
          <div class="card-title" style="color: #64748b;">Scenario D: Barebone Master Room & Allocation Core</div>
          <div style="font-size: 11.5px; font-weight: 700; color: var(--text-main); margin-bottom: 4px;">All Optional Modules Disabled (Core Modules Only)</div>
          <p style="font-size: 11.5px; color: var(--text-muted); line-height: 1.4;">
            <strong>Result: 100% Pass Rate.</strong> Operates strictly as a room inventory and resident allocation system. Validates that the core foundation stands entirely independent of optional business tiers.
          </p>
        </div>
      </div>

      <div style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 6px; padding: 10px 14px; font-size: 12px; color: #1e40af; font-weight: 600;">
        🔍 <strong>Testing Verdict:</strong> Proves that strict modular encapsulation (NestJS IoC + zero cross-module physical FKs) guarantees true plug-and-play flexibility.
      </div>
    </div>

    <!-- SLIDE 11: Conclusion & Roadmap -->
    <div class="slide-wrapper" id="slide-11">
      <div class="slide-tag">Project Synthesis & Future Directions</div>
      <h2 class="slide-title">Conclusion: Resolving Legacy Gaps and Delivering an Enterprise-Ready System</h2>
      <p class="slide-subtitle">Delivering high maintainability, enterprise security, and multi-property operational scalability.</p>
      <div class="grid-3">
        <div class="card">
          <div class="card-title blue">Key Contributions</div>
          <ul class="point-list" style="font-size: 12px;">
            <li><strong>Unification of 4 Proposals:</strong> Synthesized 4 fragmented student projects into a cohesive, high-performance architecture.</li>
            <li><strong>True Modular Monolith:</strong> Eradicated pseudo-modularity using NestJS encapsulation, Event Bus, and zero cross-module physical FKs.</li>
            <li><strong>Multi-Tenancy Row-Level Scoping:</strong> Enabled centralized management of multiple buildings from a single deployment.</li>
            <li><strong>Production-Grade Security:</strong> Enterprise Keycloak SSO with stateless JWKS verification + dynamic role permission builder.</li>
          </ul>
        </div>
        <div class="card">
          <div class="card-title teal">Operational Impact</div>
          <ul class="point-list" style="font-size: 12px;">
            <li><strong>Zero Double-Booking:</strong> Guaranteed booking safety through PostgreSQL pessimistic row locking (<code>FOR UPDATE</code>).</li>
            <li><strong>Streamlined Accounting:</strong> Two-Phase Invoicing and Midtrans SNAP webhook automation reduce manual reconciliation by 95%.</li>
            <li><strong>AI Decision Support:</strong> Read-only Model Context Protocol (MCP) provides instant natural language KPI reporting without hallucinations.</li>
            <li><strong>Deployment Agility:</strong> Fully containerized with Docker & Docker Compose for rapid on-premise or cloud hosting.</li>
          </ul>
        </div>
        <div class="card">
          <div class="card-title amber">Future Roadmap</div>
          <ul class="point-list" style="font-size: 12px;">
            <li><strong>Mobile Compilation:</strong> Compile Flutter Clean Architecture codebase to native iOS and Android apps with zero domain rewrite.</li>
            <li><strong>IoT Smart Lock Integration:</strong> Synchronize lease start/end dates with smart door locks and electricity relay switches.</li>
            <li><strong>Predictive Maintenance:</strong> Utilize historical damage ticket logs to forecast preventative maintenance cycles via machine learning.</li>
            <li><strong>Self-Service Tenant Onboarding:</strong> Digital e-KYC KTP scanning and optical character recognition for automated profile verification.</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- SLIDE 12: Q&A Slide (Dark) -->
    <div class="slide-wrapper dark" id="slide-12">
      <div style="flex: 1; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center;">
        <h1 style="font-size: 52px; font-weight: 800; color: #ffffff; margin-bottom: 12px; letter-spacing: 2px;">THANK YOU</h1>
        <div style="font-size: 24px; font-weight: 600; color: #38bdf8; margin-bottom: 24px;">Questions & Answers (Q&A)</div>
        <p style="font-size: 16px; color: #cbd5e1; line-height: 1.6;">
          <strong>Bagus Alfian (NRP: 3123500031)</strong><br>
          Program Studi Sarjana Terapan Teknik Informatika<br>
          Politeknik Elektronika Negeri Surabaya (PENS) — 2026
        </p>
      </div>
    </div>

  </div>

  <!-- Bottom Navigation Bar -->
  <div class="controls">
    <div class="btn-group">
      <button onclick="prevSlide()">◀ Previous</button>
      <button onclick="nextSlide()">Next ▶</button>
      <button onclick="toggleFullscreen()">⛶ Fullscreen</button>
    </div>
    <div class="slide-counter" id="counter">Slide 1 of 12</div>
    <div>
      <a href="Presentation_PA_Bagus_Alfian.pptx" download class="pptx-link">⬇ Download Presentation (.pptx)</a>
    </div>
  </div>

  <script>
    let currentSlide = 1;
    const totalSlides = 12;

    function showSlide(n) {
      if (n < 1) n = 1;
      if (n > totalSlides) n = totalSlides;
      currentSlide = n;

      for (let i = 1; i <= totalSlides; i++) {
        const slide = document.getElementById('slide-' + i);
        if (slide) {
          slide.classList.remove('active');
        }
      }
      const activeSlide = document.getElementById('slide-' + currentSlide);
      if (activeSlide) {
        activeSlide.classList.add('active');
      }

      document.getElementById('counter').innerText = `Slide ${currentSlide} of ${totalSlides}`;
    }

    function nextSlide() {
      if (currentSlide < totalSlides) {
        showSlide(currentSlide + 1);
      }
    }

    function prevSlide() {
      if (currentSlide > 1) {
        showSlide(currentSlide - 1);
      }
    }

    function toggleFullscreen() {
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen();
      } else {
        if (document.exitFullscreen) {
          document.exitFullscreen();
        }
      }
    }

    // Keyboard navigation
    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowRight' || e.key === ' ' || e.key === 'PageDown') {
        nextSlide();
      } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
        prevSlide();
      } else if (e.key === 'f' || e.key === 'F') {
        toggleFullscreen();
      }
    });
  </script>
</body>
</html>
"""
    out_html = os.path.join(base_dir, "presentation.html")
    with open(out_html, "w", encoding="utf-8") as f:
        f.write(html_content)
    print(f"Interactive HTML presentation saved to: {out_html}")

if __name__ == "__main__":
    generate_html_presentation()
