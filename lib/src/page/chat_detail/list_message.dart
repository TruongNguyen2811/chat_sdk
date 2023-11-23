import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:web_socket_channel/io.dart';

import '../../../cardoctor_chatapp.dart';
import '../../model/form_text.dart';
import '../../model/send_message_response.dart';
import '../../utils/utils.dart';
import '../../widget/receiver_card.dart';
import '../../widget/sender_card.dart';
import '../contains.dart';
import 'package:collection/collection.dart';

class ListMessage extends StatefulWidget {
  final List<Map<String, dynamic>> listMessage;
  final ChatAppCarDoctorUtilOption data;
  final Function(void) loadMoreHistory;
  final ScrollController? scrollController;
  final Color? receiverBackground;
  final Color? receiverTextColor;
  final LinearGradient? receiverLinear;
  final Color? senderBackground;
  final Color? senderTextColor;
  final LinearGradient? senderLinear;
  final List<Map<String, dynamic>> listMessageLoadMore;
  final ValueChanged<Map<String, dynamic>> userInRoomChat;

  ListMessage({
    Key? key,
    required this.listMessage,
    required this.data,
    required this.loadMoreHistory,
    this.scrollController,
    this.receiverBackground,
    this.senderBackground,
    this.receiverTextColor,
    this.senderTextColor,
    this.receiverLinear,
    this.senderLinear,
    required this.listMessageLoadMore,
    required this.userInRoomChat,
  }) : super(key: key);

  @override
  State<ListMessage> createState() => _ListMessageState();
}

class _ListMessageState extends State<ListMessage> {
  final ScrollController _defaultScrollController = ScrollController();

  ScrollController get _scrollController =>
      widget.scrollController ?? _defaultScrollController;

  Completer? _loadMoreCompleter;
  int index = 0;
  List<SendMessageResponse> listMessage = [];

  var _isVisible = false;
  late final IOWebSocketChannel channel;

  scrollToEnd() {
    final double end = _scrollController.position.minScrollExtent;
    _scrollController.animateTo(end,
        curve: Curves.easeIn, duration: const Duration(seconds: 1));
  }

  void scrollControllerListener() async {
    if (_loadMoreCompleter == null || _loadMoreCompleter!.isCompleted) {
      if (_scrollController.offset ==
          _scrollController.position.minScrollExtent) {
        if (_isVisible) {
          if (mounted) {
            setState(() {
              _isVisible = false;
            });
          }
        }
      } else {
        if (!_isVisible) {
          if (mounted) {
            setState(() {
              _isVisible = true;
            });
          }
        }
      }
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) {
        _loadMoreCompleter = Completer();

        widget.loadMoreHistory({});
        var listMessageOld = widget.listMessageLoadMore
            .map((map) => SendMessageResponse.fromMap(map))
            .toList();
        if (mounted) {
          setState(() {
            listMessage.addAll(listMessageOld);
          });
        }
        _loadMoreCompleter!.complete();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(scrollControllerListener);
    listMessage = widget.listMessage
        .map((map) => SendMessageResponse.fromMap(map))
        .toList();
    try {
      channel = IOWebSocketChannel.connect(
        Uri.parse('wss://' +
            widget.data.cluseterID +
            '.piesocket.com/v3/' +
            widget.data.groupName +
            '?api_key=' +
            widget.data.apiKey +
            '&notify_self=1'),
      );
      print('Connect socket');
      connectWebsocket();
    } catch (e) {
      print('Error when connect socket');
      print(e);
    }
  }

  connectWebsocket() {
    try {
      channel.stream.asBroadcastStream().listen(
            (message) {
              var x = json.decode(message);
              if (x['typing'] != null) {
              } else {
                var x = SendMessageResponse.fromMap(json.decode(message));
                if ((x.id == null && x.username == widget.data.userIDReal) ||
                    (x.username != widget.data.userIDReal && x.id != null)) {
                  listMessage.insert(0, x);
                } else {
                  for (int i = 0; i < listMessage.length; i++) {
                    if (listMessage[i].attachmentType == x.attachmentType) {
                      listMessage[i].id = x.id;
                      listMessage[i].createdAtStr = x.createdAtStr;
                    }
                  }
                }
                if (x.id != null) {
                  widget.userInRoomChat.call({
                    'groupName': x.groupName,
                    'username': x.username,
                    'messageId': x.id,
                  });
                }
              }
              if (mounted) setState(() {});
            },
            cancelOnError: true,
            onError: (error) {
              if (kDebugMode) {
                print('loi ket noi socket');
                print(error);
              }
            },
            onDone: () {},
          );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: listMessage.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          "Gửi tin nhắn đến chuyên gia của chúng tôi để tư vấn nhé!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kTextGreyDarkColors,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: listMessage.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        bool old = true;
                        if (index == listMessage.length - 1) {
                        } else {
                          if (Utils.formatMessageDateCheck(
                              listMessage[index].createdAtStr!,
                              listMessage[index + 1].createdAtStr!)) {
                            old = false;
                          } else {
                            old = true;
                          }
                        }
                        if (index > 0 &&
                            listMessage[index].username ==
                                widget.data.userIDReal &&
                            listMessage[index - 1].username ==
                                widget.data.userIDReal) {
                          List<FormFile> sampleFile = [];
                          List<FormItem> sample = [];
                          List<FormService> sampleServices = [];
                          List<String> images = [];
                          String urlVideo = '';
                          if (listMessage[index].type == 2) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.value!) {
                              sample.add(e);
                            }
                          } else if (listMessage[index].type == 5) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueImage!) {
                              images.add(e.image!);
                            }
                          } else if (listMessage[index].type == 6) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueFiles!) {
                              sampleFile.add(e);
                            }
                          } else if (listMessage[index].type == 7) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            urlVideo = x.urlVideo ?? '';
                          } else if (listMessage[index].type == 8) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueServices!) {
                              sampleServices.add(e);
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: SenderCard(
                              color: widget.receiverBackground ?? Colors.black,
                              listService: sampleServices,
                              senderBackground: widget.senderBackground,
                              senderLinear: widget.senderLinear,
                              senderTextColor: widget.senderTextColor,
                              listFiles: sampleFile,
                              data: listMessage[index],
                              listForm: sample,
                              listImages: images,
                              urlVideo: urlVideo,
                              old: old,
                              statusMessage: listMessage[index].id == null
                                  ? StatusMessage.sending
                                  : StatusMessage.send,
                              local: listMessage[index].groupId == null,
                            ),
                          );
                        }
                        if (index > 0 &&
                            listMessage[index].username ==
                                widget.data.userIDReal &&
                            listMessage[index - 1].username !=
                                widget.data.userIDReal) {
                          List<FormFile> sampleFile = [];
                          List<FormItem> sample = [];
                          List<FormService> sampleServices = [];
                          List<String> images = [];
                          String urlVideo = '';
                          if (listMessage[index].type == 2) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.value!) {
                              sample.add(e);
                            }
                          } else if (listMessage[index].type == 5) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueImage!) {
                              images.add(e.image!);
                            }
                          } else if (listMessage[index].type == 6) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueFiles!) {
                              sampleFile.add(e);
                            }
                          } else if (listMessage[index].type == 7) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            urlVideo = x.urlVideo ?? '';
                          } else if (listMessage[index].type == 8) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueServices!) {
                              sampleServices.add(e);
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: SenderCard(
                              color: widget.receiverBackground ?? Colors.black,
                              listService: sampleServices,
                              senderBackground: widget.senderBackground,
                              senderLinear: widget.senderLinear,
                              senderTextColor: widget.senderTextColor,
                              urlVideo: urlVideo,
                              listFiles: sampleFile,
                              data: listMessage[index],
                              listForm: sample,
                              listImages: images,
                              old: old,
                              statusMessage: listMessage[index].id == null
                                  ? StatusMessage.sending
                                  : StatusMessage.send,
                              local: listMessage[index].groupId == null,
                            ),
                          );
                        }
                        if (listMessage[index].username ==
                            widget.data.userIDReal) {
                          List<FormFile> sampleFile = [];
                          List<FormItem> sample = [];
                          List<FormService> sampleServices = [];
                          List<String> images = [];
                          String urlVideo = '';
                          if (listMessage[index].type == 2) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.value!) {
                              sample.add(e);
                            }
                          } else if (listMessage[index].type == 5) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueImage!) {
                              images.add(e.image!);
                            }
                          } else if (listMessage[index].type == 6) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueFiles!) {
                              sampleFile.add(e);
                            }
                          } else if (listMessage[index].type == 7) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            urlVideo = x.urlVideo ?? '';
                          } else if (listMessage[index].type == 8) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueServices!) {
                              sampleServices.add(e);
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: SenderCard(
                              newMessage: true,
                              color: widget.receiverBackground ?? Colors.black,
                              listService: sampleServices,
                              senderBackground: widget.senderBackground,
                              senderLinear: widget.senderLinear,
                              senderTextColor: widget.senderTextColor,
                              urlVideo: urlVideo,
                              listFiles: sampleFile,
                              data: listMessage[index],
                              listForm: sample,
                              listImages: images,
                              old: old,
                              statusMessage: listMessage[index].id == null
                                  ? StatusMessage.sending
                                  : StatusMessage.send,
                              local: listMessage[index].groupId == null,
                            ),
                          );
                        }
                        if (index > 0 &&
                            listMessage[index].username !=
                                widget.data.userIDReal &&
                            listMessage[index].username !=
                                listMessage[index - 1].username &&
                            listMessage[index - 1].username !=
                                widget.data.userIDReal) {
                          List<FormFile> sampleFile = [];
                          List<FormItem> sample = [];
                          List<FormService> sampleServices = [];
                          List<String> images = [];
                          String urlVideo = '';
                          if (listMessage[index].type == 2) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.value!) {
                              sample.add(e);
                            }
                          } else if (listMessage[index].type == 5) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueImage!) {
                              images.add(e.image!);
                            }
                          } else if (listMessage[index].type == 6) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueFiles!) {
                              sampleFile.add(e);
                            }
                          } else if (listMessage[index].type == 7) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            urlVideo = x.urlVideo ?? '';
                          } else if (listMessage[index].type == 8) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueServices!) {
                              sampleServices.add(e);
                            }
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: ReceiverCard(
                              color: widget.receiverBackground ?? Colors.black,
                              listService: sampleServices,
                              receiverBackground: widget.receiverBackground,
                              receiverLinear: widget.receiverLinear,
                              receiverTextColor: widget.receiverTextColor,
                              listFiles: sampleFile,
                              urlVideo: urlVideo,
                              onlyOnePerson: false,
                              listForm: sample,
                              data: listMessage[index],
                              listImages: images,
                              old: old,
                              seen: false,
                            ),
                          );
                        }
                        if (index > 0 &&
                            listMessage[index].username !=
                                widget.data.userIDReal &&
                            listMessage[index - 1].username !=
                                widget.data.userIDReal) {
                          List<FormFile> sampleFile = [];
                          List<FormItem> sample = [];
                          List<FormService> sampleServices = [];
                          List<String> images = [];
                          String urlVideo = '';
                          if (listMessage[index].type == 2) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.value!) {
                              sample.add(e);
                            }
                          } else if (listMessage[index].type == 5) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueImage!) {
                              images.add(e.image!);
                            }
                          } else if (listMessage[index].type == 6) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueFiles!) {
                              sampleFile.add(e);
                            }
                          } else if (listMessage[index].type == 7) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            urlVideo = x.urlVideo ?? '';
                          } else if (listMessage[index].type == 8) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueServices!) {
                              sampleServices.add(e);
                            }
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: ReceiverCard(
                              color: widget.receiverBackground ?? Colors.black,
                              listService: sampleServices,
                              receiverBackground: widget.receiverBackground,
                              receiverLinear: widget.receiverLinear,
                              receiverTextColor: widget.receiverTextColor,
                              urlVideo: urlVideo,
                              listFiles: sampleFile,
                              onlyOnePerson: true,
                              data: listMessage[index],
                              listForm: sample,
                              listImages: images,
                              old: old,
                              seen: false,
                            ),
                          );
                        }
                        if (index > 0 &&
                            listMessage[index].username !=
                                widget.data.userIDReal &&
                            listMessage[index - 1].username ==
                                widget.data.userIDReal) {
                          List<FormFile> sampleFile = [];
                          List<FormItem> sample = [];
                          List<FormService> sampleServices = [];
                          List<String> images = [];
                          String urlVideo = '';
                          if (listMessage[index].type == 2) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.value!) {
                              sample.add(e);
                            }
                          } else if (listMessage[index].type == 5) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueImage!) {
                              images.add(e.image!);
                            }
                          } else if (listMessage[index].type == 6) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueFiles!) {
                              sampleFile.add(e);
                            }
                          } else if (listMessage[index].type == 7) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            urlVideo = x.urlVideo ?? '';
                          } else if (listMessage[index].type == 8) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueServices!) {
                              sampleServices.add(e);
                            }
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: ReceiverCard(
                              color: widget.receiverBackground ?? Colors.black,
                              listService: sampleServices,
                              receiverBackground: widget.receiverBackground,
                              receiverLinear: widget.receiverLinear,
                              receiverTextColor: widget.receiverTextColor,
                              listFiles: sampleFile,
                              urlVideo: urlVideo,
                              onlyOnePerson: false,
                              listForm: sample,
                              data: listMessage[index],
                              listImages: images,
                              old: old,
                              seen: false,
                            ),
                          );
                        } else {
                          List<FormFile> sampleFile = [];
                          List<FormItem> sample = [];
                          List<FormService> sampleServices = [];
                          List<String> images = [];
                          String urlVideo = '';
                          if (listMessage[index].type == 2) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.value!) {
                              sample.add(e);
                            }
                          } else if (listMessage[index].type == 5) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueImage!) {
                              images.add(e.image!);
                            }
                          } else if (listMessage[index].type == 6) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueFiles!) {
                              sampleFile.add(e);
                            }
                          } else if (listMessage[index].type == 7) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            urlVideo = x.urlVideo ?? '';
                          } else if (listMessage[index].type == 8) {
                            var x = FormData.fromJson(json
                                .decode(listMessage[index].originalMessage!));
                            for (var e in x.valueServices!) {
                              sampleServices.add(e);
                            }
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: ReceiverCard(
                              color: widget.receiverBackground ?? Colors.black,
                              listService: sampleServices,
                              receiverBackground: widget.receiverBackground,
                              receiverLinear: widget.receiverLinear,
                              receiverTextColor: widget.receiverTextColor,
                              listFiles: sampleFile,
                              urlVideo: urlVideo,
                              onlyOnePerson: false,
                              listForm: sample,
                              data: listMessage[index],
                              listImages: images,
                              old: old,
                              seen: false,
                            ),
                          );
                        }
                      },
                    ),
            ),
          ),
          if (_isVisible)
            Positioned(
              right: 28,
              bottom: 28,
              child: GestureDetector(
                onTap: () {
                  scrollToEnd();
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.senderBackground ?? Color(0xFFFF8D4E),
                      gradient: widget.senderBackground != null
                          ? null
                          : widget.senderLinear != null
                              ? widget.senderLinear
                              : kLinearColor),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
