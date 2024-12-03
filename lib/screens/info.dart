import 'dart:io';
import 'package:food_store/screens/product_management.dart';
import '../data/product_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/user_service.dart';
import 'login.dart';

class Info extends StatefulWidget {
  const Info({Key? key}) : super(key: key);

  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  final _productService = ProductService();
  final _userService = UserService();
  String _username = '';
  String _email = '';
  String _phone = '';
  File? _avatar;
  bool _isAdmin = false; // Biến để lưu trạng thái admin

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Gọi phương thức để lấy dữ liệu người dùng khi khởi tạo
  }

  Future<void> _fetchUserData() async {
    try {
      Map<String, dynamic> userData = await _userService.getUserData();
      setState(() {
        _username = userData['username'];
        _email = userData['email'];
        _phone = userData['phoneNo'];
        _isAdmin = userData['admin']; // Lưu trạng thái admin
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bạn chưa đăng nhập!!!")),
      );
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController usernameController =
            TextEditingController(text: _username);
        TextEditingController emailController =
            TextEditingController(text: _email);
        TextEditingController phoneController =
            TextEditingController(text: _phone);

        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone No'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateUserData(usernameController.text, emailController.text,
                    phoneController.text);
                Navigator.of(context).pop(); // Đóng hộp thoại sau khi lưu
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserData(
      String username, String email, String phoneNo) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _userService.updateUserData(user, username, email, phoneNo);
      setState(() {
        _fetchUserData(); // Làm mới giao diện với dữ liệu đã cập nhật
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User data updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  '- Personal Information -',
                  style: TextStyle(
                    fontFamily: 'SVN-Blog Script',
                    fontSize: 35,
                    color: Colors.pink[400],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Container(
                  width: 320,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.redAccent.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: user != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 80,
                              backgroundImage: _avatar != null
                                  ? FileImage(_avatar!)
                                  : AssetImage('assets/anh_bia/jpg/f1.jpg')
                                      as ImageProvider,
                            ),
                            SizedBox(height: 20),
                            Text(
                              _username,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              _email,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              _phone,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Bạn chưa đăng nhập.',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  // Chuyển tới trang đăng nhập
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LoginScreen(), // Trang đăng nhập
                                    ),
                                  );
                                },
                                child: Text('Đăng nhập ngay'),
                              ),
                            ],
                          ),
                        ),
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    // Nút "Sửa thông tin cá nhân" chỉ hiển thị khi đã đăng nhập
                    if (user != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          onPressed: _showEditDialog,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.edit, color: Colors.white),
                              SizedBox(width: 20),
                              Text(
                                'Sửa thông tin cá nhân',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.indigo.shade200,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Nút "Quản lý sản phẩm" chỉ hiển thị nếu là admin
                      if (_isAdmin) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProductManagementPage()),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.production_quantity_limits,
                                    color: Colors.white),
                                SizedBox(width: 20),
                                Text(
                                  'Quản lý sản phẩm',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red.shade300,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
