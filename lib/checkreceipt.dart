import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodies/products.dart';
import 'backend.dart';

class PurchaseSuccessCart extends StatefulWidget {
  const PurchaseSuccessCart({super.key});

  @override
  State<PurchaseSuccessCart> createState() => _PurchaseSuccessStateCart();
}

class _PurchaseSuccessStateCart extends State<PurchaseSuccessCart> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.chevron_back,
            color: CupertinoColors.black,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (context) => Products()),
            );
          },
        ),
        middle: Text(
          "Transaction Receipt",
          style: TextStyle(letterSpacing: 1.1, fontWeight: FontWeight.w500),
        ),
      ),

      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(40, 30, 40, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: CupertinoColors.activeGreen,
                      size: 80,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Purchased Successful",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.activeGreen,
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Transaction Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.black,
                            ),
                          ),
                          SizedBox(height: 10),

                          ...receiptItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Product: ${item['product']}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        "Price: ₱${item['price']}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Quantity: ${item['quantity']}",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "Total: ₱${item['total']}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    Text(
                      "Thank you for your purchase!",
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "$receiptDate",
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
