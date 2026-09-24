# GlowQR Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign GlowQR with dark/neon aesthetic, mobile-first layout, logo-only header, hero-first homepage, and QR-focus preview page.

**Architecture:** Single-page app feel with minimal navigation. Views use Tailwind CSS utility classes with custom color palette. Active Storage for QR image hosting.

**Tech Stack:** Rails 8.1, Tailwind CSS, Active Storage, ChunkyPNG for QR generation

---

## File Structure

- `app/views/layouts/application.html.erb` - Base layout with dark background
- `app/views/pages/home.html.erb` - Hero-first homepage with form
- `app/views/qr_codes/preview.html.erb` - QR focus preview page
- `app/assets/stylesheets/application.css` - Custom Tailwind config
- `app/views/shared/_logo.html.erb` - Shared logo partial (optional)

---

## Tasks

### Task 1: Update Application Layout with Dark Theme

**Files:**
- Modify: `app/views/layouts/application.html.erb`
- Modify: `app/assets/stylesheets/application.css`

- [ ] **Step 1: Update application layout with dark background**

Replace the entire `app/views/layouts/application.html.erb`:

```erb
<!DOCTYPE html>
<html class="h-full">
  <head>
    <title><%= content_for(:title) || "GlowQR" %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="application-name" content="GlowQR">
    <meta name="mobile-web-app-capable" content="yes">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= yield :head %>

    <link rel="icon" href="/icon.png" type="image/png">
    <link rel="icon" href="/icon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="/icon.png">

    <%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body class="h-full bg-[#0a0a0f] text-white antialiased">
    <main class="min-h-screen flex flex-col items-center justify-center px-5 py-12">
      <%= yield %>
    </main>
  </body>
</html>
```

- [ ] **Step 2: Run tests to verify nothing broke**

```bash
cd /home/kevin/Projects/AISlop/qr_codes/.worktrees/phase1
bin/rails test
```

Expected: All tests pass

- [ ] **Step 3: Commit**

```bash
git add app/views/layouts/application.html.erb
git commit -m "feat: update layout with dark theme and centered content"
```

---

### Task 2: Redesign Homepage (Hero-First)

**Files:**
- Modify: `app/views/pages/home.html.erb`

- [ ] **Step 1: Rewrite homepage with dark/neon design**

Replace `app/views/pages/home.html.erb` with:

```erb
<div class="w-full max-w-md">
  <%# Logo %>
  <div class="text-center mb-8">
    <a href="/" class="text-[#ff00ff] text-sm font-medium hover:opacity-80 transition-opacity">
      ✨ GlowQR
    </a>
  </div>

  <%# Hero %>
  <div class="text-center mb-8">
    <h1 class="text-3xl font-bold text-white mb-2">
      QR codes in 30 seconds
    </h1>
    <p class="text-[#666666] text-sm">
      No signup. Just paste & go.
    </p>
  </div>

  <%# Form Card %>
  <div class="bg-[#1a1a24] border border-[#333333] rounded-xl p-6">
    <form action="/qr_codes" method="POST" class="flex flex-col gap-4">
      <%# URL Input %>
      <input
        type="url"
        name="url"
        placeholder="Paste your URL here..."
        required
        class="w-full bg-[#0f0f18] border border-[#333333] rounded-lg px-4 py-3 text-white placeholder-[#666666] focus:outline-none focus:border-[#ff00ff] transition-colors"
      />

      <%# Template Selector %>
      <div class="grid grid-cols-2 gap-3">
        <% @templates.each do |template| %>
          <label class="cursor-pointer group">
            <input type="radio" name="template" value="<%= template[:id] %>" class="sr-only peer" <%= template[:featured] ? "checked" : "" %> />
            <div class="border-2 border-[#333333] rounded-lg p-4 text-center transition-all peer-checked:border-[#ff00ff] peer-checked:shadow-[0_0_15px_rgba(255,0,255,0.3)] group-hover:border-[#555555]">
              <div class="text-3xl mb-2"><%= template[:emoji] %></div>
              <div class="text-xs font-medium text-[#888888]"><%= template[:name] %></div>
            </div>
          </label>
        <% end %>
      </div>

      <%# Submit Button %>
      <button
        type="submit"
        class="w-full bg-gradient-to-r from-[#ff00ff] to-[#ff6600] text-white font-semibold py-3 px-6 rounded-lg hover:opacity-90 transition-opacity"
      >
        Generate Free
      </button>
    </form>
  </div>
</div>
```

- [ ] **Step 2: Verify page renders**

Start dev server and check localhost renders correctly with dark theme.

- [ ] **Step 3: Commit**

```bash
git add app/views/pages/home.html.erb
git commit -m "feat: redesign homepage with dark neon theme"
```

---

### Task 3: Redesign Preview Page (QR Focus)

**Files:**
- Modify: `app/views/qr_codes/preview.html.erb`

- [ ] **Step 1: Rewrite preview page with QR focus design**

Replace `app/views/qr_codes/preview.html.erb` with:

```erb
<div class="w-full max-w-md">
  <%# Logo %>
  <div class="text-center mb-8">
    <a href="/" class="text-[#ff00ff] text-sm font-medium hover:opacity-80 transition-opacity">
      ✨ GlowQR
    </a>
  </div>

  <%# QR Code Display %>
  <div class="text-center mb-6">
    <div class="inline-block p-3 rounded-full border-4 border-[#ff00ff] shadow-[0_0_30px_rgba(255,0,255,0.5)] bg-white">
      <%= image_tag @qr_code.image,
                    alt: "QR Code",
                    class: "w-48 h-48 mx-auto rounded-full" %>
    </div>
  </div>

  <%# Template Name %>
  <p class="text-center text-[#666666] text-sm mb-6">
    <%= @qr_code.template_name %> template
  </p>

  <%# Download Button %>
  <%= link_to "Download PNG",
              @qr_code.image,
              download: "qr_#{@qr_code.short_code}.png",
              class: "block w-full text-center bg-gradient-to-r from-[#ff00ff] to-[#ff6600] text-white font-semibold py-3 px-6 rounded-lg hover:opacity-90 transition-opacity mb-4" %>

  <%# Share Link %>
  <div class="bg-[#1a1a24] border border-[#333333] rounded-lg p-3 flex gap-2">
    <input
      type="text"
      value="<%= request.original_url %>"
      readonly
      class="flex-1 bg-transparent text-[#888888] text-sm outline-none"
    />
    <button
      onclick="navigator.clipboard.writeText('<%= request.original_url %>'); this.textContent = 'Copied!'; setTimeout(() => this.textContent = 'Copy', 2000)"
      class="bg-[#ff00ff] text-white text-sm font-medium px-3 py-1 rounded hover:opacity-90 transition-opacity"
    >
      Copy
    </button>
  </div>

  <%# Create Another %>
  <div class="text-center mt-8">
    <%= link_to "Create another QR code", root_path, class: "text-[#444444] hover:text-[#666666] text-sm transition-colors" %>
  </div>
</div>
```

- [ ] **Step 2: Generate a test QR code and verify the page renders correctly**

```bash
curl -s -X POST http://localhost:3000/qr_codes -d "url=https://example.com&template=10"
```

Then visit the preview URL and verify:
- Dark background
- Neon magenta glow around QR
- Gradient download button
- Copy button works

- [ ] **Step 3: Commit**

```bash
git add app/views/qr_codes/preview.html.erb
git commit -m "feat: redesign preview page with QR focus layout"
```

---

### Task 4: Update Tailwind Config (if needed)

**Files:**
- Modify: `app/assets/builds/tailwind.css` (or wherever Tailwind config lives)

- [ ] **Step 1: Check if custom colors are needed**

If Tailwind v4/v3 with `@apply` directives, add custom color classes to support the hex colors used in views. Otherwise, the inline hex values work directly with Tailwind.

- [ ] **Step 2: Commit if changes made**

```bash
git add -A
git commit -m "chore: add custom color palette for dark theme"
```

---

### Task 5: Run Full Test Suite

**Files:**
- Test: All existing tests

- [ ] **Step 1: Run full test suite**

```bash
bin/rails test
```

Expected: All tests pass

- [ ] **Step 2: Commit final changes**

```bash
git add -A
git commit -m "feat: complete GlowQR dark theme redesign"
```

---

## Verification Checklist

After all tasks:
- [ ] Homepage loads with dark background (#0a0a0f)
- [ ] Logo "✨ GlowQR" in magenta
- [ ] URL input with dark styling
- [ ] Template cards with hover effects and selected glow
- [ ] Gradient "Generate Free" button
- [ ] Preview page shows QR with neon glow border
- [ ] Download button with gradient
- [ ] Copy link functionality works
- [ ] All tests pass
- [ ] Mobile view looks good (centered, appropriate sizing)

---

## Notes

- The design uses inline hex colors (`#0a0a0f`, `#ff00ff`, etc.) which Tailwind v4 supports directly
- QR images are served via Active Storage (already implemented)
- No backend changes needed - this is purely frontend redesign
- Consider adding favicon with glow effect in future iteration
