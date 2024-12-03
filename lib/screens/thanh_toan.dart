import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../data/cart_service.dart';
import 'danh_gia.dart';
import 'xac_nhan.dart';
import '../data/user_service.dart';

class ThanhToan extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;

  String? userId;

  ThanhToan({required this.totalAmount, required this.cartItems, this.userId});

  @override
  _ThanhToanState createState() => _ThanhToanState();
}

class _ThanhToanState extends State<ThanhToan> {
  String _selectedPaymentMethod = 'cash'; // Giá trị mặc định thanh toán
  final _formKey = GlobalKey<FormState>();
  // Tạo một instance của UserService
  final UserService _userService = UserService();

  // Lưu trữ thông tin cá nhân
  String _username = '';
  String _phone = '';
  String _address = '';
  String _email = '';

  String? _selectedDiscountCode; // Mã giảm giá đã chọn
  double _discountAmount = 0.0; // Số tiền giảm giá

  // Danh sách mã giảm giá
  final List<Map<String, dynamic>> discountCodes = [
    {'code': 'DISCOUNT10', 'percentage': 10},
    {'code': 'DISCOUNT20', 'percentage': 20},
    {'code': 'DISCOUNT30', 'percentage': 30},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Gọi phương thức để lấy dữ liệu người dùng khi khởi tạo
  }

  /// Lấy dữ liệu người dùng từ Firestore
  Future<void> _fetchUserData() async {
    try {
      Map<String, dynamic> userData = await _userService.getUserData();
      setState(() {
        _username = userData['username']; // Lưu tên người dùng vào biến
        _email = userData['email'];
        _phone = userData['phoneNo'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user data: $e")),
      );
    }
  }

  Future<void> _createBill() async {
    // Tạo document mới trong collection bill
    CollectionReference bills = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('bill');

    // Tạo danh sách để chứa thông tin sản phẩm
    List<Map<String, dynamic>> productsList = [];

    // Kiểm tra nếu cartItems không rỗng
    if (widget.cartItems.isNotEmpty) {
      // Thêm thông tin sản phẩm vào danh sách
      for (var item in widget.cartItems) {
        productsList.add({
          'name': item['name'],
          'quantity': item['quantity'],
          'price': item['price'],
          'total': item['price'] * item['quantity'],
        });
      }
    } else {
      // Xử lý nếu không có sản phẩm nào trong giỏ hàng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Giỏ hàng trống!")),
      );
      return; // Thoát khỏi phương thức nếu giỏ hàng trống
    }

    // Tạo document hóa đơn với thông tin sản phẩm
    DocumentReference billDoc = await bills.add({
      'date': DateTime.now(),
      'paymentMethod': _selectedPaymentMethod,
      'info': {
        'name': _username,
        'email': _email,
        'phone': _phone,
        'address': _address,
      },
      'products': productsList, // Thêm danh sách sản phẩm vào hóa đơn
    });
  }

  @override
  Widget build(BuildContext context) {
    double finalAmount = widget.totalAmount - _discountAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thanh Toán',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hóa đơn
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent, width: 3.0),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ngăn cách
                    Center(
                      child: Image.asset(
                        'assets/logo/ngan_cach.png',
                        height: 50,
                        width: 300,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'HÓA ĐƠN',
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(4.0, 4.0),
                              blurRadius: 5.0,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Chi tiết hóa đơn
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('   SẢN PHẨM',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22)),
                              Text('GIÁ   ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22)),
                            ],
                          ),
                        ),
                        Divider(color: Colors.redAccent),
                        ...widget.cartItems.map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${item['name']}    x${item['quantity']}',
                                      style: TextStyle(
                                        color: Colors.pink.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      )),
                                  Text(
                                      '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      )),
                                ],
                              ),
                            )),
                        Divider(color: Colors.redAccent),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tổng cộng',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              Text('\$${widget.totalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  )),
                            ],
                          ),
                        ),

                        // Mục nhập mã giảm giá
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Chọn mã giảm giá',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedDiscountCode,
                          items: discountCodes.map((discount) {
                            return DropdownMenuItem<String>(
                              value: discount['code'],
                              child: Text(
                                  '${discount['code']} - ${discount['percentage']}%'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDiscountCode = value;
                              _discountAmount = value != null
                                  ? widget.totalAmount *
                                      (discountCodes.firstWhere((discount) =>
                                              discount['code'] ==
                                              value)['percentage'] /
                                          100)
                                  : 0.0;
                            });
                          },
                        ),
                        SizedBox(height: 8),

                        Divider(color: Colors.redAccent),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('  TỔNG TIỀN',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              Text('\$${finalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1),

                    // Ngăn cách
                    Center(
                      child: Image.asset(
                        'assets/logo/ngan_cach.png',
                        height: 50,
                        width: 230,
                        fit: BoxFit.fitWidth,
                      ),
                    ),

                    // Thông tin cá nhân
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '        THÔNG TIN CÁ NHÂN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 5.0,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.redAccent),
                          onPressed: () {
                            // Chức năng sửa thông tin cá nhân
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'Chỉnh sửa thông tin',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Thêm validator cho các TextFormField
                                          TextFormField(
                                            decoration: InputDecoration(
                                              labelText: 'Tên',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 10),
                                            ),
                                            initialValue: _username,
                                            onSaved: (value) =>
                                                _username = value!,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Vui lòng nhập tên';
                                              }
                                              return null; // Nếu không có lỗi
                                            },
                                          ),
                                          SizedBox(height: 16),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              labelText: 'Số điện thoại',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 10),
                                            ),
                                            initialValue: _phone,
                                            onSaved: (value) => _phone = value!,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Vui lòng nhập số điện thoại';
                                              }
                                              return null;
                                            },
                                          ),
                                          SizedBox(height: 16),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              labelText: 'Địa chỉ',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 10),
                                            ),
                                            initialValue: _address,
                                            onSaved: (value) =>
                                                _address = value!,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Vui lòng nhập địa chỉ';
                                              }
                                              return null;
                                            },
                                          ),
                                          SizedBox(height: 16),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              labelText: 'Email',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 10),
                                            ),
                                            initialValue: _email,
                                            onSaved: (value) => _email = value!,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Vui lòng nhập email';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          _formKey.currentState!.save();
                                          Navigator.of(context).pop();
                                          setState(
                                              () {}); // Refresh to show updated info
                                        }
                                      },
                                      child: Text('Lưu'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Thông tin cá nhân
                    Align(
                      alignment: Alignment
                          .center, // Căn giữa Container thông tin cá nhân
                      child: Container(
                        width: MediaQuery.of(context).size.width *
                            (2 / 3), // Chiều rộng bằng 2/3 chiều rộng màn hình
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.redAccent),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Căn lề trái cho văn bản
                          children: [
                            Text(
                                'Tên: ${_username.isNotEmpty ? _username : " "}',
                                style: TextStyle(fontSize: 18)),
                            SizedBox(height: 8),
                            Text(
                                'Số điện thoại: ${_phone.isNotEmpty ? _phone : " "}',
                                style: TextStyle(fontSize: 18)),
                            SizedBox(height: 8),
                            Text(
                                'Địa chỉ: ${_address.isNotEmpty ? _address : " "}',
                                style: TextStyle(fontSize: 18)),
                            SizedBox(height: 8),
                            Text('Email: ${_email.isNotEmpty ? _email : " "}',
                                style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Phần thanh toán
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'THANH TOÁN',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 5.0,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Radio(
                              value: 'cash',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value as String;
                                });
                              },
                            ),
                            Text('Thanh toán tiền mặt',
                                style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              value: 'qr',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value as String;
                                });
                              },
                            ),
                            Text('Thanh toán quét mã QR',
                                style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    // Nút "Mua"
                    ElevatedButton(
                      onPressed: () {
                        // Kiểm tra xem thông tin cá nhân có đầy đủ không
                        if (_address.isEmpty) {
                          _showErrorMessage(context, 'Vui lòng nhập địa chỉ.');
                        } else {
                          // Nếu thông tin đầy đủ, tạo bill
                          _createBill().then((_) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => XacNhan(
                                  buyProducts: widget.cartItems.map((item) {
                                    return Product(
                                      name: item['name'],
                                      image: item['image'],
                                      price: item['price'],
                                      quantity: item['quantity'],
                                    );
                                  }).toList(),
                                  success: true,
                                ),
                              ),
                            );
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade300,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text('MUA HÀNG',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm hiển thị thông báo
  void _showErrorMessage(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade100, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade400,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Tự động tắt thông báo sau 2 giây
    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
