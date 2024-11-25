//
//  MultipleChoiceQuizView.swift
//  swiftStudy
//
//  Created by kimtaein on 11/23/24.
//

import SwiftUI

struct QuizQuestion {
    let question: String
    let options: [String]
    let correctAnswer: Int
}

struct MultipleChoiceQuizView: View {
    @State private var remainingQuestions: [QuizQuestion] = [
        QuizQuestion(question: "___는 노란색이고 너무 달콤한 과일이야.", options: ["바나나", "사과", "키위", "포도"], correctAnswer: 0),
        QuizQuestion(question: "빨간색 껍질의 과일을 고르시오", options: ["사과", "복숭아", "키위", "배"], correctAnswer: 0),
        QuizQuestion(question: "초록색 과육의 과일을 고르시오", options: ["사과", "배", "키위", "감"], correctAnswer: 2),
        QuizQuestion(question: "신 맛이 아주 강한 연노란색 과육의 과일을 고르시오", options: ["바나나", "레몬", "포도", "복숭아"], correctAnswer: 1)
    ].shuffled()
    
    @State private var currentQuestion: QuizQuestion?
    @State private var selectedAnswer: Int? = nil
    @State private var showResult = false
    @State private var score = 0
    
    var body: some View {
        VStack(spacing: 20) {
            if let question = currentQuestion {
                Text(question.question)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                
                ForEach(0..<question.options.count, id: \.self) { index in
                    Button(action: {
                        selectedAnswer = index
                        checkAnswer()
                    }) {
                        Text(question.options[index])
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedAnswer == index ? Color.yellow : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                
                if showResult {
                    Text(selectedAnswer == question.correctAnswer ? "정답입니다!" : "오답입니다.")
                        .font(.headline)
                        .foregroundColor(selectedAnswer == question.correctAnswer ? .green : .red)
                        .padding()
                }
            } else {
                Text("모든 문제를 완료했습니다!")
                    .font(.title)
                    .padding()
                
                Text("점수: \(score) / \(score + remainingQuestions.count)")
                    .font(.headline)
                    .padding()
                
                Button("다시 시작하기") {
                    resetQuiz()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            loadNextQuestion()
        }
    }
    
    private func checkAnswer() {
        guard let current = currentQuestion else { return }
        
        if selectedAnswer == current.correctAnswer {
            score += 1
            showResult = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                loadNextQuestion()
            }
        } else {
            showResult = true
        }
    }
    
    private func loadNextQuestion() {
        if !remainingQuestions.isEmpty {
            currentQuestion = remainingQuestions.removeFirst()
            selectedAnswer = nil
            showResult = false
        } else {
            currentQuestion = nil
        }
    }
    
    private func resetQuiz() {
        remainingQuestions = [
            QuizQuestion(question: "___는 노란색이고 너무 달콤한 과일이야.", options: ["바나나", "사과", "키위", "포도"], correctAnswer: 0),
            QuizQuestion(question: "빨간색 껍질의 과일을 고르시오", options: ["사과", "복숭아", "키위", "배"], correctAnswer: 0),
            QuizQuestion(question: "초록색 과육의 과일을 고르시오", options: ["사과", "배", "키위", "감"], correctAnswer: 2),
            QuizQuestion(question: "신 맛이 아주 강한 연노란색 과육의 과일을 고르시오", options: ["바나나", "레몬", "포도", "복숭아"], correctAnswer: 1)
        ].shuffled()
        score = 0
        loadNextQuestion()
    }
}
