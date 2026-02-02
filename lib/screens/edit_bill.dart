import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_billshare/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_billshare/utils/bill_services.dart';

class EditBillPage extends StatefulWidget {
  final BillInstance bill;
  const EditBillPage({super.key, required this.bill});

  @override
  State<EditBillPage> createState() => _EditBillPageState();
}

class _EditBillPageState extends State<EditBillPage> {
  final BillService _billService = BillService();
  final editBillFormKey = GlobalKey<ShadFormState>();
  final ValueNotifier<bool> isPaidNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isRecurringNotifier = ValueNotifier<bool>(false);
  final TextEditingController _memberController = TextEditingController();
  final ValueNotifier<DateTime?> dueDateNotifier = ValueNotifier<DateTime?>(
    DateTime.now(),
  );
  bool isLoading = false;

  void submitForm() async {
    if (!editBillFormKey.currentState!.validate()) return;

    editBillFormKey.currentState!.save();

    final formData = Map<String, dynamic>.from(
      editBillFormKey.currentState!.value,
    );

    if (formData['tag_color'] is BillColor) {
      formData['tag_color'] = (formData['tag_color'] as BillColor).hex;
    }

    setState(() => isLoading = true);

    try {
      await _billService.updateBillInstance(
        formData: formData,
        instanceId: widget.bill.instanceId,
      );

      if (!mounted) return;

      final sonner = ShadSonner.of(context);
      final id = Random().nextInt(1000);

      sonner.show(
        ShadToast(
          id: id,
          title: const Text('Bill successfully saved!'),
          backgroundColor: const Color(0xFFDBF6DA),
          action: ShadButton(
            backgroundColor: const Color(0xFF24240F),
            child: const Text('Close'),
            onPressed: () => sonner.hide(id),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final sonner = ShadSonner.of(context);
      final id = Random().nextInt(1000);
      sonner.show(
        ShadToast.destructive(
          id: id,
          title: const Text('Failed to save bill'),
          description: Text(e.toString()),
          action: ShadButton.destructive(
            child: const Text('Close'),
            onPressed: () => sonner.hide(id),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _memberController.dispose();
    isPaidNotifier.dispose();
    isRecurringNotifier.dispose();
    dueDateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialColor = billPalette.firstWhere(
      (bc) => bc.hex == widget.bill.tagColor,
      orElse: () => billPalette.first,
    );

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 8),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ShadForm(
          key: editBillFormKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ShadButton(
                      backgroundColor: context.darkGreen,
                      hoverBackgroundColor: context.darkGreen.withValues(
                        alpha: 0.8,
                      ),
                      leading: const Icon(Icons.receipt_long, size: 18),

                      child: const Text('Update Bill'),
                      onPressed: () {
                        submitForm();
                      },
                    ),
                  ],
                ),
                ShadSelectFormField<BillColor>(
                  id: 'tag_color',
                  minWidth: 350,
                  label: const Text('Bill Color'),
                  initialValue: initialColor,
                  decoration: context.addBillFormInputDecoration,
                  options: billPalette
                      .map(
                        (bc) => ShadOption(
                          value: bc,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: bc.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(bc.name),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  selectedOptionBuilder: (context, bc) => Row(
                    children: [
                      CircleAvatar(backgroundColor: bc.color, radius: 8),
                      const SizedBox(width: 12),
                      Text(bc.name),
                    ],
                  ),
                  validator: (v) => v == null ? 'Please select a color' : null,
                ),
                SizedBox(height: 8),
                ShadInputFormField(
                  id: 'title',
                  initialValue: widget.bill.title,
                  enabled: isLoading == true ? false : true,
                  label: Text('Bill Title'),
                  placeholder: const Text('Enter the title for this bill...'),
                  decoration: context.addBillFormInputDecoration,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  validator: (v) {
                    if (v.isEmpty) {
                      return 'Bill title is required.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8),
                ShadInputFormField(
                  id: 'description',
                  initialValue: widget.bill.description,
                  enabled: isLoading == true ? false : true,
                  label: Text('Bill Description'),
                  placeholder: const Text(
                    'Add information on what the bill is about...',
                  ),
                  minLines: 3,
                  maxLines: 5,
                  decoration: context.addBillFormInputDecoration,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 8),
                ShadInputFormField(
                  id: 'total_amount',
                  initialValue: widget.bill.amountDue.toStringAsFixed(2),
                  enabled: isLoading == true ? false : true,
                  label: Text('Total Amount to Pay'),
                  placeholder: const Text('ex. "2000.00"'),
                  leading: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('PHP'),
                  ),
                  decoration: context.addBillFormInputDecoration,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  validator: (v) {
                    if (v.isEmpty) {
                      return 'Please enter an amount';
                    }

                    final currencyRegEx = RegExp(r'^\d*\.?\d*$');

                    if (!currencyRegEx.hasMatch(v)) {
                      return 'Please enter a valid number (e.g., 12.50) and do not include commas.';
                    }

                    final double? amount = double.tryParse(v);
                    if (amount == null || amount <= 0) {
                      return 'Amount must be greater than 0';
                    }

                    return null;
                  },
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ShadDatePickerFormField(
                      id: 'due_date',
                      enabled: isLoading == true ? false : true,
                      initialValue: widget.bill.dueDate,
                      label: const Text('Due Date'),
                      onChanged: (date) {
                        dueDateNotifier.value = date;
                      },
                      closeOnSelection: true,
                      backgroundColor: context.white,
                      buttonDecoration: ShadDecoration(
                        border: ShadBorder.all(
                          width: 1,
                          color: context.darkGreen,
                        ),
                      ),
                      popoverDecoration: ShadDecoration(
                        color: context.white,
                        border: ShadBorder.all(
                          width: 1,
                          color: context.darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ShadFormBuilderField<List<String>>(
                  id: 'members',
                  enabled: isLoading == true ? false : true,
                  initialValue: List<String>.from(
                    widget.bill.membersSnapshot.map((e) => e.toString()),
                  ),
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShadInputFormField(
                          enabled: isLoading == true ? false : true,
                          controller: _memberController,
                          label: Text(
                            'Bill Members',
                            style: GoogleFonts.poppins(
                              color: context.darkGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          placeholder: const Text(
                            'Enter names (e.g. John, Jane, Bob) and then press Done...',
                          ),
                          decoration: context.addBillFormInputDecoration,
                          textInputAction: TextInputAction.done,

                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              final currentList = List<String>.from(
                                state.value ?? [],
                              );

                              final List<String> newNames = value
                                  .split(',')
                                  .map((name) => name.trim())
                                  .where((name) => name.isNotEmpty)
                                  .toList();

                              for (var name in newNames) {
                                if (!currentList.contains(name)) {
                                  currentList.add(name);
                                }
                              }

                              state.didChange(currentList);
                              _memberController.clear();
                            }
                          },
                        ),
                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: (state.value ?? []).map((name) {
                            return ShadBadge(
                              backgroundColor: context.darkGreen,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(color: context.white),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      if (isLoading == true) return;
                                      final currentList = List<String>.from(
                                        state.value!,
                                      );
                                      currentList.remove(name);
                                      state.didChange(currentList);
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 12,
                                      color: context.white.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BillColor {
  final String name;
  final String hex;
  final Color color;

  const BillColor(this.name, this.hex, this.color);
}

final List<BillColor> billPalette = [
  BillColor('Slate', '#64748B', const Color(0xFF64748B)),
  BillColor('Tomato', '#EF4444', const Color(0xFFEF4444)),
  BillColor('Amber', '#F59E0B', const Color(0xFFF59E0B)),
  BillColor('Emerald', '#10B981', const Color(0xFF10B981)),
  BillColor('Blue', '#3B82F6', const Color(0xFF3B82F6)),
  BillColor('Violet', '#8B5CF6', const Color(0xFF8B5CF6)),
  BillColor('Rose', '#F43F5E', const Color(0xFFF43F5E)),
];
