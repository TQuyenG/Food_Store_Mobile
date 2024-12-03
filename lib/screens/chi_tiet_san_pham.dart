import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm import này
import 'package:food_store/screens/trang_chu.dart';
import '../data/cart_service.dart';
import 'gio_hang.dart';
import 'login.dart';

// Lớp ProductDetail là StatefulWidget để quản lý trạng thái đánh giá
class ProductDetail extends StatefulWidget {
  final String name; // Tên sản phẩm
  final String image; // Hình ảnh sản phẩm
  final double price; // Giá sản phẩm
  final String details; // Chi tiết sản phẩm
  final List<Map<String, dynamic>> reviews; // Danh sách đánh giá

  // Constructor nhận các tham số cần thiết
  ProductDetail({
    required this.name,
    required this.image,
    required this.price,
    required this.details,
    required this.reviews,
    required void Function(String productName, double price, String image)
        addToCart, // Thêm tham số đánh giá
  });

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Khởi tạo Firestore
  final CartService _cartService = CartService(); // Khởi tạo CartService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Mũi tên quay về
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => TrangChu()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Text(
          widget.name,
          style: TextStyle(
            fontFamily: 'SVN-Bistro Script',
            fontSize: 40,
            color: Colors.black,
            shadows: [
              Shadow(
                offset: Offset(2.0, 3.0),
                blurRadius: 1.0,
                color: Colors.red.withOpacity(0.5),
              ),
            ],
          ),
        ),
        backgroundColor: Color(0xFFFDC9C9),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/anh_bia/jpg/f11.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: EdgeInsets.all(24),
              margin: EdgeInsets.only(top: 0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
              ),
              constraints: BoxConstraints(
                maxWidth: 1000, // Giới hạn chiều rộng tối đa
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(widget.image,
                              height: 350, fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(height: 16),
                      _productInfo(), // Hiển thị thông tin sản phẩm
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(thickness: 3, color: Colors.black), // Đường kẻ ngang
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm hiển thị thông tin sản phẩm
  Widget _productInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.name,
              style: TextStyle(
                  fontSize: 35, fontWeight: FontWeight.bold), // Tên sản phẩm
            ),
            Text(
              '\$${widget.price.toStringAsFixed(2)}', // Giá sản phẩm
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red[400],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          widget.details,
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 16),

        // Nút thêm vào giỏ hàng
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              // Gọi hàm thêm sản phẩm vào giỏ hàng
              addToCart(widget.name, widget.price, widget.image);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_shopping_cart, size: 24), // Biểu tượng giỏ hàng
                SizedBox(width: 5), // Khoảng cách giữa biểu tượng và văn bản
                Text('Thêm vào giỏ',
                    style: TextStyle(fontSize: 20)), // Văn bản nút
              ],
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8),
              backgroundColor: Colors.white, // Nền trắng
              side: BorderSide(
                color: Colors.red[400]!, // Viền ngoài hơi đậm màu đỏ
                width: 2, // Độ dày của viền
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Thêm sản phẩm vào giỏ hàng
  void addToCart(String productName, double price, String image) {
    if (_cartService.currentUserId == null) {
      final snackBar = SnackBar(
        content: Text(
            'Bạn chưa đăng nhập. Vui lòng đăng nhập để thêm vào giỏ hàng.'),
        action: SnackBarAction(
          label: 'Đăng nhập',
          onPressed: () {
            // Chuyển tới trang đăng nhập
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            );
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

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
}
