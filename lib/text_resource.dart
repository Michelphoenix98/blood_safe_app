import 'package:conditional_questions/conditional_questions.dart';

List<Question> questions() {
  return [
    Question(
      question: "This is a standard question",
      //isMandatory: true,
      validate: (field) {
        if (field.isEmpty) return "Field cannot be empty";
        return null;
      },
    ),
    PolarQuestion(
        question: "Have you made any donations in the past?",
        answers: ["Yes", "No"],
        isMandatory: true),
    PolarQuestion(
        question: "In the last 3 months have you had a vaccination?",
        answers: ["Yes", "No"]),
    PolarQuestion(
        question: "Have you ever taken medication for HIV?",
        answers: ["Yes", "No"]),
    NestedQuestion(
      question: "The series will depend on your answer",
      answers: ["Yes", "No"],
      children: {
        'Yes': [
          PolarQuestion(
              question: "Have you ever taken medication for H1n1?",
              answers: ["Yes", "No"]),
          PolarQuestion(
              question: "Have you ever taken medication for Rabies?",
              answers: ["Yes", "No"]),
          Question(
            question: "This is another standard question",
          ),
        ],
        'No': [
          NestedQuestion(question: "Why'd you say no?", answers: [
            "Yes",
            "No"
          ], children: {
            'Yes': [
              PolarQuestion(
                  question: "So you agree?",
                  answers: ["Yes", "No", "I prefer not to say"]),
            ],
            'No': [
              PolarQuestion(
                  question: "Why are we even having this convo?",
                  answers: ["Yes", "No"]),
            ]
          }),
        ],
      },
    )
  ];
}
