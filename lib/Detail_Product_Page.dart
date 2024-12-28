import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DetailProdukPage extends StatefulWidget {
  final int productId;

  DetailProdukPage({super.key, required this.productId});

  @override
  _DetailProdukPageState createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  Map<String, dynamic> product = {};
  List<dynamic> reviews = [];
  int cartQuantity = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProductDetail();
  }

  Future<void> fetchProductDetail() async {
    try {
      print("Fetching products from the server...");
      final response =
      await http.get(Uri.parse('http://172.21.240.1:3006/product/${widget.productId}?format=json'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          setState(() {
            product = data['data']['product']['data'];
            reviews = data['data']['reviews'];
            isLoading = false;
          });
          print("Successfully fetched ${product.length} products.");
        } else {
          throw Exception("Unexpected response format: $data");
        }
      } else {
        throw Exception("Failed to load products. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Format harga
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detail Produk",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : product.isEmpty
          ? Center(child: Text("Produk tidak ditemukan"))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gambar produk
            Container(
              height: 600,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: product['image_url'] != null
                      ? NetworkImage(product['image_url'])
                      : AssetImage('assets/headset-bluetooth.jpg') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            // Nama dan harga produk
            Text(
              product['name'] ?? 'Nama produk tidak tersedia',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(58, 66, 86, 1.0),

              ),
            ),
            SizedBox(height: 8.0),
            Text(
              currencyFormat.format(product['price']),
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),

            // Add to cart button
            ElevatedButton.icon(
              onPressed: () {

              },
              label: Text(
                "Add To Cart",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 12.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Deskripsi Produk",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                product['description'] ?? 'Deskripsi tidak tersedia',
                style: TextStyle(fontSize: 16.0),
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(height: 20.0),

            // Review produk
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ulasan Pelanggan",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            if (reviews.isNotEmpty)
              ...reviews.map((review) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['review']['comment'] ??
                              'Tidak ada komentar',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 4.0),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index <
                                  (review['review']['ratings'] ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20.0,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList()
            else
              Text(
                "Belum ada ulasan.",
                style: TextStyle(fontSize: 16.0),
              ),
          ],
        ),
      ),
    );
  }
}