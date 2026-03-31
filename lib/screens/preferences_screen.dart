import 'package:emailsummaryagent/models/enums.dart';
import 'package:emailsummaryagent/models/user_preferences.dart';
import 'package:emailsummaryagent/models/user_profile.dart';
import 'package:emailsummaryagent/services/app_backend.dart';
import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({
    super.key,
    required this.backend,
    required this.profile,
    required this.isInitialSetup,
    this.initialSetupDestinationBuilder,
  });

  final AppBackend backend;
  final UserProfile profile;
  final bool isInitialSetup;
  final Widget Function(UserPreferences preferences)?
  initialSetupDestinationBuilder;

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late SummaryType _summaryType;
  late EmailFilter _emailFilter;
  late SummaryStyle _summaryStyle;
  late DeliveryMethod _deliveryMethod;
  late TextEditingController _countController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _summaryType = widget.profile.preferences.summaryType;
    _emailFilter = widget.profile.preferences.emailFilter;
    _summaryStyle = widget.profile.preferences.summaryStyle;
    _deliveryMethod = widget.profile.preferences.deliveryMethod;
    _countController = TextEditingController(
      text: widget.profile.preferences.numberOfEmails.toString(),
    );
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final count = int.tryParse(_countController.text.trim());
    if (count == null || count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Number of emails must be greater than 0.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final prefs = UserPreferences(
      summaryType: _summaryType,
      emailFilter: _emailFilter,
      numberOfEmails: count,
      summaryStyle: _summaryStyle,
      deliveryMethod: _deliveryMethod,
    );

    await widget.backend.savePreferences(widget.profile.uid, prefs);

    if (!mounted) {
      return;
    }

    if (widget.isInitialSetup) {
      final destinationBuilder = widget.initialSetupDestinationBuilder;
      if (destinationBuilder == null) {
        Navigator.of(context).pop();
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destinationBuilder(prefs)),
      );
    } else {
      Navigator.of(context).pop(prefs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isInitialSetup ? 'Set Preferences' : 'Edit Preferences',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<SummaryType>(
            value: _summaryType,
            decoration: const InputDecoration(labelText: 'Summary Type'),
            items: SummaryType.values
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.label)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _summaryType = value);
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmailFilter>(
            value: _emailFilter,
            decoration: const InputDecoration(labelText: 'Email Filter'),
            items: EmailFilter.values
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.label)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _emailFilter = value);
              }
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _countController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Number of Emails per Batch',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<SummaryStyle>(
            value: _summaryStyle,
            decoration: const InputDecoration(labelText: 'Summary Style'),
            items: SummaryStyle.values
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.label)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _summaryStyle = value);
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<DeliveryMethod>(
            value: _deliveryMethod,
            decoration: const InputDecoration(labelText: 'Delivery Method'),
            items: DeliveryMethod.values
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.label)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _deliveryMethod = value);
              }
            },
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(
              widget.isInitialSetup ? 'Save & Continue' : 'Save Changes',
            ),
          ),
        ],
      ),
    );
  }
}
