# ToDoList iOS Application - Flow Documentation

## Table of Contents
1. [Application Overview](#application-overview)
2. [Architecture](#architecture)
3. [Application Flow](#application-flow)
4. [Authentication Flow](#authentication-flow)
5. [Home & Task Management Flow](#home--task-management-flow)
6. [Calendar Flow](#calendar-flow)
7. [Categories Flow](#categories-flow)
8. [Settings Flow](#settings-flow)
9. [Services & Data Layer](#services--data-layer)
10. [Models](#models)

---

## Application Overview

**ToDoList** is a modern iOS task management application built with SwiftUI and Firebase. It provides users with a comprehensive task management system featuring task creation, categorization, scheduling, and collaboration capabilities.

### Key Features
- 🔐 Firebase Authentication (Email/Password & Google Sign-In)
- ✅ Task Management (Create, Read, Update, Delete)
- 📅 Calendar View with Due Date Tracking
- 🏷️ Category-based Task Organization
- 🎨 Color Customization for Tasks
- 👥 Collaborator Support
- ⚙️ User Profile & Settings Management
- 🔒 Account Security Features

---

## Architecture

### Technology Stack
- **Frontend**: SwiftUI
- **Backend**: Firebase (Authentication, Realtime Database)
- **Image Storage**: Cloudinary Service
- **State Management**: Swift Observation Framework (@Observable)
- **Architecture Pattern**: MVVM (Model-View-ViewModel)

### Project Structure
```
ToDoList/
├── App/                          # App entry point and main navigation
├── Features/
│   ├── Auth/                     # Authentication feature
│   │   ├── ViewModels/          # Login & Register view models
│   │   └── Views/               # Auth UI screens
│   ├── Home/                     # Task management feature
│   │   ├── ViewModels/          # Home & Task view models
│   │   └── Views/               # Task UI screens
│   └── Settings/                 # User settings feature
│       ├── ViewModels/          # Settings view model
│       └── Views/               # Settings UI screens
├── Models/                       # Data models
├── Services/                     # Firebase & external services
├── Shared/                       # Reusable components
│   ├── Components/              # UI components
│   ├── Extensions/              # Swift extensions
│   ├── Helpers/                 # Utility functions
│   └── Theme/                   # Design system
└── Assets.xcassets/             # Images and colors
```

---

## Application Flow

### App Launch Sequence

```
┌─────────────────────────────────────────────────┐
│ ToDoListApp.swift                               │
│ - Configures Firebase on launch                │
│ - Displays AuthCoordinator                     │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ AuthCoordinator (Root View)                    │
│ - Shows SplashScreen (3 seconds)               │
│ - Checks authentication state                  │
│ - Listens to Firebase Auth changes             │
└─────────────────┬───────────────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
         ▼                 ▼
    ┌─────────┐      ┌──────────┐
    │ Logged  │      │ Logged   │
    │ Out     │      │ In       │
    └────┬────┘      └─────┬────┘
         │                 │
         ▼                 ▼
   ┌──────────┐      ┌──────────┐
   │LoginView │      │MainTabView│
   └──────────┘      └──────────┘
```

### Auth State Management

**AuthStateManager** continuously monitors:
- Firebase Authentication state
- UserDefaults for persistent login state
- Current user ID

**Actions on State Change:**
- **User Logs In**: Navigate to MainTabView
- **User Logs Out**: Navigate to LoginView
- **Session Expires**: Auto-logout and return to LoginView

---

## Authentication Flow

### 1. Login Flow

#### Entry Point: `LoginView`
#### ViewModel: `LoginViewModel`

**User Actions & System Flow:**

```
User Opens App
    ↓
[SplashScreen displayed for 3 seconds]
    ↓
[Check if user is authenticated]
    ↓
┌───────────────────────────────────┐
│ LoginView                         │
│ Input: Email & Password           │
└───────────────┬───────────────────┘
                │
                ▼
User enters credentials and taps "Sign In"
                │
                ▼
┌─────────────────────────────────────────┐
│ LoginViewModel.signIn()                 │
│ Actions:                                │
│ 1. Validate email format                │
│ 2. Validate password (min 6 chars)     │
│ 3. Call FirebaseAuthService.signIn()   │
│ 4. Update lastLoginAt timestamp        │
│ 5. Save login state to UserDefaults    │
│ 6. Set isAuthenticated = true          │
└─────────────────┬───────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
    Success            Error
         │                 │
         ▼                 ▼
   Navigate to      Show error
   MainTabView      message
```

**Alternative: Google Sign-In**

```
User taps "Sign in with Google"
    ↓
LoginViewModel.signInWithGoogle()
    ↓
┌─────────────────────────────────────────┐
│ Actions:                                │
│ 1. Open Google Sign-In flow            │
│ 2. Authenticate with Google credentials│
│ 3. Check if user exists in database    │
│ 4. If not, create user profile         │
│ 5. Update lastLoginAt timestamp        │
│ 6. Save login state                    │
│ 7. Navigate to MainTabView             │
└─────────────────────────────────────────┘
```

**Validation Rules:**
- Email: Must be valid email format (contains @)
- Password: Minimum 6 characters

**Error Handling:**
- Invalid credentials: Display "Invalid email or password"
- Network error: Display "Network connection failed"
- Account not found: Display "User not found"

---

### 2. Registration Flow

#### Entry Point: `RegisterView`
#### ViewModel: `RegisterViewModel`

**User Actions & System Flow:**

```
User taps "Sign Up" from LoginView
    ↓
┌───────────────────────────────────┐
│ RegisterView                      │
│ Input: Display Name, Email,       │
│        Password, Confirm Password │
└───────────────┬───────────────────┘
                │
                ▼
User fills form and taps "Create Account"
                │
                ▼
┌─────────────────────────────────────────┐
│ RegisterViewModel.register()            │
│ Actions:                                │
│ 1. Validate display name (not empty)   │
│ 2. Validate email format                │
│ 3. Validate password (min 6 chars)     │
│ 4. Confirm passwords match              │
│ 5. Call FirebaseAuthService.register() │
│ 6. Create User object with data        │
│ 7. Save user to Realtime Database      │
│ 8. Save login state to UserDefaults    │
│ 9. Set isAuthenticated = true          │
└─────────────────┬───────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
    Success            Error
         │                 │
         ▼                 ▼
   Navigate to      Show error
   MainTabView      message
```

**Alternative: Google Sign-Up**

```
User taps "Sign up with Google"
    ↓
RegisterViewModel.signUpWithGoogle()
    ↓
┌─────────────────────────────────────────┐
│ Actions:                                │
│ 1. Open Google Sign-In flow            │
│ 2. Authenticate with Google credentials│
│ 3. Check if user already exists        │
│ 4. If not, create new user profile     │
│ 5. Save user data to database          │
│ 6. Save login state                    │
│ 7. Navigate to MainTabView             │
└─────────────────────────────────────────┘
```

**Validation Rules:**
- Display Name: Cannot be empty
- Email: Must be valid email format
- Password: Minimum 6 characters
- Confirm Password: Must match password

**User Data Created:**
```swift
User {
    id: Firebase Auth UID
    email: User's email
    displayName: User-provided name
    firstName: Extracted from displayName
    lastName: Extracted from displayName
    createdAt: Current timestamp
    lastLoginAt: Current timestamp
    appTheme: "Light" (default)
    profilePhoto: Random pastel color
}
```

---

## Home & Task Management Flow

### Main Tab Navigation

```
┌──────────────────────────────────┐
│ MainTabView                      │
│ ├─ Tab 0: HomeView              │
│ ├─ Tab 1: CalendarView          │
│ ├─ Tab 2: CategoryView          │
│ └─ Tab 3: SettingsView          │
└──────────────────────────────────┘
```

---

### 3. Home View Flow

#### Entry Point: `HomeView`
#### ViewModel: `HomeViewModel`

**Initial Load Sequence:**

```
User navigates to Home tab
    ↓
┌─────────────────────────────────────────┐
│ HomeView.onAppear()                     │
│ Actions:                                │
│ 1. Get current userId from Firebase    │
│ 2. Load user profile                   │
│ 3. Load all user's tasks               │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│ HomeViewModel.loadUserProfile()         │
│ - Fetch User from Realtime Database    │
│ - Display greeting with user name       │
│ - Show user profile picture/initials   │
└─────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│ HomeViewModel.loadTasks()               │
│ - Fetch all TaskItems for userId       │
│ - Sort by date/priority                 │
│ - Display in task list                  │
└─────────────────────────────────────────┘
```

**HomeView Components:**

1. **Greeting Card**
   - Displays user's name and profile
   - Shows current date
   - Personalized greeting (Good Morning/Afternoon/Evening)

2. **Schedule Timeline**
   - Shows tasks scheduled for today
   - Grouped by time slots
   - Click to view task details

3. **Task List**
   - Displays all tasks
   - Filter options: All, Completed, Pending
   - Search functionality
   - Swipe actions: Edit, Delete

**User Actions:**

```
┌─────────────────────────────────────────┐
│ HOME VIEW USER ACTIONS                  │
├─────────────────────────────────────────┤
│                                         │
│ 1. ADD NEW TASK                        │
│    ├─ Tap "+" button                   │
│    ├─ Navigate to AddTaskView          │
│    └─ Create task (see Add Task Flow)  │
│                                         │
│ 2. VIEW TASK DETAILS                   │
│    ├─ Tap on TaskCard                  │
│    ├─ Navigate to TaskDetailView       │
│    └─ View/Edit task information       │
│                                         │
│ 3. TOGGLE TASK COMPLETION              │
│    ├─ Tap checkbox on TaskCard         │
│    ├─ Call HomeViewModel               │
│    │   .toggleTaskCompletion()         │
│    ├─ Update task.isCompleted          │
│    ├─ Update task.updatedAt            │
│    └─ Save to database                 │
│                                         │
│ 4. DELETE TASK                         │
│    ├─ Swipe left on TaskCard           │
│    ├─ Tap delete button                │
│    ├─ Call HomeViewModel.deleteTask()  │
│    ├─ Remove from Realtime Database    │
│    └─ Remove from local task list      │
│                                         │
│ 5. SEARCH TASKS                        │
│    ├─ Enter search query in SearchBar  │
│    ├─ Filter tasks by title/category   │
│    └─ Display matching results         │
│                                         │
│ 6. VIEW ALL TASKS                      │
│    ├─ Tap "See All" link               │
│    ├─ Navigate to AllTasksView         │
│    └─ Display complete task list       │
│                                         │
└─────────────────────────────────────────┘
```

---

### 4. Add Task Flow

#### Entry Point: `AddTaskView`
#### ViewModel: `AddTaskViewModel`

**User Actions & System Flow:**

```
User taps "+" button in HomeView
    ↓
┌─────────────────────────────────────────┐
│ AddTaskView                             │
│ Input Form:                             │
│ ├─ Task Title (required)                │
│ ├─ Description (optional)               │
│ ├─ Category (Personal, Work, etc.)      │
│ ├─ Priority (Low, Medium, High)         │
│ ├─ Color (Pastel color picker)          │
│ ├─ Due Date & Time (optional)           │
│ └─ Collaborators (email addresses)      │
└─────────────────┬───────────────────────┘
                  │
                  ▼
User fills form and taps "Create"
                  │
                  ▼
┌─────────────────────────────────────────┐
│ AddTaskViewModel.createTask()           │
│ Actions:                                │
│ 1. Validate title is not empty         │
│ 2. Get current userId                  │
│ 3. Create TaskItem object:              │
│    - id: Generated UUID                 │
│    - userId: Current user ID            │
│    - title: User input                  │
│    - description: User input (optional) │
│    - category: Selected category        │
│    - color: Selected color hex          │
│    - priority: Selected priority        │
│    - isCompleted: false (default)       │
│    - dueDate: Selected date timestamp   │
│    - createdAt: Current timestamp       │
│    - updatedAt: Current timestamp       │
│    - collaborators: Email list          │
│    - notifyOnChanges: true (default)    │
│ 4. Save task to Realtime Database      │
│ 5. Dismiss AddTaskView                 │
│ 6. Refresh HomeView task list          │
└─────────────────┬───────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
    Success            Error
         │                 │
         ▼                 ▼
   Task created     Show error
   View dismissed   message
   Home refreshed
```

**Task Creation Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| Title | String | Yes | - | Task name |
| Description | String | No | nil | Detailed description |
| Category | Enum | Yes | Personal | Task category |
| Color | String (Hex) | Yes | #DDD6FE | Card background color |
| Priority | Enum | Yes | Medium | Task priority level |
| Due Date | Date | No | nil | Task deadline |
| Collaborators | [String] | No | [] | Collaborator emails |
| Notify | Bool | Yes | true | Notification preference |

**Category Options:**
- Personal
- Work
- Lifestyle
- Research
- Design

**Priority Options:**
- Low (→)
- Medium (↗)
- High (⇈)

**Color Picker:**
- Pre-defined pastel colors
- Custom color selection available

---

### 5. Task Detail & Edit Flow

#### Entry Point: `TaskDetailView`
#### ViewModel: `TaskViewModel`

**User Actions & System Flow:**

```
User taps on TaskCard
    ↓
┌─────────────────────────────────────────┐
│ TaskDetailView                          │
│ Display:                                │
│ ├─ Task title                           │
│ ├─ Task description                     │
│ ├─ Category chip                        │
│ ├─ Priority indicator                   │
│ ├─ Due date & time                      │
│ ├─ Completion status checkbox           │
│ ├─ Task color preview                   │
│ └─ Collaborators list                   │
└─────────────────┬───────────────────────┘
                  │
                  ▼
```

**Available Actions:**

```
┌─────────────────────────────────────────┐
│ TASK DETAIL ACTIONS                     │
├─────────────────────────────────────────┤
│                                         │
│ 1. EDIT TASK                           │
│    ├─ Tap "Edit" button                │
│    ├─ Enable editing mode              │
│    ├─ Modify any task field            │
│    ├─ Tap "Save"                       │
│    ├─ TaskViewModel.updateTask()       │
│    ├─ Update task.updatedAt            │
│    └─ Save changes to database         │
│                                         │
│ 2. TOGGLE COMPLETION                   │
│    ├─ Tap checkbox                     │
│    ├─ TaskViewModel                    │
│    │   .toggleCompletion()             │
│    ├─ Toggle task.isCompleted          │
│    ├─ Auto-save changes                │
│    └─ Update UI state                  │
│                                         │
│ 3. CHANGE CATEGORY                     │
│    ├─ Tap category chip                │
│    ├─ Select new category              │
│    ├─ TaskViewModel                    │
│    │   .updateCategory()               │
│    └─ Save automatically               │
│                                         │
│ 4. CHANGE PRIORITY                     │
│    ├─ Tap priority selector            │
│    ├─ Select new priority level        │
│    ├─ TaskViewModel.updatePriority()   │
│    └─ Save automatically               │
│                                         │
│ 5. CHANGE COLOR                        │
│    ├─ Tap color preview                │
│    ├─ Open ColorPickerSheet            │
│    ├─ Select new color                 │
│    ├─ TaskViewModel.updateColor()      │
│    └─ Save automatically               │
│                                         │
│ 6. UPDATE DUE DATE                     │
│    ├─ Tap date/time section            │
│    ├─ Pick new date/time               │
│    ├─ TaskViewModel.updateDueDate()    │
│    └─ Save automatically               │
│                                         │
│ 7. MANAGE COLLABORATORS                │
│    ├─ Add collaborator:                │
│    │  ├─ Enter email address           │
│    │  ├─ Validate email format         │
│    │  ├─ TaskViewModel                 │
│    │  │   .addCollaborator()           │
│    │  └─ Update collaborators list     │
│    └─ Remove collaborator:             │
│       ├─ Swipe on collaborator email   │
│       ├─ TaskViewModel                 │
│       │   .removeCollaborator()        │
│       └─ Update collaborators list     │
│                                         │
│ 8. DELETE TASK                         │
│    ├─ Tap "Delete" button              │
│    ├─ Show confirmation alert          │
│    ├─ Confirm deletion                 │
│    ├─ TaskViewModel.deleteTask()       │
│    ├─ Remove from database             │
│    ├─ Dismiss TaskDetailView           │
│    └─ Refresh HomeView                 │
│                                         │
└─────────────────────────────────────────┘
```

**Update Flow:**

```
Task field modified
    ↓
┌─────────────────────────────────────────┐
│ TaskViewModel.updateTask()              │
│ Actions:                                │
│ 1. Set task.updatedAt = current time   │
│ 2. Call RealtimeDatabaseService         │
│     .updateTask(task)                   │
│ 3. Update local task object            │
│ 4. Show success message                │
└─────────────────┬───────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
    Success            Error
         │                 │
         ▼                 ▼
   Changes saved    Show error
   UI updated       message
```

---

## Calendar Flow

### 6. Calendar View

#### Entry Point: `CalendarView`
#### ViewModel: Integrated with HomeViewModel

**User Actions & System Flow:**

```
User taps Calendar tab
    ↓
┌─────────────────────────────────────────┐
│ CalendarView                            │
│ Actions:                                │
│ 1. Load user's tasks from database     │
│ 2. Filter tasks with due dates         │
│ 3. Display calendar with marked dates  │
│ 4. Show tasks for selected date        │
└─────────────────┬───────────────────────┘
                  │
                  ▼
```

**Calendar Features:**

```
┌─────────────────────────────────────────┐
│ CALENDAR VIEW ACTIONS                   │
├─────────────────────────────────────────┤
│                                         │
│ 1. VIEW MONTHLY CALENDAR               │
│    ├─ Display current month            │
│    ├─ Highlight dates with tasks       │
│    ├─ Show today's date                │
│    └─ Navigate between months          │
│                                         │
│ 2. SELECT DATE                         │
│    ├─ Tap on calendar date             │
│    ├─ Filter tasks for that date       │
│    ├─ Display task list below calendar │
│    └─ Show task count for date         │
│                                         │
│ 3. VIEW TASK DETAILS                   │
│    ├─ Tap on task in date list         │
│    ├─ Navigate to TaskDetailView       │
│    └─ View/edit task information       │
│                                         │
│ 4. TOGGLE TASK COMPLETION              │
│    ├─ Tap checkbox on task             │
│    ├─ Update completion status         │
│    └─ Save to database                 │
│                                         │
│ 5. NAVIGATE MONTHS                     │
│    ├─ Swipe left/right                 │
│    ├─ Use arrow buttons                │
│    └─ Jump to specific month           │
│                                         │
└─────────────────────────────────────────┘
```

**Data Flow:**

```
┌─────────────────────────────────────────┐
│ RealtimeDatabaseService                 │
│  .fetchTasksWithDueDates(userId)       │
└─────────────────┬───────────────────────┘
                  │
                  ▼
          [All tasks with dueDate != nil]
                  │
                  ▼
┌─────────────────────────────────────────┐
│ Group tasks by date                     │
│ - Convert timestamps to Date objects   │
│ - Group by day                          │
│ - Sort by time within each day         │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│ Display in Calendar                     │
│ - Mark dates with dots/indicators       │
│ - Show count badge for multiple tasks   │
└─────────────────────────────────────────┘
```

---

## Categories Flow

### 7. Category View

#### Entry Point: `CategoryView`

**User Actions & System Flow:**

```
User taps Categories tab
    ↓
┌─────────────────────────────────────────┐
│ CategoryView                            │
│ Actions:                                │
│ 1. Load all user's tasks               │
│ 2. Group tasks by category             │
│ 3. Display category cards with counts  │
└─────────────────┬───────────────────────┘
                  │
                  ▼
```

**Category Display:**

```
┌─────────────────────────────────────────┐
│ CATEGORY GRID LAYOUT                    │
├─────────────────────────────────────────┤
│                                         │
│ ┌────────────┐  ┌────────────┐        │
│ │ Personal   │  │   Work     │        │
│ │ 12 tasks   │  │  8 tasks   │        │
│ └────────────┘  └────────────┘        │
│                                         │
│ ┌────────────┐  ┌────────────┐        │
│ │ Lifestyle  │  │  Research  │        │
│ │  5 tasks   │  │  3 tasks   │        │
│ └────────────┘  └────────────┘        │
│                                         │
│ ┌────────────┐                         │
│ │  Design    │                         │
│ │  2 tasks   │                         │
│ └────────────┘                         │
│                                         │
└─────────────────────────────────────────┘
```

**Available Actions:**

```
┌─────────────────────────────────────────┐
│ CATEGORY VIEW ACTIONS                   │
├─────────────────────────────────────────┤
│                                         │
│ 1. VIEW CATEGORY TASKS                 │
│    ├─ Tap on category card             │
│    ├─ Filter tasks by selected category│
│    ├─ Display filtered task list       │
│    └─ Show category name in header     │
│                                         │
│ 2. VIEW TASK STATISTICS                │
│    ├─ Display total tasks per category │
│    ├─ Show completion percentage       │
│    └─ Display color-coded indicators   │
│                                         │
│ 3. ADD TASK TO CATEGORY                │
│    ├─ Tap "+" button                   │
│    ├─ Navigate to AddTaskView          │
│    └─ Pre-select current category      │
│                                         │
│ 4. SEARCH WITHIN CATEGORY              │
│    ├─ Use SearchBar                    │
│    ├─ Filter by task title             │
│    └─ Display matching results         │
│                                         │
└─────────────────────────────────────────┘
```

---

## Settings Flow

### 8. Settings & Account Management

#### Entry Point: `SettingsView`
#### ViewModel: `SettingsViewModel`

**Initial Load:**

```
User taps Settings tab
    ↓
┌─────────────────────────────────────────┐
│ SettingsViewModel.loadCurrentUser()    │
│ Actions:                                │
│ 1. Get current userId from Firebase    │
│ 2. Fetch User from Realtime Database   │
│ 3. Load user profile data              │
│ 4. Populate form fields                │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│ SettingsView Display:                   │
│ ├─ Profile section                      │
│ │  ├─ Profile photo/color               │
│ │  ├─ Display name                      │
│ │  └─ Email address                     │
│ ├─ Account Options                      │
│ │  ├─ Personal Information              │
│ │  ├─ Account Security                  │
│ │  └─ Change Password                   │
│ └─ Actions                              │
│    ├─ Sign Out                          │
│    └─ Delete Account                    │
└─────────────────────────────────────────┘
```

**Available Actions:**

```
┌─────────────────────────────────────────┐
│ SETTINGS VIEW ACTIONS                   │
├─────────────────────────────────────────┤
│                                         │
│ 1. UPDATE PERSONAL INFORMATION         │
│    ├─ Navigate to PersonalInfoView     │
│    ├─ Edit first name                  │
│    ├─ Edit last name                   │
│    ├─ Change profile photo:            │
│    │  ├─ Option A: Upload from gallery │
│    │  │  ├─ Open ImagePicker           │
│    │  │  ├─ Select image               │
│    │  │  ├─ Upload to Cloudinary       │
│    │  │  └─ Save URL to user profile   │
│    │  └─ Option B: Choose color        │
│    │     ├─ Open ColorPickerSheet      │
│    │     ├─ Select pastel color        │
│    │     └─ Save hex to user profile   │
│    ├─ Tap "Save Changes"               │
│    ├─ SettingsViewModel                │
│    │   .updatePersonalInfo()           │
│    ├─ Validate inputs                  │
│    ├─ Update user object               │
│    ├─ Save to Realtime Database        │
│    └─ Show success message             │
│                                         │
│ 2. CHANGE PASSWORD                     │
│    ├─ Navigate to ChangePasswordView   │
│    ├─ Input:                           │
│    │  ├─ Current password              │
│    │  ├─ New password                  │
│    │  └─ Confirm new password          │
│    ├─ Validate inputs:                 │
│    │  ├─ Current password not empty    │
│    │  ├─ New password min 6 chars      │
│    │  └─ Passwords match               │
│    ├─ Tap "Update Password"            │
│    ├─ SettingsViewModel                │
│    │   .changePassword()               │
│    ├─ Re-authenticate user             │
│    ├─ Call FirebaseAuthService         │
│    │   .updatePassword()               │
│    ├─ Update password in Firebase Auth │
│    └─ Show success message             │
│                                         │
│ 3. ACCOUNT SECURITY                    │
│    ├─ Navigate to AccountSecurityView  │
│    ├─ View account email               │
│    ├─ View account creation date       │
│    ├─ View last login timestamp        │
│    └─ Access security settings         │
│                                         │
│ 4. SIGN OUT                            │
│    ├─ Tap "Sign Out" button            │
│    ├─ Show confirmation alert          │
│    ├─ Confirm sign out                 │
│    ├─ SettingsViewModel.signOut()     │
│    ├─ Call FirebaseAuthService         │
│    │   .signOut()                      │
│    ├─ Clear UserDefaults:              │
│    │  ├─ Remove "isLoggedIn"           │
│    │  └─ Remove "userId"               │
│    ├─ Clear local state                │
│    ├─ Navigate to LoginView            │
│    └─ AuthCoordinator updates state    │
│                                         │
│ 5. DELETE ACCOUNT                      │
│    ├─ Tap "Delete Account" button      │
│    ├─ Show warning alert               │
│    ├─ Confirm deletion                 │
│    ├─ SettingsViewModel                │
│    │   .deleteAccount()                │
│    ├─ Actions (in order):              │
│    │  ├─ Delete all user's tasks       │
│    │  │  from Realtime Database        │
│    │  ├─ Delete user profile data      │
│    │  │  from Realtime Database        │
│    │  ├─ Delete Firebase Auth account  │
│    │  │  via FirebaseAuthService       │
│    │  │    .deleteAccount()            │
│    │  └─ Clear UserDefaults            │
│    ├─ Navigate to LoginView            │
│    └─ Show deletion confirmation       │
│                                         │
└─────────────────────────────────────────┘
```

**Personal Info Update Flow:**

```
User modifies personal information
    ↓
Tap "Save Changes"
    ↓
┌─────────────────────────────────────────┐
│ SettingsViewModel                       │
│  .updatePersonalInfo()                  │
│ Actions:                                │
│ 1. Validate first name not empty       │
│ 2. Validate last name not empty        │
│ 3. Create updated User object:         │
│    - firstName = trimmed input          │
│    - lastName = trimmed input           │
│    - displayName = "First Last"         │
│    - profilePhoto = URL or hex color    │
│ 4. Call RealtimeDatabaseService         │
│     .updateUser(updatedUser)           │
│ 5. Update local user state             │
│ 6. Show success message                │
└─────────────────┬───────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
    Success            Error
         │                 │
         ▼                 ▼
   Profile         Show error
   updated         message
   Success shown
```

**Change Password Flow:**

```
User enters password information
    ↓
Tap "Update Password"
    ↓
┌─────────────────────────────────────────┐
│ SettingsViewModel.changePassword()     │
│ Actions:                                │
│ 1. Validate current password not empty │
│ 2. Validate new password (min 6 chars) │
│ 3. Validate passwords match            │
│ 4. Re-authenticate user:               │
│    - Get current user email            │
│    - Call FirebaseAuthService          │
│      .signIn(email, currentPassword)   │
│ 5. If authenticated, update password:  │
│    - Call FirebaseAuthService          │
│      .updatePassword(newPassword)      │
│ 6. Clear password fields               │
│ 7. Show success message                │
└─────────────────┬───────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
    Success            Error
         │                 │
         ▼                 ▼
   Password        Show error:
   updated         - Wrong current
   Success shown     password
                   - Weak password
                   - Network error
```

**Delete Account Flow:**

```
User taps "Delete Account"
    ↓
Show confirmation alert
    ↓
User confirms deletion
    ↓
┌─────────────────────────────────────────┐
│ SettingsViewModel.deleteAccount()      │
│ Sequential Actions:                     │
│                                         │
│ 1. Delete all user's tasks:            │
│    ├─ Get userId                       │
│    ├─ Fetch all tasks for user         │
│    ├─ Loop through tasks               │
│    └─ Delete each from database        │
│                                         │
│ 2. Delete user profile:                │
│    ├─ Call RealtimeDatabaseService     │
│    │   .deleteUser(userId)             │
│    └─ Remove user data from database   │
│                                         │
│ 3. Delete Firebase Auth account:       │
│    ├─ Call FirebaseAuthService         │
│    │   .deleteAccount()                │
│    └─ Remove authentication account    │
│                                         │
│ 4. Clear local state:                  │
│    ├─ UserDefaults.remove("isLoggedIn")│
│    ├─ UserDefaults.remove("userId")    │
│    └─ Synchronize UserDefaults         │
│                                         │
│ 5. Navigate to LoginView               │
│    └─ AuthCoordinator updates state    │
│                                         │
└─────────────────┬───────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
    Success            Error
         │                 │
         ▼                 ▼
   Account         Show error
   deleted         message
   Logged out      (may require
   At LoginView    re-auth)
```

---

## Services & Data Layer

### 9. FirebaseAuthService

**Purpose**: Manages all Firebase Authentication operations

**Actor**: Thread-safe singleton service

**Key Methods:**

| Method | Description | Actions |
|--------|-------------|---------|
| `signIn(email, password)` | Authenticate existing user | - Validate credentials<br>- Sign in via Firebase Auth<br>- Return user ID |
| `register(email, password)` | Create new user account | - Validate inputs<br>- Create Firebase Auth account<br>- Return user ID |
| `signInWithGoogle()` | Google OAuth authentication | - Configure Google Sign-In<br>- Get Google credentials<br>- Sign in to Firebase<br>- Return user ID |
| `signOut()` | Log out current user | - Sign out from Firebase Auth<br>- Clear auth state |
| `deleteAccount()` | Delete user's auth account | - Get current user<br>- Delete from Firebase Auth |
| `sendPasswordReset(email)` | Send password reset email | - Send reset link via Firebase |
| `updateEmail(newEmail)` | Change user email | - Send verification email<br>- Update email in Firebase |
| `updatePassword(newPassword)` | Change user password | - Validate new password<br>- Update in Firebase Auth |
| `currentUserId` | Get current user ID | - Return Firebase Auth UID or nil |
| `currentUserEmail` | Get current user email | - Return Firebase Auth email or nil |
| `isAuthenticated()` | Check if user is logged in | - Return boolean status |

**Error Handling:**

```swift
enum AuthError {
    case noUserLoggedIn
    case invalidCredentials
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case networkError
    case googleSignInNotConfigured
    case unknown
}
```

---

### 10. RealtimeDatabaseService

**Purpose**: Manages all Firebase Realtime Database operations

**Actor**: Thread-safe singleton service

**Database Structure:**

```
firebase-realtime-database/
├── users/
│   └── {userId}/
│       ├── id
│       ├── email
│       ├── displayName
│       ├── firstName
│       ├── lastName
│       ├── createdAt
│       ├── lastLoginAt
│       ├── appTheme
│       └── profilePhoto
└── tasks/
    └── {userId}/
        └── {taskId}/
            ├── id
            ├── userId
            ├── title
            ├── description
            ├── category
            ├── color
            ├── priority
            ├── isCompleted
            ├── dueDate
            ├── createdAt
            ├── updatedAt
            ├── collaborators[]
            └── notifyOnChanges
```

**User Operations:**

| Method | Action | Database Path |
|--------|--------|---------------|
| `saveUser(user)` | Create new user profile | `/users/{userId}` |
| `fetchUser(userId)` | Get user profile data | `/users/{userId}` |
| `updateUser(user)` | Update user information | `/users/{userId}` |
| `deleteUser(userId)` | Delete user profile | `/users/{userId}` |

**Task Operations:**

| Method | Action | Database Path |
|--------|--------|---------------|
| `saveTask(task)` | Create new task | `/tasks/{userId}/{taskId}` |
| `fetchTasks(userId)` | Get all user tasks | `/tasks/{userId}` |
| `fetchTask(userId, taskId)` | Get single task | `/tasks/{userId}/{taskId}` |
| `updateTask(task)` | Update task information | `/tasks/{userId}/{taskId}` |
| `deleteTask(userId, taskId)` | Delete task | `/tasks/{userId}/{taskId}` |
| `fetchTasksWithDueDates(userId)` | Get tasks with due dates | `/tasks/{userId}` (filtered) |

**Generic Operations:**

| Method | Description |
|--------|-------------|
| `setValue(value, at: path)` | Set any value at path |
| `getValue(at: path)` | Get value from path |
| `updateValues(values, at: path)` | Update multiple values |
| `deleteValue(at: path)` | Delete value at path |
| `observeValue(at: path, completion)` | Real-time listener |
| `removeObserver(at: path, handle)` | Remove listener |
| `removeAllObservers(at: path)` | Remove all listeners |

---

### 11. CloudinaryService

**Purpose**: Manages image uploads to Cloudinary CDN

**Key Methods:**

| Method | Description | Actions |
|--------|-------------|---------|
| `uploadImage(image)` | Upload image to Cloudinary | - Convert UIImage to Data<br>- Upload to Cloudinary API<br>- Return image URL |
| `deleteImage(publicId)` | Delete image from Cloudinary | - Call Cloudinary delete API<br>- Remove image from CDN |

**Usage in App:**
- Profile photo uploads
- Task attachments (if implemented)
- Image processing and optimization

---

## Models

### 12. User Model

**Purpose**: Represents a user in the application

```swift
struct User: Codable, Identifiable, Equatable {
    let id: String                    // Firebase Auth UID
    var email: String                 // User's email
    var displayName: String           // Full name
    var firstName: String?            // First name
    var lastName: String?             // Last name
    var createdAt: TimeInterval       // Account creation timestamp
    var lastLoginAt: TimeInterval?    // Last login timestamp
    var appTheme: String              // Theme preference ("Light"/"Dark")
    var profilePhoto: String?         // Cloudinary URL or hex color
    
    // Computed Properties
    var initials: String              // User initials (e.g., "JD")
    var profileColor: Color           // Color for profile display
}
```

**Methods:**
- `toDictionary()`: Convert to Firebase-compatible dictionary
- `randomPastelColor()`: Generate random pastel color hex

---

### 13. TaskItem Model

**Purpose**: Represents a task in the application

```swift
struct TaskItem: Codable, Identifiable, Hashable {
    let id: String                    // Unique task ID (UUID)
    var userId: String                // Owner's user ID
    var title: String                 // Task title
    var description: String?          // Optional description
    var category: TaskCategory        // Task category (enum)
    var color: String                 // Card background hex color
    var priority: TaskPriority        // Priority level (enum)
    var isCompleted: Bool             // Completion status
    var dueDate: TimeInterval?        // Optional due date timestamp
    var createdAt: TimeInterval       // Creation timestamp
    var updatedAt: TimeInterval       // Last update timestamp
    var collaborators: [String]       // Email addresses of collaborators
    var notifyOnChanges: Bool         // Notification preference
    
    // Computed Properties
    var backgroundColor: Color        // SwiftUI Color from hex
}
```

**Methods:**
- `toDictionary()`: Convert to Firebase-compatible dictionary

**Associated Enums:**

```swift
enum TaskCategory: String, CaseIterable {
    case lifestyle = "Lifestyle"
    case work = "Work"
    case personal = "Personal"
    case research = "Research"
    case design = "Design"
    
    var displayName: String
    var icon: String
}

enum TaskPriority: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var displayName: String
    var icon: String
    var color: Color
}
```

---

## Data Flow Diagram

### Complete Application Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                       │
│  (Views: Login, Register, Home, Task Detail, Calendar,      │
│   Categories, Settings)                                      │
└────────────────┬────────────────────────────────────────────┘
                 │
                 │ User Actions
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                      VIEW MODELS                            │
│  (LoginViewModel, RegisterViewModel, HomeViewModel,         │
│   TaskViewModel, SettingsViewModel)                         │
│                                                              │
│  - Handle user input                                        │
│  - Validate data                                            │
│  - Manage UI state                                          │
│  - Call services                                            │
└────────────────┬────────────────────────────────────────────┘
                 │
                 │ Service Calls
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                        SERVICES                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ FirebaseAuthService                                  │  │
│  │ - Authentication                                     │  │
│  │ - User account management                            │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ RealtimeDatabaseService                              │  │
│  │ - CRUD operations on users and tasks                 │  │
│  │ - Real-time data synchronization                     │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ CloudinaryService                                    │  │
│  │ - Image upload and management                        │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────┬────────────────────────────────────────────┘
                 │
                 │ API Calls
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                     EXTERNAL SERVICES                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Firebase Authentication                              │  │
│  │ - User authentication (Email/Google)                 │  │
│  │ - Session management                                 │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Firebase Realtime Database                           │  │
│  │ - NoSQL database                                     │  │
│  │ - Real-time data sync                                │  │
│  │ - Offline support                                    │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Cloudinary CDN                                       │  │
│  │ - Image storage and delivery                         │  │
│  │ - Image optimization                                 │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Google Sign-In                                       │  │
│  │ - OAuth authentication                               │  │
│  │ - User profile retrieval                             │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## State Management

### Authentication State

**Managed by**: `AuthStateManager` and `AuthCoordinator`

**State Flow:**

```
App Launch
    ↓
Check UserDefaults "isLoggedIn"
    ↓
Check Firebase Auth.currentUser
    ↓
┌────────────────────────────────────┐
│ Authentication State               │
│ - isAuthenticated: Bool            │
│ - isLoading: Bool                  │
│ - currentUserId: String?           │
└────────────────┬───────────────────┘
                 │
    ┌────────────┴────────────┐
    │                         │
    ▼                         ▼
┌─────────┐             ┌─────────┐
│ Logged  │             │ Logged  │
│ Out     │             │ In      │
│         │             │         │
│ Show:   │             │ Show:   │
│ Login   │             │ Main    │
│ View    │             │ TabView │
└─────────┘             └─────────┘
```

**State Listeners:**
- Firebase `Auth.addStateDidChangeListener`: Monitors auth changes
- UserDefaults observation: Persists login state
- Real-time synchronization across app lifecycle

---

## Error Handling

### Error Types

**Authentication Errors:**
- Invalid credentials
- Email already in use
- Weak password
- User not found
- Network connection failed
- Google Sign-In not configured

**Database Errors:**
- Data not found
- Permission denied
- Network timeout
- Invalid data format

**Validation Errors:**
- Empty required fields
- Invalid email format
- Password too short
- Passwords don't match

### Error Display

All ViewModels have:
- `errorMessage: String?` - Displayed in alerts
- `successMessage: String?` - Displayed as toast/banner
- Automatic error clearing after user action

---

## Offline Support

### Local State Management

**UserDefaults Persistence:**
- Login state (`isLoggedIn: Bool`)
- User ID (`userId: String`)
- Last known user data

**Firebase Realtime Database:**
- Automatic offline caching
- Data synchronization when online
- Conflict resolution

---

## Security

### Data Protection

**Authentication:**
- Firebase Authentication handles password hashing
- Secure token-based sessions
- Automatic session expiration

**Database Security:**
- Firebase Realtime Database Rules (server-side)
- User-scoped data access
- Validation rules for data integrity

**Best Practices:**
- No hardcoded credentials
- Secure API key management
- HTTPS for all network requests

---

## Performance Optimizations

### Data Loading

**Lazy Loading:**
- Tasks loaded on demand
- Paginated results (if implemented)
- Efficient query filtering

**Caching:**
- Firebase offline persistence
- In-memory task cache in ViewModels
- Image caching via Cloudinary CDN

**State Updates:**
- `@Observable` for reactive UI updates
- Minimal re-renders
- Debounced search queries

---

## Future Enhancements

### Potential Features

1. **Push Notifications**
   - Task reminders
   - Collaborator updates
   - Daily summaries

2. **Task Sharing**
   - Real-time collaboration
   - Permission management
   - Activity logs

3. **Advanced Filtering**
   - Custom filters
   - Saved searches
   - Smart lists

4. **Analytics Dashboard**
   - Task completion statistics
   - Productivity insights
   - Time tracking

5. **Widgets**
   - Home screen widgets
   - Lock screen widgets
   - Today view integration

6. **Dark Mode**
   - System theme support
   - Custom themes
   - Per-view theme override

7. **Export/Import**
   - CSV/JSON export
   - Backup/restore
   - Data portability

---

## Conclusion

This documentation provides a comprehensive overview of the ToDoList application's flow and actions. Each feature follows a clear pattern:

1. **User Action** → Triggers UI event
2. **View** → Captures user input
3. **ViewModel** → Validates and processes data
4. **Service** → Communicates with Firebase
5. **Database** → Persists/retrieves data
6. **UI Update** → Reflects changes to user

The application follows modern iOS development best practices with SwiftUI, MVVM architecture, and reactive state management using the Observation framework.

---

**Last Updated**: March 9, 2026  
**Version**: 1.0  
**Platform**: iOS (SwiftUI)  
**Minimum iOS Version**: iOS 16.0+
