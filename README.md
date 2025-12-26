# Subscription Radar

Subscription Radar is a Flutter app for tracking recurring subscriptions and understanding how small, ongoing payments add up over time.

I built this project to explore local data persistence, UI-driven state updates, and incremental feature design using Flutter. The focus is on clarity and real-world usefulness rather than visual flash.

---

## Why this project?

Most people have multiple subscriptions spread across platforms and often underestimate how much they spend monthly or yearly.

Subscription Radar centralizes this information and answers simple but important questions:
- How much am I spending every month?
- Which subscriptions are due soon?
- Which ones are cancelled but still worth tracking?

---

## What the app currently does

### Manage subscriptions
- Add subscriptions with name, cost, billing cycle, due date, and category
- Edit existing subscriptions
- Delete subscriptions with confirmation
- Cancel and resume subscriptions without deleting data

### Spending summaries
- Calculates total monthly spend
- Calculates total yearly spend
- Converts yearly subscriptions into monthly equivalents
- Displays small summary tiles for quick overview

### Due-date awareness
- Tracks next due date for each subscription
- Highlights subscriptions due within the next 7 days

### Reminder preferences (in-app)
- Enable or disable reminders per subscription
- Choose reminder timing (1, 3, or 7 days before due date)
- Reminder settings are stored locally  
  (system notifications will be added later for mobile builds)

### Detailed view
- Tapping a subscription opens a details screen
- View full information and status
- Edit, cancel/resume, or delete from one place

---

## Technical approach

### Data storage
- Uses Hive for fast, local persistence
- Strongly typed subscription model
- Data persists across app restarts
- No backend or cloud dependency by design

### UI and state
- Built with Flutter (Material 3)
- Reactive updates using `ValueListenableBuilder`
- UI automatically reflects data changes
- No external state-management libraries used (intentional for simplicity)

### Design choices
- Kept logic explicit and readable
- Avoided premature abstractions
- Focused on building a complete, working core before adding extras

---

## Tech stack
- Flutter  
- Dart  
- Hive (local database)  
- Material 3  

---

## Current status

This project is actively under development.  
Features are added incrementally as I test ideas and improve the architecture.

---

## Known limitations
- Currently developed and tested on Web/Desktop
- Reminder system is in-app only (no OS notifications yet)
- No cloud sync or authentication

---

## Planned improvements
- Native notifications on Android and iOS
- Filters (active / cancelled / due soon)
- Sorting by due date and cost
- Spending charts and trends
- Optional cloud backup

---

## What this project demonstrates
- Practical data modeling
- Persistent local storage
- UI-driven state updates
- Incremental feature development
- Translating a real-world problem into working software
