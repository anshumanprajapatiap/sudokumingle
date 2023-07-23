import 'package:flutter/material.dart';

class LiveUserWidget extends StatelessWidget {
  final Map<String, int> liveUserData;
  const LiveUserWidget({super.key, required this.liveUserData});

  @override
  Widget build(BuildContext context) {
    int total = liveUserData.values.reduce((sum, value) => sum + value)+1;
    return Container(
      width: MediaQuery.of(context).size.width*.5,
      child: Column(
        children: [
          Text('Number of Live Users $total'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Easy: ${liveUserData['Easy']}'),
              Text('Medium: ${liveUserData['Medium']}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hard: ${liveUserData['Hard']}'),
              Text('Master: ${liveUserData['Master']}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grandmaster: ${liveUserData['Grandmaster']}'),
              Text('Do Not Try: ${liveUserData['Do Not Try']}')
            ],
          )
        ],
      ),
    );
  }
}
