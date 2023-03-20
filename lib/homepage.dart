import "package:flutter/material.dart";
import "package:hdg_final/collpage.dart";
import "package:permission_handler/permission_handler.dart";

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller:_controller ,
          ),
          SizedBox(height: 30,),
          InkWell(
            onTap: () async {
              await [Permission.camera, Permission.microphone].request().then((value){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CallPage(channelName: _controller.text.trim())));
              });
                 },
            child: Container(
              width: 100,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:Colors.blueAccent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text("Join Video Call", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),) ,
            ),
          )
        ],
      ),
    );
  }
}
