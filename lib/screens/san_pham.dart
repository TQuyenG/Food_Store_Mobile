import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chi_tiet_san_pham.dart';
import '../data/product_service.dart';
import 'gio_hang.dart';
import '../data/cart_service.dart';
import 'login.dart'; // Import CartService

class SanPham extends StatefulWidget {
  const SanPham({Key? key}) : super(key: key);

  @override
  _SanPhamState createState() => _SanPhamState();
}

class _SanPhamState extends State<SanPham> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService(); // Khởi tạo CartService
  List<Map<String, dynamic>> products = [];
  Map<String, List<String>> categoriesWithSubcategories = {};

  String _selectedCategory = 'TẤT CẢ';
  String? _selectedSubCategory;
  bool _isCategoryVisible = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
  }

  Future<void> fetchProducts() async {
    products = await _productService.getAllProducts();
    setState(() {});
  }

  Future<void> fetchCategories() async {
    categoriesWithSubcategories =
        await _productService.getCategoriesAndSubcategories();
    setState(() {});
  }

  // Thêm sản phẩm vào giỏ hàng
  void addToCart(String productName, double price, String image) {
    User? currentUser =
        FirebaseAuth.instance.currentUser; // Kiểm tra trạng thái đăng nhập

    if (currentUser == null) {
      // Nếu người dùng chưa đăng nhập
      final snackBar = SnackBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        duration: Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Icon(Icons.warning,
                        color: Colors.red, size: 28), // Biểu tượng cảnh báo
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bạn chưa đăng nhập. Đăng nhập ngay để mua sản phẩm.',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Chuyển tới trang đăng nhập
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(), // Trang đăng nhập
                    ),
                  );
                },
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade300),
                ),
              ),
            ],
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return; // Ngừng thực hiện nếu chưa đăng nhập
    }

    // Tiến hành thêm sản phẩm vào giỏ hàng
    _cartService.addToCart(productName, price, image).then((_) {
      final snackBar = SnackBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        duration: Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 28),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sản phẩm đã được thêm vào Giỏ hàng',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Chuyển tới trang giỏ hàng
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GioHang(
                          cartItems: []), // Cập nhật sau với dữ liệu thực
                    ),
                  );
                },
                child: Text(
                  'Đến xem',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade300),
                ),
              ),
            ],
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lọc sản phẩm theo danh mục, danh mục con và từ khóa tìm kiếm
    List<Map<String, dynamic>> filteredProducts = products.where((product) {
      final matchesCategory = _selectedCategory == 'TẤT CẢ' ||
          product['category'] == _selectedCategory;
      final matchesSubCategory = _selectedSubCategory == null ||
          product['subcategory'] == _selectedSubCategory;
      final matchesSearch =
          product['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSubCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.red[300], size: 36),
          onPressed: () {
            setState(() {
              _isCategoryVisible = !_isCategoryVisible;
            });
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              width: 200,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Type to search...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                  prefixIcon:
                      Icon(Icons.search, size: 35, color: Colors.red[300]),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.0),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/anh_bia/jpg/f11.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5), BlendMode.darken),
          ),
        ),
        child: Stack(
          children: [
            filteredProducts.isNotEmpty
                ? Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 0.655,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                      ),
                      padding: EdgeInsets.all(15.0),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _navigateToProductDetail(
                              context, filteredProducts[index]),
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                    child: Image.network(
                                      filteredProducts[index]['image'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        filteredProducts[index]['name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 0),
                                      Text(
                                        '\$${filteredProducts[index]['price'].toStringAsFixed(2)}',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14),
                                      ),
                                      SizedBox(height: 1),
                                      ElevatedButton(
                                        onPressed: () => addToCart(
                                          filteredProducts[index]['name'],
                                          filteredProducts[index]['price'],
                                          filteredProducts[index]['image'],
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade200,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 1),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Icon(
                                                    Icons.add_shopping_cart,
                                                    size: 24,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Thêm vào giỏ',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                    'Không có sản phẩm nào.',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  )),
            if (_isCategoryVisible) ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isCategoryVisible = false;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.black54,
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 200,
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54.withOpacity(0.5),
                        blurRadius: 5.0,
                        offset: Offset(2.0, 0.0),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = 'TẤT CẢ';
                                  _selectedSubCategory = null;
                                });
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'TẤT CẢ',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        for (String category
                            in categoriesWithSubcategories.keys)
                          ExpansionTile(
                            title:
                                Text(category, style: TextStyle(fontSize: 20)),
                            children: categoriesWithSubcategories[category]!
                                .map((String subCategory) {
                              return ListTile(
                                title: SizedBox(
                                  height: 35,
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedSubCategory = subCategory;
                                        // Cập nhật danh sách sản phẩm đã lọc
                                        filteredProducts =
                                            products.where((product) {
                                          return product['subcategory'] ==
                                                  subCategory &&
                                              product['category'] ==
                                                  _selectedCategory;
                                        }).toList();
                                      });
                                    },
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(subCategory,
                                          style: TextStyle(fontSize: 18)),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToProductDetail(
      BuildContext context, Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetail(
          name: product['name'],
          image: product['image'],
          price: product['price'],
          details: product['details'] ?? 'Mô tả sản phẩm.',
          addToCart: addToCart,
          reviews: [], // Cần cập nhật để lấy đánh giá thực tế nếu có
        ),
      ),
    );
  }
}
