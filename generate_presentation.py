import os
import pptx
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE

def build_presentation():
    prs = pptx.Presentation()
    # 16:9 Widescreen standard
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)
    blank_layout = prs.slide_layouts[6]

    # Color Palette Definitions
    DARK_BG = RGBColor(15, 23, 42)       # Slate 900
    WHITE = RGBColor(255, 255, 255)
    OFF_WHITE = RGBColor(248, 250, 252)  # Slate 50
    CARD_BG = RGBColor(255, 255, 255)
    CARD_BORDER = RGBColor(226, 232, 240)# Slate 200
    TEXT_MAIN = RGBColor(30, 41, 59)     # Slate 800
    TEXT_MUTED = RGBColor(100, 116, 139) # Slate 500
    ACCENT_BLUE = RGBColor(37, 99, 235)  # Blue 600
    ACCENT_TEAL = RGBColor(13, 148, 136) # Teal 600
    ACCENT_RED = RGBColor(225, 29, 72)   # Rose 600
    ACCENT_AMBER = RGBColor(217, 119, 6) # Amber 600
    TAG_BG_BLUE = RGBColor(239, 246, 255)

    base_dir = "/Users/allvvnt/alfianSpace/Kampus/PA-Management-kost"

    def set_slide_background(slide, color):
        bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, prs.slide_height)
        bg.fill.solid()
        bg.fill.fore_color.rgb = color
        bg.line.fill.background()
        return bg

    def add_header(slide, tag_text, title_text, subtitle_text=None, is_dark=False):
        # Header container
        header_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.4), Inches(11.733), Inches(1.1))
        tf = header_box.text_frame
        tf.word_wrap = True
        tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0

        # Category Tag
        p_tag = tf.paragraphs[0]
        p_tag.text = tag_text.upper()
        p_tag.font.size = Pt(10)
        p_tag.font.bold = True
        p_tag.font.color.rgb = ACCENT_BLUE if not is_dark else RGBColor(56, 189, 248)
        p_tag.space_after = Pt(2)

        # Title
        p_title = tf.add_paragraph()
        p_title.text = title_text
        p_title.font.size = Pt(22)
        p_title.font.bold = True
        p_title.font.color.rgb = WHITE if is_dark else TEXT_MAIN
        
        if subtitle_text:
            p_sub = tf.add_paragraph()
            p_sub.text = subtitle_text
            p_sub.font.size = Pt(12)
            p_sub.font.color.rgb = RGBColor(148, 163, 184) if is_dark else TEXT_MUTED
            p_sub.space_before = Pt(2)

    def add_card(slide, left, top, width, height, bg_color=CARD_BG, border_color=CARD_BORDER):
        card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
        card.fill.solid()
        card.fill.fore_color.rgb = bg_color
        card.line.color.rgb = border_color
        card.line.width = Pt(1)
        return card

    # =========================================================================
    # SLIDE 1: Title & Overview (Dark Theme)
    # =========================================================================
    s1 = prs.slides.add_slide(blank_layout)
    set_slide_background(s1, DARK_BG)

    # Accent decorative bar
    bar = s1.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.8), Inches(1.2), Inches(0.15), Inches(4.8))
    bar.fill.solid()
    bar.fill.fore_color.rgb = ACCENT_BLUE
    bar.line.fill.background()

    # Title box
    tb = s1.shapes.add_textbox(Inches(1.2), Inches(1.2), Inches(11.3), Inches(4.8))
    tf = tb.text_frame
    tf.word_wrap = True

    p = tf.paragraphs[0]
    p.text = "FINAL PROJECT DEFENSE PRESENTATION (15 MINUTES)"
    p.font.size = Pt(12)
    p.font.bold = True
    p.font.color.rgb = RGBColor(56, 189, 248)
    p.space_after = Pt(12)

    p = tf.add_paragraph()
    p.text = "Event-Driven Modular Monolithic Architecture for Integrated Multi-Building Boarding House Management Information System"
    p.font.size = Pt(28)
    p.font.bold = True
    p.font.color.rgb = WHITE
    p.space_after = Pt(20)

    p = tf.add_paragraph()
    p.text = "Presenter: Bagus Alfian (NRP: 3123500031) | Program: Applied Bachelor of Informatics Engineering\nAdvisors: Tessy Badriyah, S.Kom., M.T., Ph.D.  &  Prof. Iwan Syarif, S.Kom., M.Kom., M.Sc., Ph.D.\nDepartment of Informatics and Computer Engineering — Politeknik Elektronika Negeri Surabaya (PENS) 2026"
    p.font.size = Pt(13)
    p.font.color.rgb = RGBColor(203, 213, 225)
    p.space_after = Pt(24)

    # Bottom pill badges for core stack
    badges_box = s1.shapes.add_textbox(Inches(1.2), Inches(6.0), Inches(11.3), Inches(0.8))
    tf_b = badges_box.text_frame
    p_b = tf_b.paragraphs[0]
    p_b.text = "Core Stack: NestJS Modular Monolith • PostgreSQL (Row-Level Scoping) • Keycloak OIDC SSO • Flutter Web (Clean Architecture) • Model Context Protocol (MCP) • Midtrans SNAP"
    p_b.font.size = Pt(11)
    p_b.font.bold = True
    p_b.font.color.rgb = RGBColor(148, 163, 184)

    # =========================================================================
    # SLIDE 2: Background & Critical Analysis of Previous Work
    # =========================================================================
    s2 = prs.slides.add_slide(blank_layout)
    set_slide_background(s2, OFF_WHITE)
    add_header(s2, "Problem Context & Literature Review", "Critical Synthesis of Previous Work: Why a Unified Rewrite Was Urgent", 
               "Comprehensive investigation revealed five systemic architectural blockers in the four initial monolithic proposals.")

    # 2-column layout: Left column = 4 Previous Works; Right column = The 5 Critical Architectural Gaps
    # Card Left
    add_card(s2, Inches(0.8), Inches(1.7), Inches(5.6), Inches(5.3))
    tb_l = s2.shapes.add_textbox(Inches(1.0), Inches(1.85), Inches(5.2), Inches(5.0))
    tf_l = tb_l.text_frame
    tf_l.word_wrap = True

    p = tf_l.paragraphs[0]
    p.text = "The 4 Previous Work Proposals (June 2025)"
    p.font.size = Pt(16)
    p.font.bold = True
    p.font.color.rgb = ACCENT_BLUE
    p.space_after = Pt(10)

    prev_works = [
        ("1. Tenant & Guest Management", "Focused only on basic profile, guest logs, and lease records without cross-system sync."),
        ("2. Room & Reservation", "Handled room listings and booking schedules, but lacked strict transactional concurrency locks."),
        ("3. Finance & Transactions", "Implemented billing & Midtrans test sandbox, but tightly coupled to room database tables."),
        ("4. Operations & Maintenance", "Managed damage tickets and room inventory, isolated without unified accounting sync.")
    ]
    for title, desc in prev_works:
        p = tf_l.add_paragraph()
        p.text = f"• {title}: "
        p.font.size = Pt(12)
        p.font.bold = True
        p.font.color.rgb = TEXT_MAIN
        p_run = p.add_run()
        p_run.text = desc
        p_run.font.bold = False
        p_run.font.color.rgb = TEXT_MUTED
        p.space_after = Pt(8)

    p_summary = tf_l.add_paragraph()
    p_summary.text = "Key Takeaway: Each domain was designed in isolation for a single physical building, leading to massive technical fragmentation when unified."
    p_summary.font.size = Pt(11)
    p_summary.font.bold = True
    p_summary.font.color.rgb = ACCENT_AMBER
    p_summary.space_before = Pt(8)

    # Card Right
    add_card(s2, Inches(6.7), Inches(1.7), Inches(5.8), Inches(5.3))
    tb_r = s2.shapes.add_textbox(Inches(6.9), Inches(1.85), Inches(5.4), Inches(5.0))
    tf_r = tb_r.text_frame
    tf_r.word_wrap = True

    p = tf_r.paragraphs[0]
    p.text = "The 5 Structural Architecture Traps Identified"
    p.font.size = Pt(16)
    p.font.bold = True
    p.font.color.rgb = ACCENT_RED
    p.space_after = Pt(10)

    gaps = [
        ("1. Pseudo-Modularity (Tight Coupling)", "Laravel modules only separated by folder structure. Cross-domain service calls and physical cross-module Foreign Keys made independent testing impossible."),
        ("2. Lack of Multi-Tenancy (Single Building Only)", "Databases and business logic assumed only one building. Opening new branches required setting up separate servers and manual consolidation."),
        ("3. Database Bloat & Schema Duplication", "Mixing daily, weekly, monthly, and yearly rentals with DP & refunds exploded the schema to 41 tables with redundant billing, locks, and dead columns."),
        ("4. Primitive Security & Manual Auth", "Basic username/password without email verification, password reset, or dynamic RBAC. No per-building staff permission isolation."),
        ("5. Lack of Standard API & AI Analytical Layer", "Inconsistent REST JSON responses broke frontend reliability. No standardized AI (LLM) query interface existed for operational KPIs.")
    ]
    for title, desc in gaps:
        p = tf_r.add_paragraph()
        p.text = f"• {title}: "
        p.font.size = Pt(11)
        p.font.bold = True
        p.font.color.rgb = TEXT_MAIN
        p_run = p.add_run()
        p_run.text = desc
        p_run.font.bold = False
        p_run.font.color.rgb = TEXT_MUTED
        p.space_after = Pt(6)

    # =========================================================================
    # SLIDE 3: Modular Monolith Paradigm (Lego Analogy)
    # =========================================================================
    s3 = prs.slides.add_slide(blank_layout)
    set_slide_background(s3, OFF_WHITE)
    add_header(s3, "Architecture Foundation", "The Modular Monolithic Paradigm: Modular Isolation via the Lego Metaphor",
               "Physical bounded contexts within a single deployment unit, ensuring independent module toggling without database crashes.")

    # Image top-center / left
    lego_img_path = os.path.join(base_dir, "PA/docs/System design/01-Gambaran-umum/01_arsitektur_keseluruhan/image.png")
    if os.path.exists(lego_img_path):
        s3.shapes.add_picture(lego_img_path, Inches(0.8), Inches(1.6), width=Inches(11.733))

    # Explanation card underneath
    add_card(s3, Inches(0.8), Inches(4.35), Inches(11.733), Inches(2.75))
    tb_exp = s3.shapes.add_textbox(Inches(1.0), Inches(4.45), Inches(11.333), Inches(2.55))
    tf_exp = tb_exp.text_frame
    tf_exp.word_wrap = True

    p = tf_exp.paragraphs[0]
    p.text = "Explanatory Reading Script — Architectural Principles of the Lego System:"
    p.font.size = Pt(13)
    p.font.bold = True
    p.font.color.rgb = ACCENT_BLUE
    p.space_after = Pt(4)

    lego_points = [
        ("1. Module Gateway as the Baseplate (Purple):", "Acts as the central communication backbone. Modules never call each other directly; they only connect to the gateway via synchronous Query Gateways or asynchronous Event Buses."),
        ("2. Core Modules as Foundation Blocks (Blue):", "Consists of 5 foundational domains: User & Access Control (Auth), Building, Room, Lease (Occupancy & Schedule), and Occupancy Dashboard. These blocks are permanently active and provide the mandatory structural foundation for any property."),
        ("3. Optional Modules as Plug-and-Play Blocks (Green):", "Consists of Finance & Billing, Maintenance, Inventory, Guest Logging, and Notification. These modules can be dynamically enabled (ON) or disabled (OFF) per building based on operational requirements."),
        ("4. Fault Isolation & Independence upon Removal:", "As illustrated by the detached Finance block, disabling the Finance module (e.g., for free student dormitories or employee mess) leaves the baseplate and all other blocks functioning 100% reliably without triggering foreign key errors, crashes, or schema corruption.")
    ]
    for title, desc in lego_points:
        p = tf_exp.add_paragraph()
        p.text = f"• {title} "
        p.font.size = Pt(11)
        p.font.bold = True
        p.font.color.rgb = TEXT_MAIN
        p_run = p.add_run()
        p_run.text = desc
        p_run.font.bold = False
        p_run.font.color.rgb = TEXT_MUTED
        p.space_after = Pt(3)

    # =========================================================================
    # SLIDE 4: Architecture Evolution — Before vs After
    # =========================================================================
    s4 = prs.slides.add_slide(blank_layout)
    set_slide_background(s4, OFF_WHITE)
    add_header(s4, "System Architecture Evolution", "Architecture Comparison: Legacy Laravel Monolith (Left) vs. New NestJS Modulith (Right)",
               "Transforming a tightly coupled, single-building architecture into an event-driven modular monolith with strict domain boundaries.")

    # Side by side images
    old_arch_img = os.path.join(base_dir, "PA/docs/System design/08-design-lama/desain_sistem-1. Arsitektur Keseluruhan.drawio.png")
    new_arch_img = os.path.join(base_dir, "PA/docs/System design/01-Gambaran-umum/01_arsitektur_keseluruhan/arsitektur_terpadu.png")

    # Left Container (Before)
    add_card(s4, Inches(0.8), Inches(1.6), Inches(5.6), Inches(3.4))
    tb_label_l = s4.shapes.add_textbox(Inches(0.9), Inches(1.65), Inches(5.4), Inches(0.3))
    p = tb_label_l.text_frame.paragraphs[0]
    p.text = "BEFORE: Legacy 12-Module Laravel Architecture"
    p.font.size = Pt(12)
    p.font.bold = True
    p.font.color.rgb = ACCENT_RED
    if os.path.exists(old_arch_img):
        s4.shapes.add_picture(old_arch_img, Inches(1.1), Inches(2.0), width=Inches(5.0))

    # Right Container (After)
    add_card(s4, Inches(6.8), Inches(1.6), Inches(5.7), Inches(3.4))
    tb_label_r = s4.shapes.add_textbox(Inches(6.9), Inches(1.65), Inches(5.5), Inches(0.3))
    p = tb_label_r.text_frame.paragraphs[0]
    p.text = "AFTER: New Event-Driven NestJS Modular Monolith"
    p.font.size = Pt(12)
    p.font.bold = True
    p.font.color.rgb = ACCENT_TEAL
    if os.path.exists(new_arch_img):
        s4.shapes.add_picture(new_arch_img, Inches(7.0), Inches(2.0), width=Inches(5.3))

    # Text explanation card underneath
    add_card(s4, Inches(0.8), Inches(5.15), Inches(11.7), Inches(2.0))
    tb_arch_notes = s4.shapes.add_textbox(Inches(0.95), Inches(5.2), Inches(11.4), Inches(1.9))
    tf_an = tb_arch_notes.text_frame
    tf_an.word_wrap = True

    p = tf_an.paragraphs[0]
    p.text = "Explanatory Reading Script — Architectural Transformation Highlights:"
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = ACCENT_BLUE
    p.space_after = Pt(2)

    arch_diffs = [
        ("• Boundary Enforcement:", "The old system relied only on folder conventions in Laravel; in practice, services directly queried other modules' models. The new system enforces module encapsulation at compile time using NestJS IoC containers and explicit `@Module({ exports })` exports."),
        ("• Decoupled Communication:", "Cross-module data queries must go through the Module Gateway (Query Gateway), and state-mutating side effects use asynchronous domain events via an internal Event Bus (`LeaseCreated`, `PaymentSettled`)."),
        ("• Security & Protocols:", "Replaced basic DB authentication with enterprise Keycloak OpenID Connect (OIDC) verifying stateless JWTs via JWKS. Added read-only Model Context Protocol (MCP) server for instant AI analytics and Hexagonal outbound adapters for Midtrans and WhatsApp.")
    ]
    for title, desc in arch_diffs:
        p = tf_an.add_paragraph()
        p.text = f"{title} "
        p.font.size = Pt(10.5)
        p.font.bold = True
        p.font.color.rgb = TEXT_MAIN
        p_run = p.add_run()
        p_run.text = desc
        p_run.font.bold = False
        p_run.font.color.rgb = TEXT_MUTED
        p.space_after = Pt(2)

    # =========================================================================
    # SLIDE 5: Database Schema Evolution — ERD Before vs After
    # =========================================================================
    s5 = prs.slides.add_slide(blank_layout)
    set_slide_background(s5, OFF_WHITE)
    add_header(s5, "Database Schema Evolution", "ERD Comparison: 41 Bloated Tables (Left) vs. Streamlined 13-Table Domain Schema (Right)",
               "Eliminating physical cross-module Foreign Keys and replacing complex rental branching with pure monthly leases and soft references.")

    # Side by side images
    old_erd_img = os.path.join(base_dir, "PA/docs/System design/08-design-lama/erd_fix_2.drawio.png")
    new_erd_img = os.path.join(base_dir, "PA/docs/System design/04-ERD/erd_13_tabel.png")

    # Left Card
    add_card(s5, Inches(0.8), Inches(1.6), Inches(5.6), Inches(3.4))
    tb_erd_l = s5.shapes.add_textbox(Inches(0.9), Inches(1.65), Inches(5.4), Inches(0.3))
    p = tb_erd_l.text_frame.paragraphs[0]
    p.text = "BEFORE: 41 Bloated Tables & Physical Cross-Domain FKs"
    p.font.size = Pt(12)
    p.font.bold = True
    p.font.color.rgb = ACCENT_RED
    if os.path.exists(old_erd_img):
        s5.shapes.add_picture(old_erd_img, Inches(1.0), Inches(2.0), width=Inches(5.2))

    # Right Card
    add_card(s5, Inches(6.8), Inches(1.6), Inches(5.7), Inches(3.4))
    tb_erd_r = s5.shapes.add_textbox(Inches(6.9), Inches(1.65), Inches(5.5), Inches(0.3))
    p = tb_erd_r.text_frame.paragraphs[0]
    p.text = "AFTER: Streamlined 13 Domain Tables (Zero Cross-Module Physical FKs)"
    p.font.size = Pt(12)
    p.font.bold = True
    p.font.color.rgb = ACCENT_TEAL
    if os.path.exists(new_erd_img):
        s5.shapes.add_picture(new_erd_img, Inches(6.9), Inches(2.0), width=Inches(5.5))

    # Text explanation card underneath
    add_card(s5, Inches(0.8), Inches(5.15), Inches(11.7), Inches(2.0))
    tb_erd_notes = s5.shapes.add_textbox(Inches(0.95), Inches(5.2), Inches(11.4), Inches(1.9))
    tf_en = tb_erd_notes.text_frame
    tf_en.word_wrap = True

    p = tf_en.paragraphs[0]
    p.text = "Explanatory Reading Script — Database Schema Refactoring Highlights:"
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = ACCENT_BLUE
    p.space_after = Pt(2)

    erd_diffs = [
        ("• Zero Cross-Module Foreign Keys:", "In the new ERD, physical FK constraints (green lines) only exist strictly inside the same module. All cross-module relationships (orange lines) use indexed logical soft references (e.g. building_id, room_id, lease_id). This allows any optional table to be dropped or bypassed without cascading constraint violations."),
        ("• Business Model Simplification:", "Eliminated chaotic bifurcations of daily/weekly/annual rents and installment tracking. The system now enforces a pure monthly rental unit with per-building minimum stay (`min_rental_months`) and Two-Phase Invoicing (DP/Booking fee + settlement)."),
        ("• Strict Multi-Tenancy Row-Level Scoping:", "Every single operational table contains a `building_id` column. NestJS queries automatically inject building filters extracted from the user's verified JWT token, ensuring total data isolation in a shared database.")
    ]
    for title, desc in erd_diffs:
        p = tf_en.add_paragraph()
        p.text = f"{title} "
        p.font.size = Pt(10.5)
        p.font.bold = True
        p.font.color.rgb = TEXT_MAIN
        p_run = p.add_run()
        p_run.text = desc
        p_run.font.bold = False
        p_run.font.color.rgb = TEXT_MUTED
        p.space_after = Pt(2)

    # =========================================================================
    # SLIDE 6: Key Architectural Pillars & Concurrency Protection
    # =========================================================================
    s6 = prs.slides.add_slide(blank_layout)
    set_slide_background(s6, OFF_WHITE)
    add_header(s6, "Architectural In-Depth", "Core Pillars: Multi-Tenancy, Concurrency Control, and Production Reliability",
               "Solving high-concurrency double bookings, tenant data leaks, and idempotent digital payment operations.")

    # 3 Cards side by side
    card_w = Inches(3.7)
    card_h = Inches(5.2)

    # Card 1: Multi-Tenancy
    add_card(s6, Inches(0.8), Inches(1.7), card_w, card_h)
    tb_p1 = s6.shapes.add_textbox(Inches(0.95), Inches(1.85), Inches(3.4), Inches(4.9))
    tf_p1 = tb_p1.text_frame
    tf_p1.word_wrap = True
    p = tf_p1.paragraphs[0]
    p.text = "1. Multi-Tenancy Row Scoping"
    p.font.size = Pt(14)
    p.font.bold = True
    p.font.color.rgb = ACCENT_BLUE
    p.space_after = Pt(8)

    pts1 = [
        "Shared Database Model: Single PostgreSQL database with logical tenant isolation via `building_id`.",
        "Zero Cross-Tenant Leakage: Admin managers are locked to their assigned building. Queries automatically append building scopes.",
        "Unified Portfolio Analytics: Property owners can view aggregated portfolio cash flow without complex distributed database joins.",
        "Schema Efficiency: Single migration scripts run once across all buildings instead of managing separate database instances."
    ]
    for pt in pts1:
        p = tf_p1.add_paragraph()
        p.text = f"• {pt}"
        p.font.size = Pt(11)
        p.font.color.rgb = TEXT_MAIN
        p.space_after = Pt(6)

    # Card 2: Concurrency & Double Booking
    add_card(s6, Inches(4.8), Inches(1.7), card_w, card_h)
    tb_p2 = s6.shapes.add_textbox(Inches(4.95), Inches(1.85), Inches(3.4), Inches(4.9))
    tf_p2 = tb_p2.text_frame
    tf_p2.word_wrap = True
    p = tf_p2.paragraphs[0]
    p.text = "2. Concurrency & Anti-Collision"
    p.font.size = Pt(14)
    p.font.bold = True
    p.font.color.rgb = ACCENT_TEAL
    p.space_after = Pt(8)

    pts2 = [
        "Pessimistic Locking: When a tenant clicks reserve, the database executes `SELECT ... FOR UPDATE` on the room record inside an atomic transaction.",
        "Overlapping Validation: Checks for existing active/pending leases during the requested time window.",
        "Zero Double Bookings: Competing requests for the same room are queued; once the first transaction commits, subsequent conflicting requests are safely rejected with HTTP 422.",
        "Two-Phase DP Mechanism: Supports booking confirmation via DP flat or full 1st-month payment with auto-expiry."
    ]
    for pt in pts2:
        p = tf_p2.add_paragraph()
        p.text = f"• {pt}"
        p.font.size = Pt(11)
        p.font.color.rgb = TEXT_MAIN
        p.space_after = Pt(6)

    # Card 3: Production Payments & Auth
    add_card(s6, Inches(8.8), Inches(1.7), card_w, card_h)
    tb_p3 = s6.shapes.add_textbox(Inches(8.95), Inches(1.85), Inches(3.4), Inches(4.9))
    tf_p3 = tb_p3.text_frame
    tf_p3.word_wrap = True
    p = tf_p3.paragraphs[0]
    p.text = "3. Midtrans & Keycloak OIDC"
    p.font.size = Pt(14)
    p.font.bold = True
    p.font.color.rgb = ACCENT_AMBER
    p.space_after = Pt(8)

    pts3 = [
        "Midtrans SNAP Gateway: Pop-up checkout supporting Virtual Accounts, QRIS, and e-wallets.",
        "Double-Payment Protection: Idempotency keys prevent duplicate invoices during network retries.",
        "Cryptographic Webhook: Backend verifies SHA-512 signatures (`order_id + status + gross_amount + server_key`) before settling invoices.",
        "Stateless Auth via Keycloak: High-security SSO, automated email verification, password reset, and stateless JWT JWKS verification without per-request auth server overhead."
    ]
    for pt in pts3:
        p = tf_p3.add_paragraph()
        p.text = f"• {pt}"
        p.font.size = Pt(11)
        p.font.color.rgb = TEXT_MAIN
        p.space_after = Pt(6)

    # =========================================================================
    # SLIDE 7: AI Analytical Layer — Model Context Protocol (MCP)
    # =========================================================================
    s7 = prs.slides.add_slide(blank_layout)
    set_slide_background(s7, OFF_WHITE)
    add_header(s7, "Intelligent Capabilities", "Model Context Protocol (MCP): Deterministic, Read-Only AI Analytical Assistant",
               "Bridging Large Language Models with operational business data securely without data mutation risks.")

    # Image diagram on the left
    mcp_img = os.path.join(base_dir, "PA/docs/System design/06-Teori-Penunjang/gambar_2_14_mcp.png")
    add_card(s7, Inches(0.8), Inches(1.7), Inches(5.6), Inches(5.3))
    tb_mcp_title = s7.shapes.add_textbox(Inches(1.0), Inches(1.85), Inches(5.2), Inches(0.4))
    p = tb_mcp_title.text_frame.paragraphs[0]
    p.text = "MCP Architecture: Client-Host-Server Protocol"
    p.font.size = Pt(14)
    p.font.bold = True
    p.font.color.rgb = ACCENT_BLUE

    if os.path.exists(mcp_img):
        s7.shapes.add_picture(mcp_img, Inches(1.0), Inches(2.3), width=Inches(5.2))

    # Right Card: Detailed Points to Read
    add_card(s7, Inches(6.7), Inches(1.7), Inches(5.8), Inches(5.3))
    tb_mcp_r = s7.shapes.add_textbox(Inches(6.9), Inches(1.85), Inches(5.4), Inches(5.0))
    tf_mr = tb_mcp_r.text_frame
    tf_mr.word_wrap = True

    p = tf_mr.paragraphs[0]
    p.text = "Explanatory Reading Script — Why MCP is Revolutionary for Property SIM:"
    p.font.size = Pt(13)
    p.font.bold = True
    p.font.color.rgb = ACCENT_TEAL
    p.space_after = Pt(8)

    mcp_points = [
        ("• Open Industry Standard (JSON-RPC 2.0):", "Model Context Protocol bridges AI LLMs (Claude, Gemini, Ollama) directly to the operational database via standardized tool calling."),
        ("• Strictly Read-Only Operations:", "All exposed MCP tools (`get_occupancy_rates`, `get_financial_summary`, `get_maintenance_backlog`) are strictly read-only aggregations. The AI cannot execute data mutations, updates, or deletes. All critical business decisions remain firmly human-in-the-loop."),
        ("• Grounded Data (Zero Hallucination):", "Rather than guessing or generalizing, the LLM analyzes user prompts, issues precise parameterized tool calls to the backend, receives exact numeric JSON data, and formulates clear executive summaries."),
        ("• Automated Tenant Boundary Enforcement:", "The MCP server enforces strict building security scoping; owners can query portfolio-wide data, while property managers can only access analytics for their assigned building."),
        ("• Instant Executive Insight:", "Property owners can ask in plain natural language: 'Which building had the highest occupancy this month?' or 'How much unpaid rent is outstanding?' without navigating dozens of manual dashboard menus.")
    ]
    for title, desc in mcp_points:
        p = tf_mr.add_paragraph()
        p.text = f"{title} "
        p.font.size = Pt(11)
        p.font.bold = True
        p.font.color.rgb = TEXT_MAIN
        p_run = p.add_run()
        p_run.text = desc
        p_run.font.bold = False
        p_run.font.color.rgb = TEXT_MUTED
        p.space_after = Pt(5)

    # =========================================================================
    # SLIDE 8: Frontend Architecture & Multi-Role User Interface
    # =========================================================================
    s8 = prs.slides.add_slide(blank_layout)
    set_slide_background(s8, OFF_WHITE)
    add_header(s8, "Frontend Engineering & Design System", "Flutter Web with Clean Architecture & Tailored Role-Based Portals",
               "Separating business logic from the UI layer while providing dedicated workspaces for Owners, Admins, and Tenants.")

    # 3 mockup cards side-by-side
    owner_mockup = os.path.join(base_dir, "PA/docs/System design/07-Mockup-UI/01_dasbor_pemilik_owner.png")
    admin_mockup = os.path.join(base_dir, "PA/docs/System design/07-Mockup-UI/02_dasbor_pengelola_admin.png")
    resident_mockup = os.path.join(base_dir, "PA/docs/System design/07-Mockup-UI/03_portal_penghuni_resident.png")

    m_w = Inches(3.7)
    m_h = Inches(3.3)

    # Mockup 1: Owner
    add_card(s8, Inches(0.8), Inches(1.6), m_w, m_h)
    tb_m1 = s8.shapes.add_textbox(Inches(0.9), Inches(1.65), Inches(3.5), Inches(0.3))
    p = tb_m1.text_frame.paragraphs[0]
    p.text = "1. Owner Dashboard (Multi-Building)"
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = ACCENT_BLUE
    if os.path.exists(owner_mockup):
        s8.shapes.add_picture(owner_mockup, Inches(0.95), Inches(2.0), width=Inches(3.4))

    # Mockup 2: Admin
    add_card(s8, Inches(4.8), Inches(1.6), m_w, m_h)
    tb_m2 = s8.shapes.add_textbox(Inches(4.9), Inches(1.65), Inches(3.5), Inches(0.3))
    p = tb_m2.text_frame.paragraphs[0]
    p.text = "2. Admin Dashboard (Operations)"
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = ACCENT_TEAL
    if os.path.exists(admin_mockup):
        s8.shapes.add_picture(admin_mockup, Inches(4.95), Inches(2.0), width=Inches(3.4))

    # Mockup 3: Resident
    add_card(s8, Inches(8.8), Inches(1.6), m_w, m_h)
    tb_m3 = s8.shapes.add_textbox(Inches(8.9), Inches(1.65), Inches(3.5), Inches(0.3))
    p = tb_m3.text_frame.paragraphs[0]
    p.text = "3. Resident Self-Service Portal"
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = ACCENT_AMBER
    if os.path.exists(resident_mockup):
        s8.shapes.add_picture(resident_mockup, Inches(8.95), Inches(2.0), width=Inches(3.4))

    # Explanatory card underneath
    add_card(s8, Inches(0.8), Inches(5.05), Inches(11.7), Inches(2.1))
    tb_fe_notes = s8.shapes.add_textbox(Inches(0.95), Inches(5.1), Inches(11.4), Inches(2.0))
    tf_fn = tb_fe_notes.text_frame
    tf_fn.word_wrap = True

    p = tf_fn.paragraphs[0]
    p.text = "Explanatory Reading Script — Clean Architecture & Portal Implementation:"
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = ACCENT_BLUE
    p.space_after = Pt(2)

    fe_points = [
        ("• Unidirectional Data Flow via BLoC:", "Presentation layer (Widgets) dispatches events to BLoC/Cubit, which calls pure Dart Use Cases in the Domain Layer. States are emitted immutably, ensuring millisecond unit-testability without UI dependencies."),
        ("• Strict Layer Decoupling:", "The Domain layer has zero dependencies on Flutter UI or third-party packages. If API formats or backends change, only the Data Layer (Dio Remote Data Source / DTOs) is modified."),
        ("• Cross-Platform Readiness:", "While tested and verified primarily on Flutter Web (desktop and tablet layouts), the core business rules and state machines are 100% reusable when deploying to native iOS and Android apps in the future."),
        ("• Role-Tailored UX:", "Owner portal provides portfolio cash flows and dynamic role builder; Admin portal streamlines daily check-ins, tickets, and expenses; Resident portal empowers self-service booking, digital payments, and damage reports.")
    ]
    for title, desc in fe_points:
        p = tf_fn.add_paragraph()
        p.text = f"{title} "
        p.font.size = Pt(10.5)
        p.font.bold = True
        p.font.color.rgb = TEXT_MAIN
        p_run = p.add_run()
        p_run.text = desc
        p_run.font.bold = False
        p_run.font.color.rgb = TEXT_MUTED
        p.space_after = Pt(2)

    # =========================================================================
    # SLIDE 9: System Features Matrix (Core vs Optional Plug & Play)
    # =========================================================================
    s9 = prs.slides.add_slide(blank_layout)
    set_slide_background(s9, OFF_WHITE)
    add_header(s9, "Feature Specifications & Scope", "New System Feature Matrix: 7 Core, 9 Optional, and 1 AI Analytical Feature",
               "Official specifications ratified in ADR-008 & ADR-009, enabling modular customization across property types.")

    # 2 Column cards: Core on Left, Optional & AI on Right
    add_card(s9, Inches(0.8), Inches(1.7), Inches(5.6), Inches(5.3))
    tb_f_core = s9.shapes.add_textbox(Inches(1.0), Inches(1.85), Inches(5.2), Inches(5.0))
    tf_fc = tb_f_core.text_frame
    tf_fc.word_wrap = True

    p = tf_fc.paragraphs[0]
    p.text = "Core Features (Mandatory Active in All Properties)"
    p.font.size = Pt(15)
    p.font.bold = True
    p.font.color.rgb = ACCENT_BLUE
    p.space_after = Pt(8)

    core_features = [
        ("F01: User Auth & Profile", "User registration, Keycloak token session handling, user identity & emergency contacts."),
        ("F02: Dynamic RBAC & Role Builder", "Granular modular permission sets + custom role creation via visual checkboxes without code changes."),
        ("F03: Multi-Building Management", "Multi-property master data (locations, contacts, active module toggles per building)."),
        ("F04: Building Policy Configuration", "Per-building rules: minimum rental stay (`min_rental_months`), DP policies, expiry hours, and grace periods."),
        ("F05: Master Room & Physical Capacity", "Room catalog, pricing, maximum tenant capacity (beds/people), and physical status."),
        ("F06: Occupancy Allocation & Schedule", "Dynamic member placement, anti-collision scheduling, and lifecycle tracking (`upcoming` -> `active` -> `completed`)."),
        ("F07: Occupancy Monitoring Dashboard", "Real-time room layout visualization and building occupancy rate statistics.")
    ]
    for code, desc in core_features:
        p = tf_fc.add_paragraph()
        p.text = f"• {code}: "
        p.font.size = Pt(11)
        p.font.bold = True
        p.font.color.rgb = TEXT_MAIN
        p_run = p.add_run()
        p_run.text = desc
        p_run.font.bold = False
        p_run.font.color.rgb = TEXT_MUTED
        p.space_after = Pt(4)

    # Right Card: Optional & AI
    add_card(s9, Inches(6.7), Inches(1.7), Inches(5.8), Inches(5.3))
    tb_f_opt = s9.shapes.add_textbox(Inches(6.9), Inches(1.85), Inches(5.4), Inches(5.0))
    tf_fo = tb_f_opt.text_frame
    tf_fo.word_wrap = True

    p = tf_fo.paragraphs[0]
    p.text = "Optional Plug & Play Features & AI Extension"
    p.font.size = Pt(15)
    p.font.bold = True
    p.font.color.rgb = ACCENT_TEAL
    p.space_after = Pt(8)

    opt_features = [
        ("F08: Two-Phase Invoicing & DP", "Automated recurring billing + DP Phase 1 (booking) & Phase 2 (settlement) without installment tables."),
        ("F09: Digital Payments & Semi-Manual Refund", "Midtrans SNAP (VA/QRIS) + automated webhook settlement + verified transfer refund requests."),
        ("F10: Flat Overdue Fines", "Automated flat penalty applied after invoice due date and grace period expire."),
        ("F11: Operational Expenses", "Tracking real operational cash outflows (PLN, PAM, WiFi, repairs) with receipt uploads."),
        ("F12 & F13: Maintenance & Preventive Schedules", "Photo damage tickets, technician dispatch, and calendar-based routine service reminders."),
        ("F14: Asset Inventory & Checklist Audit", "Room furniture cataloging and check-in/check-out condition verification."),
        ("F15: Guest Log & Curfew Tracking", "Digital visitor log with optional overnight surcharge billing."),
        ("F16: Automated WhatsApp Notifications", "Instant automated billing, reminder, and payment receipts via WhatsApp gateway."),
        ("F17: AI Analytical Assistant (MCP)", "Natural language operational queries powered by read-only Model Context Protocol.")
    ]
    for code, desc in opt_features:
        p = tf_fo.add_paragraph()
        p.text = f"• {code}: "
        p.font.size = Pt(10.5)
        p.font.bold = True
        p.font.color.rgb = TEXT_MAIN
        p_run = p.add_run()
        p_run.text = desc
        p_run.font.bold = False
        p_run.font.color.rgb = TEXT_MUTED
        p.space_after = Pt(3)

    # =========================================================================
    # SLIDE 10: Empirical Testing & Module Independence Validation
    # =========================================================================
    s10 = prs.slides.add_slide(blank_layout)
    set_slide_background(s10, OFF_WHITE)
    add_header(s10, "Empirical Validation & Testing", "Module Independence Testing: 100% Pass Rate Across 4 Real-World Scenarios",
               "Proving zero cascading failures when business modules are dynamically toggled off.")

    # 4 Scenarios Cards (2x2 Grid)
    scenarios = [
        ("Scenario A: Full Commercial Boarding House", "All Modules Active (Core + Finance + Maintenance + Inventory + Guest + Notification)", 
         "100% Pass Rate. Full end-to-end automation of two-phase invoicing, Midtrans payment callbacks, WhatsApp receipts, and maintenance tickets executed flawlessly.", ACCENT_BLUE),
        ("Scenario B: Free Staff Mess / Subsidized Student Dorm", "Finance & Notification Modules Disabled (Billing OFF)", 
         "100% Pass Rate. Tenant allocations and room bookings confirmed immediately without generating invoices or payment gateway requests. Zero database foreign key errors.", ACCENT_TEAL),
        ("Scenario C: Minimal Remote Rental Property", "Maintenance, Inventory, and Guest Modules Disabled", 
         "100% Pass Rate. System operates purely on automated lease management and digital payments. UI cleanly hides operational menus with no backend query crashes.", ACCENT_AMBER),
        ("Scenario D: Barebone Master Room & Allocation Core", "All Optional Modules Disabled (Core Modules Only)", 
         "100% Pass Rate. Operates strictly as a room inventory and resident allocation system. Validates that the core foundation stands entirely independent of optional business tiers.", RGBColor(100, 116, 139))
    ]

    coords = [
        (Inches(0.8), Inches(1.7)),
        (Inches(6.8), Inches(1.7)),
        (Inches(0.8), Inches(4.2)),
        (Inches(6.8), Inches(4.2))
    ]

    for i, (title, active_info, result, color) in enumerate(scenarios):
        left, top = coords[i]
        add_card(s10, left, top, Inches(5.7), Inches(2.3))
        tb_sc = s10.shapes.add_textbox(left + Inches(0.15), top + Inches(0.12), Inches(5.4), Inches(2.05))
        tf_sc = tb_sc.text_frame
        tf_sc.word_wrap = True

        p = tf_sc.paragraphs[0]
        p.text = title
        p.font.size = Pt(13)
        p.font.bold = True
        p.font.color.rgb = color
        p.space_after = Pt(2)

        p = tf_sc.add_paragraph()
        p.text = active_info
        p.font.size = Pt(10.5)
        p.font.bold = True
        p.font.color.rgb = TEXT_MAIN
        p.space_after = Pt(4)

        p = tf_sc.add_paragraph()
        p.text = f"Result: {result}"
        p.font.size = Pt(10.5)
        p.font.color.rgb = TEXT_MUTED

    # Bottom summary banner
    add_card(s10, Inches(0.8), Inches(6.65), Inches(11.7), Inches(0.65), bg_color=TAG_BG_BLUE, border_color=ACCENT_BLUE)
    tb_b = s10.shapes.add_textbox(Inches(1.0), Inches(6.67), Inches(11.3), Inches(0.6))
    p_b = tb_b.text_frame.paragraphs[0]
    p_b.text = "Testing Verdict: Proves that strict modular encapsulation (NestJS IoC + zero cross-module physical FKs) guarantees true plug-and-play flexibility."
    p_b.font.size = Pt(11)
    p_b.font.bold = True
    p_b.font.color.rgb = ACCENT_BLUE

    # =========================================================================
    # SLIDE 11: Conclusion, Impact & Future Roadmap
    # =========================================================================
    s11 = prs.slides.add_slide(blank_layout)
    set_slide_background(s11, OFF_WHITE)
    add_header(s11, "Project Synthesis & Future Directions", "Conclusion: Resolving Legacy Gaps and Delivering an Enterprise-Ready System",
               "Delivering high maintainability, enterprise security, and multi-property operational scalability.")

    # 3 Cards
    c_w = Inches(3.7)
    c_h = Inches(5.2)

    # Card 1: Core Contributions
    add_card(s11, Inches(0.8), Inches(1.7), c_w, c_h)
    tb_c1 = s11.shapes.add_textbox(Inches(0.95), Inches(1.85), Inches(3.4), Inches(4.9))
    tf_c1 = tb_c1.text_frame
    tf_c1.word_wrap = True
    p = tf_c1.paragraphs[0]
    p.text = "Key Contributions"
    p.font.size = Pt(15)
    p.font.bold = True
    p.font.color.rgb = ACCENT_BLUE
    p.space_after = Pt(8)

    pts_c1 = [
        "Unification of 4 Proposals: Synthesized 4 fragmented student projects into a cohesive, high-performance architecture.",
        "True Modular Monolith: Eradicated pseudo-modularity using NestJS encapsulation, Event Bus, and zero cross-module physical FKs.",
        "Multi-Tenancy Row-Level Scoping: Enabled centralized management of multiple buildings from a single deployment.",
        "Production-Grade Security: Enterprise Keycloak SSO with stateless JWKS verification + dynamic role permission builder."
    ]
    for pt in pts_c1:
        p = tf_c1.add_paragraph()
        p.text = f"• {pt}"
        p.font.size = Pt(11)
        p.font.color.rgb = TEXT_MAIN
        p.space_after = Pt(6)

    # Card 2: Operational Impact
    add_card(s11, Inches(4.8), Inches(1.7), c_w, c_h)
    tb_c2 = s11.shapes.add_textbox(Inches(4.95), Inches(1.85), Inches(3.4), Inches(4.9))
    tf_c2 = tb_c2.text_frame
    tf_c2.word_wrap = True
    p = tf_c2.paragraphs[0]
    p.text = "Operational Impact"
    p.font.size = Pt(15)
    p.font.bold = True
    p.font.color.rgb = ACCENT_TEAL
    p.space_after = Pt(8)

    pts_c2 = [
        "Zero Double-Booking: Guaranteed booking safety through PostgreSQL pessimistic row locking (`FOR UPDATE`).",
        "Streamlined Accounting: Two-Phase Invoicing and Midtrans SNAP webhook automation reduce manual reconciliation by 95%.",
        "AI Decision Support: Read-only Model Context Protocol (MCP) provides instant natural language KPI reporting without hallucinations.",
        "Deployment Agility: Fully containerized with Docker & Docker Compose for rapid on-premise or cloud hosting."
    ]
    for pt in pts_c2:
        p = tf_c2.add_paragraph()
        p.text = f"• {pt}"
        p.font.size = Pt(11)
        p.font.color.rgb = TEXT_MAIN
        p.space_after = Pt(6)

    # Card 3: Future Roadmap
    add_card(s11, Inches(8.8), Inches(1.7), c_w, c_h)
    tb_c3 = s11.shapes.add_textbox(Inches(8.95), Inches(1.85), Inches(3.4), Inches(4.9))
    tf_c3 = tb_c3.text_frame
    tf_c3.word_wrap = True
    p = tf_c3.paragraphs[0]
    p.text = "Future Roadmap"
    p.font.size = Pt(15)
    p.font.bold = True
    p.font.color.rgb = ACCENT_AMBER
    p.space_after = Pt(8)

    pts_c3 = [
        "Mobile Compilation: Compile Flutter Clean Architecture codebase to native iOS and Android apps with zero domain rewrite.",
        "IoT Smart Lock Integration: Synchronize lease start/end dates with smart door locks and electricity relay switches.",
        "Predictive Maintenance: Utilize historical damage ticket logs to forecast preventative maintenance cycles via machine learning.",
        "Self-Service Tenant Onboarding: Digital e-KYC KTP scanning and optical character recognition for automated profile verification."
    ]
    for pt in pts_c3:
        p = tf_c3.add_paragraph()
        p.text = f"• {pt}"
        p.font.size = Pt(11)
        p.font.color.rgb = TEXT_MAIN
        p.space_after = Pt(6)

    # =========================================================================
    # SLIDE 12: Q&A & Closing (Dark Theme)
    # =========================================================================
    s12 = prs.slides.add_slide(blank_layout)
    set_slide_background(s12, DARK_BG)

    tb_end = s12.shapes.add_textbox(Inches(1.5), Inches(2.2), Inches(10.333), Inches(3.5))
    tf_end = tb_end.text_frame
    tf_end.word_wrap = True

    p = tf_end.paragraphs[0]
    p.text = "THANK YOU"
    p.font.size = Pt(44)
    p.font.bold = True
    p.font.color.rgb = WHITE
    p.alignment = PP_ALIGN.CENTER
    p.space_after = Pt(12)

    p = tf_end.add_paragraph()
    p.text = "Questions & Answers (Q&A)"
    p.font.size = Pt(22)
    p.font.bold = True
    p.font.color.rgb = RGBColor(56, 189, 248)
    p.alignment = PP_ALIGN.CENTER
    p.space_after = Pt(24)

    p = tf_end.add_paragraph()
    p.text = "Bagus Alfian (NRP: 3123500031)\nProgram Studi Sarjana Terapan Teknik Informatika\nPoliteknik Elektronika Negeri Surabaya (PENS) — 2026"
    p.font.size = Pt(14)
    p.font.color.rgb = RGBColor(203, 213, 225)
    p.alignment = PP_ALIGN.CENTER

    out_path = os.path.join(base_dir, "Presentation_PA_Bagus_Alfian.pptx")
    prs.save(out_path)
    print(f"Presentation successfully saved to: {out_path}")

if __name__ == "__main__":
    build_presentation()
