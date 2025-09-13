# 💬 ChatApp – Avoiding Duplicate File Downloads

This project is a **Flutter + Firebase-based Chat Application** with a unique feature:  
it prevents **duplicate file downloads** by using **hashing and local storage**.  
The system also maintains a **forward queue**, tracks **file sender IDs**, and provides **admin oversight** for better file sharing management.

---

## 🚀 Features
- 💬 **Real-time chat** with Firebase backend  
- 📂 **File sharing** with duplicate detection via hashing  
- 🔄 **Forward queue** management for smooth file forwarding  
- 🛡 **Admin oversight** for monitoring shared files  
- ⚡ **Optimized storage** by avoiding unnecessary re-downloads  
- 📱 **Cross-platform** support with Flutter  

---

## 🛠️ Tech Stack
- **Frontend:** Flutter, Dart  
- **Backend:** Firebase Authentication, Firebase Firestore, Firebase Storage  
- **IDE:** Android Studio  
- **Language:** Dart  
- **Cloud:** Google Firebase  

---

## 📂 Project Structure
chatapp/
│── lib/ # Main Flutter app code
│ ├── main.dart # App entry point
│ ├── chat_page.dart # Chat screen
│ ├── forward_page.dart # Forwarding feature
│ └── firebase_options.dart
│
│── android/ # Android-specific config
│── ios/ # iOS-specific config
│── pubspec.yaml # Dependencies
│── pubspec.lock


---

## 📦 Installation & Setup

1. **Clone this repo**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/Avoiding-Duplicate-File-Downloads-in-Chat-App.git
   cd Avoiding-Duplicate-File-Downloads-in-Chat-App
2.Install dependencies:
flutter pub get  

3. Configure Firebase:

*Add your google-services.json (Android) in:

android/app/google-services.json

*Add your GoogleService-Info.plist (iOS) in:

ios/Runner/GoogleService-Info.plist

4. Run the app:

flutter run


👨‍💻 Author
Balasundhar K J
📧 balasunder961@gmail.com
| 📍 Karaikal, India
   
