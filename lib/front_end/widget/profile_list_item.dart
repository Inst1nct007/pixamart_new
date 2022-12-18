import 'package:flutter/material.dart';

class ProfileListItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final String page;

  const ProfileListItem({Key? key, required this.text, required this.icon, required this.page})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width / 24.5),
      child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, page);
          },
          style: ElevatedButton.styleFrom(
              primary: Colors.blueAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.all(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              SizedBox(
                width: MediaQuery.of(context).size.width / 24.5,
              ),
              Text(text,style: const TextStyle(fontFamily:'Nexa',fontWeight: FontWeight.bold,),),
            ],
          )),
    );
  }
}