# 📱 Lost & Found App

A Flutter-based **Lost and Found application** designed to help users report and find lost items easily. The app integrates with **Supabase** for authentication and data management, providing a smooth and secure user experience.

---

## 🚀 Features

- 🔐 **User Authentication**  
  Users can **sign up** and **log in** using their email and password, powered by **Supabase Authentication**.

- 🧾 **Report Lost Items**  
  After signing in, users can **report lost items** by providing relevant details (item name, description, location, and contact info).

- 🔍 **Search & Filter Lost Items**  
  Users can browse through reported items with **search and filter options** to easily find specific items.

- 👤 **User Profile Page**  
  Each user has a personal profile page where they can view and manage their submitted reports.

- 💬 **Contact Item Owner**  
  When a user finds a lost item, they can contact the reporter directly to return it.

- ☁️ **Supabase Integration**  
  All user data, reports, and authentication processes are managed securely using **Supabase**.

---

## 🛠️ Tech Stack

| Category | Technology |
|-----------|-------------|
| **Frontend** | Flutter |
| **Backend / Database** | Supabase |
| **Authentication** | Supabase Auth |
| **Language** | Dart |

---

## 📦 Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/LuhenaAbebe/lost-and-found-app.git
   cd lost-and-found-app
2. **Install dependencies**
   ```bash
   flutter pub get
3️. **Set up Supabase**

Create a new project in Supabase
.

From your Supabase dashboard, copy your Project URL and Anon Key.

Add them in your Flutter app’s configuration file, for example:

Create a file:
lib/config/supabase_config.dart

Add:

const String supabaseUrl = "YOUR_SUPABASE_URL";
const String supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY";


(or use an .env file if your project is set up for environment variables)

4️. **Run the app**
```bash
flutter run
```
## 👤 Author
- **Luhena Abebe**  
- GitHub: [@LuhenaAbebe](https://github.com/LuhenaAbebe)  
- LinkedIn: [Luhena Abebe](https://www.linkedin.com/in/luhena-abebe-408314380)  
