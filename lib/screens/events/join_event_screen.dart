import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../models/event_model.dart';

class JoinEventScreen extends StatefulWidget {
  const JoinEventScreen({Key? key}) : super(key: key);

  @override
  _JoinEventScreenState createState() => _JoinEventScreenState();
}

class _JoinEventScreenState extends State<JoinEventScreen> {
  late EventModel _event;
  VipTier? _selectedTier;
  int _groupSize = 1;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get event from route arguments
    _event = ModalRoute.of(context)!.settings.arguments as EventModel;
    // Set default tier if VIP options are available
    if (_event.hasVipOptions && _event.vipTiers.isNotEmpty) {
      _selectedTier = _event.vipTiers.first;
    }
  }

  double _calculateTotal() {
    if (_event.isFree) return 0;

    double basePrice = _selectedTier?.pricePerPerson ?? _event.price ?? 0;
    double total = basePrice * _groupSize;

    // Apply combo discount if applicable
    if (_event.hasComboDeals) {
      for (var combo in _event.comboDiscounts) {
        if (_groupSize >= combo.minPeople && _groupSize <= combo.maxPeople) {
          total = total * (1 - combo.discountPercentage / 100);
          break;
        }
      }
    }

    return total;
  }

  String? _getApplicableDiscount() {
    if (!_event.hasComboDeals) return null;

    for (var combo in _event.comboDiscounts) {
      if (_groupSize >= combo.minPeople && _groupSize <= combo.maxPeople) {
        return '${combo.discountPercentage}% off - ${combo.description}';
      }
    }

    return null;
  }

  Future<void> _joinEvent() async {
    setState(() => _isLoading = true);

    try {
      final success = await context.read<EventProvider>().joinEvent(
        _event.id,
        'current_user_id', // TODO: Get from auth provider
        selectedTier: _selectedTier,
        groupSize: _groupSize,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/events/confirmation',
          arguments: {
            'event': _event,
            'tier': _selectedTier,
            'groupSize': _groupSize,
            'total': _calculateTotal(),
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join event: $e')),
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
        title: const Text('Join Event'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Event summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _event.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(_event.formattedDate),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 8),
                      Text(_event.formattedTime),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_event.location)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // VIP tier selection
          if (_event.hasVipOptions) ...[
            const Text(
              'Select Tier',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...(_event.vipTiers.map((tier) => RadioListTile<VipTier>(
              value: tier,
              groupValue: _selectedTier,
              onChanged: tier.isFull
                  ? null
                  : (value) => setState(() => _selectedTier = value),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tier.name),
                  Text('\$${tier.pricePerPerson}'),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tier.description),
                  if (tier.isFull)
                    const Text(
                      'FULL',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ))),
            const SizedBox(height: 24),
          ],

          // Group size selection
          const Text(
            'Number of People',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: _groupSize > 1
                    ? () => setState(() => _groupSize--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 16),
              Text(
                _groupSize.toString(),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _groupSize < (_event.maxAttendees - _event.currentAttendees)
                    ? () => setState(() => _groupSize++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Price breakdown
          const Text(
            'Price Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Base Price'),
                      Text(
                        _event.isFree
                            ? 'FREE'
                            : '\$${_selectedTier?.pricePerPerson ?? _event.price}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Number of People'),
                      Text('× $_groupSize'),
                    ],
                  ),
                  if (_getApplicableDiscount() != null) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Group Discount'),
                        Text(
                          _getApplicableDiscount()!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _event.isFree ? 'FREE' : '\$${_calculateTotal().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _joinEvent,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('CONFIRM'),
          ),
        ),
      ),
    );
  }
} 