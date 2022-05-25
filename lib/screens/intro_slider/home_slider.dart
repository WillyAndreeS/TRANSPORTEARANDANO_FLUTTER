import 'package:flutter/material.dart';
import 'package:transporte_arandanov2/constants.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HomeIntro extends StatefulWidget {
  const HomeIntro({Key? key}) : super(key: key);

  @override
  _HomeIntroState createState() => _HomeIntroState();
}

class _HomeIntroState extends State<HomeIntro> {
  final YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: "lZFSGuO6Jvs",
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ));
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text("Tutorial Transporte Arandano"),
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
            bottomActions: [ProgressBar(isExpanded: true)],
            showVideoProgressIndicator: true,
            progressIndicatorColor: kPrimaryColor),
      ),
    );
  }
}
