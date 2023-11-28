import 'package:calling_room/signaling.dart';
import 'package:calling_room/widget/custom_snackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  ValueNotifier<Signaling> signaling = ValueNotifier<Signaling>(Signaling());
  ValueNotifier<bool> mute = ValueNotifier<bool>(true);

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  TextEditingController textEditingController = TextEditingController();

  String? roomId;

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.value.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
    });
    signaling.notifyListeners();
    _localRenderer.notifyListeners();
    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calling Room - WebRTC",
            style: TextStyle(color: Colors.teal)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: ValueListenableBuilder(
            valueListenable: mute,
            builder: (context, muteValue, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                height: size.height * .9,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: !muteValue,
                              child: videoView(
                                  child: RTCVideoView(
                                _localRenderer,
                                mirror: true,
                                objectFit: RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                              )),
                            ),
                            const SizedBox(height: 10),
                            videoView(
                                child: RTCVideoView(
                              _remoteRenderer,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            ))
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Join Meeting : "),
                          Flexible(
                            child: TextFormField(
                              controller: textEditingController,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    ValueListenableBuilder<Signaling>(
                        valueListenable: signaling,
                        builder: (context, signalingValue, child) {
                          return Wrap(
                            spacing: 10,
                            children: [
                              ValueListenableBuilder<bool>(
                                  valueListenable: mute,
                                  builder: (context, muteValue, child) {
                                    return ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor: muteValue
                                              ? MaterialStateProperty.all<
                                                  Color>(Colors.grey)
                                              : MaterialStateProperty.all<
                                                  Color>(Colors.teal)),
                                      onPressed: () async {
                                        muteValue
                                            ? await signalingValue
                                                .openUserMedia(_localRenderer,
                                                    _remoteRenderer)
                                            : await signalingValue
                                                .hangUp(_localRenderer);
                                        mute.value = !mute.value;
                                        mute.notifyListeners();
                                        setState(() {});
                                      },
                                      child: FittedBox(
                                        child: Row(
                                          children: [
                                            Icon(muteValue
                                                ? Icons
                                                    .video_camera_front_outlined
                                                : Icons.video_camera_front),
                                            Icon(muteValue
                                                ? Icons.mic_off_outlined
                                                : Icons.mic)
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                              ElevatedButton(
                                onPressed: () async {
                                  roomId = await signalingValue
                                      .createRoom(_remoteRenderer);
                                  textEditingController.text = roomId!;
                                  signaling.notifyListeners();
                                },
                                child: const Text("Create Meeting"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Add roomId
                                  signaling.value
                                      .joinRoom(
                                    textEditingController.text.trim(),
                                    _remoteRenderer,
                                  )
                                      .then((value) {
                                    showSnackBar(
                                        title: signaling.value.toString());
                                  });
                                  signaling.notifyListeners();
                                },
                                child: const Text("Join room"),
                              ),
                            ],
                          );
                        }),
                    const SizedBox(height: 15),
                  ],
                ),
              );
            }),
      ),
    );
  }

  Widget videoView({required Widget child}) {
    return Expanded(
        child:
            ClipRRect(borderRadius: BorderRadius.circular(20), child: child));
  }
}
