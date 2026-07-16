import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late double _amount;
  late TransactionType _type;
  late String _reason;
  late String _category;
  late DateTime _date;
  String? _notes;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amount = widget.transaction!.amount;
      _type = widget.transaction!.type;
      _reason = widget.transaction!.reason;
      _category = widget.transaction!.category;
      _date = widget.transaction!.date;
      _notes = widget.transaction!.notes;
    } else {
      _amount = 0;
      _type = TransactionType.credit;
      _reason = '';
      _category = AppConstants.creditCategories.first;
      _date = DateTime.now();
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final newTxn = Transaction()
        ..amount = _amount
        ..type = _type
        ..reason = _reason
        ..category = _category
        ..date = _date
        ..notes = _notes
        ..createdAt = widget.transaction?.createdAt ?? DateTime.now()
        ..updatedAt = DateTime.now();

      if (widget.transaction != null) {
        newTxn.id = widget.transaction!.id;
      }

      await ref.read(transactionRepositoryProvider).saveTransaction(newTxn);
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    final categories = _type == TransactionType.credit 
        ? AppConstants.creditCategories 
        : AppConstants.debitCategories;

    if (!categories.contains(_category)) {
      _category = categories.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.credit,
                    label: Text('Credit'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: TransactionType.debit,
                    label: Text('Debit'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (Set<TransactionType> selection) {
                  setState(() {
                    _type = selection.first;
                  });
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: _amount == 0 ? '' : _amount.toString(),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter amount';
                  if (double.tryParse(val) == null) return 'Enter valid number';
                  return null;
                },
                onSaved: (val) => _amount = double.parse(val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _reason,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter reason' : null,
                onSaved: (val) => _reason = val!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _category = val!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(AppFormatters.date(_date)),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => _notes = val,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('SAVE TRANSACTION', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
