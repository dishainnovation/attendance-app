import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/login.dart';

import '../Utils/userInfo.dart';

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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      title: Text(title),
      centerTitle: false,
      leading: leading,
      shape: bottom != null
          ? null
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(80),
              ),
            ),
      actions: !kDebugMode
          ? []
          : [
              InkWell(
                child: Image.asset('assets/images/logout.png', height: 30),
                onTap: () async {
                  await UserInfo.logout().then((onValue) {
                    if (onValue) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    }
                  });
                },
              ),
              const SizedBox(width: 20),
            ],
      bottom: bottom,
    );
  }
}
