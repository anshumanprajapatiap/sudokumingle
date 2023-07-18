
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GlobalMethodUtil{

  static Future<void> warningDialog({
    required String title,
    required String subtitle,
    required Function fct,
    required BuildContext context,
  }) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(children: [
              // Image.asset(
              //   'assets/images/warning-sign.png',
              //   height: 20,
              //   width: 20,
              //   fit: BoxFit.fill,
              // ),
              const SizedBox(
                width: 8,
              ),
              Text(title),
            ]),
            content: Text(subtitle),
            actions: [
              // TextButton(
              //   onPressed: () {
              //     if (Navigator.canPop(context)) {
              //       Navigator.pop(context);
              //     }
              //   },
              //   child: TextWidget(
              //     color: Colors.cyan,
              //     text: 'Cancel',
              //     textSize: 18,
              //   ),
              // ),
              TextButton(
                onPressed: () {
                  fct();
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'OK',
                ),
              ),
            ],
          );
        });
  }
}

class FirebaseGlobalMethodUtil{

  static void deleteDocument(String collectionName, String documentId) {
    FirebaseFirestore.instance
        .collection(collectionName)
        .doc(documentId)
        .delete()
        .then((_) {
      print("Document deleted successfully!");
    }).catchError((error) {
      print("Error deleting document: $error");
    });
  }

}