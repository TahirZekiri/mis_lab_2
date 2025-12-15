import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meal_preview.dart';
import 'device_id_service.dart';

class FavoritesService extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final DeviceIdService _deviceIdService;
  String? _deviceId;

  final Map<String, MealPreview> _favoritesById = {};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  Object? _lastError;

  FavoritesService({
    FirebaseFirestore? firestore,
    DeviceIdService? deviceIdService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _deviceIdService = deviceIdService ?? DeviceIdService();

  Object? get lastError => _lastError;

  List<MealPreview> get favorites => _favoritesById.values.toList()
    ..sort((a, b) => a.strMeal.toLowerCase().compareTo(b.strMeal.toLowerCase()));

  bool isFavorite(String idMeal) => _favoritesById.containsKey(idMeal);

  Future<void> init() async {
    try {
      _deviceId = await _deviceIdService.getOrCreate();
      _subscribe(_deviceId!);
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _lastError = e;
      notifyListeners();
    }
  }

  void _subscribe(String deviceId) {
    _subscription?.cancel();
    _subscription = _firestore
        .collection('device_favorites')
        .doc(deviceId)
        .collection('favorites')
        .snapshots()
        .listen((snapshot) {
      final next = <String, MealPreview>{};
      for (final doc in snapshot.docs) {
        final preview = MealPreview.fromJson(doc.data());
        if (preview.idMeal.isNotEmpty) {
          next[preview.idMeal] = preview;
        }
      }
      _favoritesById
        ..clear()
        ..addAll(next);
      _lastError = null;
      notifyListeners();
    }, onError: (e) {
      _lastError = e;
      notifyListeners();
    });
  }

  Future<bool> toggle(MealPreview meal) async {
    if (meal.idMeal.isEmpty) return false;
    try {
      final deviceId = _deviceId ?? await _deviceIdService.getOrCreate();
      _deviceId = deviceId;
      final docRef = _firestore
          .collection('device_favorites')
          .doc(deviceId)
          .collection('favorites')
          .doc(meal.idMeal);

      if (_favoritesById.containsKey(meal.idMeal)) {
        await docRef.delete();
      } else {
        await docRef.set(meal.toJson());
      }
      _lastError = null;
      return true;
    } catch (e) {
      _lastError = e;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}


