import 'package:flutter/material.dart';
import '../data/product_service.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({Key? key}) : super(key: key);

  @override
  _ProductManagementPageState createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> _products = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _editingProductId;

  final List<String> _categories = [
    'MÓN CHÍNH',
    'FAST FOOD',
    'ĐỒ NGỌT',
    'THỨC UỐNG',
  ];

  final Map<String, List<String>> _subcategories = {
    'MÓN CHÍNH': ['Bánh Mì', 'Cơm', 'Món Nước', 'Món Xào', 'Sushi'],
    'FAST FOOD': ['Hamburger', 'Tacos', 'Sandwich'],
    'ĐỒ NGỌT': ['Bánh Ngọt', 'Bánh Mặn', 'Kem', 'Mousse'],
    'THỨC UỐNG': ['Coffee', 'Nước Ép', 'Nước Ngọt', 'Trà'],
  };

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      _products = await _productService.getProducts();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lấy danh sách sản phẩm: $e")),
      );
    }
  }

  void _showAddProductForm() {
    _resetFormFields();
    _showFormDialog('THÊM SẢN PHẨM');
  }

  void _showEditProductForm(Map<String, dynamic> product) {
    _populateFormFields(product);
    _showFormDialog('CẬP NHẬT SẢN PHẨM');
  }

  void _resetFormFields() {
    _nameController.clear();
    _priceController.clear();
    _imageController.clear();
    _selectedCategory = null;
    _selectedSubcategory = null;
    _editingProductId = null;
  }

  void _populateFormFields(Map<String, dynamic> product) {
    _nameController.text = product['name'] ?? '';
    _priceController.text = product['price']?.toString() ?? '';
    _imageController.text = product['image'] ?? '';
    _selectedCategory = product['category'];
    _selectedSubcategory = product['subcategory'];
    _editingProductId = product['id'];
  }

  void _showFormDialog(String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Tên sản phẩm', _nameController),
                _buildTextField('Giá sản phẩm', _priceController,
                    keyboardType: TextInputType.number),
                _buildTextField('Hình ảnh sản phẩm (URL)', _imageController),
                _buildCategoryDisplay(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveProduct();
                Navigator.of(context).pop();
                _fetchProducts();
              },
              child: Text(_editingProductId == null ? 'Thêm' : 'Cập nhật'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildCategoryDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () => _showCategoryDialog(),
          child: Text('Chọn Phân loại'),
        ),
        if (_selectedCategory != null && _selectedSubcategory != null)
          Text(
            'Phân loại: $_selectedCategory - $_selectedSubcategory',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chọn Phân loại'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: Text("Chọn phân mục lớn"),
                isExpanded: true,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedSubcategory = null; // Reset subcategory
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Phân mục lớn',
                ),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedSubcategory,
                hint: Text("Chọn phân mục nhỏ"),
                isExpanded: true,
                items: _selectedCategory != null &&
                        _subcategories.containsKey(_selectedCategory)
                    ? _subcategories[_selectedCategory]!
                        .map((String subcategory) {
                        return DropdownMenuItem<String>(
                          value: subcategory,
                          child: Text(subcategory),
                        );
                      }).toList()
                    : [],
                onChanged: (value) {
                  setState(() {
                    _selectedSubcategory = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Phân mục nhỏ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProduct() async {
    try {
      if (_editingProductId == null) {
        await _productService.addProduct(
          _nameController.text,
          double.tryParse(_priceController.text) ?? 0,
          _selectedCategory ?? '',
          _selectedSubcategory ?? '',
          _imageController.text,
        );
      } else {
        await _productService.updateProduct(_editingProductId!, {
          'name': _nameController.text,
          'price': double.tryParse(_priceController.text) ?? 0,
          'category': _selectedCategory ?? '',
          'subcategory': _selectedSubcategory ?? '',
          'image': _imageController.text,
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lưu sản phẩm: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý sản phẩm'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddProductForm,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTableHeader(),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return _buildProductRow(_products[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Table(
      border: TableBorder(
        bottom: BorderSide(color: Colors.red, width: 2),
      ),
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            _buildHeaderCell('SẢN PHẨM'),
            _buildHeaderCell('PHÂN LOẠI'),
            _buildHeaderCell('GIÁ'),
            _buildHeaderCell('CHỨC NĂNG'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProductRow(Map<String, dynamic> product) {
    return Table(
      border: TableBorder(
        bottom: BorderSide(color: Colors.black, width: 1),
      ),
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            _buildProductCell(
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    child: Image.network(
                      product['image'] ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      product['name'] ?? 'Tên không có',
                      style: TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            _buildProductCell(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    product['category'] ?? 'Không có',
                    style: TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product['subcategory'] ?? 'Không có',
                    style: TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _buildProductCell(
              Center(
                child: Text(
                  '${product['price']?.toString() ?? '0'}',
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            _buildProductCell(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 18),
                    onPressed: () => _showEditProductForm(product),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 18),
                    onPressed: () {
                      if (product['id'] != null) {
                        _deleteProduct(product['id']);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("ID sản phẩm không hợp lệ")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductCell(Widget child) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: child,
      ),
    );
  }

  void _deleteProduct(String productId) async {
    // Hiển thị hộp thoại xác nhận
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa sản phẩm này không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Đóng hộp thoại nếu không muốn xóa
              },
              child: Text('Không'),
            ),
            TextButton(
              onPressed: () async {
                await _productService.deleteProduct(productId);
                Navigator.of(context).pop(); // Đóng hộp thoại xác nhận
                _fetchProducts(); // Cập nhật danh sách sản phẩm
              },
              child: Text('Có'),
            ),
          ],
        );
      },
    );
  }
}
