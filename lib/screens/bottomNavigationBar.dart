import 'package:flutter/material.dart';
import 'package:sudokumingle/screens/profileScreen.dart';

import '../main.dart';
import 'homeScreen.dart';


late _TabsScreenState tabstate;
class TabsScreen extends StatefulWidget {
  const TabsScreen({Key? key}) : super(key: key);

  @override
  State<TabsScreen> createState() {
    tabstate = _TabsScreenState();
    return tabstate;
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int currentIndexPage = 1;
  List pageItems = [
    HomeScreen(),
    HomeScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    //final provider = Provider.of<GoogleSignInProvider>(context, listen:false);
    return Scaffold(
      bottomNavigationBar: Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
          child: bottomNavigationBar(currentIndexPage, context)
      ),
      body: pageItems.elementAt(currentIndexPage),
    );
  }
}



Widget bottomNavigationBar(int index, BuildContext context) {
  double iconSize = 28;
  return CustomBottomBar(
    currentIndex: index,
    onTap: (i) => tabstate.setState(() => tabstate.currentIndexPage = i),
    margin: EdgeInsets.only(left: 30, right: 30),
    items: [

      /// Home
      CustomBottomBarItem(
        icon: Icon(Icons.bar_chart, size: iconSize,),
        selectedColor: Theme.of(context).primaryColor,
      ),

      /// Stats
      CustomBottomBarItem(
        icon: Icon(Icons.home, size: iconSize,),
        selectedColor: Theme.of(context).primaryColor,
      ),
      /// Split
      CustomBottomBarItem(
        icon: Icon(Icons.account_circle_outlined, size: iconSize,),
        selectedColor: Theme.of(context).primaryColor,
      ),
    ],
  );
}


class CustomBottomBar extends StatelessWidget {
  CustomBottomBar({
    Key? key,
    required this.items,
    this.backgroundColor,
    this.currentIndex = 0,
    this.onTap,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.selectedColorOpacity,
    this.itemShape = const StadiumBorder(),
    this.margin = const EdgeInsets.all(8),
    this.itemPadding = const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutQuint,
  }) : super(key: key);

  /// A list of tabs to display, ie `Home`, `Likes`, etc
  final List<CustomBottomBarItem> items;

  /// The tab to display.
  final int currentIndex;

  /// Returns the index of the tab that was tapped.
  final Function(int)? onTap;

  /// The background color of the bar.
  final Color? backgroundColor;

  /// The color of the icon and text when the item is selected.
  final Color? selectedItemColor;

  /// The color of the icon and text when the item is not selected.
  final Color? unselectedItemColor;

  /// The opacity of color of the touchable background when the item is selected.
  final double? selectedColorOpacity;

  /// The border shape of each item.
  final ShapeBorder itemShape;

  /// A convenience field for the margin surrounding the entire widget.
  final EdgeInsets margin;

  /// The padding of each item.
  final EdgeInsets itemPadding;

  /// The transition duration
  final Duration duration;

  /// The transition curve
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: backgroundColor ?? Colors.transparent,
      child: SafeArea(
        minimum: margin,
        child: Row(
          /// Using a different alignment when there are 2 items or less
          /// so it behaves the same as BottomNavigationBar.
          mainAxisAlignment: items.length <= 2
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.spaceBetween,
          children: [
            for (final item in items)
              TweenAnimationBuilder<double>(
                tween: Tween(
                  end: items.indexOf(item) == currentIndex ? 1.0 : 0.0,
                ),
                curve: curve,
                duration: duration,
                builder: (context, t, _) {
                  final _selectedColor = item.selectedColor ??
                      selectedItemColor ??
                      theme.primaryColor;

                  final _unselectedColor = item.unselectedColor ??
                      unselectedItemColor ??
                      theme.iconTheme.color;

                  return Material(
                    color: Color.lerp(
                        _selectedColor.withOpacity(0.0),
                        _selectedColor.withOpacity(selectedColorOpacity ?? 0.0),
                        t),
                    shape: itemShape,
                    child: InkWell(
                      onTap: () => onTap?.call(items.indexOf(item)),
                      customBorder: itemShape,
                      focusColor: _selectedColor.withOpacity(0.1),
                      highlightColor: _selectedColor.withOpacity(0.1),
                      splashColor: _selectedColor.withOpacity(0.1),
                      hoverColor: _selectedColor.withOpacity(0.1),
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: itemPadding.right * t,
                          left: itemPadding.left * t,
                          // top: itemPadding.top * t,
                          // bottom: itemPadding.bottom * t
                        ),
                        // (Directionality.of(context) == TextDirection.ltr
                        //     ? EdgeInsets.only(right: itemPadding.right * t, left: itemPadding.left * t)
                        //     : EdgeInsets.only(left: itemPadding.left * t)),
                        child: Row(
                            children: [
                              IconTheme(
                                data: IconThemeData(
                                  color: Color.lerp(
                                      _unselectedColor, _selectedColor, t),
                                  size: 24,
                                ),
                                child: items.indexOf(item) == currentIndex
                                    ? item.activeIcon ?? item.icon
                                    : item.icon,
                              ),
                            ]
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// A tab to display in a [CustomBottomBar]
class CustomBottomBarItem {
  /// An icon to display.
  final Widget icon;

  /// An icon to display when this tab bar is active.
  final Widget? activeIcon;

  /// Text to display, ie `Home`
  final Widget? title;

  /// A primary color to use for this tab.
  final Color? selectedColor;

  /// The color to display when this tab is not selected.
  final Color? unselectedColor;

  CustomBottomBarItem({
    required this.icon,
    this.title,
    this.selectedColor,
    this.unselectedColor,
    this.activeIcon,
  });
}
