import 'package:flutter/material.dart';

class FriendsActionWidget extends StatelessWidget {
  FriendsActionWidget();

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        FloatingActionButton.extended(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) =>
                    _buildRequestDialog(context));
          },
          label: const Text('Add Friend'),
          backgroundColor: Colors.green,
        ),
        const Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0)),
        FloatingActionButton.extended(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => _buildReportDialog(context));
          },
          label: const Text('Report'),
          backgroundColor: Colors.red,
        )
      ]);
  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );
  Widget _buildReportDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('This wanker has been reported'),
      backgroundColor: Colors.orange,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
              "We will review your report. Thank you for making the community safe"),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildRequestDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.orange,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text("Friend request sent to this monkey"),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
