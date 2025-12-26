import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/subscription.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final Subscription? existing;
  final int? existingKey;

  const AddSubscriptionScreen({super.key, this.existing, this.existingKey});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _costCtrl = TextEditingController();

  String _cycle = 'Monthly';
  String _category = 'Other';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    if (s != null) {
      _nameCtrl.text = s.subName;
      _costCtrl.text = s.cost.toStringAsFixed(0);
      _cycle = s.cycle;
      _category = s.category;
      _dueDate = s.nextDueDate;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final cost = double.parse(_costCtrl.text.trim());

    final box = Hive.box<Subscription>('subscriptions');

    // If editing, keep the existing flags (cancel/reminder settings)
    final old = widget.existing;

    final updated = Subscription(
      subName: name,
      cost: cost,
      cycle: _cycle,
      nextDueMs: _dueDate.millisecondsSinceEpoch,
      category: _category,
      isCancelled: old?.isCancelled ?? false,
      remindersOn: old?.remindersOn ?? false,
      remindDaysBefore: old?.remindDaysBefore ?? 3,
    );

    if (widget.existingKey != null) {
      await box.put(widget.existingKey, updated);
    } else {
      await box.add(updated);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.existingKey == null ? 'Add Subscription' : 'Edit Subscription';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Netflix, Spotify...',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cost (₹)',
                  hintText: '199',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter a cost';
                  final n = double.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _cycle,
                decoration: const InputDecoration(
                  labelText: 'Billing cycle',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'Yearly', child: Text('Yearly')),
                ],
                onChanged: (v) => setState(() => _cycle = v ?? 'Monthly'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Streaming', child: Text('Streaming')),
                  DropdownMenuItem(value: 'Music', child: Text('Music')),
                  DropdownMenuItem(value: 'Gaming', child: Text('Gaming')),
                  DropdownMenuItem(value: 'Productivity', child: Text('Productivity')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'Other'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event),
                label: Text('Next due: ${_dueDate.toLocal().toString().split(' ').first}'),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
