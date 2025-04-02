import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:foodies/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'backend.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List<int> quantities = [];

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
                            buttonStatus = true;
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
            leading: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(
                      CupertinoIcons.chevron_back,
                      color: CupertinoColors.black,
                    ),
                    onPressed: () {
                      buttonStatus
                          ? Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          )
                          : null;
                    },
                  ),
                  Text(
                    "Products",
                    style: TextStyle(
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            trailing: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(
                      CupertinoIcons.cart,
                      color: CupertinoColors.black,
                    ),
                    onPressed: () {
                    },
                  ),

                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(
                      CupertinoIcons.money_rubl_circle,
                      color: CupertinoColors.black,
                    ),
                    onPressed: () {
                    },
                  ),
                ],
              ),
            ),
          ),

          child: SafeArea(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, int index) {
                final item = products;

                Future<void> addtoCart() async {
                  try {
                    final response = await http.post(
                      Uri.parse("${server}addtocart.php"),
                      body: {
                        "productid": item[index]["id"],
                        "stock": quantities[index].toString(),
                      },
                    );

                    if (response.statusCode == 200) {
                      getData();
                      setState(() {
                        addedTocart = true;
                      });
                    }
                  } catch (e) {
                    print("Error occurred: $e");

                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoAlertDialog(
                          content: Text(
                            "An error occurred. Please try again.",
                            style: TextStyle(fontSize: 15),
                          ),
                          actions: [
                            CupertinoButton(
                              child: Text(
                                "Close",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: CupertinoColors.destructiveRed,
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
                  }
                }

                DateTime now = DateTime.now();

                String displaydate = DateFormat(
                  'MMMM dd, yyyy hh:mm a',
                ).format(now);
                String purchasedate = DateFormat(
                  'yyyy-MM-dd kk:mm:ss',
                ).format(now);

                if (quantities.length <= index) {
                  quantities.add(1);
                }
                int stock = int.parse(item[index]["stock"]);
                double totalprice =
                    double.parse(item[index]["price"]) * quantities[index];

                Future<void> buy() async {
                  final response = await http.post(
                    Uri.parse("${server}buy.php"),
                    body: {
                      "productid": item[index]["id"],
                      "name": item[index]["name"],
                      "quantity": quantities[index].toString(),
                      "purchasedate": purchasedate,
                      "price": item[index]["price"],
                      "totalprice": totalprice.toString(),
                    },
                  );
                  print(response.body);

                  if (response.statusCode == 200) {
                    print("Success");
                    setState(() {
                      receiptProduct = item[index]["name"];
                      receiptPrice = item[index]["price"];
                      receiptTotal = totalprice.toString();
                      receiptQuantity = quantities[index].toString();
                      receiptDate = displaydate;
                    });

                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoAlertDialog(
                          content: Column(
                            children: [
                              Text(
                                "Processing Purchase",
                                style: TextStyle(fontSize: 15),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: CupertinoActivityIndicator(),
                              ),
                            ],
                          ),
                        );
                      },
                    );

                    Timer(Duration(seconds: 1), () {
                      Navigator.of(context).pop();
                      setState(() {
                        buttonStatus = true;
                      });
                      Timer(Duration(seconds: 1), () {
                      });
                    });

                    quantities[index] = 1;
                  } else {
                    setState(() {
                      buttonStatus = true;
                    });
                    print("Failed");
                  }
                }

                return CupertinoListTile(
                  title: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 140,
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
                          const SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    20,
                                    0,
                                    0,
                                  ),
                                  child: Text(
                                    products[index]["name"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    0,
                                    0,
                                    0,
                                  ),
                                  child: Text(
                                    "₱" + products[index]["price"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Colors.black87,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                stock != 0
                                    ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        10,
                                        0,
                                        0,
                                        0,
                                      ),
                                      child: Text(
                                        "Stk: $stock",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    )
                                    : SizedBox.shrink(),

                                stock != 0
                                    ? Row(
                                      children: [
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          child: const Icon(
                                            CupertinoIcons.minus,
                                            size: 18,
                                            color: CupertinoColors.black,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (quantities[index] > 1) {
                                                quantities[index]--;
                                              }
                                            });
                                          },
                                        ),
                                        Text(
                                          "${quantities[index]}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          child: const Icon(
                                            CupertinoIcons.add,
                                            size: 18,
                                            color: CupertinoColors.black,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (int.parse(
                                                    products[index]["stock"],
                                                  ) !=
                                                  quantities[index]) {
                                                quantities[index]++;
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                    : Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        10,
                                        0,
                                        0,
                                        10,
                                      ),
                                      child: Text(
                                        "Out of stock",
                                        style: TextStyle(
                                          color: CupertinoColors.destructiveRed,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                            child: Column(
                              children: [
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: const Icon(
                                    CupertinoIcons.cart_badge_plus,
                                    size: 24,
                                    color: CupertinoColors.systemRed,
                                  ),
                                  onPressed: () {
                                    stock != 0
                                        ? showCupertinoDialog(
                                          context: context,
                                          builder: (context) {
                                            return CupertinoAlertDialog(
                                              title: Text(
                                                "Add  ${products[index]["name"]} to your cart?",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),

                                              actions: [
                                                CupertinoButton(
                                                  child: Text(
                                                    "Confirm",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    addtoCart();
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
                                                              .systemRed,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        )
                                        : showCupertinoDialog(
                                          context: context,
                                          builder: (context) {
                                            return CupertinoAlertDialog(
                                              content: Text(
                                                "Item unavailable or quantity exceeds stock.",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              actions: [
                                                CupertinoButton(
                                                  child: Text(
                                                    "Close",
                                                    style: TextStyle(
                                                      color:
                                                          CupertinoColors
                                                              .systemRed,
                                                      fontSize: 16,
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

                                const SizedBox(height: 20),
                                Container(
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.destructiveRed,
                                  ),
                                  child: CupertinoButton(
                                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Buy Now",
                                          style: TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          "$totalprice",
                                          style: TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onPressed: () {
                                      stock != 0
                                          ? showCupertinoDialog(
                                            context: context,
                                            builder: (context) {
                                              return CupertinoAlertDialog(
                                                content: Text(
                                                  "Would you like to purchase this item now?",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                actions: [
                                                  CupertinoButton(
                                                    child: Text(
                                                      "Buy Now",
                                                      style: TextStyle(
                                                        color:
                                                            CupertinoColors
                                                                .activeBlue,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      buy();
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
                                                                .systemRed,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          )
                                          : showCupertinoDialog(
                                            context: context,
                                            builder: (context) {
                                              return CupertinoAlertDialog(
                                                content: Text(
                                                  "Item unavailable or quantity exceeds stock.",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                actions: [
                                                  CupertinoButton(
                                                    child: Text(
                                                      "Close",
                                                      style: TextStyle(
                                                        color:
                                                            CupertinoColors
                                                                .systemRed,
                                                        fontSize: 16,
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
