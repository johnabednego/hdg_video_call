import "package:agora_rtc_engine/rtc_engine.dart";
import "package:flutter/material.dart";
import "package:agora_rtc_engine/rtc_local_view.dart" as RtcLocalView;
import "package:agora_rtc_engine/rtc_remote_view.dart" as RtcRemoteView;
import "package:hdg_final/homepage.dart";
class CallPage extends StatefulWidget {

  final String channelName;

  const CallPage({Key? key, required this.channelName}) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {

  late RtcEngine _engine;
  bool loading =false;
  String appId ="0d578ab265ce42b89bc6a17ed567aba4";
  List  _remoteUids=[];
  double xPosition=0;
  double yPosition=0;
  bool muted=false;


  void initSate(){
    super.initState();
    initializeAgora();
  }

  void dispose(){
    super.dispose();
    _engine.destroy();
  }

  Future<void> initializeAgora() async {
        setState(() {
          loading=true;
        });
        _engine= await RtcEngine.createWithContext(RtcEngineContext(appId));
        await _engine.enableVideo();
        await _engine.setChannelProfile(ChannelProfile.Communication);
        _engine.setEventHandler(RtcEngineEventHandler(
          joinChannelSuccess: (channel, uid, elapsed){
            print("Channel joined");
          },
          userJoined: (uid, elapsed){
            print("Userjoined: $uid");
            setState(() {
              _remoteUids.add(uid);
            });
        },
          userOffline: (uid, elapsed){
            print("Useroffline: $uid");
            setState(() {
              _remoteUids.remove(uid);
            });
          }
        ));
        await _engine.joinChannel(null, widget.channelName, null, 0).then((value){
          setState(() {
            loading=false;
          });
        });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:(loading)?const Center(
        child: CircularProgressIndicator(

        ),
      ): Stack(
        children:[
          Center(
            // child: renderRemoteView(context),
          ),
                  Positioned(
                      top: yPosition,
                      left: xPosition,
                      child: GestureDetector(
                          onPanUpdate: (tapInfo){
                            setState(() {
                              xPosition += tapInfo.delta.dx;
                              yPosition += tapInfo.delta.dy;
                            });
                          },
                       child: Container(
                            width: 100,
                            height: 130,
                            child: const RtcLocalView.SurfaceView(),
                       ),
                      )
                  ),
                _toolbar()
        ]
      )
    );
  }
  Widget renderRemoteView(context){
    if(_remoteUids.isNotEmpty){
      if(_remoteUids.length==1)
      {
        return RtcRemoteView.SurfaceView(uid: _remoteUids[0], channelId: widget.channelName,);
      }
      else if(_remoteUids.length==2){
        return Column(
          children: [
        RtcRemoteView.SurfaceView(uid: _remoteUids[0], channelId: widget.channelName,),
        RtcRemoteView.SurfaceView(uid: _remoteUids[1], channelId: widget.channelName,),
          ],
        );
      }
      else
        {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height:MediaQuery.of(context).size.height,
            child:GridView.builder(gridDelegate:
            const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent:200,
              childAspectRatio: 11/20,
              crossAxisSpacing: 5,
              mainAxisSpacing: 10
            ),
                itemCount: -_remoteUids.length,
                itemBuilder: (BuildContext context, index){
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RtcRemoteView.SurfaceView(uid:_remoteUids[index], channelId: widget.channelName,)
              );
            })
          );
        }
    }
    else{
      return const Text("Waiting for other user to join");
    }
  }
  Widget _toolbar(){
    return Container(
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(bottom: 30),
      child: Row(
        children: [
          RawMaterialButton(onPressed: (){
            _onToggleMute();
          },
          shape: const CircleBorder(),
            padding:const EdgeInsets.all(5),
            elevation: 2,
            fillColor: (muted)?Colors.blue:Colors.white,
            child: Icon(
                (muted)?Icons.mic_off:Icons.mic,
              color: (muted)?Colors.white:Colors.blue,
              size:40,
            ),
          ),

          RawMaterialButton(onPressed: (){
          _onCallEnd();
          },
            shape: const CircleBorder(),
            padding:const EdgeInsets.all(5),
            elevation: 2,
            fillColor: Colors.redAccent,
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size:40,
            ),
          ),

          RawMaterialButton(onPressed: (){
            _onSwitchCamera();
          },
            shape: const CircleBorder(),
            padding:const EdgeInsets.all(5),
            elevation: 2,
            fillColor: Colors.white,
            child: Icon(
             Icons.switch_camera,
              color: (muted)?Colors.white:Colors.blue,
              size:40,
            ),
          ),

        ],
      ),
    );
  }
  void _onToggleMute(){
    setState(() {
      muted=!muted;
    });
    _engine.muteLocalAudioStream(muted);
  }
  void _onCallEnd(){
    _engine.leaveChannel().then((value){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> const HomePage()));
    });
  }
  void _onSwitchCamera(){
    _engine.switchCamera();
  }
}
