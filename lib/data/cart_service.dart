import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy ID người dùng hiện tại
  String get currentUserId => _auth.currentUser!.uid;

  // Thêm sản phẩm vào giỏ hàng
  Future<void> addToCart(String productName, double price, String image) async {
    DocumentReference cartRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('cart')
        .doc(productName); // Sử dụng tên sản phẩm làm ID

    // Thực hiện transaction để đảm bảo tính chính xác
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(cartRef);

      if (snapshot.exists) {
        // Nếu sản phẩm đã tồn tại, tăng số lượng
        int newQuantity = snapshot['quantity'] + 1;
        transaction.update(cartRef, {'quantity': newQuantity});
      } else {
        // Nếu sản phẩm chưa tồn tại, thêm mới
        transaction.set(cartRef, {
          'name': productName,
          'price': price,
          'quantity': 1,
          'image': image,
        });
      }
    });
  }

  // Cập nhật số lượng sản phẩm trong giỏ hàng
  Future<void> updateCartQuantity(String productName, int newQuantity) async {
    DocumentReference cartRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('cart')
        .doc(productName);

    if (newQuantity <= 0) {
      // Nếu số lượng <= 0, xóa sản phẩm
      await cartRef.delete();
    } else {
      // Cập nhật số lượng sản phẩm
      await cartRef.update({'quantity': newQuantity});
    }
  }

  // Lấy danh sách sản phẩm trong giỏ hàng
  Stream<List<Map<String, dynamic>>> getCartItems() {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'price': doc['price'],
          'quantity': doc['quantity'],
          'image': doc['image'],
        };
      }).toList();
    });
  }

  // Chuyển sản phẩm từ giỏ hàng sang hóa đơn
  Future<void> purchaseCartItems(
      List<Map<String, dynamic>> cartItems, String review) async {
    CollectionReference buyCartRef =
        _firestore.collection('users').doc(currentUserId).collection('bill');

    for (var item in cartItems) {
      await buyCartRef.add({
        'name': item['name'],
        'price': item['price'],
        'quantity': item['quantity'],
        'image': item['image'],
        'review': review, // Thêm trường đánh giá
      });
    }
    // Xóa sản phẩm khỏi giỏ hàng sau khi mua
    await clearCart();
  }

  // Xóa tất cả sản phẩm trong giỏ hàng
  Future<void> clearCart() async {
    CollectionReference cartRef =
        _firestore.collection('users').doc(currentUserId).collection('cart');

    // Lấy tất cả tài liệu trong giỏ hàng
    QuerySnapshot snapshot = await cartRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Thêm phương thức xóa sản phẩm
  Future<void> removeCartItem(String productName) async {
    DocumentReference cartRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('cart')
        .doc(productName);
    await cartRef.delete();
  }
}
