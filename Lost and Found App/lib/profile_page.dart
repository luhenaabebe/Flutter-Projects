import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  String? email;
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        errorMessage = "No authenticated user found.";
        isLoading = false;
      });
      return;
    }

    final userEmail = user.email;

    if (userEmail == null) {
      setState(() {
        errorMessage = "User email is null.";
        isLoading = false;
      });
      return;
    }

    try {
      // Fetch items associated with the user 
      final itemsResponse = await supabase
          .from('items')
          .select('name, category, description, date, location, contact, email, image_url, status')
          .eq('email', userEmail);

      print("Items Response: $itemsResponse");

      // If response is a list (multiple rows), convert it to a List<Map>
      if (itemsResponse.isNotEmpty) {
        setState(() {
          items = List<Map<String, dynamic>>.from(itemsResponse);
          email = Supabase.instance.client.auth.currentUser?.email ?? 'No Email';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "No items found for the user.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching data: $e";
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User Profile',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (email != null)
                        Text('Email: $email', style: const TextStyle(fontSize: 18))
                      else
                        const Text('User email not found.', style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 20),
                      const Text(
                        'Items',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (items.isEmpty)
                        const Text('No items found.', style: TextStyle(color: Colors.grey))
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Card(
                                child: ListTile(
                                  title: Text(item['name'] ?? 'No name'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Category: ${item['category'] ?? 'N/A'}'),
                                      Text('Description: ${item['description'] ?? 'N/A'}'),
                                      Text('Date: ${item['date'] ?? 'N/A'}'),
                                      Text('Location: ${item['location'] ?? 'N/A'}'),
                                      Text('Contact: ${item['contact'] ?? 'N/A'}'),
                                      Text('Status: ${item['status'] ?? 'N/A'}'),
                                    ],
                                  ),
                                  leading: item['image_url'] != null
                                      ? Image.network(item['image_url'], width: 50, height: 50, fit: BoxFit.cover)
                                      : const Icon(Icons.image),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
