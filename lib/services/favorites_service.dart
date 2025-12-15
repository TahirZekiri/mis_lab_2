import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_preview.dart';

class FavoritesService extends ChangeNotifier {
  static const _storageKey = 'favorite_meals';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final Map<String, MealPreview> _favoritesById = {};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  FavoritesService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  List<MealPreview> get favorites => _favoritesById.values.toList()
    ..sort((a, b) => a.strMeal.toLowerCase().compareTo(b.strMeal.toLowerCase()));

  bool isFavorite(String idMeal) => _favoritesById.containsKey(idMeal);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw);
    if (decoded is! List) return;

    _favoritesById
      ..clear()
      ..addEntries(
        decoded.whereType<Map>().map((e) {
          final map = e.map((k, v) => MapEntry(k.toString(), v));
          final preview = MealPreview.fromJson(map);
          return MapEntry(preview.idMeal, preview);
        }),
      );
    notifyListeners();
  }

  Future<void> connectToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;
    _subscription?.cancel();
    _subscription = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .listen((snapshot) async {
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
      notifyListeners();
      await _persist();
    });
  }

  Future<void> toggle(MealPreview meal) async {
    if (meal.idMeal.isEmpty) return;
    final user = _auth.currentUser;
    final docRef = user == null
        ? null
        : _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(meal.idMeal);

    if (_favoritesById.containsKey(meal.idMeal)) {
      _favoritesById.remove(meal.idMeal);
      if (docRef != null) {
        await docRef.delete();
      }
    } else {
      _favoritesById[meal.idMeal] = meal;
      if (docRef != null) {
        await docRef.set(meal.toJson());
      }
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_favoritesById.values.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}


