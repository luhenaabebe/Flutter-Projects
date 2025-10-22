import 'package:flutter/material.dart';
import 'LostReport.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LostPage extends StatefulWidget {
  const LostPage({super.key});

  @override
  _LostPageState createState() => _LostPageState();
}

class _LostPageState extends State<LostPage> {
  String selectedCategory = "All";
  String searchQuery = "";
  List<Map<String, dynamic>> lostItems = []; // List to store items
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchLostItems(); // Fetch items when the page is loaded
    subscribeToRealTimeUpdates(); // Subscribe to real-time updates
  }


void subscribeToRealTimeUpdates() {
  final channel = Supabase.instance.client
      .from('items')
      .stream(primaryKey: ['id'])  // Use primary key or unique identifier of the table
      .order('date', ascending: false) // You can still order your stream as needed
      .listen((List<Map<String, dynamic>> payload) {
        // Handle the real-time data here
        print('New items: $payload');
        fetchLostItems(); // Re-fetch the lost items to include the new report
      });
}


  // Fetch all items from Supabase (no condition, fetch all)
Future<void> fetchLostItems() async {
  setState(() {
    isLoading = true;
  });

  try {
    // Fetch all items without filtering by email
    final response = await Supabase.instance.client
        .from('items')
        .select()
        .order('date', ascending: false); // Get all items ordered by date

    print('Retrieved items: $response'); // Log the response for debugging

    setState(() {
      lostItems = List<Map<String, dynamic>>.from(response);
    });
  } catch (e) {
    print('Error fetching items: $e'); // Log any errors
  } finally {
    setState(() {
      isLoading = false; // Stop loading after the fetch
    });
  }
}


  // Filter items based on selected category and search query
  List<Map<String, dynamic>> get filteredItems {
    return lostItems
        .where((item) =>
            (selectedCategory == "All" || item["category"] == selectedCategory) &&
            (searchQuery.isEmpty || item["name"]!.toLowerCase().contains(searchQuery.toLowerCase())))
        .toList();
  }

  // Navigate to ItemDetailPage when an item is tapped
  void navigateToItemDetailPage(BuildContext context, Map<String, dynamic> item, int index) async {
  final shouldRemove = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ItemDetailPage(item: item),
    ),
  );

  if (shouldRemove == true) {
    // Re-fetch the list to ensure it is updated
    fetchLostItems(); // Call the fetchLostItems method to get the updated list from Supabase
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Items"),
        backgroundColor: Colors.teal,
        elevation: 5,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isSmallScreen = constraints.maxWidth < 600;
          final double gridPadding = isSmallScreen ? 8.0 : 16.0;
          final double itemHeight = isSmallScreen ? 120 : 180;

          return Padding(
            padding: EdgeInsets.all(gridPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar and Lost Report Button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: "Search items...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final newItem = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LostReportPage()),
                        );
                        if (newItem != null) {
                          // Add new item and refresh list
                          fetchLostItems(); // Re-fetch the list to show updated data from the database
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text("Lost Report"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ["All", "Electronics", "Document", "Others"]
                        .map((category) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: categoryButton(category),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Items Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 2 : 4,
                      crossAxisSpacing: gridPadding,
                      mainAxisSpacing: gridPadding,
                      childAspectRatio: 1 / 1.5,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return GestureDetector(
                        onTap: () {
                          navigateToItemDetailPage(context, item, index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Image.network(
                                  item["image_url"] ?? '', // Display item image from URL
                                  fit: BoxFit.cover,
                                  height: itemHeight,
                                  width: double.infinity,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["name"]!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item["description"]!,
                                      style: const TextStyle(color: Colors.grey),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget categoryButton(String category) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = category == selectedCategory ? "All" : category;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedCategory == category ? Colors.teal : Colors.grey[300],
        foregroundColor: selectedCategory == category ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(category),
    );
  }
}

class ItemDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemDetailPage({super.key, required this.item});

  // Check if the logged-in user is the reporter of the item
  Future<bool> canDeleteItem() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return false; // No user logged in

    final reportedBy = item["reported_by"];
    print("Current user ID: ${currentUser.id}, Reported by: $reportedBy"); // Debugging line

    return reportedBy == currentUser.id; // Check if the current user is the reporter
  }

  // Delete the item from the database
Future<void> deleteItem(BuildContext context) async {
  final canDelete = await canDeleteItem();

  if (canDelete) {
    try {
      // Perform the deletion from the database
      final response = await Supabase.instance.client
          .from('items')
          .delete()
          .eq('id', item['id'])
          .select(); // Fetches the deleted row for verification

      if (response.isEmpty) {
        // Handle error if deletion fails
        print('Delete failed: No response or empty data');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete the item")),
        );
      } else {
        // Deletion was successful
        print('Delete Response: $response');
        Navigator.pop(context, true); // Return true indicating removal
      }
    } catch (e) {
      // Handle any unexpected errors
      print('Unexpected error during deletion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while deleting the item")),
      );
    }
  } else {
    // Show a message that the user cannot delete the item
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You cannot delete this item")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item["name"]!),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(item["image_url"]!, fit: BoxFit.cover, width: double.infinity),
            ),
            const SizedBox(height: 16),
            Text(
              item["name"]!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              item["description"]!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Text("Date: ${item["date"]!}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Location: ${item["location"]!}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Contact: ${item["contact"]!}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text("Status: ${item["status"]!}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  deleteItem(context); // Try to delete the item
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("Remove Item"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}