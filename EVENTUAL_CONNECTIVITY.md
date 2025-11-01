# Eventual Connectivity Architecture - AceUp

## 📋 Overview

This document explains the **offline-first architecture** with **eventual connectivity** implemented for the Shared functionality in AceUp. The system allows the app to work fully offline and automatically synchronize when internet is available.

## 🏗️ Architecture Components

### 1. **Local Database (SQLite + Drift)**
- **Location**: `lib/data/local/database/`
- **Purpose**: Single source of truth for app data
- **Tables**: 
  - Core: `Groups`, `GroupMembers`, `CalendarEvents`, `FreeBlocks`, `CachedUsers`
  - Infrastructure: `SyncQueue`, `AppSettings`
  - Schedule Cache: `Terms`, `Subjects`, `ClassTemplates`

### 2. **Connectivity Manager**
- **Location**: `lib/core/connectivity/connectivity_manager.dart`
- **Purpose**: Monitors network state (online/offline)
- **Features**:
  - Real-time connectivity detection
  - Stream of connectivity changes
  - Manual connectivity checks

```dart
// Usage example
final connectivity = ConnectivityManager();
await connectivity.initialize();

// Check current status
if (connectivity.isOnline) {
  // Perform online operation
}

// Listen to changes
connectivity.onConnectivityChanged.listen((isOnline) {
  print('Connectivity: ${isOnline ? "ONLINE" : "OFFLINE"}');
});
```

### 3. **Data Access Objects (DAOs)**
- **Location**: `lib/data/local/database/dao/`
- **Purpose**: CRUD operations on local database
- **DAOs**:
  - `GroupDao`: Groups and members management
  - `EventDao`: Calendar events caching
  - `UserDao`: User data caching with avatar support
  - `MemberScheduleDao`: Cache member schedules for offline free blocks
  - `SyncDao`: Manage sync queue for offline operations
  - `SettingsDao`: App preferences and settings

### 4. **Sync Service**
- **Location**: `lib/services/shared/sync_service.dart`
- **Purpose**: Background synchronization with Firestore
- **Features**:
  - Periodic sync (every 30 seconds when online)
  - Processes sync queue from local database
  - Retry logic with exponential backoff
  - Automatic sync when connectivity is restored

```dart
// Usage example
final syncService = SyncService(
  database: AppDatabase(),
  firestore: FirebaseFirestore.instance,
  connectivity: ConnectivityManager(),
);

// Start automatic sync
syncService.startPeriodicSync();

// Manual sync
await syncService.syncPendingOperations();
```

### 5. **Repository (Offline-First Pattern)**
- **Location**: `lib/data/repositories/shared_repository.dart`
- **Purpose**: Unified data access layer with offline-first logic
- **Pattern**:
  1. **Read**: Try local cache first → Fallback to Firestore if needed
  2. **Write**: Save locally immediately → Queue for background sync

```dart
// Usage example
final repository = SharedRepository(
  database: AppDatabase(),
  firestore: FirebaseFirestore.instance,
  connectivity: ConnectivityManager(),
);

// Get groups (offline-first)
final groups = await repository.getGroupsForUser(userId);
// ✅ Returns cached data instantly
// ☁️  Fetches from Firestore if cache is empty and online

// Create group (queued for sync)
await repository.createGroup(newGroup);
// ✅ Saved locally immediately
// 🔄 Queued for background sync to Firestore
```

## 🔄 Data Flow

### Reading Data (Offline-First)
```
User Request
    ↓
Repository
    ↓
1. Check Local Cache (SQLite)
    ├─ Data Found → Return immediately ✅
    └─ Data Not Found
        ↓
2. Check Connectivity
    ├─ Online → Fetch from Firestore → Cache locally → Return
    └─ Offline → Return empty/error ❌
```

### Writing Data (Queue for Sync)
```
User Action (Create/Update/Delete)
    ↓
Repository
    ↓
1. Save to Local Database (SQLite) ✅
    ↓
2. Add to Sync Queue
    ↓
3. Return Success to User (instant feedback)
    ↓
SyncService (Background)
    ↓
4. Process Sync Queue when online
    ↓
5. Upload to Firestore ☁️
    ↓
6. Remove from Queue on success
```

## 📦 Integration with ViewModels

### Current Status
- ✅ Local storage implemented (Drift + SQLite)
- ✅ Connectivity detection (ConnectivityManager)
- ✅ Background sync service (SyncService)
- ✅ Repository pattern (SharedRepository structure)
- ⚠️  **Pending**: Adjust SharedRepository to use `Group`, `AppUser`, `CalendarEvent` models
- ⚠️  **Pending**: Integrate with ViewModels (GroupListViewModel, GroupDetailViewModel)

### Next Steps
1. **Update SharedRepository** to match existing model structure:
   - Use `Group` instead of `GroupModel`
   - Use `AppUser` instead of `UserModel`
   - Implement `fromFirestore()` and `toFirestore()` methods

2. **Modify ViewModels** to use SharedRepository:
   ```dart
   class GroupListViewModel extends ChangeNotifier {
     final SharedRepository _repository;
     
     Future<void> loadGroups() async {
       _groups = await _repository.getGroupsForUser(currentUserId);
       notifyListeners();
     }
   }
   ```

3. **Add Connectivity UI Indicators**:
   - Show offline banner when no connection
   - Display sync status (pending items count)
   - Show "synced" checkmark when operations complete

## 🎯 Benefits

### For Users
- ✅ **Instant Response**: No waiting for network requests
- ✅ **Works Offline**: Full functionality without internet
- ✅ **Seamless Sync**: Changes upload automatically when online
- ✅ **Better UX**: No loading spinners for cached data

### For Developers
- ✅ **Single Source of Truth**: Local database is always current
- ✅ **Reduced API Calls**: Cache reduces Firestore reads/writes
- ✅ **Network Resilience**: App works in poor connectivity
- ✅ **Testable**: Easy to test offline scenarios

## 🔧 Configuration

### Initialize in main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize connectivity
  final connectivity = ConnectivityManager();
  await connectivity.initialize();
  
  // Initialize database
  final database = AppDatabase();
  
  // Initialize sync service
  final syncService = SyncService(
    database: database,
    firestore: FirebaseFirestore.instance,
    connectivity: connectivity,
  );
  syncService.startPeriodicSync();
  
  runApp(MyApp());
}
```

## 📊 Monitoring Sync Status

```dart
// Get sync statistics
final stats = await syncService.getSyncStats();
print('Pending items: ${stats['pendingCount']}');
print('Items by type: ${stats['itemsByType']}');
print('Is syncing: ${stats['isSyncing']}');
```

## 🧪 Testing

### Test Offline Scenarios
1. Turn off WiFi/mobile data
2. Create/edit groups → Should save locally
3. Turn on internet → Should sync automatically
4. Check Firestore → Changes should appear

### Test Cache
1. Load groups with internet
2. Turn off internet
3. Restart app
4. Groups should load instantly from cache

## 📝 Notes

- **Sync interval**: 30 seconds (configurable)
- **Cache expiration**: 
  - Free blocks: 30 minutes
  - Calendar events: 1 hour
  - Cached users: 1 hour
- **Retry limit**: 5 attempts (items removed after)
- **Conflict resolution**: Last write wins (Firestore merge)

## 🚀 Future Enhancements

- [ ] Conflict resolution for concurrent edits
- [ ] Delta sync (only sync changes, not full objects)
- [ ] Selective sync (sync specific data types)
- [ ] Upload photos/files with queuing
- [ ] Background sync with WorkManager (Android) / Background Fetch (iOS)
- [ ] Compression for large data transfers
