import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

List<Map<String, dynamic>> lostItems = [];

class LostReportPage extends StatefulWidget {
  const LostReportPage({super.key});

  @override
  _LostReportPageState createState() => _LostReportPageState();
}

class _LostReportPageState extends State<LostReportPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String selectedCategory = "Electronics";
  File? image;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking image")));
    }
  }

  void submitForm() async {
    if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill in all fields")));
      return;
    }

    try {
      String imageUrl = ''; // Initialize imageUrl as an empty string

      // If an image is selected, upload it to Supabase storage
      if (image != null) {
        final String filePath = 'lost-items/${DateTime.now().millisecondsSinceEpoch}.png';
        await Supabase.instance.client.storage.from('uploads').upload(filePath, image!);

        // Get the public URL for the uploaded image
        imageUrl = Supabase.instance.client.storage.from('uploads').getPublicUrl(filePath);
      }
      final currentUser = Supabase.instance.client.auth.currentUser;
      // Insert data into the Supabase table
      await Supabase.instance.client.from('items').insert({
        "name": nameController.text,
        "category": selectedCategory,
        "description": descriptionController.text,
        "date": dateController.text,
        "location": locationController.text,
        "contact": contactController.text,
        "email": Supabase.instance.client.auth.currentUser?.email ?? 'No Email',
        "status": statusController.text,
        'reported_by': currentUser?.id, // Set the reported_by field
        "image_url": imageUrl.isNotEmpty ? imageUrl : null, // Only insert image_url if it's not empty
      });

      // Check if the insertion was successful
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item reported successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Items Report Form"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            buildTextField(nameController, "Item Name", Icons.inventory),
            buildTextField(contactController, "Contact", Icons.phone),
            buildTextField(descriptionController, "Description", Icons.description),
            buildTextField(dateController, "Date", Icons.calendar_today),
            buildTextField(locationController, "Location", Icons.location_on),
            buildTextField(statusController, "Status (Lost/Found)", Icons.info),
            buildImagePicker(width),
            buildCategoryDropdown(width),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text("Post", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Column(
      children: [
        Text(
          "Report an Item",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        SizedBox(height: 10),
        Text(
          "Fill out the form below to report an item. Be sure to provide accurate details.",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  Widget buildImagePicker(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Image:", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.image),
              label: Text("Choose Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            SizedBox(width: 10),
            image == null
                ? Text("No image selected", style: TextStyle(color: Colors.grey))
                : Image.file(image!, width: width * 0.2, height: width * 0.2, fit: BoxFit.cover),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildCategoryDropdown(double width) {
    return Row(
      children: [
        Text("Category: ", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 10),
        DropdownButton<String>(
          value: selectedCategory,
          onChanged: (newCategory) {
            setState(() {
              selectedCategory = newCategory!;
            });
          },
          items: <String>['Electronics', 'Document', 'Others']
              .map<DropdownMenuItem<String>>((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
        ),
      ],
    );
  }
}
