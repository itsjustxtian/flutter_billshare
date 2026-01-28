# BillShare

This application was created using Flutter. It is a Bill/Expense tracking application where users can add bills/expenses that they have made or need to keep track of, set a due date, and then get a monthly summary on their estimated expenses.

## Updates

- _01/28/2026_:
  - Moved backend logic to bill_services.dart file and imported the saveBill function into the add_bill.dart file.
  - Added a getMonthlyBillInstances() function to get monthly bill instances
  - Updated Supabase RLS so that only owners can access their files.
  - Added a colorpicker to Add Bill Form to facilitate color tagging.
  - Added a refresh indicator function.
  - Added a carousel for Remaining Expenses and Monthly Summary.
- _01/27/2025_: Created a bill_services.dart file to separate the backend logic from the UI logic.
