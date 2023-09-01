import 'package:flutter/material.dart';
import 'package:study_up/animation/ScaleRoute.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:study_up/api_services/api_services.dart';
import 'package:study_up/constants.dart';
import 'package:study_up/views/homePage.dart';
import 'package:study_up/views/myLibraryPage.dart';
import 'package:study_up/views/profilPage.dart';

class BottomNavBarWidget extends StatefulWidget {
  final int? index;
  final List<dynamic>? libraryBookList;
  final List<dynamic>? bookAddedList;
  final List<dynamic>? catList;

  final int? internet;
  final String? amount;

  const BottomNavBarWidget(
      {Key? key,
      required this.index,
      this.amount,
      required this.bookAddedList,
      required this.catList,
      required this.libraryBookList,
      this.internet})
      : super(key: key);
  @override
  _BottomNavBarWidgetState createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget> {
  var auth_token;

  void initState() {
    super.initState();
    readCredentials().then((String result) {
      setState(() {
        auth_token = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int _selectedIndex = 0;
    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;

//        navigateToScreens(index);
      });

      switch (_selectedIndex) {
        case 0:
          Navigator.pushAndRemoveUntil(
              context,
              ScaleRoute(
                  page: HomePage(
                auth_token: auth_token,
              )),
              (Route<dynamic> route) => false);

          break;

        case 1:
          Navigator.pushAndRemoveUntil(
              context,
              ScaleRoute(page: MyLibraryPage()),
              (Route<dynamic> route) => false);

          break;
        case 2:
          Navigator.pushAndRemoveUntil(
              context,
              ScaleRoute(
                page: ProfilPage(
                  auth_token: auth_token,
                ),
              ),
              (Route<dynamic> route) => false);

          break;
        case 3:
          settingsModalSheet(context);

          break;
      }
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: "Ma librarie",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: "Mon profil",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Settings",
        )
      ],
      currentIndex: widget.index!,
      selectedItemColor: kPrimaryColor,
      onTap: _onItemTapped,
    );
  }
}
