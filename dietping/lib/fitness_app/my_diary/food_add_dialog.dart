import 'package:flutter/material.dart';

class FoodAddDialog extends StatefulWidget {
  final Function(List<dynamic>) onFoodAdded;

  const FoodAddDialog({
    Key? key,
    required this.onFoodAdded,
  }) : super(key: key);

  @override
  _FoodAddDialogState createState() => _FoodAddDialogState();
}

class _FoodAddDialogState extends State<FoodAddDialog> {
  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController foodAmountController = TextEditingController();

  // 영양성분 컨트롤러
  final TextEditingController calorieController = TextEditingController();
  final TextEditingController carbohydrateController = TextEditingController();
  final TextEditingController sugarController = TextEditingController();
  final TextEditingController fatController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController sodiumController = TextEditingController();

  String unit = "g"; // 음식 양 단위

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55, // 다이얼로그 높이 설정 (화면의 90%)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Center(
              child: Text(
                "직접 추가",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF759CE6),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 음식 이름 입력
            _buildInputField(
              controller: foodNameController,
              label: "음식 이름 (필수)",
              hintText: "음식 이름 입력",
            ),

            // 음식 양 입력
            const SizedBox(height: 16),
            Text(
              "음식 양 (필수)",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: foodAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "0",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: unit,
                  items: ["g", "ml"]
                      .map((String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      unit = newValue!;
                    });
                  },
                ),
              ],
            ),

            // 영양성분 입력
            const SizedBox(height: 16),
            Text(
              "영양성분 (선택)",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: calorieController,
              label: "칼로리",
              hintText: "0 kcal",
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: carbohydrateController,
              label: "탄수화물",
              hintText: "0 g",
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: sugarController,
              label: "당",
              hintText: "0 g",
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: fatController,
              label: "지방",
              hintText: "0 g",
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: proteinController,
              label: "단백질",
              hintText: "0 g",
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: sodiumController,
              label: "나트륨",
              hintText: "0 mg",
            ),

            // 저장 버튼
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  print("음식 이름: ${foodNameController.text}");
                  print("음식 양: ${foodAmountController.text} $unit");
                  print("칼로리: ${calorieController.text} kcal");
                  print("탄수화물: ${carbohydrateController.text} g");
                  print("당: ${sugarController.text} g");
                  print("지방: ${fatController.text} g");
                  print("단백질: ${proteinController.text} g");
                  print("나트륨: ${sodiumController.text} mg");
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF759CE6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "저장하기",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Input Field
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }
}