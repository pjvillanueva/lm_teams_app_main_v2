import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/presentation/screens/users%20screen/user_edit_form.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/cards.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/frames.dart';
import 'package:lm_teams_app/presentation/widgets/list_tiles.dart';
import 'package:lm_teams_app/presentation/widgets/under_maintenance.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(builder: (context, state) {
      if (state.user != User.empty) {
        return AppFrame(
            title: "My Profile",
            content: ListView(children: [
              Avatar(
                  isCircle: true,
                  size: Size(230.0.spMin, 230.0.spMin),
                  image: state.user.image,
                  borderWidth: 4.0.spMin,
                  placeholder: Text(state.user.initials, style: TextStyle(fontSize: 80.0.spMin))),
              SizedBox(height: 20.0.spMin),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Flexible(
                    child: Text(state.user.name,
                        softWrap: true,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 35.0.spMin,
                            color: Theme.of(context).colorScheme.onBackground),
                        textAlign: TextAlign.center))
              ]),
              const DividerWithText(title: "C O N T A C T    D E T A I L S"),
              GenericCard(content: [
                GenericListTile(
                    leading: const Icon(Icons.call, color: Colors.green),
                    title: state.user.mobile == "" ? "XX-XXXX-XXXX" : state.user.mobile,
                    subTitle: "Phone Number"),
                GenericListTile(
                    leading: const Icon(Icons.mail, color: Colors.blue),
                    title: state.user.email,
                    subTitle: "Email Address")
              ])
              // Visibility(
              //     visible: state.user!.teams != null &&
              //         state.user!.teams.length <= 0,
              //     child: Column(
              //       children: [
              //         DividerWithText(title: "T E A M S"),
              //         GenericCard(
              //             content: state.user!.teams != null
              //                 ? state.user!.teams!
              //                     .map((u) => GenericListTile(
              //                           leading: u.image != null
              //                               ? TeamAvatar(
              //                                   child: Image.network(
              //                                       u.image!.url,
              //                                       fit: BoxFit.cover,
              //                                       errorBuilder: (context,
              //                                               error,
              //                                               stackTrace) =>
              //                                           Center(
              //                                               child: Icon(
              //                                                   Icons.error,
              //                                                   color: Colors
              //                                                       .red))))
              //                               : TeamAvatar(
              //                                   child: Icon(Icons.group)),
              //                           title: u.name,
              //                           subTitle: "TEAM",
              //                           onTap: () {
              //                             print("View team");
              //                           },
              //                         ))
              //                     .toList()
              //                 : [])
              //       ],
              //     )),
            ]),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => UserEditForm(user: state.user)));
                  },
                  icon: const Icon(Icons.edit, color: Colors.white))
            ]);
      } else {
        return const UnderMaintenance();
      }
    });
  }
}
