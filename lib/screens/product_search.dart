import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductSearch extends StatefulWidget {
  const ProductSearch({super.key});

  @override
  State<ProductSearch> createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearch> {
  final _barcodeController = TextEditingController();
  String _sugarContent = ''; // To store the sugar content or error message
  bool _isLoading = false; // To show a loading indicator

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchSugarContent() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      setState(() {
        _sugarContent = 'Please enter a barcode';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _sugarContent = '';
    });

    try {
      final url = Uri.parse('https://world.openfoodfacts.org/api/v3/product/$barcode.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Print the raw response to debug (optional, can remove after testing)
        print('API Response: $data');
        // Check if the product and nutriments data exist
        if (data['product'] != null &&
            data['product']['nutriments'] != null &&
            data['product']['nutriments']['sugars_100g'] != null) {
          final sugar = data['product']['nutriments']['sugars_100g'];
          setState(() {
            _sugarContent = 'Sugar Content: $sugar g per 100g';
          });
        } else {
          setState(() {
            _sugarContent = 'Sugar content not found for this product';
          });
        }
      } else {
        setState(() {
          _sugarContent = 'Error: Failed to fetch product data (Status: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _sugarContent = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0088ff),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'lib/images/rei_ayanami.png',
                height: 150,
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Search Product',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // Barcode input field
              TextField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter barcode...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number, // Barcode is typically numeric
              ),
              const SizedBox(height: 16),
              // Search button
              GestureDetector(
                onTap: _isLoading ? null : _fetchSugarContent, // Disable button while loading
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.blue,
                    )
                        : const Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Result container
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _sugarContent.isEmpty ? 'Enter a barcode to see sugar content' : _sugarContent,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}