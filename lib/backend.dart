String server = "https://phpconfig.fun/";
//String server = "http://192.168.144.203/Foodies/";

List<dynamic> products = [];
List<dynamic> cartproducts = [];
List<dynamic> purchased = [];

String editproductname = "";
String editproductstock = "";
String editproductprice = "";
String editproductid = "";
String editproductimage = "";

String receiptProduct = "";
String receiptPrice = "";
String receiptTotal = "";
String receiptQuantity = "";
String receiptDate = "";

bool isLoading = false;
bool noInternet = false;
bool addedTocart = false;

bool buttonStatus = true;

bool cangoback = true;


List<Map<String, dynamic>> receiptItems = [];
