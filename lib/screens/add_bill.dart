import 'package:flutter/material.dart';
import 'package:flutter_billshare/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddBillPage extends StatefulWidget {
  const AddBillPage({super.key});

  @override
  State<AddBillPage> createState() => _AddBillPageState();
}

class _AddBillPageState extends State<AddBillPage> {
  final addBillFormKey = GlobalKey<ShadFormState>();
  final ValueNotifier<bool> isPaidNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isRecurringNotifier = ValueNotifier<bool>(false);
  final TextEditingController _memberController = TextEditingController();

  @override
  void dispose() {
    _memberController.dispose();
    isPaidNotifier.dispose();
    isRecurringNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 8),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: addBillFormKey,
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
                      leading: const Icon(
                        Icons.receipt_long,
                        size: 18,
                      ), // Adds a nice bill icon
                      // onPressed: _submitForm,
                      child: const Text('Save New Bill'),
                    ),
                  ],
                ),
                ShadInputFormField(
                  id: 'title',
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
                  label: Text('Total Amount to Pay'),
                  placeholder: const Text('ex. "2000.00"'),
                  decoration: context.addBillFormInputDecoration,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  validator: (v) {
                    if (v.isEmpty) {
                      return 'Please enter an amount';
                    }

                    // RegEx: Allows numbers and exactly one optional decimal point
                    final currencyRegEx = RegExp(r'^\d*\.?\d*$');

                    if (!currencyRegEx.hasMatch(v)) {
                      return 'Please enter a valid number (e.g., 12.50) and do not include commas.';
                    }

                    // Optional: Check if the number is actually greater than zero
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
                      initialValue: DateTime.now(),
                      label: const Text('Due Date'),
                      onChanged: print,
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
                  initialValue: const [],
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShadInputFormField(
                          controller: _memberController,
                          label: Text(
                            'Bill Members',
                            style: GoogleFonts.poppins(
                              color: context.darkGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          placeholder: const Text(
                            'Add names and press "Done"...',
                          ),
                          decoration: context.addBillFormInputDecoration,
                          textInputAction: TextInputAction.done,
                          // When user clicks "Done" on keyboard
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              // Create a new list from the current form state
                              final currentList = List<String>.from(
                                state.value ?? [],
                              );
                              if (!currentList.contains(value.trim())) {
                                currentList.add(value.trim());
                                state.didChange(
                                  currentList,
                                ); // Updates the ShadForm internal state
                              }
                              _memberController
                                  .clear(); // Clear input for next name
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        // Display the badges
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Bill Type',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: context.darkGreen,
                      ),
                    ),
                    SizedBox(width: 16),
                    ValueListenableBuilder<bool>(
                      valueListenable: isRecurringNotifier,
                      builder: (context, isRecurring, child) {
                        return ShadSwitchFormField(
                          id: 'is_recurring',
                          initialValue: isRecurring, // Keep this in sync
                          // Now the color logic actually reruns!
                          thumbColor: isRecurring
                              ? context.white
                              : context.darkGreen,
                          checkedTrackColor: context.darkBackground,
                          decoration: ShadDecoration(
                            border: ShadBorder.all(
                              width: 1,
                              color: context.darkGreen,
                            ),
                          ),
                          onChanged: (v) => isRecurringNotifier.value = v,
                          inputLabel: Text(
                            isRecurring ? 'Recurring' : 'Single Payment',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context.darkGreen,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Status',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: context.darkGreen,
                      ),
                    ),
                    SizedBox(width: 16),
                    ValueListenableBuilder<bool>(
                      valueListenable: isPaidNotifier,
                      builder: (context, isPaid, child) {
                        return ShadSwitchFormField(
                          id: 'payment_status',
                          initialValue: isPaid, // Keep this in sync
                          // Now the color logic actually reruns!
                          thumbColor: isPaid
                              ? context.white
                              : context.darkGreen,
                          checkedTrackColor: context.darkBackground,
                          decoration: ShadDecoration(
                            border: ShadBorder.all(
                              width: 1,
                              color: context.darkGreen,
                            ),
                          ),
                          onChanged: (v) => isPaidNotifier.value = v,
                          inputLabel: Text(
                            isPaid ? 'Paid' : 'Pending',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context.darkGreen,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
