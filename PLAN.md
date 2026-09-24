# QR Code Generator - Project Plan

## Overview

A web application for generating beautiful, customized QR codes targeted at individuals who need QR codes for their designs and creative projects. The core philosophy is simple: QR codes should be easy to create, look great, and be genuinely useful without complexity.

**Target User**: Parents, small business owners, event organizers, content creators - anyone who needs a QR code that looks good in their designs, not just a functional black-and-white square.

**App Name**: GlowQR - Evokes visual appeal, works with Disco Ball theme

---

## Business Model

### Positioning
- **Easy to use**: No learning curve, generate in under 30 seconds
- **Beautiful templates**: 10 unique styles, not just standard square codes
- **No signup required**: Free tier available without account creation
- **Pay for extras only**: Core functionality is free, pay only for premium features

### Competitive Differentiation
- Unlike QRCode Monkey (utilitarian, complex)
- Unlike Canva's built-in tool (limited templates, basic styling)
- Unlike enterprise tools (too complex for individuals)

**Value Proposition**: Get a beautiful QR code in 30 seconds. No signup. No complexity. Just pick a style, paste your link, download.

---

## Features

### Free Tier (Core Features)
- Generate unlimited QR codes with 10 templates
- No account required to generate
- PNG download at high resolution
- Basic color customization
- Optional: Save QR codes to account (requires signup)

### Premium Features (Pay-Per-QR)
| Feature | Price | Description |
|---------|-------|-------------|
| Logo in QR | $2.50 | Embed your logo/image in the QR code |
| Analytics (90 days) | $1.50 | Track how many times the QR code was scanned |
| Dynamic QR | $3.00 | Change the destination URL anytime without reprinting |

---

## Templates (10 Total)

### Shape-Based Templates (4)
1. **Classic** - Standard square QR with clean edges (professional, formal)
2. **Rounded** - Soft rounded corners on all modules (friendly, approachable)
3. **Circle Frame** - Square QR clipped to circular frame (social media, designs)
4. **Diamond** - Square QR rotated 45° in diamond frame (creative, artistic)

### Standard/Useful Templates (5)
5. **Minimal Light** - Lots of white space with subtle border (flyers, print materials)
6. **Bold Black** - Thick modules with high contrast (maximum scannability)
7. **Dotted Mosaic** - Modules rendered as small circles/dots (modern, artistic)
8. **Gradient Pop** - Color gradient applied across modules (social media, digital)
9. **Gradient Fade** - Modules fade to transparent at edges (overlays, layered designs)

### Special Template (1)
10. **Disco Ball** - Unique circular design with decorative squares and sparkles (parties, dance events, celebrations)

---

## Technical Architecture

### Stack
| Component | Technology |
|-----------|------------|
| Framework | Ruby on Rails 8.1 |
| Database | SQLite3 |
| Styling | TailwindCSS |
| QR Generation | Server-side Ruby (rqrcode gem) |
| Payments | Stripe Checkout |
| Authentication | Built-in Rails authentication |
| File Storage | Fly.io volume or local (Fly.io handles persistence) |
| Hosting | Fly.io |

### QR Code Generation Approach
- Use the `rqrcode` gem for matrix generation
- Use `rqrcode_png` gem for PNG rendering (simpler than RMagick, no native deps)
- SVG rendering added in Phase 3+ (vector format for premium users)
- Custom Ruby code for template styling (based on disco_qr.rb script)
- Store generated images as files (PNG format)

### Database Schema

#### Users Table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_digest VARCHAR(255) NOT NULL,
  created_at DATETIME,
  updated_at DATETIME
);
```

#### QR Codes Table
```sql
CREATE TABLE qr_codes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER, -- NULL for anonymous users
  url VARCHAR(2048) NOT NULL,
  template INTEGER NOT NULL CHECK (template BETWEEN 1 AND 10),
  customizations JSON, -- colors, sizes, etc.
  short_code VARCHAR(20) UNIQUE NOT NULL,
  is_dynamic BOOLEAN DEFAULT FALSE,
  current_url VARCHAR(2048), -- for dynamic QR codes
  image_path VARCHAR(255), -- file path to generated PNG
  created_at DATETIME,
  updated_at DATETIME,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_qr_codes_short_code ON qr_codes(short_code);
CREATE INDEX idx_qr_codes_user_id ON qr_codes(user_id);
```

#### Purchases Table
```sql
CREATE TABLE purchases (
  id INTEGER PRIMARY KEY,
  qr_code_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  feature VARCHAR(50) NOT NULL CHECK (feature IN ('logo', 'analytics', 'dynamic')),
  stripe_payment_id VARCHAR(100),
  amount_cents INTEGER NOT NULL,
  created_at DATETIME,
  FOREIGN KEY (qr_code_id) REFERENCES qr_codes(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

#### QR Analytics Table
```sql
CREATE TABLE qr_analytics (
  id INTEGER PRIMARY KEY,
  qr_code_id INTEGER NOT NULL,
  scanned_at DATETIME NOT NULL,
  ip_address VARCHAR(45),
  user_agent TEXT,
  referrer VARCHAR(2048),
  FOREIGN KEY (qr_code_id) REFERENCES qr_codes(id)
);

CREATE INDEX idx_qr_analytics_qr_code_id ON qr_analytics(qr_code_id);
CREATE INDEX idx_qr_analytics_scanned_at ON qr_analytics(scanned_at);
```

---

## Application Pages

### Public Pages

#### 1. Landing Page (`/`)
**Purpose**: Convert visitors into users, showcase templates, quick generation

**Components**:
- Hero section with headline: "Beautiful QR codes in 30 seconds"
- Template gallery (4 templates functional, 6 show "coming soon" badge)
- Quick generate form: URL input + template selector
- CTA: "Generate for free" button
- Features list with icons
- Simple footer

**Behavior**:
- User enters URL, picks template, clicks generate
- Redirects to preview page with generated QR code
- Shows prompt: "Create account to save this QR code?"

**Phase 1 Template Slots**:
- Disco Ball (featured, first)
- Classic
- Rounded
- Circle Frame
- (6 additional slots show gray placeholder with "coming soon" label)

#### 2. Create/Generate Page (`/create`)
**Purpose**: Full customization interface

**Components**:
- URL input field
- Template selector (10 thumbnails, clickable)
- Live preview area
- Customization panel:
  - Color picker (foreground color)
  - Background color
  - Module size selector
  - Template-specific options
- Generate button
- Upgrade prompts ("Add logo", "Enable tracking", "Make dynamic")

#### 3. Preview/Download Page (`/preview/:short_code`)
**Purpose**: Show generated QR code, offer download, upsell features

**Components**:
- Large QR code display
- Download button: PNG (SVG available in Phase 3+ for premium users)
- QR code details (template used, created date)
- Upsell cards:
  - "Add your logo for $2.50" - Shows preview with logo
  - "Track scans for $1.50" - Shows analytics dashboard preview
  - "Change URL anytime for $3.00" - Explains dynamic benefit
- Share buttons (copy link, social)
- Save to account button (if not logged in)

#### 4. Redirect Handler (`/q/:short_code`)
**Purpose**: Handle QR code scans, track analytics, redirect to destination

**Behavior**:
1. Look up QR code by short_code
2. If analytics enabled: log scan data
3. If dynamic: redirect to current_url
4. If static: redirect to url

**Response Time**: <100ms (async analytics logging)

### Authenticated Pages

#### 5. Dashboard (`/dashboard`)
**Purpose**: User's saved QR codes, quick access to downloads

**Components**:
- Grid/list of saved QR codes
- Each card shows:
  - Thumbnail of QR code
  - Template name
  - Creation date
  - Scan count (if analytics enabled)
  - Quick actions: download, edit, delete
- Search/filter functionality
- "Create new" button

#### 6. Purchase/Checkout (`/purchases/new`)
**Purpose**: Stripe checkout for premium features

**Behavior**:
- Show what user is buying (logo/analytics/dynamic)
- Price display
- Stripe Checkout integration
- Success redirect back to preview page

#### 7. Analytics Dashboard (`/analytics/:short_code`)
**Purpose**: Simple scan statistics

**Components**:
- Total scans count (large number)
- Scans over time (simple line chart or bar chart)
- Scans by day/week/month selector
- Basic table: date, count
- Export to CSV option

---

## UI/UX Design Principles

### Design System (TailwindCSS)

#### Colors
- **Primary**: `#1a1a1a` (near-black for text, borders)
- **Secondary**: `#4a4a4a` (secondary text)
- **Accent**: `#3b82f6` (buttons, links, interactive elements)
- **Background**: `#ffffff` (white)
- **Surface**: `#f8f8f8` (cards, sections)
- **Border**: `#e5e5e5` (light borders)

#### Typography
- **Headings**: Inter or system sans-serif, bold weight
- **Body**: Inter or system sans-serif, regular weight
- **Sizes**: 
  - Hero: 3xl (mobile) → 5xl (desktop)
  - H1: 2xl → 4xl
  - H2: xl → 2xl
  - Body: base (16px)
  - Small: sm (14px)

#### Spacing
- Container max-width: 1200px
- Section padding: py-12 (48px) → py-20 (80px) on desktop
- Card padding: p-6 (24px)
- Element gaps: gap-4 (16px) → gap-8 (32px)

#### Components
- **Buttons**: 
  - Primary: bg-accent, text-white, rounded-lg, px-6 py-3
  - Secondary: border border-gray-300, bg-white, rounded-lg
  - Hover states with transition
  
- **Cards**: 
  - bg-white, rounded-xl, shadow-sm, border border-gray-100
  - Hover: shadow-md transition

- **Inputs**:
  - border border-gray-300, rounded-lg, px-4 py-3
  - Focus: ring-2 ring-accent/50, border-accent

- **Template Selectors**:
  - Thumbnail cards (3-4 per row on desktop)
  - Selected state: ring-2 ring-accent
  - Hover: shadow transition

### Mobile-First Approach
- Single column layouts on mobile
- Template selector becomes horizontal scroll on mobile
- Sticky header with hamburger menu
- Touch-friendly button sizes (min 44px)
- Preview page: QR code takes full width

### Accessibility
- WCAG 2.1 AA compliant
- Proper heading hierarchy
- Alt text on all images
- Keyboard navigation support
- Color contrast ratios met
- Focus visible states

---

## QR Code Generation Logic

### Generation Flow
1. Receive URL, template ID, customizations
2. Generate QR matrix using rqrcode gem (level: :h for error correction)
3. Apply template styling logic
4. Render to PNG using RMagick/ChunkyPNG or similar
5. Save file to storage
6. Return file path and short code

### Template Implementation

Each template is a Ruby class/module that transforms the QR matrix:

```ruby
class QrTemplate
  def initialize(matrix, options = {})
    @matrix = matrix
    @options = options
  end
  
  def render_svg
    # Template-specific rendering logic
  end
end

class TemplateClassic < QrTemplate
  # Standard square rendering
end

class TemplateRounded < QrTemplate
  # Rounded rect modules
end

class TemplateCircleFrame < QrTemplate
  # Square QR clipped to circle
end

# ... etc
```

### Short Code Generation
- Use 6-character alphanumeric codes (base62)
- Example: `abc123`, `xyz789`
- Collision-resistant generation
- Format: `/q/:short_code` for redirects

---

## Monetization Implementation

### Stripe Integration
- One-time payments only (no subscriptions for simplicity)
- Stripe Checkout for secure payment flow
- Webhook handling for payment confirmation
- Store purchase record on success

### Purchase Flow
1. User clicks "Add logo" (or analytics/dynamic)
2. Create pending purchase record
3. Redirect to Stripe Checkout
4. On success: Stripe webhook marks purchase complete
5. Redirect user back to QR preview page
6. Feature now enabled

### Feature Enabling
- Logo: Store logo file, re-generate QR with logo embedded
- Analytics: Set `analytics_enabled` flag on QR code
- Dynamic: Set `is_dynamic` flag, allow URL changes

---

## Deployment & Infrastructure

### Fly.io Setup
- App name: `glowqr`
- Region: Closest to target audience (start with one region)
- SQLite: Use Fly.io volume for persistence
- File storage: Fly.io volume for QR code images
- CDN: Use Fly.io's built-in or Cloudflare

### Environment Variables
```bash
RAILS_MASTER_KEY=xxx
STRIPE_PUBLISHABLE_KEY=pk_xxx
STRIPE_SECRET_KEY=sk_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
DATABASE_URL=sqlite3:///data/production.sqlite3
```

### Database Migrations
Run on deploy:
```bash
rails db:migrate
```

### File Storage Structure
```
/storage/qr_codes/
  ├── abc123.png
  ├── abc123.svg (optional)
  └── ...
```

---

## Analytics & Tracking

### What to Track
- Scan timestamp
- IP address (anonymized for privacy)
- User agent (device/browser)
- Referrer (where scan came from)

### Privacy
- GDPR compliant
- No personal data stored
- IP addresses anonymized (last octet removed)
- Analytics data auto-deleted after 90 days

### Dashboard Metrics
- Total scans (all time)
- Scans today
- Scans this week
- Scans this month
- Simple line chart: scans per day over last 30 days

---

## Implementation Phases

### Phase 1: Working Generator (Days 1-2)
**Goal**: Get a QR generator live, no auth, no payments

**Tasks**:
- [ ] Rails 8.1 app setup with TailwindCSS
- [ ] Minimal database setup (qr_codes table only, no users yet)
- [ ] QR generation service (rqrcode gem + rqrcode_png)
- [ ] Templates 1-3: Classic, Rounded, Circle Frame
- [ ] Template 10: Disco Ball (our differentiator - leads the gallery)
- [ ] Landing page + Generate page (single page flow)
- [ ] Preview/Download page with PNG export
- [ ] Fly.io deployment

**Deliverable**: `glowqr.app` live - user enters URL, picks template, downloads QR in <30 seconds

**Persistence**: Anonymous QR codes stored in DB with shareable short code. Users bookmark the preview link - no account needed.

---

### Phase 2: Auth + Save (Days 3-4)
**Goal**: Users can save and manage their QR codes

**Tasks**:
- [ ] User authentication (Rails built-in)
- [ ] Database setup (users, qr_codes tables)
- [ ] Link "Save to account" on preview page
- [ ] Dashboard with saved QR codes
- [ ] Re-download saved QR codes

**Deliverable**: Users can create account, save QR codes, access from dashboard

---

### Phase 3: All Templates (Day 5)
**Goal**: Complete the template set

**Tasks**:
- [ ] Templates 4-9 implementation
- [ ] Template preview images for gallery
- [ ] Color customization (foreground + background)
- [ ] Template selector UI polish

**Deliverable**: All 10 templates working with color options

---

### Phase 4: Payments (Days 6-7)
**Goal**: Stripe integration, premium features

**Tasks**:
- [ ] Stripe account setup + webhooks
- [ ] Logo embedding feature ($2.50)
- [ ] Stripe Checkout integration
- [ ] Purchase records
- [ ] Logo upload functionality
- [ ] Re-generation with logo

**Deliverable**: Logo feature live, accepting payments

---

### Phase 5: Analytics + Dynamic (Days 8-10)
**Goal**: Complete premium feature set

**Tasks**:
- [ ] Redirect handler (`/q/:short_code`)
- [ ] Scan tracking (simplified: just count)
- [ ] Analytics dashboard (total scans, daily chart)
- [ ] Dynamic QR ($3.00) - change URL anytime
- [ ] Analytics feature ($1.50) - 90-day history

**Deliverable**: All premium features live

---

### Phase 6: Polish & Launch (Days 11-14)
**Goal**: Production-ready, launch

**Tasks**:
- [ ] Mobile responsiveness testing
- [ ] Performance optimization
- [ ] Security audit
- [ ] SSL/HTTPS setup
- [ ] Custom domain
- [ ] Help/docs page
- [ ] Launch announcement

**Deliverable**: Live production app at custom domain

---

## Success Metrics

### Phase 1 Milestone (Day 2)
- QR generator works end-to-end
- At least 3 templates functional (including Disco Ball)
- User can download PNG
- Live on Fly.io

### Phase 2 Milestone (Day 4)
- Users can create account
- Saved QR codes persist
- Dashboard shows saved codes

### Phase 3 Milestone (Day 5)
- All 10 templates working
- Color customization functional

### Phase 4 Milestone (Day 7)
- Logo embedding works
- First dollar earned (🎉)

### Phase 5 Milestone (Day 10)
- All premium features live

### Launch Metrics
- Time to first QR < 30 seconds
- QR generation < 1 second
- Uptime > 99.9%
- Page load < 2 seconds

---

## Future Enhancements (Post-Launch)

- Bulk QR code generation (CSV upload)
- API access for developers
- More QR code types (WiFi, vCard, email, SMS)
- Custom template creation
- Team/organization accounts
- White-label option
- Mobile app (PWA)
- Template marketplace (user-created templates)

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| QR codes don't scan reliably | Thorough testing across devices, use high error correction |
| Stripe complexity | Use Stripe Checkout (hosted), not Elements |
| File storage costs on Fly.io | Monitor usage, compress images, implement cleanup |
| Database growth | Analytics auto-delete after 90 days, QR codes soft-delete |
| Template rendering performance | Cache generated images, pre-generate previews |
| User confusion about dynamic QR | Clear explanations, tooltips, examples |

---

## Notes

- Keep it simple. Resist feature creep.
- Focus on the core use case: beautiful QR codes quickly.
- **Lead with Disco Ball** - it's the unique differentiator, put it first in the template gallery.
- Test QR code scannability across iOS and Android before launch.
- Anonymous users get a shareable preview link - no auth required for generation.
- SEO: Landing page should rank for "beautiful qr code generator".
- **Image gem**: Use `rqrcode_png` (no native dependencies, simpler than RMagick)
- **SVG format**: Add in Phase 3 as premium feature

---

## Appendix: QR Code Technical Details

### Error Correction Levels
Using `:h` (high) for all QR codes to ensure scannability even with:
- Logo overlays
- Color variations
- Slight damage/wear

### Module Size
Default: 8px per module
Recommended minimum QR size: 2cm x 2cm for reliable scanning

### Supported Formats
- PNG (primary, raster, good for web/print)
- SVG (optional, vector, scalable)

### Quiet Zone
Maintain 4-module quiet zone (white space) around all QR codes for scannability.

---

*Plan version 2.2 - App name: GlowQR*
