import 'package:flutter/material.dart';

class BookAddedModel {
  final int? id;
  final Editor? editor;
  final Author? author;
  final Country? country;
  final Category? category;
  final Language? language;
  final String? nbrPage;
  final String? description;
  final String? bookTitle;
  final String? price;
  final String? bookPicture;
  final String? book;
  const BookAddedModel(
      {Key? key,
      required this.id,
      required this.author,
      required this.book,
      required this.bookPicture,
      required this.bookTitle,
      required this.category,
      required this.country,
      required this.description,
      required this.editor,
      required this.language,
      required this.nbrPage,
      required this.price});

  factory BookAddedModel.fromJson(Map<String, dynamic> json) {
    return BookAddedModel(
        id: json['id'],
        author: Author.fromJson(json['author']),
        editor: Editor.fromJson(json['editor']),
        bookPicture: json['photo'],
        bookTitle: json['titre'],
        category: Category.fromJson(json['category']),
        country: Country.fromJson(json['countrie']),
        description: json['description'],
        language: Language.fromJson(json['langues']),
        nbrPage: json['page'],
        price: json['prix'],
        book: json['document']);
  }
}

class BookModel {
  final int? booK_id;
  final String? bookTitle;
  final Author? author;
  final String? description;
  final String? price;
  final Category? category;
  final Language? language;
  final Editor? editor;
  final Country? country;
  final String? nbrPage;
  final String? bookPicture;
  final String? book;

  const BookModel(
      {Key? key,
      this.booK_id,
      this.author,
      this.editor,
      this.bookPicture,
      this.bookTitle,
      this.category,
      this.country,
      this.description,
      this.language,
      this.nbrPage,
      this.price,
      this.book});

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
        booK_id: json['id'],
        author: Author.fromJson(json['author']),
        editor: Editor.fromJson(json['editor']),
        bookPicture: json['photo'],
        bookTitle: json['titre'],
        category: Category.fromJson(json['category']),
        country: Country.fromJson(json['countrie']),
        description: json['description'],
        language: Language.fromJson(json['langues']),
        nbrPage: json['page'],
        price: json['prix'],
        book: json['document']);
  }
}

class Category {
  final int? id;
  final String? categ;

  const Category({
    Key? key,
    this.id,
    this.categ,
  });
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      categ: json['categorie'],
    );
  }
}

class Editor {
  final int? id;
  final String? editor;

  const Editor({
    Key? key,
    this.id,
    this.editor,
  });
  factory Editor.fromJson(Map<String, dynamic> json) {
    return Editor(
      id: json['id'],
      editor: json['nom'],
    );
  }
}

class Country {
  final int? id;
  final String? country;

  const Country({Key? key, this.id, this.country});
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      country: json['pays'],
    );
  }
}

class Author {
  final int? id;
  final String? author;

  const Author({
    Key? key,
    this.id,
    this.author,
  });
  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      author: json['prenom'] + " " + json['nom'],
    );
  }
}

class Language {
  final int? id;
  final String? lang;

  const Language({Key? key, this.id, this.lang});
  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'],
      lang: json['langue'],
    );
  }
}

class UserConnecting {
  final String auth_token;
  final User user;

  const UserConnecting({required this.auth_token, required this.user});

  factory UserConnecting.fromJson(Map<String, dynamic> json) {
    return UserConnecting(
      auth_token: json['auth_token'],
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final int? id;

  final String? roleId;

  final String? firstname;
  final String? lastname;

  final String? email;
  final String? phone;

  final String? profile;

  const User({
    required this.id,
    required this.roleId,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      roleId: json["role_id"],
      firstname: json["firstname"],
      lastname: json["lastname"],
      phone: json["phoneNumber"],
      email: json["email"],
      profile: json["profile"],
    );
  }
}

class Amount {
  final String solde;

  const Amount({
    required this.solde,
  });

  factory Amount.fromJson(Map<String, dynamic> json) {
    return Amount(
      solde: json["le montant present dans le compte est de"],
    );
  }
}

class NotificationModel {
  final String title;
  final String type;
  final String price;
  final String date;
  final IconData icon;

  const NotificationModel(
      {Key? key,
      required this.date,
      required this.icon,
      required this.title,
      required this.price,
      required this.type});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: "",
      type: "",
      price: "",
      date: "",
      icon: Icons.book,
    );
  }
}

final notification_list = {
  "data": [
    {"title": "", "type": "", "price": "", "date": "", "icon": null}
  ]
};

class FavorisBookModel {
  final int? id;
  final BookModel? bookModel;
  const FavorisBookModel({Key? key, required this.id, required this.bookModel});

  factory FavorisBookModel.fromJson(Map<String, dynamic> json) {
    return FavorisBookModel(
      id: json['id'],
      bookModel: BookModel.fromJson(json['books']),
    );
  }
}
