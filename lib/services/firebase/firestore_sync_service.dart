import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import '../../models/bill.dart';
import '../../models/family_member.dart';
import '../../models/identity_document.dart';
import '../../models/medicine.dart';
import '../../models/money_entry.dart';
import '../../models/sim_card.dart';
import '../../models/task.dart';
import '../../models/warranty_product.dart';

/// Real-time Firebase Cloud Firestore synchronization service.
///
/// Dual-engine: Uses official Cloud Firestore SDK, with an automatic
/// direct Google Cloud Firestore REST API fallback if running on Web/Chrome
/// before SDK channels or scripts initialize.
class FirestoreSyncService {
  FirestoreSyncService._();
  static final FirestoreSyncService instance = FirestoreSyncService._();

  static const String _projectId = 'sheba-bondhu-6a56b';
  static const String _apiKey = 'AIzaSyCQ10mnzFaRBEmYNELW_75nQ0EizvcTPMo';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  Future<void> _ensureInitialized() async {
    if (Firebase.apps.isNotEmpty) return;
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('🔥 Firebase initialized on-demand in FirestoreSyncService');
    } catch (e) {
      try {
        await Firebase.initializeApp();
      } catch (_) {}
    }
  }

  String _cachedUid = 'default_user';

  Future<String> getUid() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.uid.isNotEmpty) {
          _cachedUid = user.uid;
          return _cachedUid;
        }
      }
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('userPhone');
      if (phone != null && phone.trim().isNotEmpty) {
        _cachedUid = 'user_${phone.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
        return _cachedUid;
      }
    } catch (_) {}
    return _cachedUid;
  }

  // --------------------------------------------------------------------------
  // REST API FALLBACK ENGINE (Guarantees Web/Chrome & Multiplatform Delivery)
  // --------------------------------------------------------------------------
  Map<String, dynamic> _toFirestoreRestFields(Map<String, dynamic> map) {
    final fields = <String, dynamic>{};
    for (final entry in map.entries) {
      final val = entry.value;
      if (val == null) {
        fields[entry.key] = {'nullValue': null};
      } else if (val is String) {
        fields[entry.key] = {'stringValue': val};
      } else if (val is int) {
        fields[entry.key] = {'integerValue': val.toString()};
      } else if (val is double) {
        fields[entry.key] = {'doubleValue': val};
      } else if (val is bool) {
        fields[entry.key] = {'booleanValue': val};
      } else if (val is List) {
        fields[entry.key] = {
          'arrayValue': {
            'values': val.map((item) => {'stringValue': item.toString()}).toList(),
          }
        };
      } else {
        fields[entry.key] = {'stringValue': val.toString()};
      }
    }
    return {'fields': fields};
  }

  Future<bool> _saveViaRest(String collection, String id, Map<String, dynamic> data) async {
    try {
      final url =
          'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/$collection/$id?key=$_apiKey';
      final body = _toFirestoreRestFields(data);
      final response = await _dio.patch(url, data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [Firestore REST] Saved $collection/$id successfully!');
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ [Firestore REST Error] $collection/$id: $e');
    }
    return false;
  }

  Future<void> _deleteViaRest(String collection, String id) async {
    try {
      final url =
          'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/$collection/$id?key=$_apiKey';
      await _dio.delete(url);
      debugPrint('✅ [Firestore REST] Deleted $collection/$id');
    } catch (e) {
      debugPrint('⚠️ [Firestore REST Delete Error]: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchViaRest(String collection) async {
    try {
      final url =
          'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/$collection?key=$_apiKey';
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        final docs = response.data['documents'] as List?;
        if (docs == null) return [];
        return docs.map((d) {
          final name = d['name'] as String? ?? '';
          final id = name.split('/').last;
          final rawFields = d['fields'] as Map<String, dynamic>? ?? {};
          final parsed = <String, dynamic>{'id': id};
          for (final f in rawFields.entries) {
            final fVal = f.value as Map<String, dynamic>;
            if (fVal.containsKey('stringValue')) {
              parsed[f.key] = fVal['stringValue'];
            } else if (fVal.containsKey('doubleValue')) {
              parsed[f.key] = (fVal['doubleValue'] as num).toDouble();
            } else if (fVal.containsKey('integerValue')) {
              parsed[f.key] = int.tryParse(fVal['integerValue'].toString()) ?? 0;
            } else if (fVal.containsKey('booleanValue')) {
              parsed[f.key] = fVal['booleanValue'];
            }
          }
          return parsed;
        }).toList();
      }
    } catch (e) {
      debugPrint('⚠️ [Firestore REST Fetch Error] $collection: $e');
    }
    return [];
  }

  // --------------------------------------------------------------------------
  // MONEY ENTRIES
  // --------------------------------------------------------------------------
  Future<void> saveMoney(MoneyEntry entry) async {
    final uid = await getUid();
    final data = entry.toMap();
    data['userId'] = uid;

    bool saved = false;
    try {
      await _ensureInitialized();
      if (Firebase.apps.isNotEmpty) {
        final db = FirebaseFirestore.instance;
        await db.collection('money').doc(entry.id).set(data, SetOptions(merge: true));
        saved = true;
        debugPrint('✅ [Firestore SDK] Saved money: ${entry.person} (৳${entry.amount})');
      }
    } catch (e) {
      debugPrint('⚠️ [Firestore SDK Error] $e. Using REST API fallback...');
    }

    if (!saved) {
      await _saveViaRest('money', entry.id, data);
    }
  }

  Future<void> deleteMoney(String id) async {
    try {
      await _ensureInitialized();
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance.collection('money').doc(id).delete();
      }
    } catch (_) {}
    await _deleteViaRest('money', id);
  }

  Future<List<MoneyEntry>> fetchMoney() async {
    final uid = await getUid();
    try {
      await _ensureInitialized();
      if (Firebase.apps.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection('money')
            .where('userId', isEqualTo: uid)
            .get();
        return snap.docs.map((d) => MoneyEntry.fromMap(d.data(), d.id)).toList();
      }
    } catch (_) {
      debugPrint('⚠️ [Firestore fetchMoney channel error]. Falling back to REST...');
    }

    final restList = await _fetchViaRest('money');
    return restList
        .where((m) => m['userId'] == uid)
        .map((m) => MoneyEntry.fromMap(m, m['id'] as String? ?? ''))
        .toList();
  }

  // --------------------------------------------------------------------------
  // BILLS
  // --------------------------------------------------------------------------
  Future<void> saveBill(Bill bill) async {
    final uid = await getUid();
    final data = bill.toMap();
    data['userId'] = uid;

    bool saved = false;
    try {
      await _ensureInitialized();
      if (Firebase.apps.isNotEmpty) {
        final db = FirebaseFirestore.instance;
        await db.collection('bills').doc(bill.id).set(data, SetOptions(merge: true));
        saved = true;
        debugPrint('✅ [Firestore SDK] Saved bill: ${bill.label} (৳${bill.amount})');
      }
    } catch (e) {
      debugPrint('⚠️ [Firestore SDK Error] $e. Using REST API fallback...');
    }

    if (!saved) {
      await _saveViaRest('bills', bill.id, data);
    }
  }

  Future<void> deleteBill(String id) async {
    try {
      await _ensureInitialized();
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance.collection('bills').doc(id).delete();
      }
    } catch (_) {}
    await _deleteViaRest('bills', id);
  }

  Future<List<Bill>> fetchBills() async {
    final uid = await getUid();
    try {
      await _ensureInitialized();
      if (Firebase.apps.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection('bills')
            .where('userId', isEqualTo: uid)
            .get();
        return snap.docs.map((d) => Bill.fromMap(d.data(), d.id)).toList();
      }
    } catch (_) {
      debugPrint('⚠️ [Firestore fetchBills channel error]. Falling back to REST...');
    }

    final restList = await _fetchViaRest('bills');
    return restList
        .where((m) => m['userId'] == uid)
        .map((m) => Bill.fromMap(m, m['id'] as String? ?? ''))
        .toList();
  }

  // --------------------------------------------------------------------------
  // TASKS
  // --------------------------------------------------------------------------
  Future<void> saveTask(Task task) async {
    final uid = await getUid();
    final data = task.toMap();
    data['userId'] = uid;

    bool saved = false;
    try {
      await _ensureInitialized();
      if (Firebase.apps.isNotEmpty) {
        final db = FirebaseFirestore.instance;
        await db.collection('tasks').doc(task.id).set(data, SetOptions(merge: true));
        saved = true;
        debugPrint('✅ [Firestore SDK] Saved task: ${task.title}');
      }
    } catch (e) {
      debugPrint('⚠️ [Firestore SDK Error] $e. Using REST API fallback...');
    }

    if (!saved) {
      await _saveViaRest('tasks', task.id, data);
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _ensureInitialized();
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance.collection('tasks').doc(id).delete();
      }
    } catch (_) {}
    await _deleteViaRest('tasks', id);
  }

  Future<List<Task>> fetchTasks() async {
    final uid = await getUid();
    try {
      await _ensureInitialized();
      if (Firebase.apps.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection('tasks')
            .where('userId', isEqualTo: uid)
            .get();
        return snap.docs.map((d) => Task.fromMap(d.data(), d.id)).toList();
      }
    } catch (_) {
      debugPrint('⚠️ [Firestore fetchTasks channel error]. Falling back to REST...');
    }

    final restList = await _fetchViaRest('tasks');
    return restList
        .where((m) => m['userId'] == uid)
        .map((m) => Task.fromMap(m, m['id'] as String? ?? ''))
        .toList();
  }

  // --------------------------------------------------------------------------
  // MEDICINES
  // --------------------------------------------------------------------------
  Future<void> saveMedicine(Medicine medicine) async {
    final uid = await getUid();
    final data = medicine.toMap();
    data['userId'] = uid;

    bool saved = false;
    try {
      await _ensureInitialized();
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('medicines')
            .doc(medicine.id)
            .set(data, SetOptions(merge: true));
        saved = true;
      }
    } catch (_) {}

    if (!saved) {
      await _saveViaRest('medicines', medicine.id, data);
    }
  }

  Future<void> deleteMedicine(String id) async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance.collection('medicines').doc(id).delete();
      }
    } catch (_) {}
    await _deleteViaRest('medicines', id);
  }

  Future<List<Medicine>> fetchMedicines() async {
    final uid = await getUid();
    try {
      if (Firebase.apps.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection('medicines')
            .where('userId', isEqualTo: uid)
            .get();
        return snap.docs.map((d) => Medicine.fromMap(d.data(), d.id)).toList();
      }
    } catch (_) {}
    final restList = await _fetchViaRest('medicines');
    return restList
        .where((m) => m['userId'] == uid)
        .map((m) => Medicine.fromMap(m, m['id'] as String? ?? ''))
        .toList();
  }

  // --------------------------------------------------------------------------
  // SIM CARDS
  // --------------------------------------------------------------------------
  Future<void> saveSim(SimCard sim) async {
    final uid = await getUid();
    final data = sim.toMap();
    data['userId'] = uid;

    bool saved = false;
    try {
      await _ensureInitialized();
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('sims')
            .doc(sim.id)
            .set(data, SetOptions(merge: true));
        saved = true;
      }
    } catch (_) {}

    if (!saved) {
      await _saveViaRest('sims', sim.id, data);
    }
  }

  Future<void> deleteSim(String id) async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance.collection('sims').doc(id).delete();
      }
    } catch (_) {}
    await _deleteViaRest('sims', id);
  }

  Future<List<SimCard>> fetchSims() async {
    final uid = await getUid();
    try {
      if (Firebase.apps.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection('sims')
            .where('userId', isEqualTo: uid)
            .get();
        return snap.docs.map((d) => SimCard.fromMap(d.data(), d.id)).toList();
      }
    } catch (_) {}
    final restList = await _fetchViaRest('sims');
    return restList
        .where((m) => m['userId'] == uid)
        .map((m) => SimCard.fromMap(m, m['id'] as String? ?? ''))
        .toList();
  }

  // --------------------------------------------------------------------------
  // IDENTITY DOCUMENTS
  // --------------------------------------------------------------------------
  Future<void> saveDocument(IdentityDocument doc) async {
    final uid = await getUid();
    final data = doc.toMap();
    data['userId'] = uid;

    bool saved = false;
    try {
      await _ensureInitialized();
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('documents')
            .doc(doc.id)
            .set(data, SetOptions(merge: true));
        saved = true;
      }
    } catch (_) {}

    if (!saved) {
      await _saveViaRest('documents', doc.id, data);
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance.collection('documents').doc(id).delete();
      }
    } catch (_) {}
    await _deleteViaRest('documents', id);
  }

  Future<List<IdentityDocument>> fetchDocuments() async {
    final uid = await getUid();
    try {
      if (Firebase.apps.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection('documents')
            .where('userId', isEqualTo: uid)
            .get();
        return snap.docs.map((d) => IdentityDocument.fromMap(d.data(), d.id)).toList();
      }
    } catch (_) {}
    final restList = await _fetchViaRest('documents');
    return restList
        .where((m) => m['userId'] == uid)
        .map((m) => IdentityDocument.fromMap(m, m['id'] as String? ?? ''))
        .toList();
  }

  // --------------------------------------------------------------------------
  // FAMILY MEMBERS
  // --------------------------------------------------------------------------
  Future<void> saveFamily(FamilyMember member) async {
    final uid = await getUid();
    final data = member.toMap();
    data['userId'] = uid;

    bool saved = false;
    try {
      await _ensureInitialized();
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('family')
            .doc(member.id)
            .set(data, SetOptions(merge: true));
        saved = true;
      }
    } catch (_) {}

    if (!saved) {
      await _saveViaRest('family', member.id, data);
    }
  }

  Future<void> deleteFamily(String id) async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance.collection('family').doc(id).delete();
      }
    } catch (_) {}
    await _deleteViaRest('family', id);
  }

  Future<List<FamilyMember>> fetchFamily() async {
    final uid = await getUid();
    try {
      if (Firebase.apps.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection('family')
            .where('userId', isEqualTo: uid)
            .get();
        return snap.docs.map((d) => FamilyMember.fromMap(d.data(), d.id)).toList();
      }
    } catch (_) {}
    final restList = await _fetchViaRest('family');
    return restList
        .where((m) => m['userId'] == uid)
        .map((m) => FamilyMember.fromMap(m, m['id'] as String? ?? ''))
        .toList();
  }

  // --------------------------------------------------------------------------
  // WARRANTY PRODUCTS
  // --------------------------------------------------------------------------
  Future<void> saveWarranty(WarrantyProduct product) async {
    final uid = await getUid();
    final data = product.toMap();
    data['userId'] = uid;

    bool saved = false;
    try {
      await _ensureInitialized();
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('warranties')
            .doc(product.id)
            .set(data, SetOptions(merge: true));
        saved = true;
      }
    } catch (_) {}

    if (!saved) {
      await _saveViaRest('warranties', product.id, data);
    }
  }

  Future<void> deleteWarranty(String id) async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance.collection('warranties').doc(id).delete();
      }
    } catch (_) {}
    await _deleteViaRest('warranties', id);
  }

  Future<List<WarrantyProduct>> fetchWarranty() async {
    final uid = await getUid();
    try {
      if (Firebase.apps.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection('warranties')
            .where('userId', isEqualTo: uid)
            .get();
        return snap.docs.map((d) => WarrantyProduct.fromMap(d.data(), d.id)).toList();
      }
    } catch (_) {}
    final restList = await _fetchViaRest('warranties');
    return restList
        .where((m) => m['userId'] == uid)
        .map((m) => WarrantyProduct.fromMap(m, m['id'] as String? ?? ''))
        .toList();
  }
}
