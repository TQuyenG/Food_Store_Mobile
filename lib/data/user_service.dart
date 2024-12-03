import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Lưu thông tin người dùng mới
  Future<void> saveUserData(User user, String username, String phoneNo,
      {bool admin = false}) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'username': username,
        'email': user.email,
        'phoneNo': phoneNo,
        'admin': admin, // Mặc định là false
      });
    } catch (e) {
      throw Exception("Error saving user data: $e");
    }
  }

  /// Cập nhật thông tin người dùng
  Future<void> updateUserData(
      User user, String username, String email, String phoneNo,
      {bool? admin}) async {
    try {
      Map<String, dynamic> updates = {
        'username': username,
        'email': email,
        'phoneNo': phoneNo,
      };
      if (admin != null) {
        updates['admin'] = admin;
      }
      await _firestore.collection('users').doc(user.uid).update(updates);
    } catch (e) {
      throw Exception("Error updating user data: $e");
    }
  }

  /// Lấy thông tin người dùng
  Future<Map<String, dynamic>> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();
      return snapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception("No user is currently logged in.");
    }
  }

  /// Tải thông tin người dùng (có thể dùng để khởi tạo thông tin)
  Future<Map<String, dynamic>> loadUserData() async {
    return await getUserData();
  }
}
