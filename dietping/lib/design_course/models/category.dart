class Category {
  Category({
    this.title = '',
    this.imagePath = '',
    this.lessonCount = 0,
    this.money = 0,
    this.rating = 0.0,
    this.code = '',
  });

  String title;
  int lessonCount;
  int money;
  double rating;
  String imagePath;
  String code;
/*
  static List<Category> categoryList = <Category>[
    Category(
      imagePath: 'assets/design_course/interFace1.png',
      title: 'User interface Design',
      lessonCount: 24,
      money: 25,
      rating: 4.3,
    ),
    Category(
      imagePath: 'assets/design_course/interFace2.png',
      title: 'User interface Design',
      lessonCount: 22,
      money: 18,
      rating: 4.6,
    ),
    Category(
      imagePath: 'assets/design_course/interFace1.png',
      title: 'User interface Design',
      lessonCount: 24,
      money: 25,
      rating: 4.3,
    ),
    Category(
      imagePath: 'assets/design_course/interFace2.png',
      title: 'User interface Design',
      lessonCount: 22,
      money: 18,
      rating: 4.6,
    ),
    Category(
      imagePath: 'assets/design_course/interFace2.png',
      title: 'User interface Design',
      lessonCount: 22,
      money: 18,
      rating: 4.3,
    ),
  ];
*/

 // static List<Category> popularCourseList = <Category>[
  static List<Category> popularCourseList = <Category>[
    Category(
      imagePath: 'assets/design_course/study.png',
      title: '수능점수 Up 특별 식단',
      lessonCount: 12,
      money: 25,
      rating: 4.8,
      code: '254001',
    ),
    Category(
      imagePath: 'assets/design_course/healthy.png',
      title: '美와 건강 다이어트 식단',
      lessonCount: 28,
      money: 208,
      rating: 4.9,
      code: '254002',
    ),
    Category(
      imagePath: 'assets/design_course/family.png',
      title: '행복한 가정을 위한 식단',
      lessonCount: 12,
      money: 25,
      rating: 4.8,
      code: '254003',
    ),
    Category(
      imagePath: 'assets/design_course/wow.png',
      title: '특별한 날 이벤트',
      lessonCount: 28,
      money: 208,
      rating: 4.9,
      code: '254004',
    ),
    Category(
      imagePath: 'assets/design_course/wow.png',
      title: '기분이 좋아지는 식단',
      lessonCount: 28,
      money: 208,
      rating: 4.8,
      code: '254005',
    ),
  ];
}
