import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final String? fileHash;
  final String? file;
  final List<String> fQueue;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    required this.fQueue,
    this.fileHash,
    this.file,
  });

  Map<String, dynamic> toMap(){
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'fQueue' : fQueue,
      'fileHash': fileHash,
      'file': file,
    };
  }
}