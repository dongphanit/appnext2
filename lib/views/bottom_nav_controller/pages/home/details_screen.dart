import 'package:flutter/material.dart';
import 'package:flutter_tour_app/constant/constant.dart';
import 'package:flutter_tour_app/services/firestore_services.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/payment_screen.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class ProductDetailsScreen extends StatefulWidget {
  late String productUrl;
  ProductDetailsScreen({required this.productUrl, Key? key}) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String productName = "Loading...";
  String price = "Loading...";
  String productDescription = "Loading...";
  String productImg = "Loading...";
  String priceDiscount = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  // Hàm lấy dữ liệu sản phẩm
  Future<void> fetchProductDetails() async {
    // URL của sản phẩm trên Flipkart
    final url = widget.productUrl;
    // Gửi yêu cầu GET
    final response = await http.get(Uri.parse(url), headers: {
      // "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
    });

    // Nếu yêu cầu thành công
    if (response.statusCode == 200) {
      // Phân tích HTML
      var document = parser.parse(response.body);

      // Lấy tên sản phẩm
      var nameElement = document.querySelector("span.mEh187");
      setState(() {
        productName = nameElement != null ? nameElement.text.trim() : "N/A";
      });

      // Lấy giá sản phẩm
      var priceElement = document.querySelector("div.Nx9bqj.CxhGGd");
      var descriptionElement = document.querySelector("span.VU-ZEz");
      var imageElement = document.querySelector("img.DByuf4.IZexXJ.jLEJ7H");
      print(imageElement!.attributes['src'] ?? "N/A");

      setState(() {
        price = priceElement != null ? priceElement.text.trim() : "N/A";
        if (priceElement != null) {
          price = priceElement.text.trim();
          double originalPrice = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
          double discountPrice = originalPrice * 0.9;
          priceDiscount = "₹${discountPrice.toStringAsFixed(2)}";
        } else {
          price = "N/A";
          priceDiscount = "N/A";
        }
        productDescription = descriptionElement != null ? descriptionElement.text.trim() : "N/A";
        productImg = imageElement != null ? imageElement.attributes['src'] ?? "N/A" : "N/A";
      });
    } else {
      setState(() {
        productName = "Failed to load product.";
        price = "N/A";
        productDescription= "";
        productImg = "";
        priceDiscount = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Carousel
            SizedBox(
              height: 300,
              child: PageView(
                children: [
                  Image.network(
                    productImg != "Loading..." ? productImg : 'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network('https://via.placeholder.com/150', fit: BoxFit.cover);
                    },
                  ),
                 
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Product Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                productName, // Sử dụng tên sản phẩm đã lấy được
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Product Ratings and Price
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Row(
            //     children: [
            //       Container(
            //         padding:
            //             const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //         decoration: BoxDecoration(
            //           color: Colors.green,
            //           borderRadius: BorderRadius.circular(4),
            //         ),
            //         child: const Text(
            //           '4.2 ★', // Placeholder for rating
            //           style: TextStyle(color: Colors.white),
            //         ),
            //       ),
            //       const SizedBox(width: 10),
            //       const Text(
            //         '1,245 Ratings & 150 Reviews',
            //         style: TextStyle(color: Colors.grey, fontSize: 14),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 8),

            // Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    price, // Hiển thị giá đã lấy được
                     style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                   
                  ),
                  const SizedBox(width: 10),
                  Text(
                    priceDiscount, // Placeholder for original price
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '10% off',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Product Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Product Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                productDescription, // Hiển thị mô tả sản phẩm đã lấy được
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Add to Cart and Buy Now Buttons
            Row(
              children: [
                // Expanded(
                //   child: Container(
                //     margin: const EdgeInsets.all(8.0),
                //     child: ElevatedButton(
                //       onPressed: () {},
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.orange,
                //         padding: const EdgeInsets.all(16),
                //       ),
                //       child: const Text(
                //         'ADD TO CART',
                //         style: TextStyle(fontSize: 16),
                //       ),
                //     ),
                //   ),
                // ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        String buyerAddress = "";
                        String buyerPhone = "";
                        String cardHolderId = "";
                        String productId = "";
                        double productPrice = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
                        String productUrl = widget.productUrl;
                        String userId = firebaseAuth.currentUser?.uid ?? "";

                        String orderId = await FirestoreServices().createOrder(
                          productName: productName,
                          buyerAddress: buyerAddress,
                          buyerPhone: buyerPhone,
                          cardHolderId: cardHolderId,
                          productId: productId,
                          productPrice: productPrice,
                          productUrl: productUrl,
                          userId: userId,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(orderId: orderId,),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text(
                        'BUY NOW',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Additional Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Highlights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: const Text(
            //     '- 1.5 L Capacity\n- Stainless Steel Material\n- Automatic Shut-off\n- Lightweight Design',
            //     style: TextStyle(fontSize: 16),
            //   ),
            // ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
