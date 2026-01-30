import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardServices {
  final _supabase = Supabase.instance.client;
  final now = DateTime.now();
  late final firstDay = DateTime(now.year, now.month, 1);
  late final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  Future<double> getTotalMonthlyExpense() async {
    try {
      final response = await _supabase
          .from('bill_instances')
          .select('amount_due')
          .gte('due_date', firstDay.toIso8601String())
          .lte('due_date', lastDay.toIso8601String());

      final List<dynamic> data = response;

      final total = data.fold<double>(
        0.0,
        (sum, item) =>
            sum + (double.tryParse(item['amount_due'].toString()) ?? 0.0),
      );

      return total;
    } catch (e) {
      // print('Error fetching expenses: $e');
      return 0.0;
    }
  }

  Future<double> getTotalRemainingExpense() async {
    try {
      final response = await _supabase
          .from('bill_instances')
          .select('amount_due')
          .neq('status', 'Paid')
          .gte('due_date', firstDay.toIso8601String())
          .lte('due_date', lastDay.toIso8601String());

      final List<dynamic> data = response;

      final total = data.fold<double>(
        0.0,
        (sum, item) =>
            sum + (double.tryParse(item['amount_due'].toString()) ?? 0.0),
      );

      return total;
    } catch (e) {
      // print('Error fetching expenses: $e');
      return 0.0;
    }
  }

  Future getMonthlyBillInstances() async {
    try {
      final bills = await _supabase
          .from('bill_instances')
          .select()
          .gte('due_date', firstDay.toIso8601String())
          .lte('due_date', lastDay.toIso8601String())
          // 1. Primary sort: Status (e.g., 'pending' before 'paid' alphabetically)
          // Set ascending to false if you want 'paid' at the top
          .order('status', ascending: false)
          // 2. Secondary sort: Closest due date first
          .order('due_date', ascending: true);

      return bills;
    } catch (e) {
      // print('Error fetching expenses: $e');
      return null;
    }
  }
}
