import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/logic/utility/enums.dart';
import 'package:lm_teams_app/services/auth_service.dart';

class AccountRecoveryState extends Equatable {
  const AccountRecoveryState(
      {this.code,
      this.email,
      this.index = 0,
      this.userID,
      this.status2 = SubmissionStatus.initial,
      this.status3 = SubmissionStatus.initial});
  final String? code;
  final String? email;
  final int index;
  final String? userID;
  final SubmissionStatus status2;
  final SubmissionStatus status3;

  Map<String, dynamic> toJson() => {'code': code, 'userID': userID};

  @override
  String toString() => "AccountRecoveryState: Code: $code, UserId: $userID";

  @override
  List<Object?> get props => [code, userID, index, status2, status3];

  AccountRecoveryState copyWith({
    String? code,
    String? email,
    int? index,
    String? userID,
    SubmissionStatus? status2,
    SubmissionStatus? status3,
  }) {
    return AccountRecoveryState(
      code: code ?? this.code,
      email: email ?? this.email,
      index: index ?? this.index,
      userID: userID ?? this.userID,
      status2: status2 ?? this.status2,
      status3: status3 ?? this.status3,
    );
  }
}

class AccountRecoveryCubit extends Cubit<AccountRecoveryState> {
  AccountRecoveryCubit() : super(const AccountRecoveryState());

  final AuthService auth = AuthService();

  submitRecoveryEmail(String email) async {
    emit(state.copyWith(email: email));
    auth.sendPasswordRecoveryOTP(email);
  }

  nextStep() {
    emit(state.copyWith(index: state.index + 1));
  }

  previousStep() {
    if (state.index > 0) {
      emit(state.copyWith(index: state.index - 1));
    }
  }

  Future<void> submitCode(String code) async {
    emit(state.copyWith(status2: SubmissionStatus.submissionInProgress, code: code));
    bool isValid = await auth.verifyPasswordRecoveryOTP(state.email ?? '', code);
    if (isValid) {
      emit(state.copyWith(status2: SubmissionStatus.submissionSuccesful));
    } else {
      emit(state.copyWith(status2: SubmissionStatus.submissionFailed));
    }
  }

  submitPassword(String password) async {
    emit(state.copyWith(status3: SubmissionStatus.submissionInProgress));
    var isSuccess = await auth.resetPassword(state.email ?? '', state.code ?? '', password);
    if (isSuccess) {
      emit(state.copyWith(status3: SubmissionStatus.submissionSuccesful));
    } else {
      emit(state.copyWith(status3: SubmissionStatus.submissionFailed));
    }
  }
}
