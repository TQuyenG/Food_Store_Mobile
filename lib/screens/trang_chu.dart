import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import '../data/auth_service.dart';
import 'login.dart';
import 'gio_hang.dart';
import 'san_pham.dart';
import 'info.dart';
import 'dart:math'; // Cần khai báo thư viện dart:math để sử dụng hàm min và max

class TrangChu extends StatefulWidget {
  @override
  _TrangChuState createState() => _TrangChuState();
}

class _TrangChuState extends State<TrangChu>
    with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final AuthService _auth = AuthService();
  late TabController _tabController; // Khởi tạo TabController với 4 tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  // Phương thức để đăng xuất người dùng
  void _logout() async {
    await FirebaseAuth.instance.signOut(); // Đăng xuất người dùng
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginScreen()), // Chuyển hướng về trang đăng nhập
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 30,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/logo/logo.png',
                height: 30,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Food Store',
              style: TextStyle(
                fontFamily: 'SVN-Bistro Script',
                fontSize: 30,
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
          ],
        ),
        backgroundColor: Color(0xFFFDC9C9),
        actions: [
          if (user != null) // Kiểm tra nếu người dùng đã đăng nhập
            Row(
              children: [
                Text(
                  'Hello!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 2), // Khoảng cách giữa chữ và biểu tượng
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    _logout();
                  },
                ),
              ],
            )
          else
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginScreen()), // Chuyển đến màn hình đăng nhập
                );
              },
            ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Chuyển đến tab Giỏ Hàng
              _tabController.animateTo(2);
            },
          ),
        ],
        elevation: 4,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PageStorage(
            bucket: PageStorageBucket(),
            child: TrangChuContent(key: PageStorageKey('homeTab')),
          ),
          PageStorage(
            bucket: PageStorageBucket(),
            child: SanPham(key: PageStorageKey('productTab')),
          ),
          PageStorage(
            bucket: PageStorageBucket(),
            child: GioHang(cartItems: [], key: PageStorageKey('cartTab')),
          ),
          PageStorage(
            bucket: PageStorageBucket(),
            child: Info(key: PageStorageKey('infoTab')),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFDC9C9),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.home), text: 'Trang Chủ'),
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Sản Phẩm'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'Giỏ Hàng'),
            Tab(icon: Icon(Icons.person), text: 'Tài khoản'),
          ],
          labelColor: Colors.pink, // Màu của nhãn được chọn
          unselectedLabelColor: Colors.black54, // Màu của nhãn không được chọn
          indicator: ShapeDecoration(
            color: Colors.white.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding:
              EdgeInsets.symmetric(horizontal: 10), // Khoảng cách giữa các tab
        ),
      ),
    );
  }
}

class TrangChuContent extends StatefulWidget {
  const TrangChuContent({Key? key}) : super(key: key); // Thêm Key
  @override
  _TrangChuContentState createState() => _TrangChuContentState();
}

class _TrangChuContentState extends State<TrangChuContent> {
  int currentImage = 0; // Chỉ số slide hình ảnh hiện tại

  List<String> displayedChars = [];
  int currentCharIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), _startCarousel);
    _startTypingAnimation();
  }

  // Phần slide hình ảnh
  void _startCarousel() {
    setState(() {
      currentImage =
          (currentImage + 1) % 3; // Cập nhật chỉ số slide hình ảnh hiện tại
    });
    Future.delayed(
        Duration(seconds: 3), _startCarousel); // Tạo vòng lặp với độ trễ 3 giây
  }

  // Hàm khởi động animation cho chữ
  void _startTypingAnimation() {
    const welcomeMessage = 'WELCOME TO STORE!';
    Future.delayed(Duration(milliseconds: 50), () {
      if (currentCharIndex < welcomeMessage.length) {
        setState(() {
          displayedChars.add(
              welcomeMessage[currentCharIndex]); // Thêm ký tự vào danh sách
          currentCharIndex++;
        });
        _startTypingAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước của màn hình
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1/ Banner quảng cáo
          Container(
            height: min(max(screenHeight * 0.3, 200),
                400), // Giới hạn chiều cao trong khoảng 200 đến 400
            width: double.infinity, // Đặt chiều rộng bằng chiều rộng màn hình
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/anh_bia/gif/mon_an4.gif'), // Đường dẫn đến hình ảnh
                fit: BoxFit.cover, // Đảm bảo hình ảnh bao phủ khung
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Màu sắc của bóng
                  spreadRadius: 2, // Tán xạ bóng
                  blurRadius: 8, // Độ mờ của bóng
                  offset: Offset(0, 3), // Vị trí bóng
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // 2.1/ Tiêu đề chào mừng
          Container(
            width: double.infinity, // Đặt chiều rộng bằng chiều rộng màn hình
            padding: EdgeInsets.symmetric(
                horizontal: min(screenWidth * 0.02, 30), vertical: 0.1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade100, Colors.red.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.7),
                  offset: Offset(3, 3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(displayedChars.length, (index) {
                  return AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(milliseconds: 300),
                    child: Text(
                      displayedChars[index], // Hiển thị từng ký tự
                      style: TextStyle(
                        fontFamily: 'SJ-Cambell',
                        fontSize: min(MediaQuery.of(context).size.width * 0.09,
                            70), // Giới hạn kích thước chữ tối đa là 70
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(3, 3.5),
                            blurRadius: 3,
                          ),
                        ],
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Row cho hai cột
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWideScreen =
                  constraints.maxWidth > 650; // Kiểm tra kích thước màn hình

              return isWideScreen
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Cột bên trái cho tiêu đề chào mừng và biểu tượng
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 2.2/ Đoạn văn giới thiệu
                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                margin: EdgeInsets.symmetric(vertical: 10),
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.05),
                                child: Column(
                                  children: [
                                    // Tiêu đề
                                    Container(
                                      child: Column(
                                        children: [
                                          Text(
                                            '~ Món Ngon Mỗi Ngày ~',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: min(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.08,
                                                  50),
                                              fontFamily: 'SVN-Bistro Script',
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87
                                                  .withOpacity(0.7),
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(2.0, 2.0),
                                                  blurRadius: 5.0,
                                                  color: Colors.red.shade200,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Đoạn văn giới thiệu
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01),
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Tại ',
                                            style: TextStyle(
                                              fontSize: min(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.035,
                                                  22),
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Food Store',
                                            style: TextStyle(
                                              fontSize: min(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.04,
                                                  24),
                                              color: Colors.pink,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                ', chúng tôi cung cấp những nguyên liệu tươi ngon và các món ăn hấp dẫn, đáp ứng mọi nhu cầu ẩm thực của bạn. '
                                                'Với sự cam kết về chất lượng và hương vị, mỗi bữa ăn đều trở thành niềm vui. '
                                                'Hãy khám phá ngay hôm nay!',
                                            style: TextStyle(
                                              fontSize: min(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.035,
                                                  22),
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 20),

                              // 3/ Biểu tượng với style
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buildIconContainer(
                                      Icons.fastfood,
                                      Colors.orange,
                                      Colors.deepOrange,
                                      screenWidth),
                                  SizedBox(width: screenWidth * 0.03),
                                  buildIconContainer(
                                      Icons.local_drink,
                                      Colors.blue,
                                      Colors.blueAccent,
                                      screenWidth),
                                  SizedBox(width: screenWidth * 0.03),
                                  buildIconContainer(Icons.cake, Colors.pink,
                                      Colors.pink, screenWidth),
                                  SizedBox(width: screenWidth * 0.03),
                                  buildIconContainer(
                                      Icons.icecream,
                                      Colors.blue.shade300,
                                      Colors.lightBlue,
                                      screenWidth),
                                  SizedBox(width: screenWidth * 0.03),
                                  buildIconContainer(
                                      Icons.local_pizza,
                                      Colors.red.shade300,
                                      Colors.redAccent,
                                      screenWidth),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Khoảng cách giữa hai cột
                        SizedBox(width: 20),

                        // Cột bên phải cho slide show
                        Expanded(
                          child: Center(
                            child: _buildImageCarousel(context),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        // Nếu màn hình nhỏ, cột bên trái sẽ ở hàng trên
                        // 2.2/ Đoạn văn giới thiệu
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05),
                          child: Column(
                            children: [
                              // Tiêu đề
                              Container(
                                child: Column(
                                  children: [
                                    Text(
                                      '~ Món Ngon Mỗi Ngày ~',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: min(
                                            MediaQuery.of(context).size.width *
                                                0.08,
                                            50),
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
                                  ],
                                ),
                              ),

                              // Đoạn văn giới thiệu
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Tại ',
                                      style: TextStyle(
                                        fontSize: min(
                                            MediaQuery.of(context).size.width *
                                                0.035,
                                            22),
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Food Store',
                                      style: TextStyle(
                                        fontSize: min(
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                            24),
                                        color: Colors.pink,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ', chúng tôi cung cấp những nguyên liệu tươi ngon và các món ăn hấp dẫn, đáp ứng mọi nhu cầu ẩm thực của bạn. '
                                          'Với sự cam kết về chất lượng và hương vị, mỗi bữa ăn đều trở thành niềm vui. '
                                          'Hãy khám phá ngay hôm nay!',
                                      style: TextStyle(
                                        fontSize: min(
                                            MediaQuery.of(context).size.width *
                                                0.035,
                                            22),
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // 3/ Biểu tượng với style - hàng trên cho cột trái
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildIconContainer(Icons.fastfood, Colors.orange,
                                Colors.deepOrange, screenWidth),
                            SizedBox(width: screenWidth * 0.03),
                            buildIconContainer(Icons.local_drink, Colors.blue,
                                Colors.blueAccent, screenWidth),
                            SizedBox(width: screenWidth * 0.03),
                            buildIconContainer(Icons.cake, Colors.pink,
                                Colors.pink, screenWidth),
                            SizedBox(width: screenWidth * 0.03),
                            buildIconContainer(
                                Icons.icecream,
                                Colors.blue.shade300,
                                Colors.lightBlue,
                                screenWidth),
                            SizedBox(width: screenWidth * 0.03),
                            buildIconContainer(
                                Icons.local_pizza,
                                Colors.red.shade300,
                                Colors.redAccent,
                                screenWidth),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Slide show - hàng dưới cho cột phải
                        Container(
                          height: 200, // Chiều cao của slide show
                          width:
                              double.infinity, // Chiều rộng chiếm hết màn hình
                          child: _buildImageCarousel(context),
                        ),
                      ],
                    );
            },
          ),

          SizedBox(height: 20),

          // 5.1/ Giới thiệu dịch vụ
          serviceIntroduction(),
          SizedBox(height: 0), // Tạo khoảng cách giữa các hàng

          SizedBox(height: 20),

          // 6.1/ Tiêu đề danh mục
          Container(
            width: double.infinity, // Đặt chiều rộng bằng chiều rộng màn hình
            padding: EdgeInsets.symmetric(
                horizontal: min(screenWidth * 0.02, 30), vertical: 0.1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.7),
                  offset: Offset(3, 3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '- DANH MỤC SẢN PHẨM -',
                style: TextStyle(
                  fontFamily: 'SJ-Cambell',
                  fontSize: min(MediaQuery.of(context).size.width * 0.07,
                      60), // Giới hạn kích thước chữ tối đa là 70
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(3, 3.5),
                      blurRadius: 3,
                    ),
                  ],
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // 6.2/ Giới thiệu các loại sản phẩm trong menu
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Căn giữa theo chiều dọc
              children: [
                // Món chính
                SizedBox(
                  height: 120, // Chiều cao cố định cho mỗi mục
                  width: 800,
                  child: productCategory(
                    title: 'MÓN CHÍNH',
                    imageAsset: 'assets/anh_bia/jpg/f3.jpg',
                    description: 'Các món ăn chính hấp dẫn và đầy dinh dưỡng',
                    onPressed: () {
                      print('Món chính được chọn');
                    },
                    isEven: false, // Không phải box chẵn
                  ),
                ),
                SizedBox(height: 10), // Khoảng cách giữa các mục
                // Fast food
                SizedBox(
                  height: 120,
                  width: 800,
                  child: productCategory(
                    title: 'FAST FOOD',
                    imageAsset: 'assets/anh_bia/jpg/f9.jpg',
                    description: 'Các món ăn nhanh tiện lợi và đầy hương vị',
                    onPressed: () {
                      print('Fast Food được chọn');
                    },
                    isEven: true, // Box chẵn
                  ),
                ),
                SizedBox(height: 10),
                // Đồ ngọt
                SizedBox(
                  height: 120,
                  width: 800,
                  child: productCategory(
                    title: 'ĐỒ NGỌT',
                    imageAsset: 'assets/anh_bia/jpg/f6.jpg',
                    description: 'Các món tráng miệng và bánh ngọt thơm ngon',
                    onPressed: () {
                      print('Đồ ngọt được chọn');
                    },
                    isEven: false, // Không phải box chẵn
                  ),
                ),
                SizedBox(height: 10),
                // Thức uống
                SizedBox(
                  height: 120,
                  width: 800,
                  child: productCategory(
                    title: 'THỨC UỐNG',
                    imageAsset: 'assets/anh_bia/jpg/f1.jpg',
                    description: 'Các loại thức uống đa dạng và tươi mát',
                    onPressed: () {
                      print('Thức uống được chọn');
                    },
                    isEven: true, // Box chẵn
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // 7/ Sản phẩm bán chạy
          productSection(
            '~ Sản Phẩm Bán Chạy ~',
            [
              {
                'imagePath':
                    'https://i.pinimg.com/736x/55/c9/fe/55c9fee5f520ddcb95a635e0f3d39595.jpg',
                'name': 'Mì hoành thánh',
                'price': 35000,
              },
              {
                'imagePath':
                    'https://i.pinimg.com/736x/95/e5/3a/95e53a3659adf692c0cc1fcd91010671.jpg',
                'name': 'Phở bò viên',
                'price': 40000,
              },
              {
                'imagePath':
                    'https://i.pinimg.com/736x/46/11/8f/46118f1a43779595e68d6520a3ab721c.jpg',
                'name': 'Hamburger bò 2 tầng',
                'price': 40000,
              },
              {
                'imagePath':
                    'https://i.pinimg.com/736x/55/c9/fe/55c9fee5f520ddcb95a635e0f3d39595.jpg',
                'name': 'Mì hoành thánh',
                'price': 35000,
              },
              {
                'imagePath':
                    'https://i.pinimg.com/736x/c7/cc/7e/c7cc7e1f51fe68fac7fe95ae4c55afd7.jpg',
                'name': 'Hủ tiếu',
                'price': 40000,
              },
              {
                'imagePath':
                    'https://i.pinimg.com/736x/46/11/8f/46118f1a43779595e68d6520a3ab721c.jpg',
                'name': 'Hamburger bò 2 tầng',
                'price': 40000,
              },
            ],
          ),

          SizedBox(height: 20),

          // 8/ Sản phẩm mới nhất
          productSection(
            '~ Sản Phẩm Mới Nhất ~',
            [
              {
                'imagePath':
                    'https://i.pinimg.com/736x/1c/c7/b8/1cc7b81423b52dd34763d14ae03abf2a.jpg',
                'name': 'Sushi',
                'price': 45000,
              },
              {
                'imagePath':
                    'https://media.istockphoto.com/id/542331706/vi/anh/tacos-t%C3%B4m-cay-t%E1%BB%B1-l%C3%A0m.jpg?s=612x612&w=0&k=20&c=gdZyCMg7cU-TQKX7wm0mHVRqeWwaRX-1fkDlkrqS2TU=',
                'name': 'Tacos tôm',
                'price': 40000,
              },
              {
                'imagePath':
                    'https://i.pinimg.com/736x/c7/cc/7e/c7cc7e1f51fe68fac7fe95ae4c55afd7.jpg',
                'name': 'Hủ tiếu',
                'price': 50000,
              },
              {
                'imagePath':
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQBnfTXs9DpaPffvPTpjsS2XrGmEqiS1PebKA&s',
                'name': 'Chocolate Cake',
                'price': 35000,
              },
              {
                'imagePath':
                    'https://i.ytimg.com/vi/RoHWiA6pogg/maxresdefault.jpg',
                'name': 'Apple Pie',
                'price': 40000,
              },
              {
                'imagePath':
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2ErERfa41ZbV7xPe3KimnHlRTUdS8sC8ltqEMRgLLtcJrjO1VF6YIbQC3jZVv_aKpDAU&usqp=CAU',
                'name': 'Bánh mì bì',
                'price': 40000,
              },
            ],
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  // 3. Hàm tạo biểu tượng với style
  Widget buildIconContainer(
      IconData icon, Color bgColor, Color iconColor, double screenWidth) {
    // Điều chỉnh kích thước icon dựa trên kích thước màn hình
    double iconSize =
        screenWidth * 0.04; // Kích thước icon lớn hơn khi màn hình lớn hơn

    // Đảm bảo kích thước không quá nhỏ hoặc quá lớn
    if (iconSize < 32) {
      iconSize = 32; // Kích thước nhỏ nhất là 32
    } else if (iconSize > 45) {
      iconSize = 45; // Kích thước lớn nhất là 45
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon,
          size: iconSize,
          color: iconColor), // Sử dụng kích thước icon đã điều chỉnh
    );
  }

  // 4. Hàm tạo slide show carousel
  Widget _buildImageCarousel(BuildContext context) {
    // Lấy kích thước của màn hình
    var screenWidth = MediaQuery.of(context).size.width;

    // Thiết lập kích thước tối đa và tối thiểu
    double maxWidth = 900; // Chiều rộng tối đa
    double minWidth = 400; // Chiều rộng tối thiểu
    double maxHeight = 300; // Chiều cao tối đa
    double minHeight = 200; // Chiều cao tối thiểu

    double carouselWidth = min(max(screenWidth * 1, minWidth), maxWidth);
    double carouselHeight =
        min(max(carouselWidth * 0.45, minHeight), maxHeight);

    return Stack(
      alignment: Alignment.center,
      children: [
        ImageSlideshow(
          width:
              carouselWidth, // Đặt chiều rộng của slideshow theo tỷ lệ chiều rộng màn hình
          height: carouselHeight, // Đặt chiều cao theo tỷ lệ chiều rộng
          initialPage: currentImage, // Hiển thị hình ảnh bắt đầu
          indicatorColor:
              Colors.pinkAccent, // Màu của chấm tròn mục lục khi ảnh được hiện
          indicatorBackgroundColor:
              Colors.grey, // Màu của chấm tròn mục lục khi ảnh chưa hiện
          children: List.generate(10, (index) {
            return GestureDetector(
              onTap: () {
                // Xử lý khi nhấn vào hình ảnh
                print('Image tapped: $index');
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: 10), // Khoảng cách giữa các hình ảnh
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30), // Bo tròn các góc
                  child: Image.asset(
                    'assets/anh_bia/jpg/f${index + 1}.jpg', // Đường dẫn hình ảnh
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }),
          onPageChanged: (value) {
            setState(() {
              currentImage = value; // Cập nhật currentImage khi trang thay đổi
            });
            print('Page changed: $value'); // In ra chỉ số của hình ảnh hiện tại
          },
          autoPlayInterval: 3000, // Tự động chuyển sau mỗi 3 giây
          isLoop: true, // Lặp lại từ đầu
        ),
      ],
    );
  }

  // 5.1 Hàm tạo bố cục phần giới thiệu dịch vụ
  Widget serviceFeature(IconData icon, String title, String description) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Icon(icon, size: 30, color: Colors.black),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
                Text(description,
                    style: TextStyle(fontSize: 12), textAlign: TextAlign.left),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5.2 Hàm giới thiệu dịch vụ
  Widget serviceIntroduction() {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 10, vertical: 5), // Padding bên trái và bên phải là 10
      color: Colors.grey[200],
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Kiểm tra chiều rộng màn hình
          if (constraints.maxWidth > 700) {
            // Nếu màn hình lớn (desktop), sử dụng 1 hàng
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 150), // Đặt padding trái và phải là 150
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Sử dụng spaceBetween để tối ưu hóa khoảng cách
                children: [
                  serviceFeature(Icons.local_shipping, 'FREESHIP',
                      'Đơn từ 200k, giao hàng miễn phí'),
                  serviceFeature(Icons.access_time, 'ĐÚNG GIỜ',
                      'Đảm bảo giao hàng đúng giờ hoặc trong 2 giờ dưới 10km'),
                  serviceFeature(Icons.payment, 'THANH TOÁN',
                      'Thanh toán bằng tiền mặt hoặc chuyển khoản'),
                  serviceFeature(Icons.verified, 'ĐẢM BẢO',
                      'Đảm bảo thức ăn vẫn còn nóng khi nhận hàng'),
                ],
              ),
            );
          } else {
            // Nếu màn hình nhỏ, chia thành 2 hàng
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    serviceFeature(Icons.local_shipping, 'FREESHIP',
                        'Đơn từ 200k, giao hàng miễn phí'),
                    SizedBox(width: 8),
                    serviceFeature(Icons.access_time, 'ĐÚNG GIỜ',
                        'Đảm bảo giao hàng đúng giờ hoặc trong 2 giờ dưới 10km'),
                  ],
                ),
                SizedBox(height: 8), // Khoảng cách giữa 2 hàng
                Container(
                  color: Colors.grey[300], // Màu nền xám cho Row thứ hai
                  padding: EdgeInsets.all(8), // Padding cho container
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      serviceFeature(Icons.payment, 'THANH TOÁN',
                          'Thanh toán bằng tiền mặt hoặc chuyển khoản'),
                      SizedBox(width: 8),
                      serviceFeature(Icons.verified, 'ĐẢM BẢO',
                          'Đảm bảo thức ăn vẫn còn nóng khi nhận hàng'),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // 6. Tạo hàm cho phần 6.2/ category
  Widget productCategory({
    required String title, // Tiêu đề của danh mục sản phẩm
    required String imageAsset, // Đường dẫn đến hình ảnh của sản phẩm
    required String description, // Mô tả về sản phẩm
    required VoidCallback onPressed, // Hàm xử lý sự kiện khi nhấn nút
    bool isEven = false, // Kiểm tra xem có phải box chẵn không
  }) {
    return Container(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(38),
          ),
          padding: EdgeInsets.symmetric(
              vertical: 5, horizontal: 0), // Padding cho nút
        ).copyWith(
          // Tùy chỉnh các trạng thái khác nhau của nút
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered) ||
                  states.contains(MaterialState.pressed)) {
                return Colors.white; // Chữ màu trắng khi rê chuột hoặc nhấn
              }
              return Colors.red[200]!; // Màu chữ đỏ khi trạng thái bình thường
            },
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.red[200]!; // Nền hồng nhạt khi rê chuột
              } else if (states.contains(MaterialState.pressed)) {
                return Colors.red[300]!; // Nền hồng đậm hơn khi click
              }
              return Colors.white
                  .withOpacity(0.8); // Nền trắng khi trạng thái bình thường
            },
          ),
        ),
        child: Row(
          children: [
            if (!isEven) ...[
              // Nếu không phải box chẵn
              // Hiển thị hình ảnh ở cột bên trái
              Container(
                width: 150, // Độ rộng của hình ảnh
                height: 120, // Chiều cao của hình ảnh
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.black54, width: 2), // Viền khung hình ảnh
                  borderRadius: BorderRadius.circular(38),
                  image: DecorationImage(
                    image: AssetImage(imageAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 20), // Khoảng cách giữa hình ảnh và văn bản
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Căn giữa trên dưới
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Căn trái cho văn bản
                  children: [
                    // Tiêu đề
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 35,
                        fontFamily: 'SJ Brushzerker BB',
                        shadows: [
                          Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 3),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5), // Khoảng cách giữa tiêu đề và mô tả
                    // Mô tả sản phẩm
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87, // Màu chữ mặc định
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Nếu là box chẵn
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Căn giữa trên dưới
                  crossAxisAlignment:
                      CrossAxisAlignment.end, // Căn phải cho văn bản
                  children: [
                    // Tiêu đề
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 35,
                        fontFamily: 'SJ Brushzerker BB',
                        shadows: [
                          Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 2),
                        ],
                      ),
                      textAlign: TextAlign.center, // Căn giữa cho tiêu đề
                    ),
                    SizedBox(height: 5), // Khoảng cách giữa tiêu đề và mô tả
                    // Mô tả sản phẩm
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87, // Màu chữ mặc định
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20), // Khoảng cách giữa văn bản và hình ảnh
              Container(
                width: 150, // Độ rộng của hình ảnh
                height: 120, // Chiều cao của hình ảnh
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54, width: 2),
                  borderRadius: BorderRadius.circular(38),
                  image: DecorationImage(
                    image: AssetImage(imageAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 7+8. Hàm tạo phần sản phẩm bán chạy / mới nhất
  Widget productSection(String title, List<Map<String, dynamic>> products) {
    PageController boxController = PageController(viewportFraction: 0.8);
    int currentPage = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        // Hàm chuyển sang trang tiếp theo
        void nextPage() {
          boxController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut, // Hiệu ứng chuyển mượt
          );
        }

        // Hàm quay lại trang trước đó
        void previousPage() {
          boxController.previousPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut, // Hiệu ứng chuyển mượt
          );
        }

        return Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 1000, // Chiều dài tối đa của phần này
              ),
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
                            fontSize: 40, // Kích thước chữ tiêu đề
                            fontFamily: 'SVN-Bistro Script', // Font tùy chỉnh
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
                      // Danh sách sản phẩm
                      Container(
                        height: 180,
                        child: PageView.builder(
                          controller:
                              boxController, // Sử dụng controller để điều khiển
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
                                    color:
                                        Colors.red.shade200.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                children: [
                                  // Ảnh sản phẩm
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      product['imagePath'],
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Tên và giá sản phẩm
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.black87
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
                                            product['name'].toUpperCase(),
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
                                          Text(
                                            '${product['price'].toStringAsFixed(0)} VNĐ',
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
                                              child: Text('Xem thêm >>'),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor: Colors.red
                                                    .shade300, // Màu nền nút
                                                minimumSize: Size(30, 30),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        10), // Khoảng cách từ chữ với viền nút
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8), // bo góc nút
                                                ),
                                                elevation:
                                                    20, // Độ dày của bóng
                                                shadowColor: Colors.black
                                                    .withOpacity(
                                                        0.9), // Màu bóng
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
                      // Nút quay lại trang trước
                      Positioned(
                        left: 0,
                        top: 70, // Căn giữa theo chiều dọc
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Colors.redAccent,
                          ),
                          onPressed: previousPage, // Chuyển trang khi nhấn nút
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      // Nút tới trang tiếp theo
                      Positioned(
                        right: 0,
                        top: 70,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            size: 30,
                            color: Colors.redAccent,
                          ),
                          onPressed: nextPage, // Chuyển trang khi nhấn nút
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
}
