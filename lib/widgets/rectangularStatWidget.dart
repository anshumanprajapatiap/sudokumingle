import 'package:flutter/material.dart';

class RectangularStatWidget extends StatelessWidget {
  final String text;
  final String value;
  final IconData iconToUse;
  const RectangularStatWidget({super.key, required this.text, required this.value, required this.iconToUse});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width*0.8,
      // color: Theme.of(context).primaryColor.withAlpha(100),
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        color: Theme.of(context).primaryColor.withAlpha(50),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width*0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(iconToUse,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(height: 10,),
                Text(text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),)
              ],
            ),
          ),
          //
          Text(value,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),)
        ],
      ),
    );
  }
}
