import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../models/event_model.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1, hours: 2));
  bool _isFree = true;
  bool _hasVipOptions = false;
  bool _hasComboDeals = false;
  List<String> _tags = [];
  List<VipTier> _vipTiers = [];
  List<ComboDiscount> _comboDiscounts = [];
  bool _isLoading = false;

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDate),
      );
      if (time != null) {
        setState(() {
          _startDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          // Ensure end date is after start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(hours: 2));
          }
        });
      }
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endDate),
      );
      if (time != null) {
        setState(() {
          _endDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        String newTag = '';
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            onChanged: (value) => newTag = value,
            decoration: const InputDecoration(hintText: 'Enter tag'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                if (newTag.isNotEmpty) {
                  setState(() {
                    _tags.add(newTag);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  void _addVipTier() {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String description = '';
        double price = 0;
        int maxAttendees = 0;
        List<String> benefits = [];

        return AlertDialog(
          title: const Text('Add VIP Tier'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => name = value,
                  decoration: const InputDecoration(labelText: 'Tier Name'),
                ),
                TextField(
                  onChanged: (value) => description = value,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  onChanged: (value) => price = double.tryParse(value) ?? 0,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price per Person'),
                ),
                TextField(
                  onChanged: (value) => maxAttendees = int.tryParse(value) ?? 0,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Max Attendees'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        String benefit = '';
                        return AlertDialog(
                          title: const Text('Add Benefit'),
                          content: TextField(
                            onChanged: (value) => benefit = value,
                            decoration: const InputDecoration(labelText: 'Benefit'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (benefit.isNotEmpty) {
                                  benefits.add(benefit);
                                }
                                Navigator.pop(context);
                              },
                              child: const Text('ADD'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('ADD BENEFIT'),
                ),
                if (benefits.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Benefits:'),
                  ...benefits.map((b) => Text('• $b')),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && description.isNotEmpty && price > 0 && maxAttendees > 0) {
                  setState(() {
                    _vipTiers.add(VipTier(
                      id: DateTime.now().toString(),
                      name: name,
                      description: description,
                      pricePerPerson: price,
                      benefits: benefits,
                      maxAttendees: maxAttendees,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  void _addComboDiscount() {
    showDialog(
      context: context,
      builder: (context) {
        int minPeople = 0;
        int maxPeople = 0;
        double discount = 0;
        String description = '';

        return AlertDialog(
          title: const Text('Add Group Discount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => minPeople = int.tryParse(value) ?? 0,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Minimum People'),
              ),
              TextField(
                onChanged: (value) => maxPeople = int.tryParse(value) ?? 0,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Maximum People'),
              ),
              TextField(
                onChanged: (value) => discount = double.tryParse(value) ?? 0,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Discount Percentage'),
              ),
              TextField(
                onChanged: (value) => description = value,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                if (minPeople > 0 && maxPeople >= minPeople && discount > 0 && description.isNotEmpty) {
                  setState(() {
                    _comboDiscounts.add(ComboDiscount(
                      minPeople: minPeople,
                      maxPeople: maxPeople,
                      discountPercentage: discount,
                      description: description,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final event = EventModel(
        id: DateTime.now().toString(), // Backend will generate actual ID
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
        location: _locationController.text,
        organizerId: 'current_user_id', // TODO: Get from auth provider
        organizerName: 'Current User', // TODO: Get from auth provider
        maxAttendees: int.parse(_maxAttendeesController.text),
        isFree: _isFree,
        price: _isFree ? null : double.parse(_priceController.text),
        tags: _tags,
        hasVipOptions: _hasVipOptions,
        hasComboDeals: _hasComboDeals,
        vipTiers: _vipTiers,
        comboDiscounts: _comboDiscounts,
      );

      final success = await context.read<EventProvider>().createEvent(event);

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/events');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic details
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Event Title'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a title' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a description' : null,
            ),

            const SizedBox(height: 16),

            // Date and time
            ListTile(
              title: const Text('Start Date & Time'),
              subtitle: Text(
                '${_startDate.day}/${_startDate.month}/${_startDate.year} at ${_startDate.hour}:${_startDate.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectStartDate,
            ),

            ListTile(
              title: const Text('End Date & Time'),
              subtitle: Text(
                '${_endDate.day}/${_endDate.month}/${_endDate.year} at ${_endDate.hour}:${_endDate.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectEndDate,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a location' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _maxAttendeesController,
              decoration: const InputDecoration(labelText: 'Maximum Attendees'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter max attendees';
                final number = int.tryParse(value!);
                if (number == null || number <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Price settings
            SwitchListTile(
              title: const Text('Free Event'),
              value: _isFree,
              onChanged: (value) => setState(() => _isFree = value),
            ),

            if (!_isFree)
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_isFree) return null;
                  if (value?.isEmpty ?? true) return 'Please enter a price';
                  final number = double.tryParse(value!);
                  if (number == null || number <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),

            const SizedBox(height: 16),

            // Tags
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tags',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addTag,
                          icon: const Icon(Icons.add),
                          label: const Text('ADD'),
                        ),
                      ],
                    ),
                    if (_tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: _tags
                            .map((tag) => Chip(
                                  label: Text(tag),
                                  onDeleted: () => setState(() => _tags.remove(tag)),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // VIP options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('VIP Options'),
                      value: _hasVipOptions,
                      onChanged: (value) => setState(() => _hasVipOptions = value),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_hasVipOptions) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('VIP Tiers'),
                          TextButton.icon(
                            onPressed: _addVipTier,
                            icon: const Icon(Icons.add),
                            label: const Text('ADD'),
                          ),
                        ],
                      ),
                      if (_vipTiers.isNotEmpty)
                        ...(_vipTiers.map((tier) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(tier.name),
                                subtitle: Text(tier.description),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => setState(() => _vipTiers.remove(tier)),
                                ),
                              ),
                            ))),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Combo deals
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('Group Discounts'),
                      value: _hasComboDeals,
                      onChanged: (value) => setState(() => _hasComboDeals = value),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_hasComboDeals) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Discounts'),
                          TextButton.icon(
                            onPressed: _addComboDiscount,
                            icon: const Icon(Icons.add),
                            label: const Text('ADD'),
                          ),
                        ],
                      ),
                      if (_comboDiscounts.isNotEmpty)
                        ...(_comboDiscounts.map((combo) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text('${combo.discountPercentage}% off'),
                                subtitle: Text(combo.description),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      setState(() => _comboDiscounts.remove(combo)),
                                ),
                              ),
                            ))),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createEvent,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('CREATE EVENT'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxAttendeesController.dispose();
    _priceController.dispose();
    super.dispose();
  }
} 