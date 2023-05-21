import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:test_data/provider/ResidentProvider.dart';
import 'package:test_data/provider/UserProvider.dart';
import 'package:flutter/material.dart';
import '../MainFacilitySettings/UserPeopleManagementPage.dart';
import '../Supplementary/CustomWidget.dart';
import '/Supplementary/PageRouteWithAnimation.dart';
import '/Supplementary/ThemeColor.dart';
import 'package:http/http.dart' as http; //http 사용

import 'package:test_data/Backend.dart';
ThemeColor themeColor = ThemeColor();

class WriteCommentPage extends StatefulWidget {
  const WriteCommentPage({Key? key}) : super(key: key);


  @override
  State<WriteCommentPage> createState() => _WriteCommentPageState();
}

class _WriteCommentPageState extends State<WriteCommentPage> {
  final formKey = GlobalKey<FormState>();
  String _contents = '';

  // 서버에 한마디 업로드
  Future<void> addComment(userId, nhresidentid, facilityId) async {
    var url = Uri.parse(Backend.getUrl() + 'letters');
    var headers = {'Content-type': 'application/json'};
    var body = json.encode({
      "user_id": userId,
      "nhresident_id": nhresidentid,
      "facility_id": facilityId,
      "contents": _contents,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print("성공");
    } else {
      throw Exception();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer2<UserProvider, ResidentProvider> (
          builder: (context, userProvider, residentProvider, child){
            return customPage(
              title: '한마디 작성',
              onPressed: () async {
                print('한마디');
                if (checkClick.isRedundentClick(DateTime.now())) {
                  return;
                }

                if(this.formKey.currentState!.validate()) {
                  this.formKey.currentState!.save();
                  try {
                    await addComment(userProvider.uid, residentProvider.resident_id, residentProvider.facility_id);
                    Navigator.pop(context);
                  } catch(e) {
                    showToast('한마디 업로드 실패! 다시 시도해주세요');
                    // showDialog(
                    //     context: context,
                    //     barrierDismissible: false, // 바깥 영역 터치시 닫을지 여부
                    //     builder: (BuildContext context) {
                    //       return AlertDialog(
                    //         content: Text("한마디 업로드 실패! 다시 시도해주세요"),
                    //         insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
                    //         actions: [
                    //           TextButton(
                    //             child: const Text('확인'),
                    //             onPressed: () {
                    //               Navigator.of(context).pop();
                    //             },
                    //           ),
                    //         ],
                    //       );
                    //     }
                    // );
                  }
                }},
              body: commentWrite(),
              buttonName: '완료',
            );
          }
      ),
    );
  }

  Widget commentWrite(){
    String currentDate = DateTime.now().toString().substring(0, 10).replaceAll('-', '.');
    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          text('날짜'),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 8),
                child: Text(currentDate),
                ),
              ),
            ),
          SizedBox(height: 10,),
          text('한마디 작성'),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: createField(),
          ),
        ],
      ),
    );
  }
  Widget createField() {
    return Form(
      key: formKey,
      child: SizedBox(
        height: 300,
        child: TextFormField(
          validator: (value) {
            if(value!.isEmpty) { return '내용을 입력하세요'; }
            else { return null; }
          },
          maxLines: 100,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(width: 2, color: Colors.red),
            ),
          ),
          onSaved: (value) {
            _contents = value!;
          }
        ),
      ),
    );
  }

  //글자 출력
  Widget text(String text) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 8),
      child: Text('$text',
        style: TextStyle(fontWeight: FontWeight.bold),
        //textScaleFactor: 1.2,
      ),
    );
  }
}
