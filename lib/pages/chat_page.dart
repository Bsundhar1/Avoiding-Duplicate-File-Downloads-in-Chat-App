  import 'dart:io';
  import 'package:chatapp/pages/fowardPage.dart';
  import 'package:chatapp/repo/auth_repository.dart';
  import 'package:chatapp/repo/chat_repository.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/material.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';
  import 'package:flutter_dotenv/flutter_dotenv.dart';
  import 'package:path_provider/path_provider.dart';
  import 'package:open_file/open_file.dart';
  import 'package:sqflite/sqflite.dart';
  import 'package:path/path.dart' as p;

  class ChatPage extends StatefulWidget {
    final String user;
    final String email;
    final String clientID;
    const ChatPage(
        {super.key,
        required this.user,
        required this.email,
        required this.clientID});

    @override
    State<ChatPage> createState() => _ChatPageState();
  }

  class _ChatPageState extends State<ChatPage> {
    final chatRepository = ChatRepository();

    final authRepository = AuthRepository();

    final messageController = TextEditingController();

    File? pdfFile;

    FocusNode focusNode = FocusNode();

    @override
    void initState() {
      super.initState();

      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
        }
      });

      Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
    }

    @override
    void dispose() {
      focusNode.dispose();
      // TODO: implement dispose
      super.dispose();
    }

    final ScrollController scrollController = ScrollController();

    void scrollDown() {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    }

    Future<FilePickerResult?> pickPdfFile() async {
      return await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
    }

    void selectPdfFile() async {
      final result = await pickPdfFile();
      if (result != null) {
        setState(() {
          pdfFile = File(result.files.first.path!);
        });
      }
    }

    void sendMessage() async {
      if (pdfFile == null) {
        if (messageController.text.isNotEmpty) {
          await chatRepository.sendMessage(
              widget.clientID, messageController.text);
          messageController.clear();
        }
      } else {
        await chatRepository.sendFile(
            widget.clientID, messageController.text, pdfFile);
        setState(() {
          pdfFile = null;
        });
        messageController.clear();
      }

      scrollDown();
    }

    void showForwardQueueDialog(List<String> fQueue) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Forward Queue"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: fQueue.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Row(
                    children: [
                      Text("${index +1}. "),
                      Text(
                        fQueue[index],
                      ),
                    ],
                  ));
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: Text(
            widget.user,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black87,
        ),
        body: Column(children: [Expanded(child: messageList())]),
        bottomNavigationBar: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pdfFile != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.grey[800],
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pdfFile!.path.split('/').last,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            pdfFile = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              Container(
                alignment: Alignment.center,
                height: 45,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: pdfFile == null
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          )
                        : null),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 35,
                        width: 50,
                        child: TextField(
                          focusNode: focusNode,
                          style: const TextStyle(fontSize: 15),
                          controller: messageController,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            hintText: 'What are your thoughts?',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 10.0),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    IconButton(
                        onPressed: () => selectPdfFile(),
                        icon: const Icon(Icons.attach_file_rounded),
                        color: Colors.white),
                    CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white,
                        child: IconButton(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 7),
                            onPressed: () => sendMessage(),
                            icon: const Icon(Icons.send))),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget messageList() {
      String senderID = authRepository.getUser()!.uid;
      return StreamBuilder(
          stream: chatRepository.displayMessages(widget.clientID, senderID),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Error");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading...");
            }

            return ListView(
              controller: scrollController,
              children:
                  snapshot.data!.docs.map((doc) => messageItem(doc)).toList(),
            );
          });
    }

    Widget messageItem(DocumentSnapshot doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      bool isCurrentUser = data['senderID'] == authRepository.getUser()!.uid;
      bool isAdmin =
          "0PLdQyKfXbehy4paaQ0Kqnq9BG93" == authRepository.getUser()!.uid;
      var alignment =
          isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
      var bubbleColor = isCurrentUser ? Colors.purple[300] : Colors.grey[300];
      var textColor = isCurrentUser ? Colors.white : Colors.black;

      String? fileUrl = data['file'];  

      if (fileUrl != null && fileUrl.isNotEmpty) {
        return GestureDetector(
          onLongPress: () {
            if (isAdmin) {
              List<dynamic> dynamicQueue = data['fQueue'];
              List<String> forwardQueue = dynamicQueue.cast<String>(); 
              showForwardQueueDialog(forwardQueue);
            }
          },
          child: Align(
            alignment: alignment,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: isCurrentUser
                      ? const Radius.circular(15)
                      : const Radius.circular(0),
                  topRight: isCurrentUser
                      ? const Radius.circular(0)
                      : const Radius.circular(15),
                  bottomLeft: const Radius.circular(15),
                  bottomRight: const Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (fileUrl != null && fileUrl.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.file_copy_rounded, color: Colors.blue),
                        IconButton(
                          icon: const Icon(Icons.download, color: Colors.white),
                          onPressed: () =>
                              _downloadAndOpenPDF(fileUrl, data['fileHash']),
                        ),
                        Flexible(
                          child: Text(
                            data['message'],
                            style: TextStyle(color: textColor, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForwardPage(
                                  message: data,
                                  context: context,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.share),
                          color: Colors.black,
                        ),
                      ],
                    ),
                  if (fileUrl == null)
                    Text(
                      data['message'],
                      style: TextStyle(color: textColor, fontSize: 16),
                    ),
                ],
              ),
            ),
          ),
        );
      } else {
        return Align(
          alignment: alignment,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: isCurrentUser
                    ? const Radius.circular(15)
                    : const Radius.circular(0),
                topRight: isCurrentUser
                    ? const Radius.circular(0)
                    : const Radius.circular(15),
                bottomLeft: const Radius.circular(15),
                bottomRight: const Radius.circular(15),
              ),
            ),
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  data['message'],
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }
    }

    Future<Database> _openDatabase() async {
      final directory = await getApplicationDocumentsDirectory();
      final path = p.join(directory.path, 'media_hashes.db');

      return openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            '''
          CREATE TABLE media_hashes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fileHash TEXT UNIQUE,
            fileName TEXT
          )
          ''',
          );
        },
      );
    }

    Future<bool> _fileHashExists(Database db, String fileHash) async {
      final result = await db.query(
        'media_hashes',
        where: 'fileHash = ?',
        whereArgs: [fileHash],
      );
      return result.isNotEmpty;
    }

    Future<void> _addFileHash(
        Database db, String fileHash, String fileName) async {
      await db.insert(
        'media_hashes',
        {'fileHash': fileHash, 'fileName': fileName},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    Future<void> _downloadAndOpenPDF(String url, String fileHash) async {
      final db = await _openDatabase();
      final fileName = url.split('/').last;

      if (await _fileHashExists(db, fileHash)) {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("File Already Viewed"),
              content: const Text(
                  "You have already viewed this file. Do you want to download anyways?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Download"),
                ),
              ],
            );
          },
        );

        if (result != true) return;
      }

      try {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          await _addFileHash(db, fileHash, fileName);

          final result = await OpenFile.open(filePath);
          if (result.type != ResultType.done) {
            print("Failed to open PDF: ${result.message}");
            throw 'Could not open PDF file';
          }
        } else {
          throw 'Failed to download PDF. Status code: ${response.statusCode}';
        }
      } catch (e) {
        print("Error opening or downloading file: $e");
        throw 'Could not open or download PDF file: $e';
      }
    }
  }
