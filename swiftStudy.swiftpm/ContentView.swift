import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("퀴즈를 시작해보세요!")
                    .font(.largeTitle)
                    .padding()
                
                NavigationLink(destination: MatchingGameView()) {
                    Text("단어 맞추기 게임 시작")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: MultipleChoiceQuizView()) {
                    Text("다지선다 퀴즈 시작")
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("퀴즈 선택")
        }
    }
}
