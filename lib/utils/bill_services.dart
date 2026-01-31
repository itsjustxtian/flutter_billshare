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
      throw Exception('Failed to save bill: $e');
    }
  }

  Future<void> _saveSingleBill(Map<String, dynamic> formData) async {
    final billResponse = await _supabase
        .from('bill_instances')
        .insert({
          'title': formData['title'],
          'description': formData['description'],
          'amount_due': _parseAmount(formData['total_amount']),
          'due_date': (formData['due_date'] as DateTime).toIso8601String(),
          'members_snapshot': formData['members'],
          'status': formData['payment_status'] ? 'Paid' : 'Pending',
          'tag_color': formData['tag_color'],
        })
        .select('instance_id, amount_due, members_snapshot')
        .single();

    await _createPaymentRows(billResponse);
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
          'frequency': frequency.name,
          'members': formData['members'],
          'next_generation_date': nextDate.toIso8601String(),
          'tag_color': formData['tag_color'],
        })
        .select()
        .single();

    final billResponse = await _supabase
        .from('bill_instances')
        .insert({
          'template_id': template['template_id'],
          'title': formData['title'],
          'description': formData['description'],
          'amount_due': _parseAmount(formData['total_amount']),
          'due_date': firstDueDate.toIso8601String(),
          'members_snapshot': formData['members'],
          'status': formData['payment_status'] ? 'Paid' : 'Pending',
          'tag_color': formData['tag_color'],
        })
        .select('instance_id, amount_due, members_snapshot')
        .single();

    await _createPaymentRows(billResponse);
  }

  Future<void> _createPaymentRows(Map<String, dynamic> billData) async {
    final String instanceId = billData['instance_id'];
    final double totalAmount = _parseAmount(billData['amount_due']);
    final List<dynamic> members = billData['members_snapshot'] ?? [];

    if (members.isEmpty) return;

    final double splitAmount = totalAmount / members.length;

    final List<Map<String, dynamic>> paymentRows = members.map((name) {
      return {
        'instance_id': instanceId,
        'member_name': name.toString(),
        'amount_owed': splitAmount,
        'amount_paid': 0.0,
        'user_id': _supabase.auth.currentUser?.id,
      };
    }).toList();

    await _supabase.from('bill_payments').insert(paymentRows);
  }

  Future<List<Map<String, dynamic>>> fetchPaymentsForBill(
    String instanceId,
  ) async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from('bill_payments')
          .select()
          .eq('instance_id', instanceId)
          .order('member_name', ascending: true);

      return response;
    } catch (e) {
      throw Exception('Failed to fetch payments: $e');
    }
  }

  /// Records a specific partial payment amount
  Future<void> recordPartialPayment(String paymentId, double newTotal) async {
    await _supabase
        .from('bill_payments')
        .update({
          'amount_paid': newTotal,
          'paid_at': DateTime.now().toIso8601String(),
        })
        .eq('payment_id', paymentId);
  }

  Future<void> updateBillStatus(String instanceId, String status) async {
    await _supabase
        .from('bill_instances')
        .update({'status': status})
        .eq('instance_id', instanceId);
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

class BillInstance {
  final String instanceId;
  final String? templateId;
  final String createdBy;
  final String title;
  final String? description;
  final double amountDue;
  final DateTime dueDate;
  final List<dynamic> membersSnapshot; // Maps to jsonb
  String status;
  final DateTime? createdAt;
  final String? tagColor;

  BillInstance({
    required this.instanceId,
    this.templateId,
    required this.createdBy,
    required this.title,
    this.description,
    required this.amountDue,
    required this.dueDate,
    required this.membersSnapshot,
    required this.status,
    this.createdAt,
    this.tagColor,
  });

  factory BillInstance.fromMap(Map<String, dynamic> map) {
    return BillInstance(
      instanceId: map['instance_id'],
      templateId: map['template_id'],
      createdBy: map['created_by'],
      title: map['title'],
      description: map['description'],
      amountDue: (map['amount_due'] as num).toDouble(),
      dueDate: DateTime.parse(map['due_date']),
      membersSnapshot: List<dynamic>.from(map['members_snapshot'] ?? []),
      status: map['status'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      tagColor: map['tag_color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (instanceId.isNotEmpty) 'instance_id': instanceId,
      'template_id': templateId,
      'created_by': createdBy,
      'title': title,
      'description': description,
      'amount_due': amountDue,
      'due_date': dueDate.toIso8601String(),
      'members_snapshot': membersSnapshot,
      'status': status,
      'tag_color': tagColor,
    };
  }
}

class BillPayments {
  final String paymentId;
  final String? instanceId;
  final String memberName;
  final double amountOwed;
  double? amountPaid;
  final DateTime? paidAt;
  final String userId;

  BillPayments({
    required this.paymentId,
    this.instanceId,
    required this.memberName,
    required this.amountOwed,
    this.amountPaid,
    this.paidAt,
    required this.userId,
  });

  factory BillPayments.fromMap(Map<String, dynamic> map) {
    return BillPayments(
      paymentId: map['payment_id'],
      instanceId: map['instance_id'],
      memberName: map['member_name'] ?? 'Unknown',
      amountOwed: (map['amount_owed'] as num).toDouble(),
      amountPaid: (map['amount_paid'] as num? ?? 0).toDouble(),
      paidAt: map['paid_at'] != null ? DateTime.parse(map['paid_at']) : null,
      userId: map['user_id'] ?? '',
    );
  }
}
