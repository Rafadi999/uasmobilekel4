import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// General function (already made by you, no change)

  Future<String> addData(String collection, Map<String, dynamic> data) async {
    DocumentReference docRef = await _firestore.collection(collection).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> setData(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateData(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteData(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  Stream<QuerySnapshot> getDataStream(String collection, {String? orderBy, bool descending = true}) {
    if (orderBy != null) {
      return _firestore.collection(collection).orderBy(orderBy, descending: descending).snapshots();
    }
    return _firestore.collection(collection).snapshots();
  }

  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  Stream<DocumentSnapshot> getDocumentStream(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  // ================= 🔥 Khusus Pengumuman 🔥 =================
  Stream<List<Announcement>> getAnnouncements() {
    return _firestore.collection('pengumuman').orderBy('dibuat', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Announcement.fromMap(doc.id, doc.data())).toList(),
    );
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    await _firestore.collection('pengumuman').add(announcement.toMap());
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    await _firestore.collection('pengumuman').doc(announcement.id).update(announcement.toMap());
  }

  Future<void> deleteAnnouncement(String id) async {
    await _firestore.collection('pengumuman').doc(id).delete();
  }
}