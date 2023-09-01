import "package:flutter/material.dart";
import 'package:study_up/constants.dart';
import 'package:study_up/views/widgets/widget.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  var list = [];

  void initState() {
    super.initState();
    readNotifications().then((List<String> value) {
      setState(() {
        list = value.reversed.toList();
      });
    });
  }

  List<String> formatText(String text) {
    List<String> original = text.split('|');
    List<String> result = [];

    return [original[0], original[1], original[2], original[3]];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      child: Container(
        height: heightP(context, 1),
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: heightP(context, 0.05),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7)),
                  child: ClipRect(
                      child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        color: KSecondaryColor,
                      ),
                      Text("Retour")
                    ],
                  )),
                ),
              ),
              Text("")
            ],
          ),
          Container(
            height: heightP(context, 0.85),
            child: list.length == 0
                ? EmptyPage(
                    message: "Aucune notifications",
                    image: "empty_notification.png")
                : ListView.builder(
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, index) {
                      return NotificationItem(
                        title: formatText(list[index])[1],
                        amount: formatText(list[index])[3],
                        date: formatText(list[index])[2],
                        type: formatText(list[index])[0],
                        icon: Icons.book,
                      );
                    }),
          )
        ]),
      ),
    );
  }
}
