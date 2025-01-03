import 'package:flutter/material.dart';
import 'package:education_apps/app/modules/profile/views/qr_code_picker_screen.dart'; // Import the screen for the QR Code picker (not used but can be helpful)

class TopUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Top Up Saldo',
          style: TextStyle(color: Colors.white), // AppBar title color set to white
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)), // Set the icon color (including back icon) to black
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back button icon
          onPressed: () {
            Navigator.pop(context); // Pop the current screen from the stack (go back)
          },
          color: const Color.fromARGB(255, 255, 255, 255), // Set the back icon color to black
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih metode top up saldo Anda:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // Virtual Account button
            _buildTopUpOption(
              context,
              'Top Up dengan Virtual Account',
              Icons.account_balance_wallet,
              Colors.blue.shade600,
            ),
            const SizedBox(height: 15),
            // Bank Transfer button
            _buildTopUpOption(
              context,
              'Top Up dengan Bank Transfer',
              Icons.account_balance,
              Colors.green.shade600,
            ),
            const SizedBox(height: 15),
            // QR Code button that will navigate to CameraScreen
            _buildTopUpOption(
              context,
              'Top Up dengan QR Code',
              Icons.qr_code,
              Colors.purple.shade600,
              onTap: () {
                // Navigate to CameraScreen when QR Code option is selected
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUpOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          leading: Icon(
            icon,
            color: color,
            size: 28,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87, // Text color set to black for better contrast
            ),
          ),
        ),
      ),
    );
  }
}
