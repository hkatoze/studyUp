import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_up/constants.dart';

import 'package:study_up/models/models.dart';

//Verifier la connexion internet
Future<int> internetCheck() async {
  int response = 400;

  try {
    var request = await http.get(
      Uri.parse("https://www.google.com"),
    );

    if (request.statusCode >= 200 && request.statusCode < 300) {
      return 200;
    } else {
      print(request.reasonPhrase);
    }
    throw Exception('Some arbitrary error');
  } catch (e) {
    return response;
  }
}

//Connexion de l'utilisateur
Future<UserConnecting> loginChecked(String email, String password) async {
  UserConnecting userConnected = UserConnecting(
      auth_token: "auth_token",
      user: User(
          id: 0,
          email: "email",
          phone: "phone",
          profile: "profile",
          lastname: "lastname",
          firstname: "firstname",
          roleId: "roleId"));

  try {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://bookstudy.smt-group.net/api/login'));
    request.fields.addAll({'email': email, 'password': password});

    http.StreamedResponse streamedResponse = await request.send();

    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> json = jsonDecode(response.body);
      UserConnecting userConnectedt = UserConnecting.fromJson(json);
      return userConnectedt;
    } else {
      print(response.reasonPhrase);
      return userConnected;
    }
  } catch (e) {
    return userConnected;
  }
}

//creation d'un fichier en local pour le chemin de la photo de profil
writeProfilPath(String path) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/profil_path.txt');
  await file.writeAsString(path);
}

//reccupération  du chemin de la photo de profil
Future<String> readProfilPath() async {
  String text = '';
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/profil_path.txt');
    text = await file.readAsString();
  } catch (e) {
    print("Couldn't read file");
  }
  return text;
}

//creation d'un fichier en local pour les informations de l'utilisateur
writeUserName(String name) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/user.txt');
  await file.writeAsString(name);
}

//reccupération  des informations de l'utilisateur
Future<String> readUserName() async {
  String text = '';
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/user.txt');
    text = await file.readAsString();
  } catch (e) {
    print("Couldn't read file");
  }
  return text;
}

//reccupération du mot de passe stocké en local
Future<String> readEmail() async {
  String text = '';
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/user_email.txt');
    text = await file.readAsString();
  } catch (e) {
    print("Couldn't read file");
  }
  return text;
}

//creation d'un fichier en local pour stocker l'adresse mail
writeEmail(String email) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/user_email.txt');
  await file.writeAsString(email);
}

//creation d'un fichier en local pour stocker le mot de passe
writeCredentials(String auth) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/studyUp_auth.txt');
  await file.writeAsString(auth);
}

//creation d'un fichier en local pour stocker les credentials
writePassword(String password) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/user_password.txt');
  await file.writeAsString(password);
}

//reccupération du mot de passe stocké en local
Future<String> readPassword() async {
  String text = '';
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/user_password.txt');
    text = await file.readAsString();
  } catch (e) {
    print("Couldn't read file");
  }
  return text;
}

//reccupération des credentials stockés en local
Future<String> readCredentials() async {
  String text = '';
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/studyUp_auth.txt');
    text = await file.readAsString();
  } catch (e) {
    print("Couldn't read file");
  }
  return text;
}

//Inscription de l'utilisateur
Future<User> register(
    String firstname, String lastname, String email, String password) async {
  User user = User(
      id: 0,
      email: "email",
      phone: "phone",
      profile: "profile",
      lastname: "lastname",
      firstname: "firstname",
      roleId: "roleId");

  var request = http.MultipartRequest(
      'POST', Uri.parse('http://bookstudy.smt-group.net/api/register'));
  request.fields.addAll({
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'password': password
  });

  http.StreamedResponse streamedResponse = await request.send();

  var response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode >= 200 && response.statusCode < 300) {
    Map<String, dynamic> json = jsonDecode(response.body);
    user = User.fromJson(json);
    await loginChecked(email, password);
    return user;
  } else {
    print(response.reasonPhrase);
    return user;
  }
}

//Déconnexion de l'utilisateur
Future<int> logout(String auth_token) async {
  var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://bookstudy.smt-group.net/api/deconnexion?token =' +
          '${auth_token}'));

  http.StreamedResponse streamedResponse = await request.send();

  var response = await http.Response.fromStream(streamedResponse);
  await writeCredentials("");

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return response.statusCode;
  } else {
    print(response.reasonPhrase);
    return 400;
  }
}

//Reccupération des livres recement ajouté
Future<List<dynamic>> getBookRecentlyAdded(var auth_token) async {
  List<BookAddedModel> bookList = [];
  final jsonKey = 'json_key_books';
  final prefs = await SharedPreferences.getInstance();
  final connectivityResult = await (Connectivity().checkConnectivity());
  final internet = await internetCheck();

  try {
    if (connectivityResult == ConnectivityResult.none || internet != 200) {
      final jsonCache = jsonDecode(prefs.getString(jsonKey)!);

      var bookListCache = await jsonCache
          .map((dynamic item) => BookAddedModel.fromJson(item))
          .toList();
      saveBookLength(bookListCache.length);

      return bookListCache;
    } else {
      var response = await http.get(
          Uri.parse("http://bookstudy.smt-group.net/api/appHome"),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $auth_token',
          });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic> json = jsonDecode(response.body);

        List<dynamic> body = json['data'];
        // Save your JSON as a String by encoding it.
        await prefs.setString(jsonKey, jsonEncode(body));

        bookList = await body
            .map((dynamic item) => BookAddedModel.fromJson(item))
            .toList();
        return bookList;
      } else {
        final jsonCache = jsonDecode(prefs.getString(jsonKey)!);

        var bookListCache = await jsonCache
            .map((dynamic item) => BookAddedModel.fromJson(item))
            .toList();
        saveBookLength(bookListCache.length);
        return bookListCache;
      }
    }
  } catch (e) {
    return bookList;
  }
}

//Reccupération des différents categories
Future<List<dynamic>> getCategories(var auth_token) async {
  List<dynamic> categoryList = [];

  final jsonKey = 'json_key_categ';
  final prefs = await SharedPreferences.getInstance();
  final connectivityResult = await (Connectivity().checkConnectivity());

  final internet = await internetCheck();

  try {
    if (connectivityResult == ConnectivityResult.none || internet != 200) {
      final jsonCache = jsonDecode(prefs.getString(jsonKey)!);

      var catListCache = await jsonCache
          .map((dynamic item) => Category.fromJson(item))
          .toList();

      return catListCache;
    } else {
      var response = await http.get(
          Uri.parse("http://bookstudy.smt-group.net/api/categories"),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $auth_token',
          });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        dynamic json = jsonDecode(response.body);

        // Save your JSON as a String by encoding it.
        await prefs.setString(jsonKey, jsonEncode(json));

        categoryList =
            json.map((dynamic item) => Category.fromJson(item)).toList();

        return categoryList;
      } else {
        final jsonCache = jsonDecode(prefs.getString(jsonKey)!);

        var catListCache = await jsonCache
            .map((dynamic item) => Category.fromJson(item))
            .toList();

        return catListCache;
      }
    }
  } catch (e) {
    return categoryList;
  }
}

//Reccupération des livres de ma librarie
Future<List<dynamic>> getFavorisBook(var auth_token) async {
  List<dynamic> bookList = [];

  final jsonKey = 'json_key_library_books';
  final prefs = await SharedPreferences.getInstance();
  final connectivityResult = await (Connectivity().checkConnectivity());
  final internet = await internetCheck();

  try {
    if (connectivityResult == ConnectivityResult.none || internet != 200) {
      final jsonCache = jsonDecode(prefs.getString(jsonKey)!);

      var bookListCache = await jsonCache
          .map((dynamic item) => FavorisBookModel.fromJson(item))
          .toList();

      return bookListCache;
    } else {
      var response = await http.get(
          Uri.parse("http://bookstudy.smt-group.net/api/getFavoris"),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $auth_token',
          });

      if ((response.statusCode >= 200 && response.statusCode < 300)) {
        Map<String, dynamic> json = jsonDecode(response.body);

        List<dynamic> body = json['data'];

        // Save your JSON as a String by encoding it.
        await prefs.setString(jsonKey, jsonEncode(body));

        bookList = body
            .map((dynamic item) => FavorisBookModel.fromJson(item))
            .toList();

        return bookList;
      } else {
        final jsonCache = jsonDecode(prefs.getString(jsonKey)!);

        var bookListCache = await jsonCache
            .map((dynamic item) => FavorisBookModel.fromJson(item))
            .toList();

        return bookListCache;
      }
    }
  } catch (e) {
    return [];
  }
}

//creation d'un fichier en local pour stocker le user_id
writeUserId(String user_id) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/user_id.txt');
  await file.writeAsString(user_id);
}

//reccupération de l'user id stocké en local
Future<String> readUserId() async {
  String text = '';
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/user_id.txt');
    text = await file.readAsString();
  } catch (e) {
    print("Couldn't read file");
  }
  return text;
}

//Achat de livre
Future<String> buyBook(
    String user_id, String book_id, String price, var auth_token) async {
  var operation = "echec";

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://bookstudy.smt-group.net/api/buyBook'),
  );

  request.headers.addAll({
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $auth_token',
  });

  request.fields
      .addAll({'user_id': user_id, 'book_id': book_id, 'price': price});

  http.StreamedResponse streamedResponse = await request.send();

  var response = await http.Response.fromStream(streamedResponse);
  print("STATUS CODE: " + response.statusCode.toString());

  if (response.statusCode >= 200 && response.statusCode < 300) {
    Map<String, dynamic> json = jsonDecode(response.body);
    print("MESSAGE: " + json['message']);

    return json['message'];
  } else {
    print(response.reasonPhrase);
    return operation;
  }
}

//Ajout de livre a ma librarie
Future<String> addToLib(String user_id, String book_id, var auth_token) async {
  var operation = "echec";
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://bookstudy.smt-group.net/api/favoris'),
    );

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $auth_token',
    });

    request.fields.addAll({
      'user_id': user_id,
      'book_id': book_id,
    });

    http.StreamedResponse streamedResponse = await request.send();

    var response = await http.Response.fromStream(streamedResponse);
    print("STATUS CODE: " + response.statusCode.toString());

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> json = jsonDecode(response.body);
      print("MESSAGE: " + json['message']);

      return json['message'];
    } else {
      print(response.reasonPhrase);
    }

    throw Exception('Some arbitrary error');
  } catch (e) {
    print(e);
    return operation;
  }
}

//suppression de livre de ma librarie
Future<String> deleteFromLib(var auth_token, String book_id) async {
  var operation = null;

  try {
    var response = await http.delete(
        Uri.parse("http://bookstudy.smt-group.net/api/delete/${book_id}"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $auth_token',
        });

    print("STATUS CODE: " + response.statusCode.toString());
    print("Book_id : " + book_id);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> json = jsonDecode(response.body);
      print("MESSAGE: " + json['message']);

      return json['message'];
    } else {
      print(response.reasonPhrase);
    }
    throw Exception('Some arbitrary error');
  } catch (e) {
    return operation;
  }
}

//Reccupération du solde actuel de l'utilisateur
Future<String> getAmount(String auth_token) async {
  String amount = ".........";

  try {
    var response = await http
        .get(Uri.parse("http://bookstudy.smt-group.net/api/account"), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $auth_token',
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> json = jsonDecode(response.body);

      return json["le montant present dans le compte est de "];
    } else {
      return ".........";
    }
  } catch (e) {
    return ".........";
  }
}

//Faire un dépôt sur le compte
Future<int> MakeDeposit(
    String phone, String amount, String otp_code, String auth_token) async {
  var operation = 400;

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://bookstudy.smt-group.net/api/deposit'),
    );

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $auth_token',
    });
    print(amount + "  " + otp_code + "  " + auth_token);

    request.fields
        .addAll({'phone': phone, 'amount': amount, 'otp_code': otp_code});

    http.StreamedResponse streamedResponse = await request.send();

    var response = await http.Response.fromStream(streamedResponse);

    print(response.statusCode);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> json = jsonDecode(response.body);

      return response.statusCode;
    } else {
      return operation;
    }
  } catch (e) {
    return operation;
  }
}

//Changer les informtions de l'utilisateur
Future<int> changeInformations(
    String firstname, String lastname, String auth_token) async {
  var operation = 400;
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://bookstudy.smt-group.net/api/changeData'),
    );

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $auth_token',
    });

    request.fields.addAll({
      'lastname': lastname,
      'firstname': firstname,
    });

    http.StreamedResponse streamedResponse = await request.send();

    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> json = jsonDecode(response.body);

      return response.statusCode;
    } else {
      print(response.reasonPhrase);
    }

    throw Exception('Some arbitrary error');
  } catch (e) {
    print(e);
    return operation;
  }
}

//Changer le mot de passe
Future<int> changePassword(String password, String auth_token) async {
  var operation = 0;
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://bookstudy.smt-group.net/api/changePassword'),
    );

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $auth_token',
    });

    request.fields.addAll({'password': password});

    http.StreamedResponse streamedResponse = await request.send();

    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 429) {
      Map<String, dynamic> json = jsonDecode(response.body);

      return response.statusCode;
    } else {
      print(response.reasonPhrase);
    }

    throw Exception('Some arbitrary error');
  } catch (e) {
    print(e);
    return operation;
  }
}

//Reccupération des livres achetés
Future<List<dynamic>> getBookBougth(var auth_token) async {
  List<FavorisBookModel> bookList = [];

  final jsonKey = 'json_key_bougth_books';
  final prefs = await SharedPreferences.getInstance();
  final connectivityResult = await (Connectivity().checkConnectivity());

  try {
    if (connectivityResult == ConnectivityResult.none) {
      final jsonCache = jsonDecode(prefs.getString(jsonKey)!);

      var bookListCache = await jsonCache
          .map((dynamic item) => FavorisBookModel.fromJson(item))
          .toList();

      return bookListCache;
    } else {
      var response = await http.get(
          Uri.parse("http://bookstudy.smt-group.net/api/payments"),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $auth_token',
          });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic> json = jsonDecode(response.body);

        List<dynamic> body = json['data'];

        // Save your JSON as a String by encoding it.
        await prefs.setString(jsonKey, jsonEncode(body));

        bookList = body
            .map((dynamic item) => FavorisBookModel.fromJson(item))
            .toList();
        print(bookList);
        return bookList;
      } else {
        final jsonCache = jsonDecode(prefs.getString(jsonKey)!);

        var bookListCache = await jsonCache
            .map((dynamic item) => FavorisBookModel.fromJson(item))
            .toList();

        return bookListCache;
      }
    }
  } catch (e) {
    return [];
  }
}
