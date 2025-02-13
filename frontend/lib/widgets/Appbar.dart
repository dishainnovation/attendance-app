import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/login.dart';

import '../Utility.dart';

class Appbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  const Appbar(
      {super.key,
      required this.title,
      this.actions,
      this.leading,
      this.bottom});
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 2,
      shadowColor: Colors.black,
      backgroundColor: Colors.green[900],
      automaticallyImplyLeading: true,
      title: Row(
        children: [
          Image.asset(
            'assets/images/attendance.png',
            width: 30,
          ),
          SizedBox(width: 10),
          Text(title),
        ],
      ),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      centerTitle: false,
      iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
      leading: leading,
      shape: bottom != null
          ? null
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(80),
              ),
            ),
      actions: [
        InkWell(
          child: Image.asset('assets/images/logout.png', width: 30),
          onTap: () async {
            await logout().then((onValue) {
              if (onValue) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              }
            });
          },
        ),
        SizedBox(width: 20),
      ],
      bottom: bottom,
    );
  }
}
