import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodies/products.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'backend.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<int> quantities = [];
  List<bool> selectedItems = [];
  bool selectAll = false;
  String purchasedate = DateFormat(
    'yyyy-MM-dd kk:mm:ss',
  ).format(DateTime.now());
  String displaydate = DateFormat(
    'MMMM dd, yyyy hh:mm a',
  ).format(DateTime.now());

  @override
  Future<void> getcartData() async {
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

      final response = await http.get(Uri.parse("${server}cart.php"));

      if (response.statusCode == 200) {
        print("FETCHED");
        setState(() {
          cartproducts = jsonDecode(response.body);
          isLoading = false;
          noInternet = false;
        });
        quantities = List<int>.generate(cartproducts.length, (index) => 1);
        selectedItems = List<bool>.generate(
          cartproducts.length,
          (index) => false,
        );
        if (cartproducts.isNotEmpty) {
          print(cartproducts[0]);
          print("OKAY");
        } else {
          print("The cart is empty.");
        }

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
        print(cartproducts[0]);
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

  Future<void> checkout() async {
    List<Map<String, dynamic>> checkedOutItems = [];
    for (int i = 0; i < cartproducts.length; i++) {
      if (selectedItems[i]) {
        checkedOutItems.add(cartproducts[i]);
      }
    }

    List<Map<String, dynamic>> requestData =
        checkedOutItems.map((item) {
          int index = cartproducts.indexOf(item);
          return {
            'cartid': item['cartid'].toString(),
            'name': item['name'],
            'quantity': quantities[index].toString(),
            'totalprice':
                (double.tryParse(item['price'].toString()) ??
                        0.0 * quantities[index])
                    .toString(),
            'price':
                double.tryParse(item['price'].toString())?.toString() ?? '0.0',
            'purchasedate': purchasedate,
            'productid': item['id'].toString(),
          };
        }).toList();

    try {
      final response = await http.post(
        Uri.parse("${server}checkout.php"),
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        setState(() {
          receiptItems = [];
          receiptDate = displaydate;
        });

        for (int i = 0; i < cartproducts.length; i++) {
          if (selectedItems[i]) {
            String receiptProduct = cartproducts[i]["name"];
            String receiptPrice = cartproducts[i]["price"];
            String receiptQuantity = quantities[i].toString();
            double totalprice = double.tryParse(receiptPrice)! * quantities[i];
            String receiptTotal = totalprice.toString();
            String receiptDate = purchasedate;

            receiptItems.add({
              'product': receiptProduct,
              'price': receiptPrice,
              'quantity': receiptQuantity,
              'total': receiptTotal,
              'date': receiptDate,
            });
          }
        }

        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              content: Column(
                children: [
                  Text("Processing Purchase", style: TextStyle(fontSize: 15)),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: CupertinoActivityIndicator(),
                  ),
                ],
              ),
            );
          },
        );
        print("PROCESS DONE");

        Timer(Duration(seconds: 1), () {
          Navigator.of(context).pop();
          setState(() {
            buttonStatus = true;
          });
          Timer(Duration(seconds: 1), () {
          });
        });

        print('Receipt Details:');
        for (var item in receiptItems) {
          print(
            'Product: ${item['product']}, Price: ${item['price']}, Quantity: ${item['quantity']}, Total: ${item['total']}, Date: ${item['date']}',
          );
        }

        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          print('Checkout successful!');
        } else {
          print('Checkout failed: ${data['message']}');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during checkout: $e');
    }
  }

  void toggleSelectAll(bool value) {
    setState(() {
      selectAll = value;

      selectedItems = List<bool>.generate(cartproducts.length, (index) {
        int stock = int.tryParse(cartproducts[index]['stock'].toString()) ?? 0;
        return stock > 0 && value;
      });
    });
  }

  void updateQuantity(int index, bool isIncrement) {
    if (cartproducts.isNotEmpty && index >= 0 && index < cartproducts.length) {
      setState(() {
        int stock = int.parse(cartproducts[index]['stock'].toString());
        if (isIncrement) {
          if (quantities[index] < stock) {
            quantities[index]++;
          }
        } else {
          if (quantities[index] > 1) {
            quantities[index]--;
          }
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    getcartData();

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
                            onPressed: getcartData,
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
                      CupertinoPageRoute(builder: (context) => Products()),
                    )
                    : null;
              },
            ),
            middle: Text(
              "Cart",
              style: TextStyle(letterSpacing: 1.1, fontWeight: FontWeight.w500),
            ),
          ),

          child: SafeArea(
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: cartproducts.length,
                  itemBuilder: (context, int index) {
                    final items = cartproducts;

                    Future<void> deleteproductcart() async {
                      final response = await http.post(
                        Uri.parse("${server}deleteproductcart.php"),
                        body: {"id": items[index]["id"]},
                      );

                      if (response.statusCode == 200) {
                        setState(() {
                          buttonStatus = true;
                        });
                        getcartData();
                      }
                    }

                    int quantity = int.parse(
                      cartproducts[index]["total_quantity"],
                    );

                    if (quantities.length <= index) {
                      quantities.add(quantity);
                    }
                    double totalprice =
                        (quantities[index]) *
                        double.parse(items[index]["price"]);

                    Future<void> buyNow() async {
                      final response = await http.post(
                        Uri.parse("${server}buyproduct.php"),
                        body: {
                          "cartid": items[index]["cartid"].toString(),
                          "productid": items[index]["id"].toString(),
                          "name": cartproducts[index]["name"],
                          "quantity": quantity.toString(),
                          "purchasedate": purchasedate,
                          "price": items[index]["price"],
                          "totalprice": totalprice.toString(),
                        },
                      );

                      print(response.body);
                      if (response.statusCode == 200) {
                        setState(() {
                          print("RECEIPT DONE");
                          receiptProduct = items[index]["name"];
                          receiptPrice = items[index]["price"];
                          receiptTotal = totalprice.toString();
                          receiptQuantity = quantity.toString();
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
                        print("PROCESS DONE");

                        Timer(Duration(seconds: 1), () {
                          Navigator.of(context).pop();
                          setState(() {
                            buttonStatus = true;
                          });
                          Timer(Duration(seconds: 1), () {
                          });
                        });
                        print("PAGEROUTE  DONE");
                      } else {
                        setState(() {
                          buttonStatus = true;
                        });
                        print("ERROR");
                      }
                    }

                    int stock = int.parse(items[index]["stock"]);
                    bool isStockSufficient = stock >= quantities[index];

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
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        server +
                                            cartproducts[index]["productimage"],
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                      10,
                                                      20,
                                                      0,
                                                      0,
                                                    ),
                                                child: Text(
                                                  cartproducts[index]["name"],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                    letterSpacing: 1.1,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
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
                                            "₱" + cartproducts[index]["price"],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        stock != 0
                                            ? Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
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
                                                    color:
                                                        CupertinoColors.black,
                                                  ),
                                                  onPressed: () {
                                                    updateQuantity(
                                                      index,
                                                      false,
                                                    );
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
                                                    color:
                                                        CupertinoColors.black,
                                                  ),
                                                  onPressed: () {
                                                    updateQuantity(index, true);
                                                  },
                                                ),
                                              ],
                                            )
                                            : Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    10,
                                                    0,
                                                    0,
                                                    10,
                                                  ),
                                              child: Text(
                                                "Out of stock",
                                                style: TextStyle(
                                                  color:
                                                      CupertinoColors
                                                          .destructiveRed,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      15,
                                      10,
                                      10,
                                      10,
                                    ),
                                    child: Column(
                                      children: [
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          child: Icon(
                                            CupertinoIcons.trash_fill,
                                            color:
                                                CupertinoColors.destructiveRed,
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
                                                        deleteproductcart();
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
                                        const SizedBox(height: 20),

                                        Transform.scale(
                                          scale: 1.3,
                                          child: CupertinoCheckbox(
                                            value: selectedItems[index],
                                            onChanged: (bool? newValue) {
                                              int stock =
                                                  int.tryParse(
                                                    cartproducts[index]['stock']
                                                        .toString(),
                                                  ) ??
                                                  0;
                                              if (stock > 0) {
                                                setState(() {
                                                  selectedItems[index] =
                                                      newValue!;
                                                });
                                              }
                                            },
                                            activeColor:
                                                (int.tryParse(
                                                              cartproducts[index]['stock']
                                                                  .toString(),
                                                            ) ??
                                                            0) >
                                                        0
                                                    ? CupertinoColors.activeBlue
                                                    : CupertinoColors
                                                        .inactiveGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Transform.scale(
                                scale: 1.5,
                                child: CupertinoCheckbox(
                                  value: selectAll,
                                  onChanged: (value) {
                                    toggleSelectAll(value!);
                                  },
                                ),
                              ),
                              Text(
                                "All",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),

                          Container(
                            child: CupertinoButton(
                              onPressed: () {
                                if (selectedItems.contains(true)) {
                                  buttonStatus ? checkout() : null;
                                  setState(() {
                                    buttonStatus = false;
                                  });
                                } else {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) {
                                      return CupertinoAlertDialog(
                                        content: Text("No Items Selected"),
                                        actions: [
                                          CupertinoButton(
                                            child: Text(
                                              "Close",
                                              style: TextStyle(
                                                color:
                                                    CupertinoColors
                                                        .destructiveRed,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                buttonStatus = true;
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              color: CupertinoColors.destructiveRed,
                              borderRadius: BorderRadius.circular(0),
                              child: Text(
                                "Check out",
                                style: TextStyle(color: CupertinoColors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
