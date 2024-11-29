import 'package:flutter/material.dart';

class AddRecipe extends StatelessWidget {
  const AddRecipe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새로운 레시피 추가'),
      ),
      body: AddRecipeForm(),
    );
  }
}

class AddRecipeForm extends StatefulWidget {
  @override
  _AddRecipeFormState createState() => _AddRecipeFormState();
}

class _AddRecipeFormState extends State<AddRecipeForm> {
  final _formKey = GlobalKey<FormState>();
  String imagePath = '';
  String titleTxt = '';
  String subTxt = '';
  int calories = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: '이미지 경로'),
              onSaved: (value) {
                imagePath = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '제목'),
              onSaved: (value) {
                titleTxt = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '내용'),
              onSaved: (value) {
                subTxt = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '칼로리'),
              keyboardType: TextInputType.number,
              onSaved: (value) {
                calories = int.parse(value!);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  // 저장된 데이터를 처리
                  print('이미지 경로: $imagePath');
                  print('제목: $titleTxt');
                  print('내용: $subTxt');
                  print('칼로리: $calories');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('레시피가 저장되었습니다!')),
                  );
                }
              },
              child: Text('저장하기'),
            ),
          ],
        ),
      ),
    );
  }
}
