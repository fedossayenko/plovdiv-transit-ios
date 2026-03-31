# Plovdiv Transit iOS App - Development Plan

## Project Overview
Native iOS 26 public transit app for Plovdiv, Bulgaria. Real-time bus tracking, route planning, and smart transit assistance.

## Data Source Strategy

### Primary: LiveTransport.eu API (reusable NOW)
The existing livetransport.eu platform provides a complete, working API that we can consume directly:
- **REST**: `https://api.livetransport.eu/plovdiv/` - lines, stops, trips, virtual boards, brigades
- **WebSocket**: `wss://api.livetransport.eu/plovdiv` - real-time vehicle positions (~222 active buses)
- **Data**: 29 bus lines, 483 stops, bilingual (bg/en), GPS coords, delays, speed, bearing

This eliminates the need to build our own backend for MVP. The livetransport.eu API is community-built and free.

### Future: Modeshift/Official API
For production-grade app with ticketing, we'd need official Modeshift API access from the municipality.

### Future: GTFS/NeTEx
For EU NAP compliance and multimodal routing. Not needed for MVP.

---

## Architecture: SPM Modular Monolith

```
PlovdivTransitApp (entry point)
├── MapFeature          - MapKit map, vehicle rendering, stop markers
├── RoutePlannerFeature - Trip planning, directions
├── StopFeature         - Virtual departure boards
├── ScheduleFeature     - Line schedules, brigades
├── AssistantFeature    - Foundation Models NLP assistant
├── TicketingFeature    - (Phase 2) PassKit, Apple Wallet
│
├── TransitNetwork      - API client, WebSocket, data parsing
├── LocationCore        - CoreLocation + CoreMotion sensor fusion
├── PaymentEngine       - (Phase 2) cEMV integration
│
├── SharedUI            - Liquid Glass components, design tokens
├── CoreModels          - Transit data models (Vehicle, Stop, Line, Trip)
└── CoreExtensions      - Utilities, logger
```

---

## Phase 1: MVP (8-10 weeks)

### Sprint 1-2: Foundation (Weeks 1-4)
- [ ] Xcode project setup with SPM modular structure
- [ ] `CoreModels` package - Swift structs for Vehicle, Stop, Line, Trip
- [ ] `TransitNetwork` package
  - REST client for livetransport.eu API
  - WebSocket client for real-time vehicle positions
  - Array-indexed data parser (EVehicle2 format)
- [ ] `SharedUI` package - Liquid Glass design system
  - GlassEffectContainer for navigation elements
  - .glassEffect(.regular) for toolbars
  - .glassEffect(.clear) for map overlays
  - Accessibility: Reduce Transparency, Increase Contrast, Reduce Motion

### Sprint 3-4: Core Features (Weeks 5-8)
- [ ] `MapFeature` - Real-time bus map
  - MapKit with vehicle annotations
  - Vehicle interpolation (dead reckoning between 15-30s updates)
  - Stop markers from 483-stop dataset
  - Route polylines from trip shapes
- [ ] `StopFeature` - Virtual departure board
  - Uses `virtualBoard/{stopId}` endpoint
  - Live countdown timers
  - Delay indicators
- [ ] `LocationCore` - User positioning
  - CoreLocation + CoreMotion fusion
  - Kalman filter for urban canyon correction
  - Pedestrian dead reckoning

### Sprint 5: Polish & Launch Prep (Weeks 9-10)
- [ ] `ScheduleFeature` - Line schedules, brigade view
- [ ] Live Activities - Bus arrival countdown on Lock Screen / Dynamic Island
- [ ] Push notification support for delays
- [ ] Offline caching (stops, lines, schedules)
- [ ] TestFlight beta

---

## Phase 2: Intelligence & Payments (Weeks 11-18)

- [ ] `AssistantFeature` - On-device Foundation Models assistant
  - SystemLanguageModel for natural language queries
  - Tool calling: findRoute, getNearbyStops, getNextBus
  - Bulgarian + English language support
- [ ] `TicketingFeature` - Apple Wallet integration
  - PassKit transit pass provisioning
  - Express Transit Mode (tap-to-pay without unlock)
  - Unified Transport Document (when API available)
- [ ] Preferred Routes integration (proactive delay notifications)
- [ ] GTFS-Flex for demand-responsive transport zones

---

## Phase 3: Compliance & Scale (Weeks 19+)

- [ ] NeTEx integration via Bulgarian NAP
- [ ] National clearinghouse API for unified ticketing
- [ ] Multimodal routing (bus + rail)
- [ ] watchOS companion
- [ ] Progressive delivery via feature flags
- [ ] Full CI/CD pipeline with Xcode Cloud

---

## Key Technical Decisions

### Swift 6 Strict Concurrency
- All ViewModels: `@MainActor`
- Network/parsing: background actors
- WebSocket stream: `AsyncStream<[Vehicle]>`
- Zero data races guaranteed at compile time

### Sensor Fusion (Kalman Filter)
State vector: `[lat, lng, v_lat, v_lng]`
- **Predict**: CoreMotion at 100Hz (accelerometer + gyroscope)
- **Update**: CoreLocation at 1Hz (GPS)
- Dynamic Kalman gain based on GPS accuracy (`horizontalAccuracy`)
- Reject GPS jumps > 50m in Old Town areas

### Liquid Glass Rules
- Glass ONLY on navigation layer (tab bar, toolbar, FABs)
- NEVER on content layer (lists, cards, map tiles)
- NEVER stack glass on glass
- Group floating controls in GlassEffectContainer
- Respect Reduce Transparency → opaque fallback
- Respect Increase Contrast → binary colors, heavy borders
- Respect Reduce Motion → no elastic bounce, no morphing

### WebSocket Data Parsing
Vehicle tuple: `[id, type, lineId, blockId, destination, delay, coords, bearing, speed, lastUpdated]`
- Parse positional arrays into typed Swift structs
- Handle both EVehicle (9 fields) and EVehicle2 (10 fields, with delay) formats
- Timestamp is Unix ms → Date conversion

### Vehicle Interpolation
Between WebSocket updates (15-30s gap):
1. Store last two positions
2. Calculate great-circle bearing + speed
3. Animate along route polyline using speed + bearing
4. Snap to nearest route segment
5. Reset on next WebSocket message

---

## Dependencies

| Dependency | Purpose | Notes |
|------------|---------|-------|
| MapKit | Native maps | Built-in, no pod needed |
| CoreLocation | GPS | Built-in |
| CoreMotion | Inertial sensors | Built-in |
| PassKit | Apple Wallet | Built-in |
| FoundationModels | On-device LLM | iOS 26+, A17 Pro+ or M1+ |
| swift-protobuf | Protobuf parsing | Only if we add GTFS-RT later |
| swift-collections | Ordered dictionaries | For efficient vehicle lookups |

Zero external dependencies for MVP. All Apple frameworks.

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| livetransport.eu API changes/goes down | App breaks | Cache aggressively, build abstraction layer, pursue official Modeshift API |
| Foundation Models not available in Bulgaria | No AI assistant | Feature flag, fallback to structured search |
| Express Transit requires Apple partnership | No tap-to-pay | Standard QR code / NFC via Modeshift SDK |
| GPS unusable in Old Town | Bad UX | Kalman filter + CoreMotion fusion |
| Plovdiv municipality doesn't approve | No official status | Launch as community app first (like livetransport.eu itself) |
