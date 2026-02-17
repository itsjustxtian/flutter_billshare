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

  Future<List<Map<String, dynamic>>?> getMonthlyBillInstances() async {
    try {
      final bills = await _supabase
          .from('bill_instances')
          .select()
          .or(
            'and(due_date.gte.${firstDay.toIso8601String()},due_date.lte.${lastDay.toIso8601String()}),status.neq.Paid',
          )
          .order('status', ascending: true)
          .order('due_date', ascending: true);

      return bills;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllBillInstances() async {
    try {
      // .select() defaults to '*'
      final List<Map<String, dynamic>> bills = await _supabase
          .from('bill_instances')
          .select()
          .order('status', ascending: false)
          .order('due_date', ascending: false);

      return bills; // Returns empty list if no rows found, which is fine
    } catch (e) {
      // Log the error for debugging
      print('Error fetching bills: $e');
      // Consider rethrowing or returning a custom Error object
      return [];
    }
  }
}
