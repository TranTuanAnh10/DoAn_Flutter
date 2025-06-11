import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../providers/constants.dart';
import '../screens/product_detail_screen.dart';

class FilterScreen extends StatefulWidget {
  final String searchText;

  const FilterScreen({Key? key, required this.searchText}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  Map<String, dynamic>? contextData;
  List<dynamic> products = [];
  Map<String, dynamic> selectedFilters = {};
  bool loading = false;
  String? errorMessage;
  late TextEditingController searchController;

  final List<String> brandOptions = ['All', 'realme', 'POCO', 'Samsung', 'MIUI', 'Redmi', 'Xiaomi', 'OnePlus', 'iPhone'];
  final List<String> priceOptions = ['5000', '10000', '15000', '20000', '25000', '30000', '40000', '50000', '100000', '150000'];
  final String priceMin = '5000';
  final String priceMax = '150000';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: widget.searchText);
    selectedFilters['Brand'] = brandOptions[0]; // Default to 'All'
    selectedFilters['PriceMin'] = priceMin; // Default to '5000'
    selectedFilters['PriceMax'] = priceMax; // Default to '150000'
    fetchProducts(searchController.text, filters: selectedFilters, initializeFilters: true);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts(String searchText, {required Map<String, dynamic> filters, bool initializeFilters = false}) async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    String query = 'q=$searchText';
    if (filters['PriceMin'] != null && filters['PriceMax'] != null &&
        filters['PriceMin'] != priceMin && filters['PriceMax'] != priceMax) {
      query += '&price=${filters['PriceMin']}-${filters['PriceMax']}';
    }

    filters.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty && key != 'PriceMin' && key != 'PriceMax') {
        if (key == 'Brand' && value == 'All') return;
        query += '&$key=$value';
      }
    });

    try {
      final url = Uri.parse('${Constant.baseUrl}/api/product/?$query');
      var token = Provider.of<Auth>(context, listen: false).token;
      final response = await http.get(url, headers: {
        'accept': 'application/json, text/plain, */*',
        'authorization': 'Bearer ${token}',
      });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        setState(() {
          contextData = jsonData['context'];
          products = jsonData['items'] ?? [];

          // Initialize dynamic filters
          if (initializeFilters && contextData?['properties'] != null) {
            for (var property in contextData!['properties']) {
              if (property['filter'] == true && property['values'] != null) {
                List<String> values = (property['values'].toString())
                    .split(',')
                    .where((v) => v.trim().isNotEmpty)
                    .toList();
                if (values.isNotEmpty && !selectedFilters.containsKey(property['name'])) {
                  selectedFilters[property['name']] = values[0];
                }
              }
            }
          }

          loading = false;
        });
      } else {
        setState(() {
          loading = false;
          errorMessage = 'Failed to load products: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Widget buildFilterWidget(dynamic property) {
    String name = property['name'];
    String valuesStr = property['values'] ?? '';
    bool filterEnabled = property['filter'] ?? false;

    if (!filterEnabled || valuesStr.isEmpty) {
      return const SizedBox.shrink();
    }

    List<String> values = valuesStr.split(',').where((v) => v.trim().isNotEmpty).toList();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedFilters[name],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              hint: Text('Select $name'),
              items: values.map((v) {
                return DropdownMenuItem<String>(
                  value: v,
                  child: Text(
                    v + (property['unit'] != null && property['unit'] != '' ? ' ${property['unit']}' : ''),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  if (val == null) {
                    selectedFilters.remove(name);
                  } else {
                    selectedFilters[name] = val;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStaticFilters() {
    final int? selectedMinPrice = selectedFilters['PriceMin'] != null
        ? int.tryParse(selectedFilters['PriceMin'])
        : null;
    final List<String> maxPriceOptions = selectedMinPrice != null
        ? priceOptions.where((price) => int.parse(price) > selectedMinPrice).toList(growable: false)
        : priceOptions;

    if (selectedFilters['PriceMax'] != null && !maxPriceOptions.contains(selectedFilters['PriceMax'])) {
      selectedFilters['PriceMax'] = maxPriceOptions.isNotEmpty ? maxPriceOptions.last : priceMax;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter search term',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    fetchProducts(searchController.text, filters: selectedFilters);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Brand',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedFilters['Brand'],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              hint: const Text('Select Brand'),
              items: brandOptions.map((v) {
                return DropdownMenuItem<String>(
                  value: v,
                  child: Text(v, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  if (val == null) {
                    selectedFilters.remove('Brand');
                  } else {
                    selectedFilters['Brand'] = val;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Price Range',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedFilters['PriceMin'],
                    decoration: InputDecoration(
                      labelText: 'Min Price',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixText: '₫ ',
                    ),
                    items: priceOptions.map((price) {
                      return DropdownMenuItem<String>(
                        value: price,
                        child: Text(price, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        if (val != null) {
                          selectedFilters['PriceMin'] = val;
                          // Reset PriceMax if invalid
                          final int minPrice = int.parse(val);
                          final int? currentMaxPrice = selectedFilters['PriceMax'] != null
                              ? int.tryParse(selectedFilters['PriceMax'])
                              : null;
                          if (currentMaxPrice == null || currentMaxPrice <= minPrice) {
                            final validMaxOptions = priceOptions.where((price) => int.parse(price) > minPrice).toList();
                            selectedFilters['PriceMax'] = validMaxOptions.isNotEmpty ? validMaxOptions.last : priceMax;
                          }
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedFilters['PriceMax'],
                    decoration: InputDecoration(
                      labelText: 'Max Price',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixText: '₫ ',
                    ),
                    items: maxPriceOptions.map((price) {
                      return DropdownMenuItem<String>(
                        value: price,
                        child: Text(price, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        if (val != null) {
                          selectedFilters['PriceMax'] = val;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildStaticFilters(),
                  if (contextData != null && contextData!['properties'] != null)
                    ...List<Widget>.from(
                      contextData!['properties'].map<Widget>((p) => buildFilterWidget(p)),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            fetchProducts(searchController.text, filters: selectedFilters);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selectedFilters.clear();
                              selectedFilters['Brand'] = brandOptions[0]; // Reset to 'All'
                              selectedFilters['PriceMin'] = priceMin;
                              selectedFilters['PriceMax'] = priceMax;
                              searchController.text = widget.searchText; // Reset to initial search text
                            });
                            fetchProducts(searchController.text, filters: selectedFilters);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Clear Filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Product list
          Expanded(
            flex: 3,
            child: products.isEmpty
                ? const Center(child: Text('No products found'))
                : ListView.builder(
              itemCount: products.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final p = products[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(productId: p['id']),
                      ));
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        p['photoUrl'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, size: 60),
                      ),
                    ),
                    title: Text(
                      p['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${p['amount']}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}