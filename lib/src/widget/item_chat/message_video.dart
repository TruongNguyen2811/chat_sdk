import 'dart:io';

import 'package:cardoctor_chatapp/src/page/video_screen/video_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../model/send_message_response.dart';

class MessageVideo extends StatefulWidget {
  final String urlVideo;
  final bool isLeft;
  // final String thumbnailUrl;
  final SendMessageResponse data;
  final bool local;

  const MessageVideo({
    Key? key,
    required this.urlVideo,
    required this.isLeft,
    // required this.thumbnailUrl,
    required this.data,
    this.local = false,
  }) : super(key: key);

  @override
  State<MessageVideo> createState() => _MessageVideoState();
}

class _MessageVideoState extends State<MessageVideo> {
  String formattedDuration = '';
  String? _thumbnailUrl;

  void generateThumbnail() async {
    try {
      print('lam thumbnail moi2');
      print(widget.urlVideo);

      if (widget.urlVideo != null && widget.urlVideo != '') {
        if (widget.local!) {
          print('yyyyyyyyyy');
          print(widget.urlVideo);

          _thumbnailUrl = await VideoThumbnail.thumbnailFile(
            video: widget.urlVideo ?? '',
            thumbnailPath: (await getTemporaryDirectory()).path,
            imageFormat: ImageFormat.PNG,
          );
          print('yyyyyyyyyy');
          print(_thumbnailUrl);
        } else if (widget.urlVideo!.isNotEmpty) {
          _thumbnailUrl = await VideoThumbnail.thumbnailFile(
            video: Uri.parse(widget.urlVideo ?? '').toString(),
            thumbnailPath: (await getTemporaryDirectory()).path,
            imageFormat: ImageFormat.WEBP,
          );
          // if (mounted)
        }
        setState(() {});
        // if (mounted) setState(() {});
      }
    } catch (e) {
      print("Loi");
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    generateThumbnail();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.65,
          child: _thumbnailUrl != null
              ? AspectRatio(
                  aspectRatio: 16 / 9,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoScreen(
                            // id: key,
                            url: widget.urlVideo,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16),
                          ),
                          child: Center(
                            child: Image.file(
                              File(_thumbnailUrl ?? ''),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // if (!_videoController.value.isPlaying)
                        Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(131, 158, 158, 158),
                            borderRadius: BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                        ),
                        // if (!_videoController.value.isPlaying)
                        const Center(
                          child: Icon(
                            Icons.play_circle_outline_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        // if (!_videoController.value.isPlaying)
                        Positioned(
                          right: widget.isLeft ? 8 : null,
                          left: !widget.isLeft ? 8 : null,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 0.5),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            child: Text(
                              widget.data.createdAtStr != null
                                  ? DateFormat('HH:mm').format(
                                      DateTime.parse(widget.data.createdAtStr!))
                                  : DateFormat('HH:mm').format(DateTime.now()),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromRGBO(139, 141, 140, 1)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              // _videoController.value.isInitialized
              //     ?

              : const AspectRatio(
                  aspectRatio: 16 / 9,
                ),
        ),
      ),
    );
  }
}
