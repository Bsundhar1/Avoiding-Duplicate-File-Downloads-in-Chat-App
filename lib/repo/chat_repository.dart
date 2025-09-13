import 'dart:io';
import 'package:chatapp/pages/components/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  Future<String> calculateFileHash(File file) async {
    try {
      final fileBytes = await file.readAsBytes();
      final digest = sha256.convert(fileBytes);
      return digest.toString();
    } catch (e) {
      print("Error calculating hash: $e");
      throw Exception("Error calculating hash");
    }
  }

  Future<void> sendMessage(String clientID, String message) async {
    final String currentID = _auth.currentUser!.uid;
    final String currentEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newmessage = Message(
        senderID: currentID,
        senderEmail: currentEmail,
        receiverID: clientID,
        message: message,
        timestamp: timestamp,
        fQueue: [currentEmail]);

    List<String> ids = [currentID, clientID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newmessage.toMap());
  }

  Future<void> sendFile(String clientID, String message, File? file) async {
    if (file == null) return;

    final String currentID = FirebaseAuth.instance.currentUser!.uid;
    final String currentEmail = FirebaseAuth.instance.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    final String fileHash = await calculateFileHash(file);

    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/drbadfd0w/image/upload');
    final request = http.MultipartRequest('POST', uri);

    var fileBytes = await file.readAsBytes();
    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: file.path.split("/").last,
      contentType: DioMediaType('application', 'pdf'),
    );

    request.files.add(multipartFile);
    request.fields['upload_preset'] = "safever";
    request.fields['resource_type'] = "image";

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("Upload Successfully");
        print(responseBody);

        final Map<String, dynamic> cloudinaryResponse =
            json.decode(responseBody);
        final String fileUrl = cloudinaryResponse['url'];

        List<String> ids = [currentID, clientID];
        ids.sort();
        String chatRoomID = ids.join('_');

        await FirebaseFirestore.instance
            .collection("chat_rooms")
            .doc(chatRoomID)
            .collection("messages")
            .add({
          'senderID': currentID,
          'senderEmail': currentEmail,
          'receiverID': clientID,
          'message': cloudinaryResponse['display_name'],
          'file': fileUrl,
          'fileHash': fileHash,
          'timestamp': timestamp,
          'fQueue': [currentEmail],
        });

        print("File and metadata uploaded to Firebase");
      } else {
        print('Cloudinary Response: $responseBody');
        throw Exception('File upload to Cloudinary failed');
      }
    } catch (e) {
      print('Error uploading file: $e');
      throw Exception('Error uploading file: $e');
    }
  }

  Future<void> forwardFile(String clientID, String message, String fileUrl, String fileHash, List<String> fQueue) async {

    final String currentID = FirebaseAuth.instance.currentUser!.uid;
    final String currentEmail = FirebaseAuth.instance.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
  
    List<String> ids = [currentID, clientID];
    ids.sort();
    String chatRoomID = ids.join('_');
    List<String> updatedFQueue = List.from(fQueue)..add(currentEmail);


    await FirebaseFirestore.instance
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add({
      'senderID': currentID,
      'senderEmail': currentEmail,
      'receiverID': clientID,
      'message': message,
      'file': fileUrl,
      'fileHash': fileHash,
      'timestamp': timestamp,
      'fQueue': updatedFQueue,
    });
  }

  Stream<QuerySnapshot> displayMessages(String firstID, String secondID) {
    List<String> ids = [firstID, secondID];
    ids.sort();
    String chatRoomID = ids.join('_');
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
