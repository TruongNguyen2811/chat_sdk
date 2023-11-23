import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/send_message_response.dart';
import '../../page/image_chat/image_chat_screen.dart';

class MessageImage extends StatelessWidget {
  const MessageImage({
    Key? key,
    required this.listImages,
    required this.data,
    required this.isLeft,
    this.local = false,
    this.loading = false,
  }) : super(key: key);
  final bool local;
  final bool loading;
  final List<String> listImages;
  final SendMessageResponse data;
  final bool isLeft;
  final String noImageAvailable =
      "https://www.esm.rochester.edu/uploads/NoPhotoAvailable.jpg";

  @override
  Widget build(BuildContext context) {
    print('-------------------');
    print(listImages);
    var key = UniqueKey().toString();
    return Align(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment:
              isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: List.generate(
            listImages.length,
            (index) {
              return GestureDetector(
                onTap: loading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImageChatScreen(
                              local: local,
                              id: key,
                              url: listImages[index],
                            ),
                          ),
                        );
                      },
                child: Stack(
                  children: [
                    Hero(
                      tag: key,
                      child: local
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                File(listImages[index]),
                                width: MediaQuery.of(context).size.width * 0.4,
                                fit: BoxFit.fill,
                              ),
                            )
                          : CachedNetworkImage(
                              placeholder: (context, url) => SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  height:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: Image.network(noImageAvailable,
                                      fit: BoxFit.cover)),
                              errorWidget: (context, url, error) => SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  height:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: Image.network(noImageAvailable,
                                      fit: BoxFit.cover)),
                              imageUrl: listImages[index],
                              imageBuilder: (context, imageProvider) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    listImages[index],
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    fit: BoxFit.fill,
                                  ),
                                );
                              },
                            ),
                    ),
                    Positioned(
                      right: isLeft ? 8 : null,
                      left: !isLeft ? 8 : null,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.5),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Text(
                          data.createdAtStr != null
                              ? DateFormat('HH:mm')
                                  .format(DateTime.parse(data.createdAtStr!))
                              : DateFormat('HH:mm').format(DateTime.now()),
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(139, 141, 140, 1)),
                        ),
                      ),
                    ),
                    if (loading)
                      Positioned(
                        right: 0,
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.5),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    if (loading)
                      Positioned(
                        right: 0,
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
