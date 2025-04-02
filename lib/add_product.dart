import 'package:flutter/cupertino.dart';
import 'package:foodies/product_management.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'backend.dart';
import 'package:flutter/services.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController _newprodname = TextEditingController();
  TextEditingController _newprodstock = TextEditingController();
  TextEditingController _newprodprice = TextEditingController();
  File? _image;



  Future<File> resizeImage(File originalImage) async {
    final rawImage = img.decodeImage(await originalImage.readAsBytes());
    final resizedImage = img.copyResize(rawImage!, width: 800);
    final resizedFile = File(originalImage.path)
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 85));
    return resizedFile;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File resizedImage = await resizeImage(File(pickedFile.path));
      setState(() {
        _image = resizedImage;
      });
      print("Resized Image Path: ${_image!.path}");
    }
  }

  Future<void> addProduct(String name, String stock, String price) async {


    if (name.isEmpty || stock.isEmpty || price.isEmpty || _image == null) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("Missing Information"),
            content: Text("Please fill in all the fields before submitting."),
            actions: [
              CupertinoButton(
                child: Text(
                  "Close",
                  style: TextStyle(color: CupertinoColors.destructiveRed),
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
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(server + "add_product.php"),
      );

      request.fields['name'] = name;
      request.fields['stock'] = stock;
      request.fields['price'] = price;

      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _image!.path),
        );
        print("Image file added: ${_image!.path}");
      }

      request.headers['Content-Type'] = 'multipart/form-data';

      var response = await request.send();

      if (response.statusCode == 200) {
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              content: Text("Product Added Successfully!"),
              actions: [
                CupertinoButton(
                  child: Text(
                    "Close",
                    style: TextStyle(color: CupertinoColors.destructiveRed),
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

        var responseData = await response.stream.bytesToString();
        print("Server response: $responseData");
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              content: Text(
                "Failed to add product. Status code: ${response.statusCode}",
              ),
              actions: [
                CupertinoButton(
                  child: Text(
                    "Close",
                    style: TextStyle(color: CupertinoColors.destructiveRed),
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

        var responseData = await response.stream.bytesToString();
        print("Error details: $responseData");
      }
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: Text("Error adding product: $e"),
            actions: [
              CupertinoButton(
                child: Text(
                  "Close",
                  style: TextStyle(color: CupertinoColors.destructiveRed),
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
  }

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
            buttonStatus
                ?    Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (context) => ProductManagement()),
            ):null;
          },
        ),
        middle: Text(
          "Add Product",
          style: TextStyle(letterSpacing: 1.1, fontWeight: FontWeight.w500),
        ),
      ),

      child: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30,20,30,20),
            child: Column(
              children: [
                SizedBox(height: 15),

                Row(
                  children: [
                    Text(
                      "Product Name",
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),                    ),
                  ],
                ),
                SizedBox(height: 5),
                CupertinoTextField(
                  controller: _newprodname,
                  placeholder: "Product name",
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      width: 1.2,
                      color: CupertinoColors.inactiveGray,
                    ),
                  ),
                ),

                SizedBox(height: 15),

                Row(
                  children: [
                    Text(
                      "Quantity",
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),                    ),
                  ],
                ),
                SizedBox(height: 5),
                CupertinoTextField(
                  controller: _newprodstock,
                  placeholder: "Quantity",
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      width: 1.2,
                      color: CupertinoColors.inactiveGray,
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: 15),

                Row(
                  children: [
                    Text(
                      "Price",
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),

                CupertinoTextField(
                  controller: _newprodprice,
                  placeholder: "Price",
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      width: 1.2,
                      color: CupertinoColors.inactiveGray,
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                  ],
                ),
                SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_image != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _image!,
                          height: MediaQuery.of(context).size.width * 0.25,
                          width: MediaQuery.of(context).size.width * 0.25,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ] else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "images/photo.png",
                          height: MediaQuery.of(context).size.width * 0.25,
                          width: MediaQuery.of(context).size.width * 0.25,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],

                    SizedBox(width: 20),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.width * 0.11,
                          width: MediaQuery.of(context).size.width * 0.55,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: CupertinoColors.systemFill,
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            onPressed: _pickImage,
                            child: Text(
                              "Pick Image",
                              style: TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),

                        Container(
                          height: MediaQuery.of(context).size.width * 0.11,
                          width: MediaQuery.of(context).size.width * 0.55,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: CupertinoColors.systemFill,
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Text(
                              "Add",
                              style: TextStyle(
                                color: CupertinoColors.systemBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            onPressed: () {

                              buttonStatus? addProduct(
                                _newprodname.text,
                                _newprodstock.text,
                                _newprodprice.text,
                              ): null;

                              setState(() {
                                buttonStatus = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
