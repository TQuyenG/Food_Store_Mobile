import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_store/screens/thanh_toan.dart';
import '../data/cart_service.dart';
import 'login.dart';

class GioHang extends StatefulWidget {
  const GioHang({Key? key, required List cartItems}) : super(key: key);

  @override
  _GioHangState createState() => _GioHangState();
}

class _GioHangState extends State<GioHang> {
  final CartService _cartService = CartService();
  List<Map<String, dynamic>> cartItems = [];
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser =
        FirebaseAuth.instance.currentUser; // Lấy thông tin người dùng hiện tại
    fetchCartItems();
  }

  // Lấy danh sách sản phẩm trong giỏ hàng
  void fetchCartItems() {
    if (_currentUser != null) {
      _cartService.getCartItems().listen((items) {
        setState(() {
          cartItems = items ?? [];
        });
      });
    }
  }

  // Cập nhật số lượng sản phẩm
  void updateQuantity(String productName, int quantity) {
    _cartService.updateCartQuantity(productName, quantity);
  }

  // Xóa sản phẩm khỏi giỏ hàng
  void removeItem(String productName) {
    _cartService.updateCartQuantity(productName, 0);
  }

  // Tính tổng giá trị các sản phẩm trong giỏ hàng
  double get totalAmount {
    return cartItems.fold(0.0, (sum, item) {
      double price = (item['price'] is int
              ? (item['price'] as int).toDouble()
              : item['price']) ??
          0.0;
      int quantity = (item['quantity'] is int ? item['quantity'] as int : 0);
      return sum + (price * quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    _currentUser = FirebaseAuth
        .instance.currentUser; // Cập nhật lại thông tin người dùng trong build

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Text(
              '- Giỏ hàng của tôi -',
              style: TextStyle(
                fontFamily: 'SVN-Blog Script',
                fontSize: 32,
                color: Colors.pink[600],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _currentUser == null // Kiểm tra trạng thái đăng nhập
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bạn chưa đăng nhập.',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Chuyển tới trang đăng nhập
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text('Đăng nhập ngay'),
                    ),
                  ],
                ),
              )
            : cartItems.isNotEmpty // Kiểm tra giỏ hàng có trống không
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề các cột
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.pink[50],
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'Sản Phẩm',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink[400],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'Số Lượng',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink[400],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'Giá',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink[400],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'Xóa',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink[400],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(thickness: 2, color: Colors.pink[200]),

                      // Danh sách sản phẩm trong giỏ hàng
                      Expanded(
                        child: ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Cột "Sản Phẩm"
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        if (item['image'] != null &&
                                            item['image'].isNotEmpty)
                                          Image.network(
                                            item['image'],
                                            width: 80,
                                            height: 80,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 80,
                                                height: 80,
                                                alignment: Alignment.center,
                                                child: Text('Ảnh lỗi',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey)),
                                              );
                                            },
                                          )
                                        else
                                          Container(
                                            width: 80,
                                            height: 80,
                                            alignment: Alignment.center,
                                            child: Text('Ảnh lỗi',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey)),
                                          ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item['name'] ??
                                                'Tên sản phẩm', // Kiểm tra null
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Cột "Số Lượng"
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            if (item['quantity'] is int &&
                                                item['quantity'] > 1) {
                                              updateQuantity(item['name'],
                                                  item['quantity'] - 1);
                                            } else {
                                              removeItem(item['name']);
                                            }
                                          },
                                          icon: Icon(Icons.remove),
                                          color: Colors.pink[200],
                                        ),
                                        Text(
                                          '${item['quantity'] ?? 0}', // Kiểm tra null
                                          style: TextStyle(fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            updateQuantity(item['name'],
                                                ((item['quantity'] ?? 0) + 1));
                                          },
                                          icon: Icon(Icons.add),
                                          color: Colors.pink[200],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Cột "Giá"
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        '\$${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}', // Kiểm tra null
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),

                                  // Cột "Xóa"
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      onPressed: () {
                                        removeItem(item['name']);
                                      },
                                      icon: Icon(Icons.delete),
                                      color: Colors.red[300],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(thickness: 3, color: Colors.pink[200]),

                      // Tổng cộng
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Tổng cộng:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '\$${totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.red[300],
                                onPressed: () {
                                  // Hiện popup xác nhận
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Center(
                                          child: Text(
                                            'Xóa tất cả',
                                            style: TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        content: Container(
                                          width: 200,
                                          child: Text(
                                            'Bạn chắc chắn muốn xóa \ntất cả sản phẩm?',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.red[300],
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 15.0,
                                                      horizontal: 30.0),
                                                ),
                                                child: Text(
                                                  'Không',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    for (var item
                                                        in cartItems) {
                                                      removeItem(item[
                                                          'name']); // Xóa tất cả sản phẩm
                                                    }
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                                style: TextButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 15.0,
                                                      horizontal: 30.0),
                                                ),
                                                child: Text(
                                                  'Có',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),

                      // Nút "Tiến hành thanh toán"
                      ElevatedButton(
                        onPressed: () {
                          if (cartItems.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ThanhToan(
                                  totalAmount: totalAmount,
                                  cartItems: cartItems,
                                  userId: _cartService.currentUserId,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Container(
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 8.0),
                                        child: Icon(Icons.cancel,
                                            color: Colors.red[300], size: 35),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Giỏ hàng trống! Vui lòng thêm sản phẩm trước khi thanh toán.',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                backgroundColor: Colors.white.withOpacity(0.9),
                                duration: Duration(milliseconds: 1000),
                                behavior: SnackBarBehavior.fixed,
                              ),
                            );
                          }
                        },
                        child: Center(
                          child: Text(
                            'Tiến hành thanh toán',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.red[400]!,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ).copyWith(
                          overlayColor:
                              MaterialStateProperty.all(Colors.red[200]),
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            return states.contains(MaterialState.pressed)
                                ? Colors.white
                                : Colors.red[400]!;
                          }),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      'Giỏ hàng trống, \nhãy thêm món ăn mới!!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
      ),
    );
  }
}
