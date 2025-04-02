import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() =>
    runApp(CupertinoApp(
        theme: CupertinoThemeData(brightness: Brightness.light),
        debugShowCheckedModeBanner: false, home: HomePage()));

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        trailing: CupertinoButton(
          child: Icon(CupertinoIcons.settings, color: CupertinoColors.black),
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Development Team',
                          style: TextStyle(color: Color(0xFF0d0d0d), fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Icon(
                            CupertinoIcons.square_arrow_right,
                            color: CupertinoColors.black,
                          ),
                          onPressed: () {
                          },
                        ),
                      ],
                    ),
                  ),
                  content: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemFill,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                "images/beyonce.jpg",
                                height: 60,
                                width: 60,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ama Beyonce",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    "Software Developer",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemFill,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                "images/bulanadi.jpeg",
                                height: 60,
                                width: 60,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bulanadi, Jhon Vianney",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    "Software Developer",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemFill,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                "images/culala.jpg",
                                height: 60,
                                width: 60,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Culala, Andrea",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    "Software Developer",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemFill,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                "images/jc.jpg",
                                height: 60,
                                width: 60,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Dizon, John Carlo V",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    "Software Developer",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemFill,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                "images/timbol.jpg",
                                height: 60,
                                width: 60,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Timbol, Christian",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    "Software Developer",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    CupertinoButton(
                      child: Text(
                        'Close',
                        style: TextStyle(color: CupertinoColors.destructiveRed),
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

      child: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 160),
              Text(
                'Foodies',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                'Bite Into Convenience, Every Time.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Image.asset('images/burger.png', width: 100, height: 100),
              SizedBox(height: 15),
              Container(
                width: 160,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemFill.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: CupertinoButton(
                  child: Text(
                    "Order Now",
                    style: TextStyle(
                      color: CupertinoColors.systemBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
