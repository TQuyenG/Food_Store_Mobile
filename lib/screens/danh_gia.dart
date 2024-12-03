import 'package:flutter/material.dart';
import 'chi_tiet_san_pham.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DanhGia extends StatefulWidget {
  final List<ReviewProduct> products; // Danh sách sản phẩm để đánh giá

  DanhGia({Key? key, required this.products}) : super(key: key);

  @override
  _DanhGiaState createState() => _DanhGiaState();
}

class ReviewProduct {
  final String name; // Tên sản phẩm
  final String image; // Hình ảnh sản phẩm
  final double price; // Giá sản phẩm
  final int quantity; // Số lượng sản phẩm

  ReviewProduct({
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });
}

class _DanhGiaState extends State<DanhGia> {
  final Map<int, int?> _ratings = {}; // Bảng lưu trữ đánh giá của sản phẩm
  final List<Map<String, dynamic>> _reviews = []; // Danh sách đánh giá
  final TextEditingController _reviewController =
      TextEditingController(); // Controller cho nội dung đánh giá

  String _username = ''; // Biến lưu trữ tên người dùng

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Lấy dữ liệu người dùng khi khởi tạo
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            _username = userDoc['username'] ??
                user.displayName ??
                user.email ??
                'Người dùng';
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() {
          _username = 'Người dùng'; // Giá trị mặc định nếu có lỗi
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Mũi tên quay về
          onPressed: () {
            Navigator.popUntil(
                context, ModalRoute.withName(Navigator.defaultRouteName));
            // Quay về trang chủ mà không đếm số lần trang
          },
        ),
        title: Text(
          'Đánh giá sản phẩm',
          style: TextStyle(
            fontFamily: 'SVN-Blog Script',
            fontSize: 32,
            color: Colors.pink[600],
          ),
        ), // Tiêu đề trang
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/anh_bia/jpg/f14.jpg'), // Hình nền
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: widget.products.length, // Số lượng sản phẩm
          itemBuilder: (context, index) {
            return _buildProductCard(
                widget.products[index], index); // Xây dựng thẻ sản phẩm
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(ReviewProduct product, int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.transparent, // Đặt màu nền của Card thành trong suốt
      elevation: 0, // Không có bóng đổ
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9), // Nền có độ trong suốt
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    product.image,
                    width: 150.0,
                    height: 150.0,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 20.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        'Giá: \$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        'Số lượng: ${product.quantity}',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _buildReviewContainer(index), // Phần đánh giá sản phẩm
          ],
        ),
      ),
    );
  }

  Widget _buildReviewContainer(int index) {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: 20), // Khoảng cách phần đánh giá với sản phẩm
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đánh giá sản phẩm',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 15),
          Text('Tên của bạn: $_username',
              style: TextStyle(fontSize: 20)), // Hiển thị tên người dùng
          SizedBox(height: 8),
          Text('Đánh giá của bạn (1-5 sao):', style: TextStyle(fontSize: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(5, (starIndex) {
              return IconButton(
                icon: Icon(
                  Icons.star,
                  color: _ratings[index] != null && _ratings[index]! > starIndex
                      ? Colors.yellow[700]
                      : Colors.grey,
                ),
                onPressed: () => _setRating(index, starIndex + 1),
              );
            }),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: InputDecoration(
                labelText: 'Nhập đánh giá của bạn',
                border: OutlineInputBorder()),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => _submitReview(index),
                child: Text(
                  'Gửi đánh giá',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                ),
              ),
              ElevatedButton(
                onPressed: () => _viewProductDetail(
                    index), // Chuyển hướng đến trang chi tiết
                child: Text(
                  'Xem sản phẩm',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.indigo.shade400,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildReviewList(index), // Hiển thị danh sách đánh giá
        ],
      ),
    );
  }

  void _setRating(int index, int rating) {
    setState(() {
      _ratings[index] = rating; // Cập nhật đánh giá
    });
  }

  void _submitReview(int index) {
    if (_reviewController.text.isNotEmpty) {
      // Lưu thông tin đánh giá vào danh sách
      final newReview = {
        'name': _username, // Lấy tên từ biến _username
        'review': _reviewController.text,
        'rating': _ratings[index], // Lấy đánh giá sao
      };
      _reviews.add(newReview); // Thêm đánh giá vào danh sách

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Đánh giá đã được gửi!')));
      _reviewController.clear(); // Xóa nội dung trường đánh giá
      setState(() {
        _ratings[index] = null; // Đặt lại đánh giá
      });
    }
  }

  Widget _buildReviewList(int index) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _reviews.length,
      itemBuilder: (context, reviewIndex) {
        final review = _reviews[reviewIndex];
        return ListTile(
          title: Text(review['name']), // Hiển thị tên người đánh giá
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Đánh giá: ${review['review']}'), // Hiển thị nội dung đánh giá
              Row(
                children: List.generate(5, (starIndex) {
                  return Icon(
                    Icons.star,
                    color: starIndex < review['rating']
                        ? Colors.yellow
                        : Colors.grey, // Màu sao
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewProductDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetail(
          name: widget.products[index].name,
          image: widget.products[index].image,
          price: widget.products[index].price,
          details: 'Chi tiết về sản phẩm ${widget.products[index].name}',
          addToCart: (String productName, double price, String image) {},
          reviews: _reviews, // Truyền danh sách đánh giá vào trang chi tiết
        ),
      ),
    );
  }
}
