import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Centralized Firebase service instances
class FirebaseService {
  // Singleton pattern
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  // Firebase instances
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  // Storage removed - using Cloudinary instead

  // Common Firestore settings
  static Future<void> configureFirestore() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Helper: Get current user ID
  String? get currentUserId => auth.currentUser?.uid;

  // Helper: Check if user is authenticated
  bool get isAuthenticated => auth.currentUser != null;

  // Helper: Get user stream
  Stream<User?> get authStateChanges => auth.authStateChanges();

  // Helper: Sign out
  Future<void> signOut() async {
    await auth.signOut();
  }

  // Image URLs are now stored as strings in Firestore (Cloudinary URLs)
  // No storage helpers needed

  // Firestore helpers with proper error handling
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      return await firestore.collection(collection).doc(docId).get();
    } catch (e) {
      throw Exception('Error fetching document: $e');
    }
  }

  Future<QuerySnapshot> getCollection(
    String collection, {
    Query Function(CollectionReference)? queryBuilder,
  }) async {
    try {
      final ref = firestore.collection(collection);
      final query = queryBuilder?.call(ref) ?? ref;
      return await query.get();
    } catch (e) {
      throw Exception('Error fetching collection: $e');
    }
  }

  Stream<DocumentSnapshot> watchDocument(String collection, String docId) {
    return firestore.collection(collection).doc(docId).snapshots();
  }

  Stream<QuerySnapshot> watchCollection(
    String collection, {
    Query Function(CollectionReference)? queryBuilder,
  }) {
    final ref = firestore.collection(collection);
    final query = queryBuilder?.call(ref) ?? ref;
    return query.snapshots();
  }
}