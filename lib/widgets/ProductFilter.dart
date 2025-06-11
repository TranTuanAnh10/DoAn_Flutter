// import 'package:flutter/material.dart';
// import '../models/product_data.dart';
//
// class ProductFilter extends StatefulWidget {
//   final ProductResponse productResponse;
//
//   ProductFilter({required this.productResponse});
//
//   @override
//   _ProductFilterState createState() => _ProductFilterState();
// }
//
// class _ProductFilterState extends State<ProductFilter> {
//   // Các biến lưu giá trị lựa chọn của người dùng
//   String? selectedColor;
//   String? selectedRAM;
//   String? selectedStorage;
//
//   // Hàm lọc sản phẩm dựa trên các lựa chọn
//   List<ProductData> getFilteredProducts() {
//     return widget.productResponse.products.where((product) {
//       bool matchesColor = selectedColor == null || product.properties.any((prop) => prop.name == "Color" && prop.value == selectedColor);
//       bool matchesRAM = selectedRAM == null || product.properties.any((prop) => prop.name == "RAM" && prop.value == selectedRAM);
//       bool matchesStorage = selectedStorage == null || product.properties.any((prop) => prop.name == "Storage" && prop.value == selectedStorage);
//
//       return matchesColor && matchesRAM && matchesStorage;
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Lấy danh sách các biến thể từ API
//     List<ProductVariant> variants = widget.productResponse.variants;
//
//     // Lấy giá trị của mỗi thuộc tính từ danh sách variants
//     List<String> colors = variants.firstWhere((variant) => variant.name == "Color").values;
//     List<String> ram = variants.firstWhere((variant) => variant.name == "RAM").values;
//     List<String> storage = variants.firstWhere((variant) => variant.name == "Storage").values;
//
//     return Scaffold(
//       appBar: AppBar(title: Text("Chọn biến thể")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Dropdown cho Color
//             DropdownButton<String>(
//               value: selectedColor,
//               hint: Text("Chọn Màu"),
//               isExpanded: true,
//               items: colors.map((color) {
//                 return DropdownMenuItem<String>(
//                   value: color,
//                   child: Text(color),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedColor = value;
//                 });
//               },
//             ),
//             // Dropdown cho RAM
//             DropdownButton<String>(
//               value: selectedRAM,
//               hint: Text("Chọn RAM"),
//               isExpanded: true,
//               items: ram.map((ramValue) {
//                 return DropdownMenuItem<String>(
//                   value: ramValue,
//                   child: Text(ramValue),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedRAM = value;
//                 });
//               },
//             ),
//             // Dropdown cho Storage
//             DropdownButton<String>(
//               value: selectedStorage,
//               hint: Text("Chọn Storage"),
//               isExpanded: true,
//               items: storage.map((storageValue) {
//                 return DropdownMenuItem<String>(
//                   value: storageValue,
//                   child: Text(storageValue),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedStorage = value;
//                 });
//               },
//             ),
//             SizedBox(height: 20),
//             // Hiển thị danh sách sản phẩm sau khi lọc
//             Expanded(
//               child: ListView.builder(
//                 itemCount: getFilteredProducts().length,
//                 itemBuilder: (context, index) {
//                   ProductData product = getFilteredProducts()[index];
//                   return Card(
//                     child: ListTile(
//                       leading: Image.network(product.photos.firstWhere((photo) => photo.isMain).url),
//                       title: Text(product.name),
//                       subtitle: Text("Giá: ${product.amount}đ"),
//                       onTap: () {
//                         // Xử lý sự kiện khi người dùng nhấn vào sản phẩm
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
