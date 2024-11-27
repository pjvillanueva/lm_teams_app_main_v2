import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:lm_teams_app/presentation/screens/auth%20screens/invited_signup_form.dart';
import 'package:lm_teams_app/services/team_service.dart';

class DeepLinkService {
  StreamController<String> controllerData = StreamController<String>();
  late StreamSubscription<Map> streamSubscription;
  StreamController<String> controllerInitSession = StreamController<String>();
  StreamController<String> controllerUrl = StreamController<String>();
  final _teamService = TeamService();

  static final DeepLinkService _deepLinkService = DeepLinkService._internal();
  factory DeepLinkService() {
    return _deepLinkService;
  }

  DeepLinkService._internal();

  void init(BuildContext context) {
    try {
      listenDynamicLinks(context);
    } on Exception {
      print("Deep Link Error");
    }
  }

  void dispose() {
    controllerData.close();
    streamSubscription.cancel();
    controllerInitSession.close();
    controllerUrl.close();
  }

  void listenDynamicLinks(BuildContext context) async {
    streamSubscription = FlutterBranchSdk.listSession().listen((data) async {
      controllerData.sink.add((data.toString()));
      if (data['invitee_id'] != null) {
        String inviteeId = data['invitee_id'];
        var teamInvitee = await _teamService.getTeamInvitee(inviteeId);

        if (teamInvitee != null) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => InvitedSignupForm(invitee: teamInvitee)));
        }
      }
    }, onError: (error) {
      print(error);
    });
  }

  Future<String?> generateLink(BranchUniversalObject buo, BranchLinkProperties lp) async {
    BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      return response.result;
    } else {
      print("Error: ${response.errorCode} - ${response.errorMessage}");
      return null;
    }
  }
}
