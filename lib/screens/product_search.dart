import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rei_sugar/screens/save_sugars.dart';

class ProductSearch extends StatefulWidget {
  const ProductSearch({super.key});

  @override
  State<ProductSearch> createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearch> {
  final _barcodeController = TextEditingController();
  String _sugarContent = '';
  bool _isLoading = false; // For Search Product loading
  bool _isSaving = false; // For Save Sugars loading
  double? _sugarValue; // To store the numeric sugar value for saving
  String? _barcode; // To store the barcode for saving

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchSugarContent() async { // Fetch sugar content from OpenFoodFacts API using barcode
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
      _barcode = barcode; // Store the barcode
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

  Future<void> _saveSugars() async { // Save sugar content to Firestore and navigate to SaveSugars screen
    if (_sugarValue != null && _barcode != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      setState(() {
        _isSaving = true; // Start loading
      });

      try {
        final now = DateTime.now();
        final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('sugarSearches')
            .add({
          'barcode': _barcode,
          'sugarValue': _sugarValue,
          'date': date,
          'timestamp': Timestamp.fromDate(now),
        });

        // Navigate to SaveSugars screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SaveSugars()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sugar value saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving sugar value: $e')),
        );
      } finally {
        setState(() {
          _isSaving = false; // Stop loading
        });
      }
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
                  //width: double.infinity,
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
                width: double.infinity, // Kept to ensure fixed width
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.all(15),
                child: Text(
                  _sugarContent.isEmpty ? 'Results Here' : _sugarContent,
                  style: const TextStyle(
                    color: Color(0xFF983c3c),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              // Save Sugars button
              GestureDetector(
                onTap: _isSaving ? null : _saveSugars, // Disable button while saving
                child: Container(
                  //width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Center(
                    child: _isSaving
                        ? const CircularProgressIndicator(
                      color: Colors.white, // Match the text color
                    )
                        : const Text(
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