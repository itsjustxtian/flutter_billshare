# BillShare

This application was created using Flutter. It is a Bill/Expense tracking application where users can add bills/expenses that they have made or need to keep track of, set a due date, and then get a monthly summary on their estimated expenses.

## Updates

- _01/30/2026_
  - Added feature to edit email and password
  - Added a password reset feature onto Log In tab in Log In page.
- _01/29/2026_
  - Added settings
  - Added an EditProfilePage
- _01/28/2026_:
  - Moved backend logic to bill_services.dart file and imported the saveBill function into the add_bill.dart file.
  - Added a getMonthlyBillInstances() function to get monthly bill instances
  - Updated Supabase RLS so that only owners can access their files.
  - Added a colorpicker to Add Bill Form to facilitate color tagging.
  - Added a refresh indicator function.
  - Added a carousel for Remaining Expenses and Monthly Summary.
  - Added a path to View Bill.
- _01/27/2025_: Created a bill_services.dart file to separate the backend logic from the UI logic.
