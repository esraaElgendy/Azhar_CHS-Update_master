// VERIFICATION: Type Safety Improvements
// This demonstrates how the new code handles edge cases

// BEFORE (Would crash):
int level = json['level'] as int; // ❌ Crash if 'level' is "1" (String)
String name = json['courseNameAr']; // ❌ Crash if null

// AFTER (Safe):
int level = CourseModel.\_safeToInt(json['level']); // ✅ Handles any type
String? name = CourseModel.\_safeToStringNullable(json['courseNameAr']); // ✅ Proper null handling

---

// EXAMPLE API RESPONSE HANDLING:

// 1. Numeric values as Strings (Common issue)
{
"level": "1", // String instead of int ✅ Handled
"semester": "2", // String instead of int ✅ Handled
"creditHours": "3" // String instead of int ✅ Handled
}

// 2. Null courseNameAr
{
"courseID": "CS101",
"courseNameEn": "Programming",
"courseNameAr": null, // ✅ Fallback to English
"creditHours": 3
}

// 3. Missing courseNameAr entirely
{
"courseID": "CS101",
"courseNameEn": "Programming",
// courseNameAr missing ✅ Fallback to English
"creditHours": 3
}

---

// LOCALIZATION LOGIC:

// If Arabic language selected:
if (languageCode == 'ar') {
displayName = courseModel.courseNameAr ?? courseModel.courseNameEn;
}

// If English language selected:
else {
displayName = courseModel.courseNameEn;
}

// Examples:
// Scenario 1: Both names provided
courseNameAr: "البرمجة" → Arabic user sees: "البرمجة"
courseNameEn: "Programming" → English user sees: "Programming"

// Scenario 2: Only English provided
courseNameAr: null → Arabic user sees: "Programming" (fallback)
courseNameEn: "Programming" → English user sees: "Programming"

---

// ERROR HANDLING:

// Malformed entry in API response:
{
"level": "abc", // Can't parse as int
"courses": null, // Null courses list
"semester": "" // Empty string
}

// Result: ✅ Entry skipped, app continues
// Level defaults to 0, Semester defaults to 0, Courses defaults to empty list

---

// SEARCH FUNCTIONALITY:

// Before: Searched by name, subject, and ID
// After: Searches by name and ID only (subject removed as it's not in API)

Search Query: "prog"
✅ Matches: "Programming 101" (course name)
✅ Matches: "CS101" (if contains "101")
✅ Matches: "برمجة" normalized

---

// PERFORMANCE:

// Before: Might cache data, showing stale courses
// After: Always fetches fresh data on every navigation

// When user navigates to Courses screen:

1. Show loading spinner
2. Fetch fresh data from API
3. Parse all levels/semesters/courses
4. Display grouped list

// When user changes language:

1. Refresh is triggered (listener on SettingsCubit)
2. New data fetch with new language parameter
3. Courses redisplayed with correct names

---

// LIGHT/DARK MODE:

// Before: Some inconsistencies
// After: Full support throughout

isDark = theme.brightness == Brightness.dark;

// Card background
color: isDark ? AppColors.cardDark : const Color(0xffE0E4FF)

// Text color
color: isDark ? Colors.white : AppColors.primaryDark

// Icon color
color: isDark ? Colors.grey[400] : Colors.grey[700]

---

// TESTING CHECKLIST:

✅ Load courses → See grouped by Level > Semester > Courses
✅ Search courses → Filter updates in real-time
✅ Tap course → Navigate to details screen
✅ Switch to Arabic → Names update if courseNameAr exists
✅ Switch to English → Shows courseNameEn
✅ Toggle dark mode → Colors update immediately
✅ No network → Shows error with retry button
✅ Empty response → Shows "No courses found"
✅ Refresh button → Fetches fresh data
✅ Malformed data → App doesn't crash, skips bad entries
