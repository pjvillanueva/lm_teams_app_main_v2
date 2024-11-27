import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/logic/cubits/entry_page_cubit.dart';
import 'package:lm_teams_app/logic/cubits/inventory_item_grid_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/presentation/screens/user%20inventory%20screen/user_inventory_page.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/services/items_service.dart';
import '../../../logic/blocs/home_screen_bloc.dart';
import '../../../logic/blocs/user_bloc.dart';

class InventoryItemsGrid extends StatefulWidget {
  const InventoryItemsGrid({Key? key}) : super(key: key);

  @override
  State<InventoryItemsGrid> createState() => _InventoryItemsGridState();
}

class _InventoryItemsGridState extends State<InventoryItemsGrid> {
  bool isInitialBuild = true;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        isInitialBuild = false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    reFetchInventoryItems(isInitialBuild, context);

    return BlocBuilder<InventoryItemGridCubit, InventoryItemGridState>(builder: (context, state) {
      return Visibility(
          visible: state.items.isNotEmpty,
          child: GridView.builder(
              itemCount: state.items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: getCrossAxisCount(width),
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: 10.0.spMin,
                  mainAxisSpacing: 10.0.spMin),
              itemBuilder: (context, index) {
                return Avatar(
                    image: state.items[index].image,
                    size: Size(100.spMin, 200.spMin),
                    placeholder: Text(state.items[index].code),
                    onTapPicture: () {
                      BlocProvider.of<EntryPageCubit>(context).addToPickedItems(state.items[index]);
                    });
              }),
          replacement: Column(children: [
            Center(child: Image.asset('assets/logo/folder.png', width: 200.w, height: 200.h)),
            const Text('Inventory is empty.'),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (newContext) {
                    return BlocProvider.value(
                        value: BlocProvider.of<HomeScreenBloc>(context),
                        child: const UserInventoryPage());
                  }));
                },
                child: const Text('Set up my inventory', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: Theme.of(context).colorScheme.secondary))
          ]));
    });
  }
}

int getCrossAxisCount(double screenWidth) {
  if (screenWidth > 400) {
    var itemWidth = screenWidth / 100;
    return itemWidth.round();
  } else {
    return 4;
  }
}

void reFetchInventoryItems(bool isInitialBuild, BuildContext context) {
  if (isInitialBuild) return;

  final user = context.read<UserBloc>().state.user;
  final homeState = context.read<HomeScreenBloc>().state;

  context.read<InventoryItemGridCubit>().getInventoryItems(
      IReadItemContext(userId: user.id, teamId: homeState.team.id, eventId: homeState.event.id));
}
