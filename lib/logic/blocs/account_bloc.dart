import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import '../../data/models/account.dart';
import '../../presentation/dialogs/interaction_dialog.dart';
import '../../services/user_service.dart';

class AccountState extends Equatable {
  const AccountState({required this.account, required this.role});

  final Account account;
  final AccountRole role;

  @override
  List<Object> get props => [account, role];

  AccountState copyWith({Account? account, AccountRole? role}) {
    return AccountState(account: account ?? this.account, role: role ?? this.role);
  }

  AccountState.fromJson(Map<String, dynamic> json)
      : account = Account.fromJson(json['account']),
        role = stringToEnum<AccountRole>(AccountRole.values, json['role']);

  Map<String, dynamic>? toJson() => {
        'account': account,
        'role': role.name,
      };
}

//events

abstract class AccountEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SetAccount extends AccountEvent {
  SetAccount({required this.account});
  final Account account;
  @override
  List<Object> get props => [account];
}

class SetAccountRole extends AccountEvent {
  SetAccountRole({required this.role});
  final AccountRole role;
  @override
  List<Object> get props => [role];
}

//bloc
class AccountBloc extends HydratedBloc<AccountEvent, AccountState> {
  AccountBloc() : super(const AccountState(account: Account.empty, role: AccountRole.le)) {
    on<AccountEvent>(_onEvent);
  }

  final userService = UserService();

  Future<void> _onEvent(AccountEvent event, Emitter<AccountState> emit) async {
    if (event is SetAccount) {
      emit(state.copyWith(account: event.account));
    } else if (event is SetAccountRole) {
      emit(state.copyWith(role: event.role));
    }
  }

  @override
  Map<String, dynamic>? toJson(AccountState state) {
    return state.toJson();
  }

  @override
  AccountState? fromJson(Map<String, dynamic> json) {
    return AccountState.fromJson(json);
  }
}
