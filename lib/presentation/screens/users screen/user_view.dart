import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/presentation/screens/users%20screen/user_admin_edit.dart';
import 'package:lm_teams_app/presentation/screens/users%20screen/user_edit_form.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/cards.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/list_tiles.dart';
import '../../widgets/frames.dart';

class UserView extends StatefulWidget {
  const UserView({
    Key? key,
    required this.user,
    required this.currentUser,
  }) : super(key: key);

  final User user;
  final User currentUser;

  @override
  _UserViewState createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  @override
  Widget build(BuildContext context) {
    User user = widget.user;

    return AppFrame(
        title: "User Profile",
        content: Column(children: [
          Avatar(
              isCircle: true,
              size: Size(200.0.spMin, 200.0.spMin),
              borderWidth: 4.0.spMin,
              image: user.image,
              placeholder: Text(user.initials, style: TextStyle(fontSize: 50.0.spMin))),
          SizedBox(height: 20.0.spMin),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: Text(
              user.name,
              softWrap: true,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35.0.spMin,
                  color: Theme.of(context).colorScheme.onBackground),
              textAlign: TextAlign.center,
            ))
          ]),
          const DividerWithText(title: "C O N T A C T    D E T A I L S"),
          GenericCard(content: [
            GenericListTile(
              leading: Icon(
                Icons.call,
                color: Colors.green,
                size: 24.0.spMin,
              ),
              title: user.mobile == "" ? "XX-XXXX-XXXX" : user.mobile,
              subTitle: "Phone Number",
            ),
            GenericListTile(
                leading: Icon(
                  Icons.mail,
                  color: Colors.blue,
                  size: 24.0.spMin,
                ),
                title: user.email,
                subTitle: "Email Address")
          ])
        ]),
        actions: [
          Visibility(
            visible: widget.currentUser.id == user.id,
            child: IconButton(
                onPressed: () async {
                  if (widget.currentUser.id == user.id) {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => UserEditForm(user: user)));
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => UserAdminEditForm(user: user)));
                  }
                },
                icon: Icon(Icons.edit, size: 24.0.spMin)),
          )
        ]);
  }
}
