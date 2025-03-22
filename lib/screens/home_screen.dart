import 'package:flutter/material.dart';
import 'package:rei_sugar/screens/product_search.dart';
import 'package:rei_sugar/screens/view_history.dart';

class HomeScreen extends StatelessWidget {
  final String email;

  const HomeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final String firstLetter;
    if (email.isNotEmpty) {
      firstLetter = email[0].toUpperCase();
    } else {
      firstLetter = '';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0088ff),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Logout button row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.logout_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Go back to LoginScreen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logout successful!')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Centered CircleAvatar
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Search Sugars button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProductSearch()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: Text(
                      'Search Sugars',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // View History button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ViewHistory()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: Text(
                      'View History',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}