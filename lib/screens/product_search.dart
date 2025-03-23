import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductSearch extends StatefulWidget {
  const ProductSearch({super.key});

  @override
  State<ProductSearch> createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearch> {
  final _barcodeController = TextEditingController();
  String _sugarContent = '';
  bool _isLoading = false;
  double? _sugarValue; // To store the numeric sugar value for saving

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
      _sugarValue = null; // Reset sugar value
    });

    try {
      final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['product'] != null &&
            data['product']['nutriments'] != null &&
            data['product']['nutriments']['sugars_100g'] != null) {
          final sugar = data['product']['nutriments']['sugars_100g'];
          setState(() {
            _sugarContent = 'Sugar Content: $sugar g per 100g';
            if (sugar is int) {
              _sugarValue = (sugar as int).toDouble();
            } else {
              _sugarValue = sugar as double?;
            }
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

  void _saveSugars() {
    if (_sugarValue != null) {
      // Placeholder: Print the sugar value for now
      print('Saving sugar value: $_sugarValue g per 100g');
      // TODO: Pass the sugar value to another screen and save it in a table
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sugar content to save')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0088ff),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Back button row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Go back to HomeScreen
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Logo
              Image.asset(
                'lib/images/rei_ayanami.png',
                height: 150,
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Check Sugar Content',
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
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Search button
              GestureDetector(
                onTap: _isLoading ? null : _fetchSugarContent,
                child: Container(
                  //width: double.infinity, // Make the button full width
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
                      'Search Product',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Result container with fixed width
              Container(
                width: double.infinity, // Match the width of the buttons
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.all(15),
                child: Text(
                  _sugarContent.isEmpty ? 'Results Here' : _sugarContent,
                  style: const TextStyle(
                    color: Color(0xFF983c3c),
                    //fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              // Save Sugars button
              GestureDetector(
                onTap: _saveSugars,
                child: Container(
                  //width: double.infinity, // Match the width of the buttons
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: const Center(
                    child: Text(
                      'Save Sugars',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}