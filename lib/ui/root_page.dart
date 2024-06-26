import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:gestwash/constants.dart';
import 'package:gestwash/ui/screens/cart_page.dart';
import 'package:gestwash/ui/screens/favorite_page.dart';
import 'package:gestwash/ui/screens/home_page.dart';
import 'package:gestwash/ui/screens/profile_page.dart';
import 'package:page_transition/page_transition.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _bottomNavIndex = 0;

  List<Widget> pages = const[
    HomePage(),
    CartPage(),
    FavoritePage(),
    ProfilePage()
  ];

  List<IconData> iconList = const[
    Icons.home,
    Icons.add_business,
    Icons.favorite,
    Icons.person
  ];

  List<String> titleList = const[
    'Home',
    'Commande',
    'Mes Affaires',
    'Profil'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(titleList[_bottomNavIndex],
                style: TextStyle(
                  color: Constants.blackColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 24
                ),
            ),
            Icon(Icons.notifications, color: Constants.blackColor, size: 30.0,)
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
                child: const CartPage(),
                type: PageTransitionType.bottomToTop
            ),
          );
        },
        backgroundColor: Constants.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(Icons.add, size: 40.0, color: Colors.white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        splashColor: Constants.primaryColor,
        activeColor: Constants.primaryColor,
        inactiveColor: Colors.black.withOpacity(.5),
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: (index){
          setState(() {
            _bottomNavIndex = index;
          });
        },
      ),
    );
  }
}
