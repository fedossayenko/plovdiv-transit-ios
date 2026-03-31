# iOS 26 Technology Status (March 2026)

## Reality Check vs Document Claims

### 1. Liquid Glass - SHIPPING
- `.glassEffect()` modifier, `GlassEffectContainer`, `.interactive()` — all real APIs
- `.buttonStyle(.glass)` and `.buttonStyle(.glassProminent)`
- Morphing transitions built-in
- **Rules:** Glass on navigation layer ONLY, never on content, never stack glass on glass
- Respect `Reduce Transparency` (automatic), use `#available(iOS 26, *)` with `.ultraThinMaterial` fallback
- WWDC session 323

### 2. Foundation Models - SHIPPING
- `SystemLanguageModel` — ~3B param on-device LLM, zero inference cost
- Guided Generation → typed Swift structs directly
- `@Tool` annotated functions for tool calling
- **Requires:** A17 Pro+ or M1+, Apple Intelligence enabled
- 15 languages, offline, built-in content filtering
- WWDC sessions 286, 301

### 3. Preferred Routes API - NOT A PUBLIC API
- **Document claim is WRONG** — no `MKMapItem.preferredRoutes` developer API exists
- It's a user-facing Apple Maps feature only
- Cannot be used programmatically by third-party apps
- **Mitigation:** Implement our own frequent route learning locally

### 4. Swift 6 Strict Concurrency - SHIPPING (with pivot)
- Swift 6.2 "Approachable Concurrency" changed the model:
  - `@MainActor` is now **default isolation** (via build flag)
  - `@concurrent` for explicit parallelism opt-in
  - Async functions run in caller's context by default
- Most teams still in gradual migration
- Apple validated: 40% perf improvement in Password Monitoring Service

### 5. Live Activities - SHIPPING (incremental)
- CarPlay support added in iOS 26
- Wallet integration for boarding passes
- Liquid Glass visual treatment
- **No** Smart Stacks, **no** Apple Watch expansion
- No major new ActivityKit APIs — same patterns as before

### 6. Express Transit / PassKit - PARTIALLY AVAILABLE
- Express Transit is **user-managed** — cannot activate programmatically
- **New:** `PKPassLibrary` API for auto-adding passes after one-time authorization
- Multi-event ticket support (good for transit passes)
- NFC required for Express Mode
- WWDC session 202

### 7. Xcode Cloud - SHIPPING (stable, no major changes)
- 25 free hours/month, paid plans up to $3,999/mo
- GitHub, GitLab, Bitbucket only
- No significant new features since 2024
- Hours don't roll over

---

## Impact on Our Plan

| Document Claim | Reality | Action |
|---------------|---------|--------|
| Preferred Routes API for proactive notifications | Not a public API | Build our own frequent route detection |
| GTFS-RT with protobuf | livetransport.eu uses JSON/WebSocket | Much simpler - just parse JSON |
| Foundation Models NLP assistant | Real, but A17 Pro+ only | Feature-flag it, fallback to structured search |
| Express Transit tap-to-pay | User-controlled, not programmable | Focus on PassKit pass provisioning instead |
| Kalman filter for positioning | Valid approach, no iOS API for this | Must implement ourselves in LocationCore |
| Liquid Glass everywhere | Real APIs, strict rules on usage | Follow glass-on-navigation-only rule |
| Swift 6 strict concurrency | Real but model changed in 6.2 | Use new @MainActor default + @concurrent |
