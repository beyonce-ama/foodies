import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodies/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'backend.dart';

class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key});

  @override
  State<ProductManagement> createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  @override
  Future<void> getData() async {
    try {
      setState(() {
        noInternet = false;
        isLoading = true;
      });

      Timer(Duration(seconds: 3), () {
        setState(() {
          noInternet = true;
        });
      });

      final response = await http.get(Uri.parse("${server}read_products.php"));

      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
          isLoading = false;
          noInternet = false;
        });

        if (isLoading != true && noInternet != true) {
          addedTocart
              ? showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    content: Text("Item Added to Cart"),
                    actions: [
                      CupertinoButton(
                        child: Text(
                          "Close",
                          style: TextStyle(
                            color: CupertinoColors.destructiveRed,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            addedTocart = false;
                          });
                        },
                      ),
                    ],
                  );
                },
              )
              : null;
        }
        print(response.body);
        print(products[0]);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        noInternet = true;
      });
      print("Error occurred: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CupertinoPageScaffold(
          child: SafeArea(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 250),

                  noInternet
                      ? Column(
                        children: [
                          Text(
                            "Server Error",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "No internet Connection",
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: getData,
                            child: Text("Retry"),
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          Text(
                            "Loading",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 15),
                          CupertinoActivityIndicator(),
                        ],
                      ),
                ],
              ),
            ),
          ),
        )
        : CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                CupertinoIcons.chevron_back,
                color: CupertinoColors.black,
              ),
              onPressed: () {
                buttonStatus
                    ? Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(builder: (context) => HomePage()),
                    )
                    : null;
              },
            ),
            middle: Text(
              "Inventory",
              style: TextStyle(letterSpacing: 1.1, fontWeight: FontWeight.w500),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.add, color: CupertinoColors.black),
              onPressed: () {
              },
            ),
          ),

          child: SafeArea(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, int index) {
                final item = products;

                Future<void> deleteproduct() async {
                  final response = await http.post(
                    Uri.parse("${server}deleteproduct.php"),
                    body: {"id": item[index]["id"]},
                  );
                  print(response.body);
                  if (response.statusCode == 200) {
                    getData();
                    setState(() {
                      buttonStatus = true;
                    });
                  }
                }

                return CupertinoListTile(
                  title: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                server + products[index]["productimage"],
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        products[index]["name"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17,
                                          letterSpacing: 1.1,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Stock: " + products[index]["stock"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Price: " + products[index]["price"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 25, 10),
                            child: Column(
                              children: [
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: Icon(
                                    CupertinoIcons.pencil,
                                    color: CupertinoColors.systemGreen,
                                  ),
                                  onPressed: () {
                                  },
                                ),
                                const SizedBox(height: 10),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: Icon(
                                    CupertinoIcons.trash_fill,
                                    color: CupertinoColors.destructiveRed,
                                  ),
                                  onPressed: () {
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoAlertDialog(
                                          content: Text(
                                            "Are you sure you want to delete this?",
                                          ),

                                          actions: [
                                            CupertinoButton(
                                              child: Text(
                                                "Confirm",
                                                style: TextStyle(
                                                  color:
                                                      CupertinoColors
                                                          .destructiveRed,
                                                ),
                                              ),
                                              onPressed: () {
                                                deleteproduct();
                                                setState(() {
                                                  buttonStatus = false;
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                            CupertinoButton(
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  color:
                                                      CupertinoColors
                                                          .systemGreen,
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
  }
}
