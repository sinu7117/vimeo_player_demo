library vimeoplayer;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:vimeo_player_demo/progress_bar.dart';

import 'Color.dart';
import 'full_screen_player.dart';
import 'quality_links.dart';

class VimeoPlayer extends StatefulWidget {
  final String id;
  final bool? autoPlay;
  final bool? looping;
  final int? position;

  VimeoPlayer({
    required this.id,
    this.autoPlay,
    this.looping,
    this.position,
    Key? key,
  }) : super(key: key);

  @override
  _VimeoPlayerState createState() =>
      _VimeoPlayerState(id, autoPlay, looping, position);
}

class _VimeoPlayerState extends State<VimeoPlayer> {
  String _id;
  bool? autoPlay = false;
  bool? looping = false;
  bool _overlay = true;
  bool fullScreen = false;
  int? position;

  _VimeoPlayerState(this._id, this.autoPlay, this.looping, this.position);

  //Custom controller
  VideoPlayerController? _controller;
  Future<void>? initFuture;

  //Quality Class
  late QualityLinks _quality;
  Map _qualityValues = {};
  var _qualityValue;

  bool _seek = false;

  double? videoHeight;
  double? videoWidth;
  late double videoMargin;

  double doubleTapRMargin = 36;
  double doubleTapRWidth = 400;
  double doubleTapRHeight = 160;
  double doubleTapLMargin = 10;
  double doubleTapLWidth = 400;
  double doubleTapLHeight = 160;

  @override
  void initState() {
    //Create class
    _quality = QualityLinks(_id);

    _quality.getQualitiesSync().then((value) {
      _qualityValues = value;
      _qualityValue = value[value.lastKey()];

      if (_controller != null && _controller!.value.isPlaying) {
        _controller!.pause();
      }

      _controller = VideoPlayerController.network(
        _qualityValue,
      );
      _controller!.setLooping(looping!);
      if (autoPlay!) _controller!.play();
      initFuture = _controller!.initialize();

      setState(() {
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
      });
    });

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        GestureDetector(
          child: FutureBuilder(
              future: initFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  double delta = MediaQuery.of(context).size.width -
                      MediaQuery.of(context).size.height *
                          _controller!.value.aspectRatio;

                  if (MediaQuery.of(context).orientation ==
                          Orientation.portrait ||
                      delta < 0) {
                    videoHeight = MediaQuery.of(context).size.width /
                        _controller!.value.aspectRatio;
                    videoWidth = MediaQuery.of(context).size.width;
                    videoMargin = 0;
                  } else {
                    videoHeight = MediaQuery.of(context).size.height;
                    videoWidth = videoHeight! * _controller!.value.aspectRatio;
                    videoMargin =
                        (MediaQuery.of(context).size.width - videoWidth!) / 2;
                  }

                  if (_seek && _controller!.value.duration.inSeconds > 2) {
                    _controller!.seekTo(Duration(seconds: position!));
                    _seek = false;
                  }

                  return Stack(
                    children: <Widget>[
                      Center(
                        child: Container(
                          height: videoHeight,
                          width: videoWidth,
                          margin: EdgeInsets.only(left: videoMargin),
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                      _videoOverlay(),
                    ],
                  );
                } else {
                  return const Center(
                      heightFactor: 6,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                      ));
                }
              }),
          onTap: () {
            setState(() {
              _overlay = !_overlay;
              if (_overlay) {
                doubleTapRHeight = videoHeight! - 36;
                doubleTapLHeight = videoHeight! - 10;
                doubleTapRMargin = 36;
                doubleTapLMargin = 10;
              } else if (!_overlay) {
                doubleTapRHeight = videoHeight! + 36;
                doubleTapLHeight = videoHeight! + 16;
                doubleTapRMargin = 0;
                doubleTapLMargin = 0;
              }
            });
          },
        ),
        GestureDetector(
            //======= Перемотка назад =======//
            child: Container(
              width: doubleTapLWidth / 2 - 30,
              height: doubleTapLHeight - 46,
              margin: EdgeInsets.fromLTRB(
                  0, 10, doubleTapLWidth / 2 + 30, doubleTapLMargin + 20),
              decoration: const BoxDecoration(
                  //color: Colors.red,
                  ),
            ),
            onTap: () {
              setState(() {
                _overlay = !_overlay;
                if (_overlay) {
                  doubleTapRHeight = videoHeight! - 36;
                  doubleTapLHeight = videoHeight! - 10;
                  doubleTapRMargin = 36;
                  doubleTapLMargin = 10;
                } else if (!_overlay) {
                  doubleTapRHeight = videoHeight! + 36;
                  doubleTapLHeight = videoHeight! + 16;
                  doubleTapRMargin = 0;
                  doubleTapLMargin = 0;
                }
              });
            },
            onDoubleTap: () {
              setState(() {
                _controller!.seekTo(Duration(
                    seconds: _controller!.value.position.inSeconds - 10));
              });
            }),
        GestureDetector(
            child: Container(
              //======= Перемотка вперед =======//
              width: doubleTapRWidth / 2 - 45,
              height: doubleTapRHeight - 60,
              margin: EdgeInsets.fromLTRB(doubleTapRWidth / 2 + 45,
                  doubleTapRMargin, 0, doubleTapRMargin + 20),
              decoration: const BoxDecoration(
                  //color: Colors.red,
                  ),
            ),
            onTap: () {
              setState(() {
                _overlay = !_overlay;
                if (_overlay) {
                  doubleTapRHeight = videoHeight! - 36;
                  doubleTapLHeight = videoHeight! - 10;
                  doubleTapRMargin = 36;
                  doubleTapLMargin = 10;
                } else if (!_overlay) {
                  doubleTapRHeight = videoHeight! + 36;
                  doubleTapLHeight = videoHeight! + 16;
                  doubleTapRMargin = 0;
                  doubleTapLMargin = 0;
                }
              });
            },
            onDoubleTap: () {
              setState(() {
                _controller!.seekTo(Duration(
                    seconds: _controller!.value.position.inSeconds + 10));
              });
            }),
      ],
    ));
  }

  //================================ Quality ================================//
  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          //Формирования списка качества
          final children = <Widget>[];
          _qualityValues.forEach((elem, value) => (children.add(ListTile(
              title: Text(' ${elem.toString()} fps'),
              onTap: () => {
                    //Обновление состояние приложения и перерисовка
                    setState(() {
                      _controller!.pause();
                      _qualityValue = value;
                      _controller =
                          VideoPlayerController.network(_qualityValue);
                      _controller!.setLooping(true);
                      _seek = true;
                      initFuture = _controller!.initialize();
                      _controller!.play();
                    }),
                  }))));
          //Вывод элементов качество списком
          return Wrap(
            children: children,
          );
        });
  }

  //================================ OVERLAY ================================//
  Widget _videoOverlay() {
    return _overlay
        ? Stack(
            children: <Widget>[
              GestureDetector(
                child: Center(
                  child: Container(
                    width: videoWidth,
                    height: videoHeight,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [Color(0x662F2C47), Color(0x662F2C47)],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: IconButton(
                    padding: EdgeInsets.only(
                        top: videoHeight! / 2 - 30,
                        bottom: videoHeight! / 2 - 30),
                    icon: _controller!.value.isPlaying
                        ? const Icon(
                            Icons.pause,
                            size: 60.0,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.play_arrow,
                            size: 60.0,
                            color: Colors.white,
                          ),
                    onPressed: () {
                      setState(() {
                        _controller!.value.isPlaying
                            ? _controller!.pause()
                            : _controller!.play();
                      });
                    }),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(
                      left: videoWidth! + videoMargin - 48,
                      bottom: videoHeight! - 70),
                  child: IconButton(
                      icon: const Icon(
                        Icons.settings,
                        size: 26.0,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        position = _controller!.value.position.inSeconds;
                        _seek = true;
                        _settingModalBottomSheet(context);
                        setState(() {});
                      }),
                ),
              ),
              Container(
                //===== Ползунок =====//
                margin: EdgeInsets.only(
                    top: videoHeight! - 45, left: videoMargin), //CHECK IT
                child: _videoOverlaySlider(),
              )
            ],
          )
        : Container(
            //===== Ползунок =====//
            margin: EdgeInsets.only(
                top: videoHeight! - 45, left: videoMargin), //CHECK IT
            child: _videoOverlaySlider(),
          );
  }

  //=================== ПОЛЗУНОК ===================//
  Widget _videoOverlaySlider() {
    return ValueListenableBuilder(
      valueListenable: _controller!,
      builder: (context, VideoPlayerValue value, child) {
        if (!value.hasError && value.isInitialized) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Expanded(
              //   child: Container(
              //     width: 46,
              //     alignment: const Alignment(0, 0),
              //     child: Text(
              //       '${value.position.inMinutes}:${value.position.inSeconds - value.position.inMinutes * 60} / ${value.duration.inMinutes}:${value.duration.inSeconds - value.duration.inMinutes * 60}',
              //       style: TextStyle(color: Colors.white),
              //     ),
              //   ),
              // ),
              Container(
                padding: EdgeInsets.only(bottom: 15, left: 10, top: 11),
                width: videoWidth! - 50,
                child: VideoProgressIndicator1(
                  _controller!,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: primary,
                    backgroundColor: const Color(0x5515162B),
                    bufferedColor: primary.withOpacity(0.5),
                  ),
                  padding:
                      const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 5.0),
                ),
              ),
              Center(
                child: Container(
                  // padding: EdgeInsets.only(
                  //     top: videoHeight! - 70,
                  //     left: videoWidth! + videoMargin - 50),
                  child: IconButton(
                      alignment: AlignmentDirectional.center,
                      icon: const Icon(
                        Icons.fullscreen,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        setState(() {
                          _controller!.pause();
                        });

                        position = await Navigator.push(
                            context,
                            PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (BuildContext context, _, __) =>
                                    FullscreenPlayer(
                                        id: _id,
                                        autoPlay: true,
                                        controller: _controller,
                                        position: _controller!
                                            .value.position.inSeconds,
                                        initFuture: initFuture,
                                        qualityValue: _qualityValue),
                                transitionsBuilder: (___,
                                    Animation<double> animation,
                                    ____,
                                    Widget child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                        scale: animation, child: child),
                                  );
                                }));
                        setState(() {
                          _controller!.play();
                          _seek = true;
                        });
                      }),
                ),
              ),
              // Container(
              //   width: 46,
              //   alignment: const Alignment(0, 0),
              //   child: Text(
              //       '${value.duration.inMinutes}:${value.duration.inSeconds - value.duration.inMinutes * 60}',style: TextStyle(color: Colors.white),),
              // ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }
}

class _VideoScrubber extends StatefulWidget {
  const _VideoScrubber({
    required this.child,
    required this.controller,
  });

  final Widget child;
  final VideoPlayerController controller;

  @override
  _VideoScrubberState createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<_VideoScrubber> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject()! as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying &&
            controller.value.position != controller.value.duration) {
          controller.play();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}

/// Displays the play/buffering status of the video controlled by [controller].
///
/// If [allowScrubbing] is true, this widget will detect taps and drags and
/// seek the video accordingly.
///
/// [padding] allows to specify some extra padding around the progress indicator
/// that will also detect the gestures.
class VideoProgressIndicator1 extends StatefulWidget {
  /// Construct an instance that displays the play/buffering status of the video
  /// controlled by [controller].
  ///
  /// Defaults will be used for everything except [controller] if they're not
  /// provided. [allowScrubbing] defaults to false, and [padding] will default
  /// to `top: 5.0`.
  const VideoProgressIndicator1(
    this.controller, {
    Key? key,
    this.colors = const VideoProgressColors(),
    required this.allowScrubbing,
    this.padding = const EdgeInsets.only(top: 5.0),
  }) : super(key: key);

  /// The [VideoPlayerController] that actually associates a video with this
  /// widget.
  final VideoPlayerController controller;

  /// The default colors used throughout the indicator.
  ///
  /// See [VideoProgressColors] for default values.
  final VideoProgressColors colors;

  /// When true, the widget will detect touch input and try to seek the video
  /// accordingly. The widget ignores such input when false.
  ///
  /// Defaults to false.
  final bool allowScrubbing;

  /// This allows for visual padding around the progress indicator that can
  /// still detect gestures via [allowScrubbing].
  ///
  /// Defaults to `top: 5.0`.
  final EdgeInsets padding;

  @override
  State<VideoProgressIndicator1> createState() =>
      _VideoProgressIndicatorState();
}

class _VideoProgressIndicatorState extends State<VideoProgressIndicator1> {
  _VideoProgressIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  late VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  VideoProgressColors get colors => widget.colors;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.isInitialized) {
      final int duration = controller.value.duration.inSeconds;
      final int position = controller.value.position.inSeconds;

      int maxBuffering = 0;
      for (final DurationRange range in controller.value.buffered) {
        final int end = range.end.inSeconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }
      progressIndicator = Stack(
        children: [
          ProgressBar(
            progress: Duration(seconds: position),
            timeLabelTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            progressBarColor: Colors.red,
            buffered: Duration(seconds: maxBuffering),
            total: Duration(seconds: duration),
            onSeek: (Duration s) {
              controller.seekTo(s);
            },
            baseBarColor: Colors.white10,
            barHeight: 4,
            thumbRadius: 7,
            bufferedBarColor: Colors.grey,
            thumbColor: Colors.white,
          ),
        ],
      );
    } else {
      progressIndicator = ProgressBar(
        timeLabelTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        progressBarColor: Colors.redAccent,
        onSeek: (Duration s) {
          controller.seekTo(s);
        },
        baseBarColor: Colors.white10,
        barHeight: 2.5,
        thumbRadius: 8,
        bufferedBarColor: Colors.grey,
        thumbColor: Colors.white,
        total: Duration(seconds: 0),
        progress: Duration(seconds: 0),
      );
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );
    if (widget.allowScrubbing) {
      return _VideoScrubber(
        controller: controller,
        child: paddedProgressIndicator,
      );
    } else {
      return paddedProgressIndicator;
    }
  }
}
// library vimeoplayer;
//
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:video_player/video_player.dart';
//
// import 'Color.dart';
// import 'fullscreen_player.dart';
// import 'quality_links.dart';
//
// class VimeoPlayer extends StatefulWidget {
//   final String id;
//   final bool? autoPlay;
//   final bool? looping;
//   final int? position;
//
//   VimeoPlayer({
//     required this.id,
//     this.autoPlay,
//     this.looping,
//     this.position,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   _VimeoPlayerState createState() =>
//       _VimeoPlayerState(id, autoPlay, looping, position);
// }
//
// class _VimeoPlayerState extends State<VimeoPlayer> {
//   String _id;
//   bool? autoPlay = false;
//   bool? looping = false;
//   bool _overlay = true;
//   bool fullScreen = false;
//   int? position;
//
//   _VimeoPlayerState(this._id, this.autoPlay, this.looping, this.position);
//
//   //Custom controller
//   VideoPlayerController? _controller;
//   Future<void>? initFuture;
//
//   //Quality Class
//   late QualityLinks _quality;
//   late Map _qualityValues;
//   var _qualityValue;
//
//   bool _seek = false;
//
//   double? videoHeight;
//   double? videoWidth;
//   late double videoMargin;
//
//   double doubleTapRMargin = 36;
//   double doubleTapRWidth = 400;
//   double doubleTapRHeight = 160;
//   double doubleTapLMargin = 10;
//   double doubleTapLWidth = 400;
//   double doubleTapLHeight = 160;
//
//   @override
//   void initState() {
//     //Create class
//     _quality = QualityLinks(_id);
//
//     _quality.getQualitiesSync().then((value) {
//       _qualityValues = value;
//       _qualityValue = value[value.lastKey()];
//
//       if (_controller != null && _controller!.value.isPlaying)
//         _controller!.pause();
//
//       _controller = VideoPlayerController.network(_qualityValue);
//       _controller!.setLooping(looping!);
//       if (autoPlay!) _controller!.play();
//       initFuture = _controller!.initialize();
//
//       setState(() {
//         SystemChrome.setPreferredOrientations(
//             [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
//       });
//     });
//
//     SystemChrome.setPreferredOrientations(
//         [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
//     SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//         child: Stack(
//       alignment: AlignmentDirectional.center,
//       children: <Widget>[
//         GestureDetector(
//           child: FutureBuilder(
//               future: initFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   double delta = MediaQuery.of(context).size.width -
//                       MediaQuery.of(context).size.height *
//                           _controller!.value.aspectRatio;
//
//                   if (MediaQuery.of(context).orientation ==
//                           Orientation.portrait ||
//                       delta < 0) {
//                     videoHeight = MediaQuery.of(context).size.width /
//                         _controller!.value.aspectRatio;
//                     videoWidth = MediaQuery.of(context).size.width;
//                     videoMargin = 0;
//                   } else {
//                     videoHeight = MediaQuery.of(context).size.height;
//                     videoWidth = videoHeight! * _controller!.value.aspectRatio;
//                     videoMargin =
//                         (MediaQuery.of(context).size.width - videoWidth!) / 2;
//                   }
//
//                   if (_seek && _controller!.value.duration.inSeconds > 2) {
//                     _controller!.seekTo(Duration(seconds: position!));
//                     _seek = false;
//                   }
//
//                   return Stack(
//                     children: <Widget>[
//                       Center(
//                         child: Container(
//                           height: videoHeight,
//                           width: videoWidth,
//                           margin: EdgeInsets.only(left: videoMargin),
//                           child: VideoPlayer(_controller!),
//                         ),
//                       ),
//                       _videoOverlay(),
//                     ],
//                   );
//                 } else {
//                   return Center(
//                       heightFactor: 6,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 4,
//                         valueColor:
//                             AlwaysStoppedAnimation<Color>(primary),
//                       ));
//                 }
//               }),
//           onTap: () {
//             setState(() {
//               _overlay = !_overlay;
//               if (_overlay) {
//                 doubleTapRHeight = videoHeight! - 36;
//                 doubleTapLHeight = videoHeight! - 10;
//                 doubleTapRMargin = 36;
//                 doubleTapLMargin = 10;
//               } else if (!_overlay) {
//                 doubleTapRHeight = videoHeight! + 36;
//                 doubleTapLHeight = videoHeight! + 16;
//                 doubleTapRMargin = 0;
//                 doubleTapLMargin = 0;
//               }
//             });
//           },
//         ),
//         GestureDetector(
//             //======= Перемотка назад =======//
//             child: Container(
//               width: doubleTapLWidth / 2 - 30,
//               height: doubleTapLHeight - 46,
//               margin: EdgeInsets.fromLTRB(
//                   0, 10, doubleTapLWidth / 2 + 30, doubleTapLMargin + 20),
//               decoration: BoxDecoration(
//                   //color: Colors.red,
//                   ),
//             ),
//             onTap: () {
//               setState(() {
//                 _overlay = !_overlay;
//                 if (_overlay) {
//                   doubleTapRHeight = videoHeight! - 36;
//                   doubleTapLHeight = videoHeight! - 10;
//                   doubleTapRMargin = 36;
//                   doubleTapLMargin = 10;
//                 } else if (!_overlay) {
//                   doubleTapRHeight = videoHeight! + 36;
//                   doubleTapLHeight = videoHeight! + 16;
//                   doubleTapRMargin = 0;
//                   doubleTapLMargin = 0;
//                 }
//               });
//             },
//             onDoubleTap: () {
//               setState(() {
//                 _controller!.seekTo(Duration(
//                     seconds: _controller!.value.position.inSeconds - 10));
//               });
//             }),
//         GestureDetector(
//             child: Container(
//               //======= Перемотка вперед =======//
//               width: doubleTapRWidth / 2 - 45,
//               height: doubleTapRHeight - 60,
//               margin: EdgeInsets.fromLTRB(doubleTapRWidth / 2 + 45,
//                   doubleTapRMargin, 0, doubleTapRMargin + 20),
//               decoration: BoxDecoration(
//                   //color: Colors.red,
//                   ),
//             ),
//             onTap: () {
//               setState(() {
//                 _overlay = !_overlay;
//                 if (_overlay) {
//                   doubleTapRHeight = videoHeight! - 36;
//                   doubleTapLHeight = videoHeight! - 10;
//                   doubleTapRMargin = 36;
//                   doubleTapLMargin = 10;
//                 } else if (!_overlay) {
//                   doubleTapRHeight = videoHeight! + 36;
//                   doubleTapLHeight = videoHeight! + 16;
//                   doubleTapRMargin = 0;
//                   doubleTapLMargin = 0;
//                 }
//               });
//             },
//             onDoubleTap: () {
//               setState(() {
//                 _controller!.seekTo(Duration(
//                     seconds: _controller!.value.position.inSeconds + 10));
//               });
//             }),
//       ],
//     ));
//   }
//
//   //================================ Quality ================================//
//   void _settingModalBottomSheet(context) {
//     showModalBottomSheet(
//         context: context,
//         builder: (BuildContext bc) {
//           //Формирования списка качества
//           final children = <Widget>[];
//           _qualityValues.forEach((elem, value) => (children.add(new ListTile(
//               title: new Text(" ${elem.toString()} fps"),
//               onTap: () => {
//                     //Обновление состояние приложения и перерисовка
//                     setState(() {
//                       _controller!.pause();
//                       _qualityValue = value;
//                       _controller =
//                           VideoPlayerController.network(_qualityValue);
//                       _controller!.setLooping(true);
//                       _seek = true;
//                       initFuture = _controller!.initialize();
//                       _controller!.play();
//                     }),
//                   }))));
//           //Вывод элементов качество списком
//           return Container(
//             child: Wrap(
//               children: children,
//             ),
//           );
//         });
//   }
//
//   //================================ OVERLAY ================================//
//   Widget _videoOverlay() {
//     return _overlay
//         ? Stack(
//             children: <Widget>[
//               GestureDetector(
//                 child: Center(
//                   child: Container(
//                     width: videoWidth,
//                     height: videoHeight,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.centerRight,
//                         end: Alignment.centerLeft,
//                         colors: [
//                           const Color(0x662F2C47),
//                           const Color(0x662F2C47)
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Center(
//                 child: IconButton(
//                     padding: EdgeInsets.only(
//                         top: videoHeight! / 2 - 30,
//                         bottom: videoHeight! / 2 - 30),
//                     icon: _controller!.value.isPlaying
//                         ? Icon(Icons.pause, size: 60.0)
//                         : Icon(Icons.play_arrow, size: 60.0),
//                     onPressed: () {
//                       setState(() {
//                         _controller!.value.isPlaying
//                             ? _controller!.pause()
//                             : _controller!.play();
//                       });
//                     }),
//               ),
//               Center(
//                 child: Container(
//                   margin: EdgeInsets.only(
//                       top: videoHeight! - 70,
//                       left: videoWidth! + videoMargin - 50),
//                   child: IconButton(
//                       alignment: AlignmentDirectional.center,
//                       icon: Icon(Icons.fullscreen, size: 30.0),
//                       onPressed: () async {
//                         setState(() {
//                           _controller!.pause();
//                         });
//
//                         position = await Navigator.push(
//                             context,
//                             PageRouteBuilder(
//                                 opaque: false,
//                                 pageBuilder: (BuildContext context, _, __) =>
//                                     FullscreenPlayer(
//                                         id: _id,
//                                         autoPlay: true,
//                                         controller: _controller,
//                                         position: _controller!
//                                             .value.position.inSeconds,
//                                         initFuture: initFuture,
//                                         qualityValue: _qualityValue),
//                                 transitionsBuilder: (___,
//                                     Animation<double> animation,
//                                     ____,
//                                     Widget child) {
//                                   return FadeTransition(
//                                     opacity: animation,
//                                     child: ScaleTransition(
//                                         scale: animation, child: child),
//                                   );
//                                 }));
//                         setState(() {
//                           _controller!.play();
//                           _seek = true;
//                         });
//                       }),
//                 ),
//               ),
//               Center(
//                 child: Container(
//                   margin: EdgeInsets.only(
//                       left: videoWidth! + videoMargin - 48,
//                       bottom: videoHeight! - 70),
//                   child: IconButton(
//                       icon: Icon(Icons.settings, size: 26.0),
//                       onPressed: () {
//                         position = _controller!.value.position.inSeconds;
//                         _seek = true;
//                         _settingModalBottomSheet(context);
//                         setState(() {});
//                       }),
//                 ),
//               ),
//               Container(
//                 //===== Ползунок =====//
//                 margin: EdgeInsets.only(
//                     top: videoHeight! - 26, left: videoMargin), //CHECK IT
//                 child: _videoOverlaySlider(),
//               )
//             ],
//           )
//         : Center(
//             child: Container(
//               height: 5,
//               width: videoWidth,
//               margin: EdgeInsets.only(top: videoHeight! - 5),
//               child: VideoProgressIndicator(
//                 _controller!,
//                 allowScrubbing: true,
//                 colors: VideoProgressColors(
//                   playedColor: primary,
//                   backgroundColor: Color(0x5515162B),
//                   bufferedColor: primary.withOpacity(0.5),
//                 ),
//                 padding: EdgeInsets.only(top: 2),
//               ),
//             ),
//           );
//   }
//
//   //=================== ПОЛЗУНОК ===================//
//   Widget _videoOverlaySlider() {
//     return ValueListenableBuilder(
//       valueListenable: _controller!,
//       builder: (context, VideoPlayerValue value, child) {
//         if (!value.hasError && value.isInitialized) {
//           return Row(
//             children: <Widget>[
//               Container(
//                 width: 46,
//                 alignment: Alignment(0, 0),
//                 child: Text(value.position.inMinutes.toString() +
//                     ':' +
//                     (value.position.inSeconds - value.position.inMinutes * 60)
//                         .toString()),
//               ),
//               Container(
//                 height: 20,
//                 width: videoWidth! - 92,
//                 child: VideoProgressIndicator(
//                   _controller!,
//                   allowScrubbing: true,
//                   colors: VideoProgressColors(
//                     playedColor: primary,
//                     backgroundColor: Color(0x5515162B),
//                     bufferedColor: primary.withOpacity(0.5),
//                   ),
//                   padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
//                 ),
//               ),
//               Container(
//                 width: 46,
//                 alignment: Alignment(0, 0),
//                 child: Text(value.duration.inMinutes.toString() +
//                     ':' +
//                     (value.duration.inSeconds - value.duration.inMinutes * 60)
//                         .toString()),
//               ),
//             ],
//           );
//         } else {
//           return Container();
//         }
//       },
//     );
//   }
//
//   @override
//   void deactivate() {
//     if (_controller != null) _controller!.dispose();
//     super.deactivate();
//   }
//
//   @override
//   void dispose() {
//     if (_controller != null) _controller!.dispose();
//     super.dispose();
//   }
// }
