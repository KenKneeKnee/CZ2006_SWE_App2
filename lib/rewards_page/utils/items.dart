import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Item {
  final String image;
  final String label;
  final double point;
  final String description;

  Item(
      {required this.image,
      required this.label,
      required this.point,
      required this.description});
}

class ItemList extends StatelessWidget {
  const ItemList({Key? key, required this.label}) : super(key: key);
  final String label;
  @override
  Widget build(BuildContext context) {
    List<Item> items = [
      Item(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlJuFWkBGj7q3J9JXfFO9y2SVfpF9FQ2vCJg&usqp=CAU",
        label: "Get 1x 5kg dumbbells",
        description: "5kg dumbbells",
        point: 20,
      ),
      Item(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT8zsvVBbx488ALKEXIDnMwcC-J3B3SXcVWzQ&usqp=CAU",
        label: "Get 1x Shaker bottle",
        description: "Shaker bottle",
        point: 10,
      ),
      Item(
        image:
            "https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcQDb9y79RWeFw3xY76OuSOZ-SzJtv2-bCYUF2AGOqB9weofOlvrOosUJ6GCGtRNsF87uOAoN5-oaO98&usqp=CAc",
        label: "Get 1x whey protein",
        description: "Protein powder",
        point: 50,
      ),
    ];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 30),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(
                    label,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                // InkWell(
                //   onTap: () {},
                //   child: Text(
                //     "See all",
                //     style: Theme.of(context).textTheme.subtitle1!.copyWith(
                //         color: Theme.of(context).colorScheme.secondary),
                //   ),
                // )
              ],
            ),
          ),
          Container(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Item item = items[index];
                return buildItem(context, item, index);
              },
              itemCount: items.length,
            ),
          ),
        ],
      ),
    );
  }

  Container buildItem(BuildContext context, Item item, int index) {
    return Container(
      width: 240,
      margin: EdgeInsets.only(left: 12, right: 4),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            bottom: 20,
            child: Image.network(
              item.image,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 24,
            child: Card(
              margin: EdgeInsets.all(1),
              child: Container(
                height: 80,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.subtitle2,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.caption,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      NumberFormat("###,###,### P").format(item.point),
                      style: Theme.of(context).textTheme.subtitle2,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 8,
            child: Container(
              padding: EdgeInsets.all(0),
              height: 32,
              width: 72,
              child: FloatingActionButton.extended(
                heroTag: "$label-${item.label}-$index",
                elevation: 1,
                onPressed: () {},
                label: Text(
                  "Redeem",
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
