import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/map/facil_map.dart';
import 'package:my_app/rewards_page/screens/rewards_page.dart';
import 'package:my_app/user_profile/screens/profile_page.dart';
import 'package:my_app/user_profile/screens/view_current_events_page.dart';

class Homepage extends StatefulWidget {
  Homepage({Key? key}) : super(key: key);
  User? user = FirebaseAuth.instance.currentUser;

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int pageIndex = 0;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _currentUser = widget.user!;
    final pages = [
      FacilitiesMap(),
      ProfilePage(user: _currentUser),

      RewardsPage(),
      ViewCurrentEventPage()
      //put page here
      //put another page here
    ];

    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          currentIndex: pageIndex,
          onTap: (index) => setState(() {
                pageIndex = index;
              }),
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                label: 'Map',
                backgroundColor: Colors.blue),
            const BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_outlined),
                label: 'Profile',
                backgroundColor: Colors.cyan),
            const BottomNavigationBarItem(
                icon: Icon(Icons.star_border_outlined),
                label: 'Rewards',
                backgroundColor: Colors.orange),
            const BottomNavigationBarItem(
                icon: Icon(Icons.sports_basketball),
                label: 'Current Events',
                backgroundColor: Colors.purple),
          ]),
    );
  }
}
