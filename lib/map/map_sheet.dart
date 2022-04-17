import 'package:flutter/material.dart';
import 'package:my_app/create-event/create-event-form.dart';
import 'package:my_app/map/map_data.dart';
import 'package:my_app/map/map_widgets.dart';
import 'package:my_app/widgets/bouncing_button.dart';
import 'package:my_app/reviews/review_page.dart';

/// PopUp shown for a SportsFacility
/// 1. Displays the facility name, facility type, address description
/// 2. Displays a hovering image depending on the SportsFacility Type
/// 3. Includes buttons to view the calendar(including create event form) and review page for this SportsFacility
class MapMarkerInfoSheet extends StatelessWidget {
  MapMarkerInfoSheet({Key? key, required this.SportsFacil, required this.index})
      : super(key: key);
  final SportsFacility SportsFacil;
  final int index;
  late String placeId = index.toString();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MapMarkerInfoHeader(SportsFacil.placeName, SportsFacil.facilityType,
              SportsFacil.addressDesc, SportsFacil.hoverImgPath),
          Row(
            children: [
              ButtonIcon(
                bgColor: Color(0xffE96B46),
                borderColor: Color(0xffE96B46),
                buttonText: "View Reviews",
                textColor: Color(0xffffffff),
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewPage(
                        placeId: placeId,
                        sportsFacility: SportsFacil,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.star),
              ),
              ButtonIcon(
                  bgColor: Color(0xffE96B46),
                  borderColor: Color(0xffE96B46),
                  buttonText: "View Calendar",
                  textColor: Color(0xffffffff),
                  icon: Icon(Icons.timer),
                  onClick: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateEventForm(
                          placeId: placeId,
                          sportsFacility: SportsFacil,
                        ),
                      ),
                    );
                  }),
            ],
          )
        ],
      ),
    );
  }
}
