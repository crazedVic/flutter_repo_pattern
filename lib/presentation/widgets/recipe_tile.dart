import 'package:flutter/material.dart';

class RecipeTile extends StatelessWidget {
  const RecipeTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:48,
      height:48.0,
      child: ClipOval(
        child: Image.network("https://picsum.photos/250?image=55"),
      ),
    );
  }
}