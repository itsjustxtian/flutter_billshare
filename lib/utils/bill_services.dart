import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BillService {
  final _supabase = Supabase.instance.client;

  Future<void> saveBill({required Map<String, dynamic> formData}) async {
    final bool isRecurring = formData['is_recurring'] ?? false;

    try {
      if (isRecurring) {
        await _saveRecurringBill(formData);
      } else {
        await _saveSingleBill(formData);
      }
    } catch (e) {
      // print('Database Error: $e');
      throw Exception('Failed to save bill: $e');
    }
  }

  Future<void> _saveSingleBill(Map<String, dynamic> formData) async {
    await _supabase.from('bill_instances').insert({
      'title': formData['title'],
      'description': formData['description'],
      'amount_due': _parseAmount(formData['total_amount']),
      'due_date': (formData['due_date'] as DateTime).toIso8601String(),
      'members_snapshot': formData['members'],
      'status': formData['payment_status'] ? 'Paid' : 'Pending',
      'tag_color': formData['tag_color'],
    });
  }

  Future<void> _saveRecurringBill(Map<String, dynamic> formData) async {
    final DateTime firstDueDate = formData['due_date'] as DateTime;
    final frequency = formData['recurring_frequency'] as RecurringFrequency;

    final nextDate = _calculateNextDate(firstDueDate, frequency);

    final template = await _supabase
        .from('bill_templates')
        .insert({
          'title': formData['title'],
          'description': formData['description'],
          'base_amount': _parseAmount(formData['total_amount']),
          'frequency':
              (formData['recurring_frequency'] as RecurringFrequency).name,
          'members': formData['members'],
          'next_generation_date': nextDate.toIso8601String(),
          'tag_color': formData['tag_color'],
        })
        .select()
        .single();

    await _supabase.from('bill_instances').insert({
      'template_id': template['template_id'],
      'title': formData['title'],
      'description': formData['description'],
      'amount_due': _parseAmount(formData['total_amount']),
      'due_date': firstDueDate.toIso8601String(),
      'members_snapshot': formData['members'],
      'status': formData['payment_status'] ? 'Paid' : 'Pending',
      'tag_color': formData['tag_color'],
    });
  }

  double _parseAmount(dynamic val) {
    if (val is double) return val;
    return double.tryParse(val.toString()) ?? 0.0;
  }
}

enum RecurringFrequency {
  daily,
  weekly,
  monthly,
  yearly;

  String get message {
    return switch (this) {
      daily => 'Daily',
      weekly => 'Weekly',
      monthly => 'Monthly',
      yearly => 'Yearly',
    };
  }
}

String getFrequencyDescription(
  RecurringFrequency frequency,
  DateTime? dueDate,
) {
  if (dueDate == null) return frequency.message;

  switch (frequency) {
    case RecurringFrequency.daily:
      return 'Daily';
    case RecurringFrequency.weekly:
      final dayName = DateFormat('EEEE').format(dueDate);
      return 'Weekly, every $dayName';
    case RecurringFrequency.monthly:
      final dayOfMonth = DateFormat('d').format(dueDate);
      return 'Monthly, every $dayOfMonth${_getDaySuffix(dueDate.day)}';
    case RecurringFrequency.yearly:
      final monthDay = DateFormat('MMMM d').format(dueDate);
      return 'Yearly, every $monthDay';
  }
}

String _getDaySuffix(int day) {
  if (day >= 11 && day <= 13) return 'th';
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

DateTime _calculateNextDate(DateTime current, RecurringFrequency freq) {
  switch (freq) {
    case RecurringFrequency.daily:
      return current.add(const Duration(days: 1));
    case RecurringFrequency.weekly:
      return current.add(const Duration(days: 7));
    case RecurringFrequency.monthly:
      // Adds exactly one month, handling shorter months safely
      return DateTime(current.year, current.month + 1, current.day);
    case RecurringFrequency.yearly:
      return DateTime(current.year + 1, current.month, current.day);
  }
}
