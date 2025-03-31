import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class VerificationOrderScreen extends StatefulWidget {
  final String orderId;

  VerificationOrderScreen({required this.orderId});
  @override
  _VerificationOrderScreenState createState() =>
      _VerificationOrderScreenState();
}

class _VerificationOrderScreenState extends State<VerificationOrderScreen> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<Map<String, dynamic>> _uploadedImages = [];
  Map<String, dynamic>? _orderData;

  @override
  void initState() {
    super.initState();

    _fetchOrderData();
  }

  Future<void> _fetchOrderData() async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'cardHolderId': FirebaseAuth.instance.currentUser?.uid,
        'status': "accepted",
      });
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .get();
      if (orderSnapshot.exists) {
        setState(() {
          _orderData = orderSnapshot.data() as Map<String, dynamic>?;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch order data: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
    _uploadImage();
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        String downloadURL;

        if (kIsWeb) {
          TaskSnapshot snapshot = await _storage
              .ref('invoices/$fileName')
              .putData(await _image!.readAsBytes());
          downloadURL = await snapshot.ref.getDownloadURL();
        } else {
          TaskSnapshot snapshot = await _storage
              .ref('invoices/$fileName')
              .putFile(File(_image!.path));
          downloadURL = await snapshot.ref.getDownloadURL();
        }
             setState(() {
          _uploadedImages.add({
            'id': fileName,
            'url': downloadURL,
          });
       });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload successful!')),
          );
        }
      } on FirebaseException catch (e) {
        if (e.code == 'unauthorized') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'User is not authorized to perform the desired action.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected!')),
        );
      }
    }
  }

  Future<void> _loadImages() async {
    ListResult result = await _storage.ref('invoices').listAll();
    List<Map<String, dynamic>> files = [];
    for (var ref in result.items) {
      final url = await ref.getDownloadURL();
      files.add({
        'url': url,
        'name': ref.name,
      });
    }
    setState(() {
      _uploadedImages = files;
    });
  }

  Future<void> _deleteImage(String refName) async {
    try {
      await _storage.ref('invoices/$refName').delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete successful!')),
      );
      _loadImages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  void _showImageDetails(Map<String, dynamic> image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Image.network( (image as Map<String, dynamic>)['url'],),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteImage(image['id']);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verification Order'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ElevatedButton(
          onPressed: () async {
            final url = _orderData?['product_url'];
            if (url != null && await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $url')),
              );
            }
          },
          child: Text('Please click to complete the transaction'),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Upload your invoice to verify your order:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
            child: Text(
              _image != null ? _image!.name : 'No file selected',
              style: TextStyle(color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
              ),
              Icon(Icons.upload_file, color: Colors.blue),
            ],
          ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Uploaded Images:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          _uploadedImages.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _uploadedImages.length,
              itemBuilder: (context, index) {
            final image = _uploadedImages[index];
            return ListTile(
              leading: Image.network(
               (image as Map<String, dynamic>)['url'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            
              onTap: () => _showImageDetails(image),
            );
              },
            )
          : Center(
              child: Text(
            'No images uploaded yet.',
            style: TextStyle(color: Colors.grey),
              ),
            ),
          SizedBox(height: 30),
          Center(
            child: ElevatedButton(
          onPressed: _uploadedImages.isNotEmpty ? _submitInvoice : null,
          child: Text('Submit'),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  void _submitInvoice() async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'imageUrl': _uploadedImages,
        'status': "completed",
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invoice submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload invoice: $e')),
      );
    }
  }
}
