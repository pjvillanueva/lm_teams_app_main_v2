import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/logic/blocs/geolocation_bloc.dart';
import 'package:lm_teams_app/presentation/widgets/frames.dart';
import 'package:lm_teams_app/services/geolocation_service.dart';

class GeolocationLogs extends StatelessWidget {
  const GeolocationLogs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppFrame(
      title: 'Geolocation Logs',
      content: BlocBuilder<GeolocationBloc, GeolocationState>(
        builder: (context, state) {
          if (state.logs != null) {
            return ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: state.logs!.length,
                separatorBuilder: (context, index) => const Divider(height: 5),
                itemBuilder: (context, int index) {
                  BGStreamData log = state.logs![index];

                  return ListTile(
                    title: Text(log.eventType.name),
                    subtitle: Text(log.data.toString()),
                    tileColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.all(10.0),
                    leading: Text(index.toString()),
                  );
                });
          } else {
            return const Text('No geolocation logs');
          }
        },
      ),
    );
  }
}
