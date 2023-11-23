import 'dart:convert';

import 'package:example/utils.dart';
import 'package:flutter/material.dart';
import 'package:cardoctor_chatapp/cardoctor_chatapp.dart';

import 'model/form_text.dart';
import 'model/send_message_request.dart';
import 'model/send_message_response.dart';
import 'navigation_utils.dart';
import 'package:web_socket_channel/io.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<String> list_image = [
  "https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230905132344096_vidma_recorder_04092023_145203.jpg",
  "https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230905132344096_vidma_recorder_04092023_145203.jpg",
  "https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230905132344096_vidma_recorder_04092023_145203.jpg",
  "https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230905132344096_vidma_recorder_04092023_145203.jpg",
  "https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230905132344096_vidma_recorder_04092023_145203.jpg",
  "https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230905132344096_vidma_recorder_04092023_145203.jpg",
  "https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230905132344096_vidma_recorder_04092023_145203.jpg",
  "https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230905132344096_vidma_recorder_04092023_145203.jpg",
];
List<FormFile> list_files = [
  FormFile(
      url:
          'https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230905132344096_vidma_recorder_04092023_145203.jpg',
      path:
          '/data/user/0/com.mfunctions.driver.dev/cache/file_picker//20230905132344096_vidma_recorder_04092023_145203.jpg'),
];

class _HomePageState extends State<HomePage> {
  late final IOWebSocketChannel channel;
  @override
  void initState() {
    super.initState();

    channel = IOWebSocketChannel.connect(
      Uri.parse(
          'wss://free.blr2.piesocket.com/v3/GR_1694157629801?api_key=yPH1ntAsHtn7CmJohZm3fpw7232PaPAWeyQyasnz&notify_self=1'),
    );
    print('Connect socket');
  }

  Future addMessage(dynamic message) async {
    try {
      channel.sink.add(json.encode(message));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // List<Map<String, dynamic>> listMessage = [];
    List<Map<String, dynamic>> listMessage = dataSend;

    ChatAppCarDoctorUtilOption data = ChatAppCarDoctorUtilOption(
        apiKey: 'yPH1ntAsHtn7CmJohZm3fpw7232PaPAWeyQyasnz',
        apiSecret: 'YBjSTOa65xpWIWYtpbTkLlhik0IBDDfW',
        cluseterID: 'free.blr2',
        getNotifySelf: '1',
        groupName: 'GR_1694157629801',
        userIDReal: 'Cardoctor1Driver');
    return SafeArea(
      child: ChatDetailScreen(
        errorGetFile: (p0) {
          if (p0['type'] == 'MAX_SEND_IMAGE_CHAT') {
            setState(() {
              Utils.showToast(
                context,
                p0['text'],
                type: ToastType.ERROR,
              );
            });
          } else if (p0['type'] == 'LIMIT_CHAT_IMAGES_IN_MB') {
            Utils.showToast(
              context,
              p0['text'],
              type: ToastType.ERROR,
            );
          }
        },
        pressCallAudio: () {},
        pressCallVideo: () {},
        pressPickVideo: (p0) {},
        color: Color(0xFF2E72BA),
        typingChat: Container(
          height: 28,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: RiveAnimation.asset(
                    'assets/animations/reply-ing.riv',
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            ],
          ),
        ),
        typing: (p0) {
          addMessage(p0);
        },
        listHistoryChat: ListMessage(
          senderTextColor: Colors.white,
          senderBackground: Color(0xFF2E72BA),
          listMessageLoadMore: [],
          data: data,
          loadMoreHistory: (p0) {
            if (mounted) {
              setState(() {
                listMessage.add(listMessage[2]);
              });
            }
          },
          listMessage: listMessage,
          userInRoomChat: (Map<String, dynamic> value) {},
        ),
        loadMoreHistory: (p0) async {},
        pressPickImage: (p0) async {},
        pressPickFiles: (p0) async {
          if (p0['list'].isNotEmpty) {
            final List<FormFile> list = [];
            for (int i = 0; i < p0['list'].length; i++) {
              list.add(
                FormFile(
                  url: list_files[i].url,
                  path: list_files[i].url,
                ),
              );
            }
            final i = FormData(key: 'form', valueFiles: list);
            addMessage(
              SendMessageRequest(
                type: 6,
                linkPreview: '',
                groupName: 'GR_1693357083059',
                attachmentType: 'file',
                username: 'Cardoctor1Driver',
                originalMessage: json.encode(i.toMap()),
              ),
            );
          }
        },
        nameTitle:
            '57bf11111 - Garage Ô Tô Hải Phương',
        data: data,
        press: (value) async {
          await Future.delayed(Duration(seconds: 4));
          addMessage(
            {
              "id": 123,
              "groupId": null,
              "userId": null,
              "profileName": "",
              "originalMessage": "${value['originalMessage']}",
              "filteredMessage": "bng",
              // "attachmentType": "${DateTime.now().millisecondsSinceEpoch}",
              "attachmentType": "${value['attachmentType']}",

              "attachment": null,
              "linkPreview": "",
              "username": 'Cardoctor1Driver',
              "groupName": 'GR_1694157629801',
              "type": null,
              "createdAtStr": DateTime.now().toString(),
              "updatedAtStr": DateTime.now().toString(),
              "createdAt": DateTime.now().toString(),
              "updatedAt": DateTime.now().toString()
            },
          );
        },
        
        dataRoom: data,
        idSender: 'Cardoctor1Driver',
        pressBack: () {
          NavigationUtils.popToFirst(context);
        },
      ),
    );
  }
}

var i = FormData(
  key: 'form',
  value: [
    FormItem(
      hintText: '',
      label: '',
      text: 'Thông tin yêu cầu',
      type: 'title',
    ),
    FormItem(
      hintText: 'Honda Civic: 82A-57329',
      label: 'Dòng xe',
      text: '',
      type: 'dropdown',
      drop: 'drop',
    ),
    FormItem(
      hintText: 'Honda',
      label: 'Loại xe',
      text: '',
      type: 'dropdown',
      drop: 'drop',
    ),
    FormItem(
        hintText: 'Số km đã chạy',
        label: 'Số km',
        text: '',
        type: 'dropdown',
        drop: 'image',
        value2: ''),
    FormItem(
      hintText: '',
      label: '',
      text: 'controllerDescription.text',
      type: 'textfield',
      // controllerDescription.text == '' || controllerDescription.text.isEmpty
      //     ? 'empty'
      //     : 'textfield',
    ),
  ],
);

var dataSend = [
  {
    "id": 735,
    "groupId": 41,
    "userId": 15,
    "profileName": "Car Doctor Expert",
    "originalMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":null,\"valueFiles\":null,\"valueServices\":[{\"title\":\"Kiểm tra xe và nhận tư vấn tại garage\",\"image\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230908174558929_vidma_recorder_26082023_103014.jpg\"},{\"title\":\"Kiểm tra xe và nhận tư vấn tại gaa xe và nhận tư vấn tại gaa xe và nhận tư vấn tại garage\",\"image\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230908174558929_vidma_recorder_26082023_103014.jpg\"},{\"title\":\"Kiểm tra xe và nhận tư vấn tại garage\",\"image\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230908174558929_vidma_recorder_26082023_103014.jpg\"}]}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"Th\u00f4ng tin y\u00eau c\u1ea7u\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"\",\"label\":\"D\u00f2ng xe\",\"hintText\":\"Honda Civic: 82A-57329\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Lo\u1ea1i xe\",\"hintText\":\"Honda\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"S\u1ed1 km\",\"hintText\":\"S\u1ed1 km \u0111\u00e3 ch\u1ea1y\",\"type\":\"dropdown\",\"drop\":\"image\",\"value2\":\"\"},{\"text\":\"controllerDescription.text\",\"label\":\"\",\"hintText\":\"\",\"type\":\"textfield\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "attachmentType": "image",
    "attachment": null,
    "linkPreview": "",
    "username": "Cardoctor1Driver",
    "groupName": "GR_1693357083059",
    "type": 8,
    "createdAtStr": "2023-09-08T17:45:59",
    "updatedAtStr": "2023-09-08T17:45:59",
    "createdAt": "2023-09-08T17:45:59",
    "updatedAt": "2023-09-08T17:45:59"
  },
  {
    "id": 735,
    "groupId": 41,
    "userId": 15,
    "profileName": "Car Doctor Expert",
    "originalMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"THONG TIN YEU CAU\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"\",\"label\":\"D\u00f2ng xe\",\"hintText\":\"Honda Civic: 82A-57329\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Lo\u1ea1i xe\",\"hintText\":\"Honda\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"S\u1ed1 km\",\"hintText\":\"S\u1ed1 km \u0111\u00e3 ch\u1ea1y\",\"type\":\"dropdown\",\"drop\":\"image\",\"value2\":\"\"},{\"text\":\"controllerDescription.text\",\"label\":\"\",\"hintText\":\"\",\"type\":\"textfield\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"Th\u00f4ng tin y\u00eau c\u1ea7u\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"\",\"label\":\"D\u00f2ng xe\",\"hintText\":\"Honda Civic: 82A-57329\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Lo\u1ea1i xe\",\"hintText\":\"Honda\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"S\u1ed1 km\",\"hintText\":\"S\u1ed1 km \u0111\u00e3 ch\u1ea1y\",\"type\":\"dropdown\",\"drop\":\"image\",\"value2\":\"\"},{\"text\":\"controllerDescription.text\",\"label\":\"\",\"hintText\":\"\",\"type\":\"textfield\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "attachmentType": "image",
    "attachment": null,
    "linkPreview": "",
    "username": "Cardoctor1Driver",
    "groupName": "GR_1693357083059",
    "type": 2,
    "createdAtStr": "2023-09-08T17:45:59",
    "updatedAtStr": "2023-09-08T17:45:59",
    "createdAt": "2023-09-08T17:45:59",
    "updatedAt": "2023-09-08T17:45:59"
  },
  {
    "id": 735,
    "groupId": 41,
    "userId": 15,
    "profileName": "Car Doctor Expert",
    "originalMessage":
        "{\"key\":\"form\",\"value\":[],\"valueImage\":[],\"valueFiles\":[],\"urlVideo\":\"https://upload.aggregatoricapaci.com/cardoctor-dev/2023/09/chat-data/testChat_746487000.mp4\"}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":null,\"valueFiles\":null,\"urlVideo\":\"https://upload.aggregatoricapaci.com/cardoctor-dev/2023/09/chat-data/testChat_746487000.mp4\"}",
    "attachmentType": "image",
    "attachment": null,
    "linkPreview": "",
    "username": "Cardoctor1Driv",
    "groupName": "GR_1693357083059",
    "type": 7,
    "createdAtStr": "2023-09-08T17:45:59",
    "updatedAtStr": "2023-09-08T17:45:59",
    "createdAt": "2023-09-08T17:45:59",
    "updatedAt": "2023-09-08T17:45:59"
  },
  {
    "id": 735,
    "groupId": 41,
    "userId": 15,
    "profileName": "Car Doctor Expert",
    "originalMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":[{\"image\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230908174558929_vidma_recorder_26082023_103014.jpg\"}],\"valueFiles\":null}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":[{\"image\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230908174558929_vidma_recorder_26082023_103014.jpg\"}],\"valueFiles\":null}",
    "attachmentType": "image",
    "attachment": null,
    "linkPreview": "",
    "username": "Cardoctor1Driver",
    "groupName": "GR_1693357083059",
    "type": 5,
    "createdAtStr": "2023-09-08T17:45:59",
    "updatedAtStr": "2023-09-08T17:45:59",
    "createdAt": "2023-09-08T17:45:59",
    "updatedAt": "2023-09-08T17:45:59"
  },
  {
    "id": 736,
    "groupId": 41,
    "userId": 16,
    "profileName": "[TVTĐ] Phạm  Khánh_0965778656",
    "originalMessage": "hjh",
    "filteredMessage": "hjh",
    "attachmentType": "",
    "attachment": null,
    "linkPreview": "",
    "username": "Cardoctor1Driver",
    "groupName": "GR_1693357083059",
    "type": null,
    "createdAtStr": "2023-09-08T17:46:16",
    "updatedAtStr": "2023-09-08T17:46:16",
    "createdAt": "2023-09-08T17:46:16",
    "updatedAt": "2023-09-08T17:46:16"
  },
  {
    "id": 735,
    "groupId": 41,
    "userId": 15,
    "profileName": "Car Doctor Expert",
    "originalMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":[],\"valueFiles\":[{\"url\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230924193044754_avatar.jpg\", \"path\":\"20230924193044754_avatar.jpg\"}]}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":[],\"valueFiles\":[{\"url\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230924193044754_avatar.jpg\", \"path\":\"20230924193044754_avatar.jpg\"}]}",
    "attachmentType": "image",
    "attachment": null,
    "linkPreview": "",
    "username": "Cardoctor1Drr",
    "groupName": "GR_1693357083059",
    "type": null,
    "createdAtStr": "2023-09-08T17:45:59",
    "updatedAtStr": "2023-09-08T17:45:59",
    "createdAt": "2023-09-08T17:45:59",
    "updatedAt": "2023-09-08T17:45:59"
  },
  {
    "id": 735,
    "groupId": 41,
    "userId": 15,
    "profileName": "Car Doctor Expert",
    "originalMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":[],\"valueFiles\":[{\"url\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230924193044754_avatar.jpg\", \"path\":\"20230924193044754_avatar.jpg\"}]}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":[],\"valueFiles\":[{\"url\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230924193044754_avatar.jpg\", \"path\":\"20230924193044754_avatar.jpg\"}]}",
    "attachmentType": "image",
    "attachment": null,
    "linkPreview": "",
    "username": "Cardoctor1Drr",
    "groupName": "GR_1693357083059",
    "type": null,
    "createdAtStr": "2023-09-08T17:45:59",
    "updatedAtStr": "2023-09-08T17:45:59",
    "createdAt": "2023-09-08T17:45:59",
    "updatedAt": "2023-09-08T17:45:59"
  },
  {
    "id": 735,
    "groupId": 41,
    "userId": 15,
    "profileName": "Car Doctor Expert",
    "originalMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":[],\"valueFiles\":[{\"url\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230924193044754_avatar.jpg\", \"path\":\"20230924193044754_avatar.jpg\"}]}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":[],\"valueFiles\":[{\"url\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230924193044754_avatar.jpg\", \"path\":\"20230924193044754_avatar.jpg\"}]}",
    "attachmentType": "image",
    "attachment": null,
    "linkPreview": "",
    "username": "Cardoctor1Drqr",
    "groupName": "GR_1693357083059",
    "type": null,
    "createdAtStr": "2023-09-08T17:45:59",
    "updatedAtStr": "2023-09-08T17:45:59",
    "createdAt": "2023-09-08T17:45:59",
    "updatedAt": "2023-09-08T17:45:59"
  },
  {
    "id": 735,
    "groupId": 41,
    "userId": 15,
    "profileName": "Car Doctor Expert",
    "originalMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":[],\"valueFiles\":[{\"url\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230924193044754_avatar.jpg\", \"path\":\"20230924193044754_avatar.jpg\"}]}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":[],\"valueFiles\":[{\"url\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230924193044754_avatar.jpg\", \"path\":\"20230924193044754_avatar.jpg\"}]}",
    "attachmentType": "image",
    "attachment": null,
    "linkPreview": "",
    "username": "Cardoctor1Drrq",
    "groupName": "GR_1693357083059",
    "type": null,
    "createdAtStr": "2023-09-08T17:45:59",
    "updatedAtStr": "2023-09-08T17:45:59",
    "createdAt": "2023-09-08T17:45:59",
    "updatedAt": "2023-09-08T17:45:59"
  },
  {
    "id": 735,
    "groupId": 41,
    "userId": 15,
    "profileName": "Car Doctor Expert",
    "originalMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":[],\"valueFiles\":[{\"url\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230924193044754_avatar.jpg\", \"path\":\"20230924193044754_avatar.jpg\"}]}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":[],\"valueFiles\":[{\"url\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230924193044754_avatar.jpg\", \"path\":\"20230924193044754_avatar.jpg\"}]}",
    "attachmentType": "image",
    "attachment": null,
    "linkPreview": "",
    "username": "Cardoctor1Drrq",
    "groupName": "GR_1693357083059",
    "type": null,
    "createdAtStr": "2023-09-08T17:45:59",
    "updatedAtStr": "2023-09-08T17:45:59",
    "createdAt": "2023-09-08T17:45:59",
    "updatedAt": "2023-09-08T17:45:59"
  },
  {
    "id": 735,
    "groupId": 41,
    "userId": 15,
    "profileName": "Car Doctor Expert",
    "originalMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":[],\"valueFiles\":[{\"url\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230924193044754_avatar.jpg\", \"path\":\"20230924193044754_avatar.jpg\"}]}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":[],\"valueFiles\":[{\"url\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230924193044754_avatar.jpg\", \"path\":\"20230924193044754_avatar.jpg\"}]}",
    "attachmentType": "image",
    "attachment": null,
    "linkPreview": "",
    "username": "Cardoctor1Driver",
    "groupName": "GR_1693357083059",
    "type": 6,
    "createdAtStr": "2023-09-08T17:45:59",
    "updatedAtStr": "2023-09-08T17:45:59",
    "createdAt": "2023-09-08T17:45:59",
    "updatedAt": "2023-09-08T17:45:59"
  },
  {
    "id": 734,
    "groupId": 41,
    "userId": 15,
    "profileName": "Car Doctor Expert",
    "originalMessage": "bshsh",
    "filteredMessage": "bshsh",
    "attachmentType": "",
    "attachment": null,
    "linkPreview": "",
    "username": "CarDoctor1EXPERT",
    "groupName": "GR_1694157629801",
    "type": null,
    "createdAtStr": "2023-09-08T17:45:49",
    "updatedAtStr": "2023-09-08T17:45:49",
    "createdAt": "2023-09-08T17:45:49",
    "updatedAt": "2023-09-08T17:45:49"
  },
  {
    "id": 733,
    "groupId": 41,
    "userId": 16,
    "profileName": "[TVTĐ] Phạm  Khánh_0965778656",
    "originalMessage": "bjdjd",
    "filteredMessage": "bjdjd",
    "attachmentType": "",
    "attachment": null,
    "linkPreview": "",
    "username": "CarDoctor60856DRIVER",
    "groupName": "GR_1694157629801",
    "type": null,
    "createdAtStr": "2023-09-08T17:44:44",
    "updatedAtStr": "2023-09-08T17:44:44",
    "createdAt": "2023-09-08T17:44:44",
    "updatedAt": "2023-09-08T17:44:44"
  },
  {
    "id": 732,
    "groupId": 41,
    "userId": 16,
    "profileName": "[TVTĐ] Phạm  Khánh_0965778656",
    "originalMessage": "Tôi cần tư vấn xe báo giá",
    "filteredMessage": "Tôi cần tư vấn xe báo giá",
    "attachmentType": "text",
    "attachment": null,
    "linkPreview": "",
    "username": "CarDoctor60856DRIVER",
    "groupName": "GR_1694157629801",
    "type": null,
    "createdAtStr": "2023-09-08T17:44:29",
    "updatedAtStr": "2023-09-08T17:44:29",
    "createdAt": "2023-09-08T17:44:29",
    "updatedAt": "2023-09-08T17:44:29"
  },
  {
    "id": 731,
    "groupId": 41,
    "userId": 16,
    "profileName": "[TVTĐ] Phạm  Khánh_0965778656",
    "originalMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"Thông tin yêu cầu\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"\",\"label\":\"Loại xe\",\"hintText\":\"Audi A3\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Năm sản xuất\",\"hintText\":\"2020-01-01\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Số km\",\"hintText\":\"Số km đã chạy\",\"type\":\"dropdown\",\"drop\":\"image\",\"value2\":\"6500\"},{\"text\":\"\",\"label\":\"Khu vực\",\"hintText\":\"Mễ Trì Hạ, Phường Mễ Trì, Quận Nam Từ Liêm, Thành phố Hà Nội\",\"type\":\"dropdown\",\"drop\":\"empty\",\"value2\":null},{\"text\":\"NHẬP THÊM MÔ TẢ\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"xnxb\",\"label\":\"\",\"hintText\":\"\",\"type\":\"textfield\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"Thông tin yêu cầu\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"\",\"label\":\"Loại xe\",\"hintText\":\"Audi A3\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Năm sản xuất\",\"hintText\":\"2020-01-01\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Số km\",\"hintText\":\"Số km đã chạy\",\"type\":\"dropdown\",\"drop\":\"image\",\"value2\":\"6500\"},{\"text\":\"\",\"label\":\"Khu vực\",\"hintText\":\"Mễ Trì Hạ, Phường Mễ Trì, Quận Nam Từ Liêm, Thành phố Hà Nội\",\"type\":\"dropdown\",\"drop\":\"empty\",\"value2\":null},{\"text\":\"NHẬP THÊM MÔ TẢ\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"xnxb\",\"label\":\"\",\"hintText\":\"\",\"type\":\"textfield\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "attachmentType": "text",
    "attachment": null,
    "linkPreview": "",
    "username": "CarDoctor60856DRIVER",
    "groupName": "GR_1694157629801",
    "type": 2,
    "createdAtStr": "2023-09-08T17:44:27",
    "updatedAtStr": "2023-09-08T17:44:27",
    "createdAt": "2023-09-08T17:44:27",
    "updatedAt": "2023-09-08T17:44:27"
  },
  {
    "id": 730,
    "groupId": 41,
    "userId": 16,
    "profileName": "[TVTĐ] Phạm  Khánh_0965778656",
    "originalMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"BÁO GIÁ GARAGE\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/CAP5591792750196685025.jpg\",\"label\":\"\",\"hintText\":\"\",\"type\":\"image\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"BÁO GIÁ GARAGE\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/CAP5591792750196685025.jpg\",\"label\":\"\",\"hintText\":\"\",\"type\":\"image\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "attachmentType": "image",
    "attachment": null,
    "linkPreview": "",
    "username": "CarDoctor60856DRIVER",
    "groupName": "GR_1694157629801",
    "type": 2,
    "createdAtStr": "2023-09-08T17:44:26",
    "updatedAtStr": "2023-09-08T17:44:26",
    "createdAt": "2023-09-08T17:44:26",
    "updatedAt": "2023-09-08T17:44:26"
  },
  {
    "id": 729,
    "groupId": 41,
    "userId": 14,
    "profileName": "[TVTĐ] NGUYỄN  THÀNH TRUNG_0901706555",
    "originalMessage": "Tôi cần tư vấn xe báo giá",
    "filteredMessage": "Tôi cần tư vấn xe báo giá",
    "attachmentType": "text",
    "attachment": null,
    "linkPreview": "",
    "username": "CarDoctor1DRIVER",
    "groupName": "GR_1694157629801",
    "type": null,
    "createdAtStr": "2023-09-08T15:51:36",
    "updatedAtStr": "2023-09-08T15:51:36",
    "createdAt": "2023-09-08T15:51:36",
    "updatedAt": "2023-09-08T15:51:36"
  },
  {
    "id": 728,
    "groupId": 41,
    "userId": 14,
    "profileName": "[TVTĐ] NGUYỄN  THÀNH TRUNG_0901706555",
    "originalMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"Thông tin yêu cầu\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"\",\"label\":\"Loại xe\",\"hintText\":\"Audi S5\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Năm sản xuất\",\"hintText\":\"2020-01-01\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Số km\",\"hintText\":\"Số km đã chạy\",\"type\":\"dropdown\",\"drop\":\"image\",\"value2\":\"6500\"},{\"text\":\"\",\"label\":\"Khu vực\",\"hintText\":\"Quận Ba Đình, Thành phố Hà Nội, Việt Nam\",\"type\":\"dropdown\",\"drop\":\"empty\",\"value2\":null},{\"text\":\"NHẬP THÊM MÔ TẢ\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"bzbsbdbdb\",\"label\":\"\",\"hintText\":\"\",\"type\":\"textfield\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"Thông tin yêu cầu\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"\",\"label\":\"Loại xe\",\"hintText\":\"Audi S5\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Năm sản xuất\",\"hintText\":\"2020-01-01\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Số km\",\"hintText\":\"Số km đã chạy\",\"type\":\"dropdown\",\"drop\":\"image\",\"value2\":\"6500\"},{\"text\":\"\",\"label\":\"Khu vực\",\"hintText\":\"Quận Ba Đình, Thành phố Hà Nội, Việt Nam\",\"type\":\"dropdown\",\"drop\":\"empty\",\"value2\":null},{\"text\":\"NHẬP THÊM MÔ TẢ\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"bzbsbdbdb\",\"label\":\"\",\"hintText\":\"\",\"type\":\"textfield\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "attachmentType": "text",
    "attachment": null,
    "linkPreview": "",
    "username": "CarDoctor1DRIVER",
    "groupName": "GR_1694157629801",
    "type": 2,
    "createdAtStr": "2023-09-08T15:51:35",
    "updatedAtStr": "2023-09-08T15:51:35",
    "createdAt": "2023-09-08T15:51:35",
    "updatedAt": "2023-09-08T15:51:35"
  },
  {
    "id": 727,
    "groupId": 41,
    "userId": 14,
    "profileName": "[TVTĐ] NGUYỄN  THÀNH TRUNG_0901706555",
    "originalMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"BÁO GIÁ GARAGE\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230908155132251_vidma_recorder_26082023_103014.jpg\",\"label\":\"\",\"hintText\":\"\",\"type\":\"image\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"BÁO GIÁ GARAGE\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/20230908155132251_vidma_recorder_26082023_103014.jpg\",\"label\":\"\",\"hintText\":\"\",\"type\":\"image\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "attachmentType": "image",
    "attachment": null,
    "linkPreview": "",
    "username": "CarDoctor1DRIVER",
    "groupName": "GR_1694157629801",
    "type": 2,
    "createdAtStr": "2023-09-08T15:51:33",
    "updatedAtStr": "2023-09-08T15:51:33",
    "createdAt": "2023-09-08T15:51:33",
    "updatedAt": "2023-09-08T15:51:33"
  },
  {
    "id": 719,
    "groupId": 41,
    "userId": 16,
    "profileName": "[TVTĐ] Phạm  Khánh_0965778656",
    "originalMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":null,\"valueFiles\":[{\"url\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/a.txt\",\"path\":\"/data/user/0/com.mfunctions.driver.dev/cache/file_picker/a.txt\"}]}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":null,\"valueImage\":null,\"valueFiles\":[{\"url\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/a.txt\",\"path\":\"/data/user/0/com.mfunctions.driver.dev/cache/file_picker/a.txt\"}]}",
    "attachmentType": "file",
    "attachment": null,
    "linkPreview": "",
    "username": "CarDoctor60856DRIVER",
    "groupName": "GR_1694157629801",
    "type": 6,
    "createdAtStr": "2023-09-08T15:41:09",
    "updatedAtStr": "2023-09-08T15:41:09",
    "createdAt": "2023-09-08T15:41:09",
    "updatedAt": "2023-09-08T15:41:09"
  },
  {
    "id": 717,
    "groupId": 41,
    "userId": 14,
    "profileName": "[TVTĐ] NGUYỄN  THÀNH TRUNG_0901706555",
    "originalMessage": "Tôi cần tư vấn xe báo giá",
    "filteredMessage": "Tôi cần tư vấn xe báo giá",
    "attachmentType": "text",
    "attachment": null,
    "linkPreview": "",
    "username": "CarDoctor1DRIVER",
    "groupName": "GR_1694157629801",
    "type": null,
    "createdAtStr": "2023-09-08T15:27:52",
    "updatedAtStr": "2023-09-08T15:27:52",
    "createdAt": "2023-09-08T15:27:52",
    "updatedAt": "2023-09-08T15:27:52"
  },
  {
    "id": 716,
    "groupId": 41,
    "userId": 14,
    "profileName": "[TVTĐ] NGUYỄN  THÀNH TRUNG_0901706555",
    "originalMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"Thông tin yêu cầu\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"\",\"label\":\"Loại xe\",\"hintText\":\"Audi A1\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Năm sản xuất\",\"hintText\":\"2022-01-01\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Số km\",\"hintText\":\"Số km đã chạy\",\"type\":\"dropdown\",\"drop\":\"image\",\"value2\":\"6500\"},{\"text\":\"\",\"label\":\"Khu vực\",\"hintText\":\"Mễ Trì Hạ, Phường Mễ Trì, Quận Nam Từ Liêm, Thành phố Hà Nội\",\"type\":\"dropdown\",\"drop\":\"empty\",\"value2\":null},{\"text\":\"NHẬP THÊM MÔ TẢ\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"vgg\",\"label\":\"\",\"hintText\":\"\",\"type\":\"textfield\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"Thông tin yêu cầu\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"\",\"label\":\"Loại xe\",\"hintText\":\"Audi A1\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Năm sản xuất\",\"hintText\":\"2022-01-01\",\"type\":\"dropdown\",\"drop\":\"drop\",\"value2\":null},{\"text\":\"\",\"label\":\"Số km\",\"hintText\":\"Số km đã chạy\",\"type\":\"dropdown\",\"drop\":\"image\",\"value2\":\"6500\"},{\"text\":\"\",\"label\":\"Khu vực\",\"hintText\":\"Mễ Trì Hạ, Phường Mễ Trì, Quận Nam Từ Liêm, Thành phố Hà Nội\",\"type\":\"dropdown\",\"drop\":\"empty\",\"value2\":null},{\"text\":\"NHẬP THÊM MÔ TẢ\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"vgg\",\"label\":\"\",\"hintText\":\"\",\"type\":\"textfield\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "attachmentType": "text",
    "attachment": null,
    "linkPreview": "",
    "username": "CarDoctor1DRIVER",
    "groupName": "GR_1694157629801",
    "type": 2,
    "createdAtStr": "2023-09-08T15:27:50",
    "updatedAtStr": "2023-09-08T15:27:50",
    "createdAt": "2023-09-08T15:27:50",
    "updatedAt": "2023-09-08T15:27:50"
  },
  {
    "id": 715,
    "groupId": 41,
    "userId": 14,
    "profileName": "[TVTĐ] NGUYỄN  THÀNH TRUNG_0901706555",
    "originalMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"BÁO GIÁ GARAGE\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/CAP4325173084563498940.jpg\",\"label\":\"\",\"hintText\":\"\",\"type\":\"image\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "filteredMessage":
        "{\"key\":\"form\",\"value\":[{\"text\":\"BÁO GIÁ GARAGE\",\"label\":\"\",\"hintText\":\"\",\"type\":\"title\",\"drop\":null,\"value2\":null},{\"text\":\"https://stg-api.cardoctor.com.vn/chat-service/api/v1/files/2023/09/chat-data/CAP4325173084563498940.jpg\",\"label\":\"\",\"hintText\":\"\",\"type\":\"image\",\"drop\":null,\"value2\":null}],\"valueImage\":null,\"valueFiles\":null}",
    "attachmentType": "image",
    "attachment": null,
    "linkPreview": "",
    "username": "CarDoctor1DRIVER",
    "groupName": "GR_1694157629801",
    "type": 2,
    "createdAtStr": "2023-09-08T15:27:48",
    "updatedAtStr": "2023-09-08T15:27:48",
    "createdAt": "2023-09-08T15:27:48",
    "updatedAt": "2023-09-08T15:27:48"
  }
];
