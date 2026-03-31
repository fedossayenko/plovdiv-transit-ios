# Plovdiv Transit iOS App - Investigation Results

## LiveTransport.eu API Investigation (March 2026)

### Architecture
- **REST API**: `https://api.livetransport.eu/plovdiv/`
- **WebSocket**: `wss://api.livetransport.eu/plovdiv` (real-time vehicle positions)
- **Cloud CDN**: `https://0.livetransport.eu/` (static assets)
- **Vehicle info**: `https://trinmo.org/api/` (fleet details, images)
- **GitHub**: https://github.com/BPilot253 (author profile, has `transitous` fork)

### REST Endpoints (discovered from source)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `data` | GET | Initial data load: lines (29) + stops (483) |
| `vehicle/{id}/trip` | GET | Current trip for a vehicle |
| `vehicle/{id}/info` | GET | Vehicle details (fleet info) |
| `trip/{id}` | GET | Trip details with shape and stops |
| `brigade/{blockId}` | GET | Brigade/block schedule |
| `brigades/{lineId}` | GET | All brigades for a line |
| `virtualBoard/{stopId}?limit=N` | GET | Live departures from a stop |
| `routeChanges` | GET | Service alerts / route changes |

### Data Model: `/data` endpoint

```json
{
  "lines": [{
    "id": "28",
    "type": "bus",
    "color": "#0073ac",
    "name": "6",
    "routeName": "Линия 6"
  }],
  "stops": [{
    "id": "9457",
    "code": "1001",
    "name": { "bg": "кв. Смирненски - ул. Юндола", "en": "kv. Smirnenski - ul. Yundola" },
    "geo": { "coords": [42.12793, 24.70177], "bearing": 0 }
  }]
}
```

- **29 bus lines** in Plovdiv
- **483 stops** with bilingual names (bg/en) and GPS coordinates

### WebSocket: Real-Time Vehicle Positions

Connected to `wss://api.livetransport.eu/plovdiv`, receives JSON arrays of vehicle tuples.

**Vehicle tuple format** (array-indexed for bandwidth efficiency):
```
[id, type, lineId, blockId, destination, delay_ms, [lat, lng], bearing, speed, lastUpdated_ms]
```

**Example**:
```json
["3/PB0104PE", "bus", "28", "6", {"bg": "Прослав 1", "en": "Proslav 1"}, 18000, [42.151884, 24.773591], 311, 0, 1774968518000]
```

**Field mapping** (from Vehicle.js EVehicle2):
| Index | Field | Type | Notes |
|-------|-------|------|-------|
| 0 | id | string | Vehicle registration (e.g., "3/PB0104PE") |
| 1 | type | string | "bus" |
| 2 | lineId | string | References lines[].id |
| 3 | blockId | string | Brigade/block identifier |
| 4 | destination | {bg, en} | Bilingual destination name |
| 5 | delay | int | Delay in milliseconds (negative = early) |
| 6 | coords | [lat, lng] | GPS coordinates |
| 7 | bearing | int | Heading in degrees |
| 8 | speed | int | Speed (km/h) |
| 9 | lastUpdated | int | Unix timestamp in ms |

**222 active vehicles** observed during testing.

### Trip Data Model (from Trip.js ETrip):
```
[tripId, blockId, lineId, shape, destination, stops[]]
```
Each stop in trip: `[stopId, scheduledTime]`

### Stop Departure Model (from Stop.js EStopDeparture):
```
[tripId, lineId, blockId, destination, vehicleId, time, status]
```
Status: 0=normal, 1=active, 2=cancelled

### Key Observations

1. **NOT GTFS/GTFS-RT** - The API uses a custom JSON/WebSocket protocol, not Protocol Buffers or standard GTFS-RT feeds
2. **Modeshift backend** - The document mentions Modeshift as the operator backend; livetransport.eu appears to be a community/third-party visualization
3. **Array-indexed data** - Vehicle positions use positional arrays instead of named objects for bandwidth savings
4. **Bilingual support** - All user-facing strings have bg/en variants
5. **trinmo.org integration** - Vehicle fleet info (model, images) from external Bulgarian transit database
6. **Multi-city platform** - Same system serves Sofia, Varna, Stara Zagora, Pleven, Blagoevgrad, and international cities
7. **OpenFreeMap tiles** - Uses MapLibre GL + OpenFreeMap, not Google Maps or Apple Maps

### What We Can Reuse

- **API endpoints** for stops, lines, real-time positions, virtual boards, trip details
- **Data models** for vehicles, stops, lines, trips, brigades
- **WebSocket protocol** for real-time vehicle tracking
- **Coordinate data** for all 483 stops
- **Route shapes** from trip endpoint
- **Bilingual strings** already available from API

### Virtual Board Response (tested)
```json
{
  "departures": [{
    "tripId": "33_9457_9696_20260331_1754",
    "lineId": "33",
    "vehicleId": "3/PB0779XT",    // optional - only if vehicle is active
    "activeTrip": true,             // optional
    "time": {
      "scheduled": 1774968840000,   // Unix ms
      "actual": 1774968840000       // Unix ms (same if no delay)
    },
    "destination": { "bg": "Марица", "en": "Maritsa" }
  }]
}
```

### Trip/Vehicle Response (tested)
```json
{
  "nextStop": 10,           // index into stops array
  "delay": -63000,          // ms (negative = early)
  "trip": {
    "id": "28_9864_9844_20260331_1736",
    "lineId": "28",
    "shape": "<encoded_polyline>",  // Google encoded polyline format
    "destination": { "bg": "Прослав 1", "en": "Proslav 1" },
    "stops": [
      { "id": "9864", "scheduled": 1774967760000 },
      { "id": "9540", "scheduled": 1774967824000 }
    ]
  }
}
```

### What Needs Custom Development

- iOS-native MapKit rendering (replacing Leaflet/MapLibre)
- GTFS/NeTEx integration for EU NAP compliance (API doesn't provide this natively)
- Ticketing/payment integration (Modeshift cEMV - separate system)
- Kalman filter for pedestrian positioning
- Apple Wallet / PassKit integration
- Foundation Models NLP assistant
- Live Activities / Dynamic Island
