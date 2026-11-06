import os
import subprocess

def generate_pdf():
    base_dir = "/Users/allvvnt/alfianSpace/Kampus/PA-Management-kost"
    
    # Absolute paths to images
    lego_img = f"file://{base_dir}/PA/docs/System%20design/01-Gambaran-umum/01_arsitektur_keseluruhan/image.png"
    old_arch = f"file://{base_dir}/PA/docs/System%20design/08-design-lama/desain_sistem-1.%20Arsitektur%20Keseluruhan.drawio.png"
    new_arch = f"file://{base_dir}/PA/docs/System%20design/01-Gambaran-umum/01_arsitektur_keseluruhan/arsitektur_terpadu.png"
    old_erd = f"file://{base_dir}/PA/docs/System%20design/08-design-lama/erd_fix_2.drawio.png"
    new_erd = f"file://{base_dir}/PA/docs/System%20design/04-ERD/erd_13_tabel.png"
    mcp_img = f"file://{base_dir}/PA/docs/System%20design/06-Teori-Penunjang/gambar_2_14_mcp.png"
    owner_mock = f"file://{base_dir}/PA/docs/System%20design/07-Mockup-UI/01_dasbor_pemilik_owner.png"
    admin_mock = f"file://{base_dir}/PA/docs/System%20design/07-Mockup-UI/02_dasbor_pengelola_admin.png"
    resident_mock = f"file://{base_dir}/PA/docs/System%20design/07-Mockup-UI/03_portal_penghuni_resident.png"

    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Final Project Presentation — Bagus Alfian (PENS 2026)</title>
  <style>
    @page {{
      size: 1920px 1080px;
      margin: 0;
    }}
    :root {{
      --primary: #2563eb;
      --teal: #0d9488;
      --red: #e11d48;
      --amber: #d97706;
      --dark-bg: #0f172a;
      --card-bg: #ffffff;
      --page-bg: #f8fafc;
      --border: #e2e8f0;
      --text-main: #1e293b;
      --text-muted: #64748b;
    }}
    * {{
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      -webkit-print-color-adjust: exact;
      print-color-adjust: exact;
    }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      background-color: var(--page-bg);
      color: var(--text-main);
      margin: 0;
      padding: 0;
    }}
    .slide {{
      width: 1920px;
      height: 1080px;
      page-break-after: always;
      break-after: page;
      position: relative;
      overflow: hidden;
      display: flex;
      flex-direction: column;
      padding: 60px 80px;
      background: var(--page-bg);
    }}
    .slide.dark {{
      background: var(--dark-bg);
      color: #f8fafc;
    }}
    .slide-tag {{
      font-size: 16px;
      text-transform: uppercase;
      font-weight: 700;
      letter-spacing: 1.5px;
      color: var(--primary);
      margin-bottom: 6px;
    }}
    .slide.dark .slide-tag {{
      color: #38bdf8;
    }}
    .slide-title {{
      font-size: 36px;
      font-weight: 800;
      color: var(--text-main);
      margin-bottom: 6px;
      line-height: 1.2;
    }}
    .slide.dark .slide-title {{
      color: #ffffff;
    }}
    .slide-subtitle {{
      font-size: 19px;
      color: var(--text-muted);
      margin-bottom: 28px;
    }}
    .slide.dark .slide-subtitle {{
      color: #94a3b8;
    }}
    
    .grid-2 {{
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 32px;
      flex: 1;
    }}
    .grid-3 {{
      display: grid;
      grid-template-columns: 1fr 1fr 1fr;
      gap: 24px;
      flex: 1;
    }}
    .grid-2x2 {{
      display: grid;
      grid-template-columns: 1fr 1fr;
      grid-template-rows: 1fr 1fr;
      gap: 20px;
      flex: 1;
    }}
    
    .card {{
      background: var(--card-bg);
      border: 1.5px solid var(--border);
      border-radius: 12px;
      padding: 24px 30px;
      display: flex;
      flex-direction: column;
    }}
    .card.dark {{
      background: #1e293b;
      border-color: #334155;
    }}
    .card-title {{
      font-size: 22px;
      font-weight: 700;
      margin-bottom: 14px;
    }}
    .card-title.blue {{ color: var(--primary); }}
    .card-title.teal {{ color: var(--teal); }}
    .card-title.red {{ color: var(--red); }}
    .card-title.amber {{ color: var(--amber); }}

    ul.point-list {{
      list-style: none;
      display: flex;
      flex-direction: column;
      gap: 12px;
      font-size: 18px;
      line-height: 1.5;
    }}
    ul.point-list li {{
      position: relative;
      padding-left: 20px;
      color: var(--text-main);
    }}
    ul.point-list li::before {{
      content: "•";
      position: absolute;
      left: 0;
      color: var(--primary);
      font-weight: bold;
      font-size: 22px;
      top: -2px;
    }}
    ul.point-list li strong {{
      color: #0f172a;
    }}
    .img-box {{
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      background: #ffffff;
      border: 1.5px solid var(--border);
      border-radius: 12px;
      overflow: hidden;
      padding: 12px;
      height: 100%;
    }}
    .img-box img {{
      max-width: 100%;
      max-height: 100%;
      object-fit: contain;
    }}
    .badge {{
      display: inline-block;
      padding: 4px 12px;
      border-radius: 6px;
      font-size: 15px;
      font-weight: 700;
      margin-bottom: 8px;
    }}
    .badge.red {{ background: #fee2e2; color: var(--red); }}
    .badge.green {{ background: #dcfce7; color: var(--teal); }}
    .badge.blue {{ background: #dbeafe; color: var(--primary); }}

    .slide-footer {{
      position: absolute;
      bottom: 24px;
      left: 80px;
      right: 80px;
      display: flex;
      justify-content: space-between;
      font-size: 14px;
      color: var(--text-muted);
      border-top: 1px solid var(--border);
      padding-top: 12px;
    }}
    .slide.dark .slide-footer {{
      border-color: #334155;
      color: #64748b;
    }}
  </style>
</head>
<body>

  <!-- SLIDE 1 -->
  <div class="slide dark">
    <div style="flex: 1; display: flex; flex-direction: column; justify-content: center; padding-left: 60px; border-left: 8px solid var(--primary);">
      <div class="slide-tag">FINAL PROJECT DEFENSE PRESENTATION (15 MINUTES)</div>
      <h1 class="slide-title" style="font-size: 46px; line-height: 1.25; margin-bottom: 24px;">
        Event-Driven Modular Monolithic Architecture for Integrated Multi-Building Boarding House Management Information System
      </h1>
      <p style="font-size: 22px; color: #cbd5e1; line-height: 1.6; margin-bottom: 36px;">
        <strong>Presenter:</strong> Bagus Alfian (NRP: 3123500031) | <strong>Program:</strong> Applied Bachelor of Informatics Engineering<br>
        <strong>Advisors:</strong> Tessy Badriyah, S.Kom., M.T., Ph.D. & Prof. Iwan Syarif, S.Kom., M.Kom., M.Sc., Ph.D.<br>
        Department of Informatics and Computer Engineering — Politeknik Elektronika Negeri Surabaya (PENS) 2026
      </p>
      <div style="background: rgba(255,255,255,0.06); padding: 18px 24px; border-radius: 8px; font-size: 18px; color: #94a3b8; display: inline-block;">
        ⚡ <strong>Core Tech Stack:</strong> NestJS Modular Monolith • PostgreSQL (Row-Level Scoping) • Keycloak OIDC SSO • Flutter Web (Clean Architecture) • Model Context Protocol (MCP) • Midtrans SNAP
      </div>
    </div>
    <div class="slide-footer">
      <span>Politeknik Elektronika Negeri Surabaya (PENS)</span>
      <span>Slide 1 of 12</span>
    </div>
  </div>

  <!-- SLIDE 2 -->
  <div class="slide">
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
        <div style="margin-top: auto; padding: 14px 18px; background: #fffbeb; border-left: 4px solid var(--amber); font-size: 16px; color: #92400e; border-radius: 4px;">
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
    <div class="slide-footer">
      <span>PA Management Kost — Problem Context</span>
      <span>Slide 2 of 12</span>
    </div>
  </div>

  <!-- SLIDE 3 -->
  <div class="slide">
    <div class="slide-tag">Architecture Foundation</div>
    <h2 class="slide-title">The Modular Monolithic Paradigm: Modular Isolation via the Lego Metaphor</h2>
    <p class="slide-subtitle">Physical bounded contexts within a single deployment unit, ensuring independent module toggling without database crashes.</p>
    
    <div style="height: 380px; display: flex; justify-content: center; align-items: center; background: #fff; border: 1.5px solid var(--border); border-radius: 12px; margin-bottom: 20px; padding: 12px;">
      <img src="{lego_img}" style="max-height: 100%; max-width: 100%; object-fit: contain;" alt="Lego Architecture">
    </div>

    <div class="card" style="padding: 20px 28px;">
      <div class="card-title blue" style="font-size: 19px; margin-bottom: 10px;">Explanatory Reading Script — Architectural Principles of the Lego System:</div>
      <ul class="point-list" style="font-size: 17px; gap: 8px;">
        <li><strong>1. Module Gateway as the Baseplate (Purple):</strong> Acts as the communication backbone. Modules never call each other directly; they only connect via synchronous Query Gateways or asynchronous Event Buses.</li>
        <li><strong>2. Core Modules as Foundation Blocks (Blue):</strong> Auth, Building, Room, Lease, and Occupancy Dashboard. These 5 modules are permanently active in every property and form the indispensable system bedrock.</li>
        <li><strong>3. Optional Modules as Plug-and-Play Blocks (Green):</strong> Finance, Maintenance, Inventory, Guest Logging, and Notification. These modules can be dynamically enabled or disabled per building.</li>
        <li><strong>4. Fault Isolation & Independence:</strong> As shown by the lifted Finance block, disabling Finance (e.g., for free student dorms or employee housing) leaves the remaining system 100% operational with zero cascading errors.</li>
      </ul>
    </div>
    <div class="slide-footer">
      <span>PA Management Kost — Modular Monolith Lego Foundation</span>
      <span>Slide 3 of 12</span>
    </div>
  </div>

  <!-- SLIDE 4 -->
  <div class="slide">
    <div class="slide-tag">System Architecture Evolution</div>
    <h2 class="slide-title">Architecture Comparison: Legacy Laravel (Left) vs. New NestJS Modulith (Right)</h2>
    <p class="slide-subtitle">Transforming a tightly coupled monolith into an event-driven modular monolith with strict domain boundaries.</p>
    
    <div class="grid-2" style="height: 480px; margin-bottom: 20px;">
      <div class="img-box">
        <div class="badge red">BEFORE: Legacy Laravel Monolith</div>
        <img src="{old_arch}" alt="Legacy Architecture" style="max-height: 400px;">
      </div>
      <div class="img-box">
        <div class="badge green">AFTER: Event-Driven NestJS Modulith</div>
        <img src="{new_arch}" alt="New Architecture" style="max-height: 400px;">
      </div>
    </div>

    <div class="card" style="padding: 16px 24px;">
      <div class="card-title blue" style="font-size: 18px; margin-bottom: 8px;">Explanatory Reading Script — Key Architecture Transformations:</div>
      <ul class="point-list" style="font-size: 16px; gap: 6px;">
        <li><strong>Boundary Enforcement:</strong> Legacy modules had folder-level boundaries easily violated by cross-service calls. NestJS enforces encapsulation at compile-time via IoC containers and explicit module exports.</li>
        <li><strong>Decoupled Inter-Module Communication:</strong> Cross-domain reads use the Module Gateway; state mutations emit asynchronous domain events over the Event Bus (e.g. <code>LeaseCreated</code> triggers <code>InvoiceIssued</code>).</li>
        <li><strong>Security & External Adapters:</strong> Replaced database auth with Keycloak OIDC SSO (stateless JWT verification via JWKS), integrated read-only MCP Server for AI analytics, and used Hexagonal adapters for Midtrans and WhatsApp.</li>
      </ul>
    </div>
    <div class="slide-footer">
      <span>PA Management Kost — Architecture Evolution</span>
      <span>Slide 4 of 12</span>
    </div>
  </div>

  <!-- SLIDE 5 -->
  <div class="slide">
    <div class="slide-tag">Database Schema Evolution</div>
    <h2 class="slide-title">ERD Comparison: 41 Bloated Tables (Left) vs. Streamlined 13-Table Schema (Right)</h2>
    <p class="slide-subtitle">Eliminating physical cross-module Foreign Keys and replacing complex rental branching with pure monthly leases.</p>
    
    <div class="grid-2" style="height: 480px; margin-bottom: 20px;">
      <div class="img-box">
        <div class="badge red">BEFORE: 41 Bloated Tables & Physical Cross-Domain FKs</div>
        <img src="{old_erd}" alt="Legacy ERD" style="max-height: 400px;">
      </div>
      <div class="img-box">
        <div class="badge green">AFTER: Streamlined 13 Domain Tables (Zero Cross-Module Physical FKs)</div>
        <img src="{new_erd}" alt="New ERD" style="max-height: 400px;">
      </div>
    </div>

    <div class="card" style="padding: 16px 24px;">
      <div class="card-title blue" style="font-size: 18px; margin-bottom: 8px;">Explanatory Reading Script — Key Database Refactoring Highlights:</div>
      <ul class="point-list" style="font-size: 16px; gap: 6px;">
        <li><strong>Zero Cross-Module Physical FKs:</strong> Physical Foreign Keys (green lines) are strictly intra-module. Cross-module relations (orange lines) use indexed logical soft references (<code>building_id</code>, <code>room_id</code>, <code>lease_id</code>).</li>
        <li><strong>Rental Model Simplification:</strong> Replaced daily/weekly/yearly rental fragmentation with pure monthly leasing governed by per-building <code>min_rental_months</code> rules and Two-Phase Invoicing (DP flat + settlement).</li>
        <li><strong>Strict Multi-Tenant Row-Level Scoping:</strong> Every operational table carries <code>building_id</code>, automatically filtered at the ORM layer from the user's verified JWT token.</li>
      </ul>
    </div>
    <div class="slide-footer">
      <span>PA Management Kost — Database Schema Evolution</span>
      <span>Slide 5 of 12</span>
    </div>
  </div>

  <!-- SLIDE 6 -->
  <div class="slide">
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
    <div class="slide-footer">
      <span>PA Management Kost — Core Architectural Pillars</span>
      <span>Slide 6 of 12</span>
    </div>
  </div>

  <!-- SLIDE 7 -->
  <div class="slide">
    <div class="slide-tag">Intelligent Capabilities</div>
    <h2 class="slide-title">Model Context Protocol (MCP): Deterministic, Read-Only AI Analytical Assistant</h2>
    <p class="slide-subtitle">Bridging Large Language Models with operational business data securely without data mutation risks.</p>
    <div class="grid-2">
      <div class="img-box">
        <div class="card-title blue" style="align-self: flex-start; font-size: 19px; margin-bottom: 8px;">MCP Architecture: Client-Host-Server Protocol</div>
        <img src="{mcp_img}" alt="MCP Protocol" style="max-height: 520px;">
      </div>
      <div class="card">
        <div class="card-title teal">Explanatory Reading Script — Why MCP for Property SIM:</div>
        <ul class="point-list" style="font-size: 17.5px; gap: 12px;">
          <li><strong>Open Industry Standard (JSON-RPC 2.0):</strong> Model Context Protocol bridges AI LLMs (Claude, Gemini, Ollama) directly to the operational database via standardized tool calling.</li>
          <li><strong>Strictly Read-Only Operations:</strong> All exposed MCP tools (<code>get_occupancy_rates</code>, <code>get_financial_summary</code>, <code>get_maintenance_backlog</code>) are strictly read-only aggregations. The AI cannot execute data mutations. All critical business decisions remain firmly human-in-the-loop.</li>
          <li><strong>Grounded Data (Zero Hallucination):</strong> The LLM issues precise parameterized tool calls to the backend, receives exact numeric JSON data, and formulates clear executive summaries.</li>
          <li><strong>Automated Tenant Boundary:</strong> Owners query portfolio-wide data, while property managers are restricted to analytics for their assigned building.</li>
          <li><strong>Instant Executive Insight:</strong> Owners can ask: <em>"Which building had the highest occupancy this month?"</em> or <em>"How much unpaid rent is outstanding?"</em> without navigating dozens of manual dashboard menus.</li>
        </ul>
      </div>
    </div>
    <div class="slide-footer">
      <span>PA Management Kost — Model Context Protocol (MCP)</span>
      <span>Slide 7 of 12</span>
    </div>
  </div>

  <!-- SLIDE 8 -->
  <div class="slide">
    <div class="slide-tag">Frontend Engineering & Design System</div>
    <h2 class="slide-title">Flutter Web with Clean Architecture & Tailored Role-Based Portals</h2>
    <p class="slide-subtitle">Separating business logic from the UI layer while providing dedicated workspaces for Owners, Admins, and Tenants.</p>
    
    <div class="grid-3" style="height: 440px; margin-bottom: 20px;">
      <div class="img-box">
        <div class="badge blue">1. Owner Dashboard (Multi-Building)</div>
        <img src="{owner_mock}" alt="Owner Dashboard" style="max-height: 360px;">
      </div>
      <div class="img-box">
        <div class="badge green">2. Admin Dashboard (Operations)</div>
        <img src="{admin_mock}" alt="Admin Dashboard" style="max-height: 360px;">
      </div>
      <div class="img-box">
        <div class="badge red">3. Resident Self-Service Portal</div>
        <img src="{resident_mock}" alt="Resident Portal" style="max-height: 360px;">
      </div>
    </div>

    <div class="card" style="padding: 16px 24px;">
      <div class="card-title blue" style="font-size: 18px; margin-bottom: 8px;">Explanatory Reading Script — Clean Architecture & Portal Implementation:</div>
      <ul class="point-list" style="font-size: 16px; gap: 6px;">
        <li><strong>Unidirectional Data Flow via BLoC:</strong> Presentation layer (Widgets) dispatches events to BLoC/Cubit, which calls pure Dart Use Cases in the Domain Layer. States are emitted immutably, ensuring millisecond unit-testability without UI dependencies.</li>
        <li><strong>Strict Layer Decoupling:</strong> The Domain layer has zero dependencies on Flutter UI or third-party packages. If API formats or backends change, only the Data Layer (Dio Remote Data Source / DTOs) is modified.</li>
        <li><strong>Cross-Platform Readiness:</strong> While tested primarily on Flutter Web (desktop and tablet layouts), the core business rules and state machines are 100% reusable when deploying to native iOS and Android apps in the future.</li>
        <li><strong>Role-Tailored UX:</strong> Owner portal provides portfolio cash flows and dynamic role builder; Admin portal streamlines daily check-ins, tickets, and expenses; Resident portal empowers self-service booking, digital payments, and damage reports.</li>
      </ul>
    </div>
    <div class="slide-footer">
      <span>PA Management Kost — Frontend Clean Architecture</span>
      <span>Slide 8 of 12</span>
    </div>
  </div>

  <!-- SLIDE 9 -->
  <div class="slide">
    <div class="slide-tag">Feature Specifications & Scope</div>
    <h2 class="slide-title">New System Feature Matrix: 7 Core, 9 Optional, and 1 AI Analytical Feature</h2>
    <p class="slide-subtitle">Official specifications ratified in ADR-008 & ADR-009, enabling modular customization across property types.</p>
    <div class="grid-2">
      <div class="card">
        <div class="card-title blue">Core Features (Mandatory Active in All Properties)</div>
        <ul class="point-list" style="font-size: 16px; gap: 8px;">
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
        <ul class="point-list" style="font-size: 15.5px; gap: 6px;">
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
    <div class="slide-footer">
      <span>PA Management Kost — Feature Specifications</span>
      <span>Slide 9 of 12</span>
    </div>
  </div>

  <!-- SLIDE 10 -->
  <div class="slide">
    <div class="slide-tag">Empirical Validation & Testing</div>
    <h2 class="slide-title">Module Independence Testing: 100% Pass Rate Across 4 Real-World Scenarios</h2>
    <p class="slide-subtitle">Proving zero cascading failures when business modules are dynamically toggled off.</p>
    
    <div class="grid-2x2" style="margin-bottom: 24px;">
      <div class="card">
        <div class="card-title blue">Scenario A: Full Commercial Boarding House</div>
        <div style="font-size: 16px; font-weight: 700; color: var(--text-main); margin-bottom: 6px;">All Modules Active (Core + Finance + Maintenance + Inventory + Guest + Notification)</div>
        <p style="font-size: 16px; color: var(--text-muted); line-height: 1.4;">
          <strong>Result: 100% Pass Rate.</strong> Full end-to-end automation of two-phase invoicing, Midtrans payment callbacks, WhatsApp receipts, and maintenance tickets executed flawlessly.
        </p>
      </div>
      <div class="card">
        <div class="card-title teal">Scenario B: Free Staff Mess / Subsidized Student Dorm</div>
        <div style="font-size: 16px; font-weight: 700; color: var(--text-main); margin-bottom: 6px;">Finance & Notification Modules Disabled (Billing OFF)</div>
        <p style="font-size: 16px; color: var(--text-muted); line-height: 1.4;">
          <strong>Result: 100% Pass Rate.</strong> Tenant allocations and room bookings confirmed immediately without generating invoices or payment gateway requests. Zero database foreign key errors.
        </p>
      </div>
      <div class="card">
        <div class="card-title amber">Scenario C: Minimal Remote Rental Property</div>
        <div style="font-size: 16px; font-weight: 700; color: var(--text-main); margin-bottom: 6px;">Maintenance, Inventory, and Guest Modules Disabled</div>
        <p style="font-size: 16px; color: var(--text-muted); line-height: 1.4;">
          <strong>Result: 100% Pass Rate.</strong> System operates purely on automated lease management and digital payments. UI cleanly hides operational menus with no backend query crashes.
        </p>
      </div>
      <div class="card">
        <div class="card-title" style="color: #64748b;">Scenario D: Barebone Master Room & Allocation Core</div>
        <div style="font-size: 16px; font-weight: 700; color: var(--text-main); margin-bottom: 6px;">All Optional Modules Disabled (Core Modules Only)</div>
        <p style="font-size: 16px; color: var(--text-muted); line-height: 1.4;">
          <strong>Result: 100% Pass Rate.</strong> Operates strictly as a room inventory and resident allocation system. Validates that the core foundation stands entirely independent of optional business tiers.
        </p>
      </div>
    </div>

    <div style="background: #eff6ff; border: 1.5px solid #bfdbfe; border-radius: 8px; padding: 16px 20px; font-size: 17px; color: #1e40af; font-weight: 600;">
      🔍 <strong>Testing Verdict:</strong> Proves that strict modular encapsulation (NestJS IoC + zero cross-module physical FKs) guarantees true plug-and-play flexibility.
    </div>
    <div class="slide-footer">
      <span>PA Management Kost — Module Independence Testing</span>
      <span>Slide 10 of 12</span>
    </div>
  </div>

  <!-- SLIDE 11 -->
  <div class="slide">
    <div class="slide-tag">Project Synthesis & Future Directions</div>
    <h2 class="slide-title">Conclusion: Resolving Legacy Gaps and Delivering an Enterprise-Ready System</h2>
    <p class="slide-subtitle">Delivering high maintainability, enterprise security, and multi-property operational scalability.</p>
    <div class="grid-3">
      <div class="card">
        <div class="card-title blue">Key Contributions</div>
        <ul class="point-list">
          <li><strong>Unification of 4 Proposals:</strong> Synthesized 4 fragmented student projects into a cohesive, high-performance architecture.</li>
          <li><strong>True Modular Monolith:</strong> Eradicated pseudo-modularity using NestJS encapsulation, Event Bus, and zero cross-module physical FKs.</li>
          <li><strong>Multi-Tenancy Row-Level Scoping:</strong> Enabled centralized management of multiple buildings from a single deployment.</li>
          <li><strong>Production-Grade Security:</strong> Enterprise Keycloak SSO with stateless JWKS verification + dynamic role permission builder.</li>
        </ul>
      </div>
      <div class="card">
        <div class="card-title teal">Operational Impact</div>
        <ul class="point-list">
          <li><strong>Zero Double-Booking:</strong> Guaranteed booking safety through PostgreSQL pessimistic row locking (<code>FOR UPDATE</code>).</li>
          <li><strong>Streamlined Accounting:</strong> Two-Phase Invoicing and Midtrans SNAP webhook automation reduce manual reconciliation by 95%.</li>
          <li><strong>AI Decision Support:</strong> Read-only Model Context Protocol (MCP) provides instant natural language KPI reporting without hallucinations.</li>
          <li><strong>Deployment Agility:</strong> Fully containerized with Docker & Docker Compose for rapid on-premise or cloud hosting.</li>
        </ul>
      </div>
      <div class="card">
        <div class="card-title amber">Future Roadmap</div>
        <ul class="point-list">
          <li><strong>Mobile Compilation:</strong> Compile Flutter Clean Architecture codebase to native iOS and Android apps with zero domain rewrite.</li>
          <li><strong>IoT Smart Lock Integration:</strong> Synchronize lease start/end dates with smart door locks and electricity relay switches.</li>
          <li><strong>Predictive Maintenance:</strong> Utilize historical damage ticket logs to forecast preventative maintenance cycles via machine learning.</li>
          <li><strong>Self-Service Tenant Onboarding:</strong> Digital e-KYC KTP scanning and optical character recognition for automated profile verification.</li>
        </ul>
      </div>
    </div>
    <div class="slide-footer">
      <span>PA Management Kost — Conclusion & Roadmap</span>
      <span>Slide 11 of 12</span>
    </div>
  </div>

  <!-- SLIDE 12 -->
  <div class="slide dark">
    <div style="flex: 1; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center;">
      <h1 style="font-size: 72px; font-weight: 800; color: #ffffff; margin-bottom: 18px; letter-spacing: 2px;">THANK YOU</h1>
      <div style="font-size: 32px; font-weight: 600; color: #38bdf8; margin-bottom: 36px;">Questions & Answers (Q&A)</div>
      <p style="font-size: 22px; color: #cbd5e1; line-height: 1.6;">
        <strong>Bagus Alfian (NRP: 3123500031)</strong><br>
        Program Studi Sarjana Terapan Teknik Informatika<br>
        Politeknik Elektronika Negeri Surabaya (PENS) — 2026
      </p>
    </div>
    <div class="slide-footer">
      <span>Politeknik Elektronika Negeri Surabaya (PENS)</span>
      <span>Slide 12 of 12</span>
    </div>
  </div>

</body>
</html>
"""
    out_html = os.path.join(base_dir, "presentation_print.html")
    with open(out_html, "w", encoding="utf-8") as f:
        f.write(html_content)
    print(f"Printable HTML written to: {out_html}")

    out_pdf = os.path.join(base_dir, "Presentation_PA_Bagus_Alfian.pdf")
    cmd = [
        "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
        "--headless",
        "--disable-gpu",
        "--run-all-compositor-stages-before-draw",
        "--print-to-pdf-no-header",
        f"--print-to-pdf={out_pdf}",
        f"file://{out_html}"
    ]
    print("Running Edge PDF export...")
    res = subprocess.run(cmd, capture_output=True, text=True)
    print(f"Edge process finished with return code {res.returncode}")
    if os.path.exists(out_pdf):
        size = os.path.getsize(out_pdf)
        print(f"PDF generated successfully at {out_pdf} ({size} bytes)")
    else:
        print("PDF generation failed:", res.stderr)

if __name__ == "__main__":
    generate_pdf()
