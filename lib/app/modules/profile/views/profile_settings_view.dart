import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:education_apps/app/modules/profile/controllers/Profile_controller.dart';
import 'package:education_apps/app/modules/profile/views/geolocation_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileController controller = Get.find<ProfileController>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();

  final box = GetStorage(); // Local storage
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    checkPendingUploads();
  }

  void fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          usernameController.text = doc['name'] ?? '';
          emailController.text = doc['email'] ?? '';
          schoolController.text = doc['school'] ?? '';
        });
      }
    }
  }

  Future<bool> hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void saveChanges() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, dynamic> dataToSave = {
      'name': usernameController.text,
      'email': emailController.text,
      'school': schoolController.text,
      'uid': user.uid,
    };

    if (await hasInternetConnection()) {
      await uploadToFirestore(dataToSave);
    } else {
      box.write('pending_upload', dataToSave);
      Get.snackbar(
        'Offline Mode',
        'Changes saved locally. Will be uploaded when online.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> uploadToFirestore(Map<String, dynamic> data) async {
    setState(() {
      isUploading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(data['uid'])
          .update({
        'name': data['name'],
        'email': data['email'],
        'school': data['school'],
      });

      Get.snackbar(
        'Success!',
        'Your changes have been saved.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      box.remove('pending_upload');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save changes to the database.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  void checkPendingUploads() async {
    var data = box.read('pending_upload');
    if (data != null && await hasInternetConnection()) {
      uploadToFirestore(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white), // Teks AppBar warna putih
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Panah putih
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated Profile Image
            Obx(
              () => GestureDetector(
                onTap: controller.getImageFromGallery,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: controller.selectedImagePath.value.isNotEmpty
                          ? FileImage(File(controller.selectedImagePath.value))
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: Colors.blue.shade400,
                      width: 4.0,
                    ),
                  ),
                  child: controller.selectedImagePath.value.isEmpty
                      ? const Icon(
                          Icons.camera_alt,
                          color: Colors.blue,
                          size: 30,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tap to change profile picture',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // Input Fields
            _buildInputField('Name', usernameController, Icons.person),
            const SizedBox(height: 20),
            _buildInputField('Email', emailController, Icons.email),
            const SizedBox(height: 20),
            _buildInputField('School', schoolController, Icons.school),
            const SizedBox(height: 30),

            // Save Button
            ElevatedButton.icon(
              onPressed: saveChanges,
              icon: isUploading
                  ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                isUploading ? 'Saving...' : 'Save Changes',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Location Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GetLocationView()),
                );
              },
              icon: const Icon(Icons.location_on),
              label: const Text('View Your Location'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                foregroundColor: Colors.blue.shade600,
                side: BorderSide(color: Colors.blue.shade600, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
