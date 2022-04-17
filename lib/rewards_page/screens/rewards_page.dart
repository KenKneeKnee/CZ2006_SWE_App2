import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_app/rewards_page/utils/categories.dart';
import 'package:my_app/rewards_page/utils/coordinator_layout.dart';
import 'package:my_app/rewards_page/utils/header.dart';
import 'package:my_app/rewards_page/utils/items.dart';
import 'package:my_app/rewards_page/utils/summary_chart.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';

///Main rewards page UI, displays the items that can be redeemed
class Menu {
  final IconData icon;
  final String title;

  Menu(this.icon, this.title);
}

List<Menu> menus = [
  Menu(Icons.home, "Home"),
  Menu(Icons.card_giftcard, "Reward"),
];

class RewardsPage extends StatefulWidget {
  RewardsPage({Key? key}) : super(key: key);

  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final ScrollController scrollController = ScrollController();

  late double minHeight;
  late double maxHeight;
  late bool isLoading = false;
  late UserData user;
  UserDbManager userdb = UserDbManager();

  int maxValue = 1000;

  List<FlSpot> totalReceived = [FlSpot(1, 1), FlSpot(1, 1)];
  List<FlSpot> totalRedeem = [FlSpot(1, 1), FlSpot(1, 1)];

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userdb.collection
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get();
    user = UserData.fromSnapshot(doc);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    minHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
    maxHeight = 360;

    return isLoading
        ? CircularProgressIndicator()
        : AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Scaffold(
              body: Stack(
                children: <Widget>[
                  CoordinatorLayout(
                    snap: true,
                    scrollController: scrollController,
                    header: buildCollapseHeader(context),
                    body: buildMainContent(context),
                  ),
                ],
              ),
            ),
          );
  }

  Widget buildSearchBox() {
    double height = 48;
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(height / 2)),
      child: Container(
        height: height,
        padding: EdgeInsets.only(left: height / 2, right: height / 2 - 12),
        child: TextFormField(
          autofocus: false,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: 16, bottom: 14),
            hintText: "What are you looking for?",
            suffixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  SingleChildScrollView buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 16,
            ),
            CategoriesList(),
            //buildSearchBox(),
            SizedBox(
              height: 24,
            ),
            ItemList(label: "Rewards"),
            // ItemList(label: "Hot"),
          ],
        ),
      ),
    );
  }

  NumberFormat _numberFormat = NumberFormat("###,###,###");

  Card buildPointSummary(
      {required String title,
      required double value,
      required Color color,
      required Widget icon,
      required double rate}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 100,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: Theme.of(context).hintColor)),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: <Widget>[
                      Text(value.toStringAsFixed(0),
                          style: Theme.of(context).textTheme.headline4),
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        width: 1,
                        height: 12,
                        color: Theme.of(context).dividerColor,
                      ),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: <Widget>[
                          Icon(
                              rate > 0
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: rate > 0
                                  ? Colors.green.shade600
                                  : Colors.red.shade600,
                              size: 24),
                          Container(
                            margin: EdgeInsets.only(left: 20),
                            child: Text(_numberFormat.format(rate),
                                style: Theme.of(context).textTheme.caption),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double offset = 0;
  SliverCollapseHeader buildCollapseHeader(BuildContext context) {
    return SliverCollapseHeader(
      minHeight: minHeight + 100,
      maxHeight: maxHeight,
      builder: (context, offset) {
        this.offset = offset;
        return Stack(
          children: <Widget>[
            Positioned.fill(
              bottom: 50,
              child: buildHeader(context, offset),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: buildPointSummary(
                        title: "Total Points",
                        value: user.points * 1.0,
                        rate: totalReceived.last.y - totalRedeem.last.y,
                        color: Colors.green,
                        icon: Icon(Icons.arrow_upward),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget buildHeader(BuildContext context, double offset) {
    return IgnorePointer(
      ignoring: false,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/rewards.png"),
                fit: BoxFit.cover),
            gradient: LinearGradient(colors: [
              Colors.amber,
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColorDark,
            ]),
            borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16 * (1 - offset)))),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Container(
            height: maxHeight - 50,
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 0,
                  right: 0,
                  top: 24 * (1 - offset),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: false,
                    title: Container(
                      color: Colors.white10,
                      child: Text(
                        offset == 1 ? "Rewards Page" : "Hi " + user.username,
                        style: TextStyle(
                          fontSize: 18 + 16 * (1 - offset),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      // IconButton(
                      //   icon: Icon(Icons.notifications),
                      //   onPressed: () {
                      //     debugPrint("clicl");
                      //   },
                      // )
                    ],
                  ),
                ),
                Positioned(
                  top: kToolbarHeight + 90,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    child: Opacity(
                      opacity: 1 - offset,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double sum(List<FlSpot> data1) {
    return data1.fold(
      0,
      (previousValue, element) => previousValue + element.y,
    );
  }
}
