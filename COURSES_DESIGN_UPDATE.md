# Courses Screen UI Update - Design Implementation

## Overview

Updated the Courses screen to match a modern, clean design with improved visual hierarchy and better user interaction patterns. All backend integration remains intact and fully functional.

## Changes Made

### 1. **Core Model Updates** (`lib/core/models/course_model.dart`)

#### Added Course Status Support

- **New Enum: `CourseStatusType`**
  - `registered`: Course is registered
  - `waiting`: Course is on waiting list
  - `prerequisiteRequired`: Course has prerequisite requirements
  - `available`: Course is available for registration
  - `unknown`: Status not determined

- **New Fields in `CourseModel`**
  - `status`: Course registration status
  - `statusInfo`: Additional status information (e.g., queue position)
  - `prerequisiteMessage`: Prerequisite requirement message

- **Enhanced JSON Parsing**
  - `_parseStatus()`: Converts API status strings to enum values
  - Handles multiple API field name variations
  - Safely defaults to `CourseStatusType.unknown` if not provided

### 2. **UI Redesign** (`lib/features/courses/presentation/pages/courses_screen.dart`)

#### Visual Design Changes

**Course Card Layout**

- Modern card design with colored left border (5px width)
- Color scheme rotates through 5 colors: Green, Amber, Red, Blue, Purple
- Subtle shadow for depth
- Rounded corners (12px border radius)
- Proper spacing and padding

**Card Structure**

```
┌─────────────────────────────────────┐
│ ■ Course Name              [CODE]  │ ← Left colored border
│   📚 Credits                        │
│                                     │
│ ✓ Registered                        │
│ [View Schedule Button] [Drop Button]│
└─────────────────────────────────────┘
```

#### New Components

**`_buildCourseItem()` - Main Course Card**

- Displays course name with course code badge
- Shows credit hours with icon
- Handles registration state
- Renders appropriate action based on status
- Index-based color rotation for visual appeal

**`_buildLoadingState()` - Loading Indicator**

- Amber background with loading spinner
- Shows "Processing..." message
- Provides visual feedback during registration/drop operations

**`_buildRegisteredState()` - Registered Course**

- Green checkmark indicator
- "Registered" status label
- Two action buttons:
  - "View Schedule" - Navigate to course schedule
  - "Drop" - Remove course from registration
- Drop button triggers confirmation dialog

**`_buildAvailableState()` - Available Course**

- Full-width "Register" button
- Primary color button matching app theme
- Triggers course registration

**`_showDropConfirmation()` - Confirmation Dialog**

- Confirmation dialog before dropping course
- Supports both AR and EN languages
- Cancel and Drop action buttons
- Maintains consistency with app design

#### Enhanced Search Bar

- Better visual hierarchy with padding
- Improved focus state with colored border
- Hint text color adapts to theme
- Search icon color adapts to theme

#### Improved Spacing and Typography

- Level headers: Bold with 16px top padding
- Semester headers: Muted color with 12px vertical padding
- Better visual separation between sections
- Improved readability with consistent spacing

#### Theme Support

- Full Light/Dark mode support
- Colors adapt based on `isDark` flag
- Proper contrast ratios for accessibility
- Consistent with app's color scheme

#### Localization Support

- Arabic and English button labels
- Localized messages in dialogs
- RTL-aware layout (maintained)
- Supported languages: AR, EN

## State Management

### Course Registration Cubit Integration

- **Loading State**: Individual course loading tracked per `courseID`
- **Registration State**: Tracks registered courses using `Set<String>`
- **Optimistic UI Updates**: Immediate visual feedback before API response
- **Error Handling**: Rollback UI on failed operations

### Error Handling

- Displays error messages via SnackBar
- Graceful fallback UI states
- Maintains data consistency
- Proper error recovery

## Backend Integration

### API Endpoints Used

- `GET /Courses/all?lang={lang}` - Fetch all courses
- `POST /CoursesRegistration/register/{courseID}?lang={lang}` - Register course
- `DELETE /CoursesRegistration/drop/{courseID}?lang={lang}` - Drop course

### Data Flow

1. **Fetch**: Course data retrieved and parsed
2. **Display**: Courses rendered with proper status
3. **Register**: Course registration via API
4. **Drop**: Course removal via API
5. **Update**: UI updates based on registration state

## Features

✅ Modern card-based UI design
✅ Color-coded course cards (auto-rotating colors)
✅ Status indicators (Registered, Loading, Available)
✅ Register/Drop/View Schedule actions
✅ Search functionality with normalization
✅ Light/Dark theme support
✅ Arabic/English localization
✅ Loading indicators for operations
✅ Confirmation dialogs for destructive actions
✅ Error handling and recovery
✅ Smooth animations and transitions
✅ Responsive layout (mobile-friendly)
✅ Maintains backend integration

## Testing Checklist

- [ ] Course cards display correctly with proper colors
- [ ] Search filters courses by name and code
- [ ] Register button works and updates UI
- [ ] Drop button shows confirmation dialog
- [ ] Loading indicators appear during operations
- [ ] Error messages display on failures
- [ ] Theme switching works properly
- [ ] Arabic/English language switching works
- [ ] Schedule view navigates correctly
- [ ] All state updates persist correctly
- [ ] No console errors or warnings
- [ ] Responsive on different screen sizes

## Future Enhancements

- Add support for waiting list queue position display
- Show prerequisite requirements with better UX
- Add course details/information modal
- Support for course prerequisites validation
- Add sorting/filtering options (by credits, semester, etc.)
- Implement course wishlist feature
- Add course recommendations
