import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Center(
                  child: Text(
                    "About Lost and Found App",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  "Our Lost and Found App is designed to help people easily report and search for lost or found items. Whether you've misplaced a cherished item or discovered something left behind, our app connects the community to ensure belongings are returned to their rightful owners.",
                  style: const TextStyle(fontSize: 16, color: Color.fromARGB(221, 5, 5, 5)),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                // Mission Section
                Text(
                  "Our Mission",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "To provide a seamless platform for people to report and retrieve lost or found items efficiently and responsibly, fostering a sense of trust and cooperation within the community.",
                  style: const TextStyle(fontSize: 16, color: Color.fromARGB(221, 5, 5, 5)),
                ),
                const SizedBox(height: 16),
                // Contact Section
                Text(
                  "Contact Us",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "For inquiries or support, reach out to us at:",
                  style: const TextStyle(fontSize: 16, color: Color.fromARGB(221, 15, 15, 15)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.email, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      "support@lostandfound.com",
                      style: TextStyle(fontSize: 16, color: Colors.teal),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.phone, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      "+251 12 34 56 78",
                      style: TextStyle(fontSize: 16, color: Colors.teal),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
