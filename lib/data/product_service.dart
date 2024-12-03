import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Thêm sản phẩm vào Firestore
  Future<void> addProduct(String name, double price, String category,
      String subcategory, String image) async {
    await _firestore.collection('products').add({
      'name': name,
      'price': price,
      'category': category,
      'subcategory': subcategory,
      'image': image,
    });
  }

  /// Lấy danh sách tất cả sản phẩm
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    QuerySnapshot snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Thêm ID vào dữ liệu
      return data;
    }).toList();
  }

  /// Lấy danh mục lớn và danh mục con từ Firestore
  Future<Map<String, List<String>>> getCategoriesAndSubcategories() async {
    QuerySnapshot snapshot = await _firestore.collection('products').get();
    Map<String, Set<String>> categoriesMap = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      String category = data['category'];
      String subcategory = data['subcategory'];

      if (!categoriesMap.containsKey(category)) {
        categoriesMap[category] = {};
      }
      categoriesMap[category]!.add(subcategory);
    }

    // Chuyển đổi từ Map<String, Set<String>> sang Map<String, List<String>>
    Map<String, List<String>> result = {};
    categoriesMap.forEach((key, value) {
      result[key] = value.toList();
    });

    return result;
  }

  /// Lấy sản phẩm theo danh mục lớn
  Future<List<Map<String, dynamic>>> getProducts({String? category}) async {
    Query query = _firestore.collection('products');

    // Nếu có danh mục, thêm điều kiện lọc
    if (category != null && category != 'TẤT CẢ') {
      query = query.where('category', isEqualTo: category);
    }

    QuerySnapshot snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Thêm ID vào dữ liệu
      return data;
    }).toList();
  }

  /// Lấy sản phẩm theo danh mục con
  Future<List<Map<String, dynamic>>> getProductsBySubcategory(
      String subcategory) async {
    QuerySnapshot snapshot = await _firestore
        .collection('products')
        .where('subcategory', isEqualTo: subcategory)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Thêm ID vào dữ liệu
      return data;
    }).toList();
  }

  /// Cập nhật thông tin sản phẩm
  Future<void> updateProduct(
      String productId, Map<String, dynamic> productData) async {
    await _firestore.collection('products').doc(productId).update(productData);
  }

  /// Xóa sản phẩm khỏi firebase
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }
}
