import 'dart:convert';

import 'package:best_flutter_ui_templates/api/api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'food_add_dialog.dart';
import 'package:http/http.dart' as http;


class FoodSearchDialog extends StatefulWidget {
  final VoidCallback onDirectAdd;
  final Function(String searchText) onSearch;
  final Function(List<dynamic> food) onFoodAdded; // 음식을 추가하는 콜백

  const FoodSearchDialog({
    Key? key,
    required this.onDirectAdd,
    required this.onSearch,
    required this.onFoodAdded,
  }) : super(key: key);

  @override
  _FoodSearchDialogState createState() => _FoodSearchDialogState();
}

class _FoodSearchDialogState extends State<FoodSearchDialog> {
  TextEditingController searchController = TextEditingController();
  List<List<dynamic>> searchResults = [];
  bool isLoading = false; // 로딩 상태 표시

  void searchFood(String text) async {
    setState(() {
      isLoading = true;
    });

    try {
      var res = await http.post(
        Uri.parse(API.searchFood),
        body: {'name': searchController.text},
      );
      if (res.statusCode == 200) {
        var resLoadD = jsonDecode(res.body);
        if (resLoadD['result'] == 'true') {
          setState(() {
            searchResults = (resLoadD['food_info'] as List).cast<List<dynamic>>();
          });
        }
      } else {
        print('Failed to load data');
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setState(() {
        isLoading = false; // 로딩 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: Color(0xFF759CE6),
        hintColor: Colors.grey,
        colorScheme: ColorScheme.light(primary: Color(0xFF759CE6)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF759CE6),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "음식 검색",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF759CE6),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "검색할 음식명 입력",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          if (searchController.text.isNotEmpty) {
                            searchFood(searchController.text);
                          }
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("닫기", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (searchResults.isEmpty)
              Center(child: Text("검색 결과가 없습니다."))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final food = searchResults[index];
                    return ListTile(
                      title: Text(food[1]),
                      subtitle: Text(
                          '칼로리: ${food[2]} Kcal | 탄수화물: ${food[3]}g | 단백질: ${food[4]}g | 지방: ${food[5]}g'),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          widget.onFoodAdded(food); // 음식 추가
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}