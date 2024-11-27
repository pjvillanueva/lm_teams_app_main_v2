import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/cubits/account_recovery_cubit.dart';
import 'package:lm_teams_app/presentation/screens/forgot%20password%20screen/change_password.dart';
import 'package:lm_teams_app/presentation/screens/forgot%20password%20screen/provide_code.dart';
import 'package:lm_teams_app/presentation/screens/forgot%20password%20screen/recovery_email_page.dart';

import '../../widgets/frames.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AccountRecoveryCubit(),
        child: BlocBuilder<AccountRecoveryCubit, AccountRecoveryState>(builder: (context, state) {
          return AppFrame(
              title: "Account Recovery",
              padding: 0.0,
              content: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(height: 600.0.spMin),
                  child: Stepper(
                      steps: [
                        Step(
                            isActive: state.index >= 0,
                            title: Text("Step 1", style: TextStyle(fontSize: 15.spMin)),
                            subtitle: Text("Recovery Email", style: TextStyle(fontSize: 11.spMin)),
                            content: const RecoveryEmailPage(),
                            state: state.index > 0 ? StepState.complete : StepState.indexed),
                        Step(
                            isActive: state.index >= 1,
                            title: Text("Step 2", style: TextStyle(fontSize: 15.spMin)),
                            subtitle: Text("Provide Code", style: TextStyle(fontSize: 11.spMin)),
                            content: const ProvideCode(),
                            state: state.index > 1 ? StepState.complete : StepState.indexed),
                        Step(
                            isActive: state.index == 2,
                            title: Text("Step 3", style: TextStyle(fontSize: 15.spMin)),
                            subtitle: Text("New Password", style: TextStyle(fontSize: 11.spMin)),
                            content: const ChangePassword())
                      ],
                      elevation: 0.0,
                      type: StepperType.horizontal,
                      currentStep: state.index,
                      controlsBuilder: (context, controls) {
                        return const Row();
                      })));
        }));
  }
}
