import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/login.dart';

import '../Utility.dart';

class Appbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  const Appbar({super.key, required this.title, this.actions, this.leading});
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: CupertinoColors.activeBlue,
      automaticallyImplyLeading: true,
      title: Row(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 34,
          ),
          SizedBox(width: 10),
          Text(title),
        ],
      ),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      centerTitle: false,
      iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
      leading: leading,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(80),
        ),
      ),
      actions: [
        InkWell(
          child: Icon(Icons.logout),
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
    );
  }
}
