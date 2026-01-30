import 'package:flutter/material.dart';
import 'package:flutter_billshare/screens/settings.dart';
import 'package:flutter_billshare/utils/utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  final UserInfo profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final editProfileKey = GlobalKey<ShadFormState>();
  final _supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> _submitChanges() async {
    if (!(editProfileKey.currentState?.saveAndValidate() ?? false)) return;

    final values = editProfileKey.currentState!.value;
    final String fullName = values['full_name'];
    final String username = values['username'];
    final String avatarUrl = values['avatar_url'];
    final String websiteUrl = values['website_url'];

    setState(() => isLoading = true);

    try {
      await _supabase
          .from('profiles')
          .update({
            'full_name': fullName,
            'username': username,
            'avatar_url': avatarUrl,
            'website': websiteUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.profile.id);

      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(description: Text('Profile updated successfully!')),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text('Failed to update profile: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(8),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ShadForm(
              key: editProfileKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton(
                        backgroundColor: context.darkGreen,

                        leading: isLoading
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.receipt_long, size: 18),
                        onPressed: isLoading ? null : _submitChanges,
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                  ShadInputFormField(
                    id: 'full_name',
                    initialValue: widget.profile.fullName,
                    enabled: isLoading == true ? false : true,
                    label: Text('Full Name'),
                    placeholder: const Text('ex. "Juan Dela Cruz"'),
                    decoration: context.addBillFormInputDecoration,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 8),
                  ShadInputFormField(
                    id: 'username',
                    initialValue: widget.profile.username,
                    enabled: isLoading == true ? false : true,
                    label: Text('Username'),
                    placeholder: const Text('ex. "Juan"'),
                    decoration: context.addBillFormInputDecoration,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 8),
                  ShadInputFormField(
                    id: 'avatar_url',
                    initialValue: widget.profile.avatarUrl,
                    enabled: isLoading == true ? false : true,
                    label: Text('Avatar URL'),
                    placeholder: const Text(
                      'Enter a link of an image available online',
                    ),
                    decoration: context.addBillFormInputDecoration,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 8),
                  ShadInputFormField(
                    id: 'website_url',
                    initialValue: widget.profile.websiteUrl,
                    enabled: isLoading == true ? false : true,
                    label: Text('Website URL'),
                    placeholder: const Text(
                      'Enter a link where people can find you.',
                    ),
                    decoration: context.addBillFormInputDecoration,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
