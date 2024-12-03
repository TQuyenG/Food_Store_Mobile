import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_store/screens/trang_chu.dart';
import '../data/cart_service.dart';
import 'gio_hang.dart';
import 'san_pham.dart'; // Import trang SanPham
import 'danh_gia.dart'; // Import trang DanhGia

class XacNhan extends StatelessWidget {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Khởi tạo Firestore
  final CartService _cartService = CartService(); // Khởi tạo CartService
  final List<Product> buyProducts; // Danh sách sản phẩm đã mua
  final bool success;

  XacNhan({required this.buyProducts, required this.success});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Mũi tên quay về
          onPressed: () {
            Navigator.popUntil(
                context,
                ModalRoute.withName(
                    Navigator.defaultRouteName)); // Quay về trang chủ
          },
        ),
        title: Text(
          'Xác Nhận Đơn Hàng',
          style: TextStyle(
            fontFamily: 'SVN-Blog Script',
            fontSize: 32,
            color: Colors.pink[600],
          ),
        ),
        backgroundColor: Color(0xFFFDC9C9),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                // Container thông báo
                _buildNotificationContainer(context),
                SizedBox(height: 30), // Khoảng cách giữa thông báo và sản phẩm

                // Phần sản phẩm đã mua
                productSection(
                  '~ Sản Phẩm Đã Mua ~',
                  buyProducts, // Sử dụng danh sách sản phẩm đã mua
                  true, // Thêm tham số để xác định đây là sản phẩm đã mua
                ),
                SizedBox(height: 30), // Khoảng cách giữa thông báo và sản phẩm

                // Phần sản phẩm khác
                productSection(
                  '~ Sản Phẩm Khác ~',
                  _getOtherProducts(),
                  false, // Thêm tham số để xác định đây không phải là sản phẩm đã mua
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Hàm tạo container thông báo
  Widget _buildNotificationContainer(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * (3 / 4),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: success ? Colors.green : Colors.red),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            success ? Icons.check_circle : Icons.cancel,
            color: success ? Colors.green : Colors.red,
            size: 50,
          ),
          SizedBox(height: 20),
          Text(
            success ? 'Mua hàng thành công!' : 'Mua hàng thất bại!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: success ? Colors.green[700] : Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            'Cảm ơn bạn đã mua hàng tại cửa hàng của chúng tôi.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TrangChu()), // Chuyển hướng tới trang chủ
                    (Route<dynamic> route) =>
                        false, // Loại bỏ tất cả các trang trước đó
                  );
                },
                child: Text('Quay về \ntrang chủ', textAlign: TextAlign.center),
              ),
              ElevatedButton(
                onPressed: () {
                  _showReorderDialog(
                      context); // Hiện dialog xác nhận khi nhấn "Mua lại"
                },
                child: Text('Mua lại'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Hàm hiển thị dialog xác nhận mua lại
  void _showReorderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm sản phẩm vào lại giỏ hàng'),
        actions: [
          TextButton(
            onPressed: () {
              // Thực hiện thêm từng sản phẩm vào giỏ hàng
              for (var product in buyProducts) {
                addToCart(context, product.name, product.price, product.image);
              }
              Navigator.of(context).pop(); // Đóng dialog
            },
            child: Text('Có'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog mà không làm gì
            },
            child: Text('Không'),
          ),
        ],
      ),
    );
  }

  // Hàm thêm sản phẩm vào giỏ hàng
  void addToCart(
      BuildContext context, String productName, double price, String image) {
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
                  // Đóng SnackBar trước khi chuyển trang
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  // Chuyển tới trang giỏ hàng
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GioHang(
                            cartItems: [])), // Cập nhật sau với dữ liệu thực
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

  // Hàm tạo phần sản phẩm khác
  Widget productSection(
      String title, List<Product> products, bool isBuyProduct) {
    PageController boxController = PageController(viewportFraction: 0.8);
    int currentPage = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        void nextPage() {
          boxController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        void previousPage() {
          boxController.previousPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        return Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề sản phẩm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'SVN-Bistro Script',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87.withOpacity(0.7),
                            shadows: [
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 5.0,
                                color: Colors.red.shade200,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Stack chứa danh sách sản phẩm và các nút chuyển trái phải
                  Stack(
                    children: [
                      Container(
                        height: 180,
                        child: PageView.builder(
                          controller: boxController,
                          itemCount: products.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Container(
                              width: 300,
                              height: 180,
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              padding: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                border: Border.all(
                                  color: Colors.red.shade200.withOpacity(0.5),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      product.image,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.black87,
                                          ],
                                          begin: Alignment.bottomRight,
                                          end: Alignment.topLeft,
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(3.0, 3.0),
                                                  blurRadius: 2.0,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          // Hiển thị giá với dấu $ và hai số 0
                                          Text(
                                            '\$${product.price.toStringAsFixed(0)}.00',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(3.0, 3.0),
                                                  blurRadius: 2.0,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Spacer(),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                // Chuyển hướng đến trang SanPham
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SanPham()), // Tạo route đến trang SanPham
                                                );
                                              },
                                              child: Text('Đến xem >>',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor:
                                                    Colors.green.shade300,
                                                minimumSize: Size(20, 30),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                elevation: 8,
                                                shadowColor: Colors.black
                                                    .withOpacity(0.9),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 70,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Colors.redAccent,
                          ),
                          onPressed: previousPage,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 70,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            size: 30,
                            color: Colors.redAccent,
                          ),
                          onPressed: nextPage,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Hàm lấy danh sách sản phẩm khác
  List<Product> _getOtherProducts() {
    return [
      Product(
        image:
            'https://i.pinimg.com/736x/1c/c7/b8/1cc7b81423b52dd34763d14ae03abf2a.jpg',
        name: 'Nigiri Sushi',
        price: 45,
        quantity: 1, // Thêm số lượng nếu cần
      ),
      Product(
        image:
            'https://i.pinimg.com/736x/95/e5/3a/95e53a3659adf692c0cc1fcd91010671.jpg',
        name: 'Phở bò viên',
        price: 40,
        quantity: 1, // Thêm số lượng nếu cần
      ),
      Product(
        image:
            'https://i.pinimg.com/736x/c7/cc/7e/c7cc7e1f51fe68fac7fe95ae4c55afd7.jpg',
        name: 'Hủ tiếu',
        price: 50,
        quantity: 1, // Thêm số lượng nếu cần
      ),
      Product(
        image:
            'https://i.pinimg.com/736x/55/c9/fe/55c9fee5f520ddcb95a635e0f3d39595.jpg',
        name: 'Mì hoành thánh',
        price: 35,
        quantity: 1, // Thêm số lượng nếu cần
      ),
      Product(
        image:
            'https://i.pinimg.com/736x/46/11/8f/46118f1a43779595e68d6520a3ab721c.jpg',
        name: 'Hamburger bò 2 tầng',
        price: 40,
        quantity: 1, // Thêm số lượng nếu cần
      ),
    ];
  }
}

// Lớp sản phẩm
class Product {
  final String name; // Tên sản phẩm
  final String image; // Hình ảnh sản phẩm
  final double price; // Giá sản phẩm
  final int quantity; // Số lượng sản phẩm

  Product({
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });
}
