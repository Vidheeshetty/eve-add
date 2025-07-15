// File: lib/providers/event_provider.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/event_model.dart';
import '../config/api_config.dart';

class EventProvider extends ChangeNotifier {
  List<EventModel> _events = [];
  List<EventModel> _filteredEvents = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EventModel> get events => _events;
  List<EventModel> get filteredEvents => _filteredEvents.isEmpty ? _events : _filteredEvents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all events
  Future<void> fetchEvents() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse(ApiConfig.eventsEndpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['events'] != null) {
          _events = (data['events'] as List)
              .map((event) => EventModel.fromJson(event))
              .toList();
        }
      } else {
        _errorMessage = 'Failed to fetch events';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new event
  Future<bool> createEvent(EventModel event) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse(ApiConfig.createEventEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(event.toJson()),
      );

      if (response.statusCode == 201) {
        await fetchEvents(); // Refresh events list
        return true;
      } else {
        _errorMessage = 'Failed to create event';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Join event
  Future<bool> joinEvent(String eventId, String userId, {VipTier? selectedTier, int? groupSize}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('${ApiConfig.joinEventEndpoint}$eventId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'vipTierId': selectedTier?.id,
          'groupSize': groupSize,
        }),
      );

      if (response.statusCode == 200) {
        await fetchEvents(); // Refresh events list
        return true;
      } else {
        _errorMessage = 'Failed to join event';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get event details
  Future<EventModel?> getEventDetails(String eventId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.eventDetailsEndpoint}$eventId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EventModel.fromJson(data['event']);
      } else {
        _errorMessage = 'Failed to fetch event details';
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user's events
  Future<List<EventModel>> getUserEvents(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.myEventsEndpoint}$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['events'] != null) {
          return (data['events'] as List)
              .map((event) => EventModel.fromJson(event))
              .toList();
        }
      }
      return [];
    } catch (e) {
      _errorMessage = 'Error: $e';
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter events
  void filterEvents({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    bool? isFree,
    bool? hasVipOptions,
  }) {
    _filteredEvents = _events.where((event) {
      bool matches = true;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        matches = matches && (
          event.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(searchQuery.toLowerCase())
        );
      }

      if (startDate != null) {
        matches = matches && event.startDate.isAfter(startDate);
      }

      if (endDate != null) {
        matches = matches && event.endDate.isBefore(endDate);
      }

      if (tags != null && tags.isNotEmpty) {
        matches = matches && tags.any((tag) => event.tags.contains(tag));
      }

      if (isFree != null) {
        matches = matches && event.isFree == isFree;
      }

      if (hasVipOptions != null) {
        matches = matches && event.hasVipOptions == hasVipOptions;
      }

      return matches;
    }).toList();

    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _filteredEvents = [];
    notifyListeners();
  }
} 