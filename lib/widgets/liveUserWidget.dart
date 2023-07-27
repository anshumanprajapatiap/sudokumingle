import 'package:flutter/material.dart';

class LiveUserWidget extends StatelessWidget {
  final Map<String, int> liveUserData;
  const LiveUserWidget({super.key, required this.liveUserData});

  @override
  Widget build(BuildContext context) {
    int total = liveUserData.values.reduce((sum, value) => sum + value)+1;
    return Container(
      width: MediaQuery.of(context).size.width*.7,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text(
              'Number of Live Users $total',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Easy: ${liveUserData['Easy']}',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13
                ),),
              Text('Medium: ${liveUserData['Medium']}',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13
                ),)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hard: ${liveUserData['Hard']}',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13
                ),),
              Text('Master: ${liveUserData['Master']}',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13
                ),)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grandmaster: ${liveUserData['Grandmaster']}',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13
                ),),
              Text('Do Not Try: ${liveUserData['Do Not Try']}',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13
                ),)
            ],
          )
        ],
      ),
    );
  }
}
