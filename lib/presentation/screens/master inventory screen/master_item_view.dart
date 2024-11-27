import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/cards.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/list_tiles.dart';

import '../../widgets/frames.dart';

class MasterItemView extends StatefulWidget {
  const MasterItemView({required this.item, Key? key}) : super(key: key);

  final InventoryItem item;
  @override
  _MasterItemViewState createState() => _MasterItemViewState();
}

class _MasterItemViewState extends State<MasterItemView> {
  @override
  Widget build(BuildContext context) {
    var item = widget.item;

    return AppFrame(
        title: "Item Details",
        content: ListView(children: [
          Avatar(
              image: item.image,
              size: Size(200.spMin, 230.spMin),
              borderWidth: 4.0.spMin,
              placeholder: Text(item.code, style: TextStyle(fontSize: 100.0.spMin))),
          SizedBox(height: 20.0.spMin),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: Text(item.name,
                    softWrap: true,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35.0,
                        color: Theme.of(context).colorScheme.onBackground),
                    textAlign: TextAlign.center))
          ]),
          const DividerWithText(title: "I T E M  D E T A I L S"),
          GenericCard(content: [
            GenericListTile(
                leading: const Icon(
                  Icons.attach_money,
                  color: Colors.green,
                ),
                title: "\$ ${item.cost}",
                subTitle: "Item Cost"),
            GenericListTile(
                leading: const Icon(Icons.text_fields, color: Colors.blue),
                title: item.code,
                subTitle: "Item Code"),
            Divider(thickness: 2.0.spMin),
            GenericListTile(
                leading: const Icon(Icons.sell, color: Colors.yellow),
                title: "Item Tag${item.tags.length > 1 ? "s" : ""}"),
            Wrap(
                runSpacing: 10.0,
                spacing: 5.0,
                children: item.tags
                    .map((item) => InputChip(
                          label: Text(item),
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          onPressed: () {},
                        ))
                    .toList())
          ])
        ]));
  }
}
