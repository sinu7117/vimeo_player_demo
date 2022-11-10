import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vimeo_player_demo/vimeo_player.dart';

class VimeoPlayerScreen extends StatefulWidget {
  const VimeoPlayerScreen({Key? key}) : super(key: key);

  @override
  State<VimeoPlayerScreen> createState() => _VimeoPlayerScreenState();
}

class _VimeoPlayerScreenState extends State<VimeoPlayerScreen> {
  String vId = '';
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 250,
                    child: VimeoPlayer(
                      id: '436374503',
                      autoPlay: true,
                      looping: true,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}
