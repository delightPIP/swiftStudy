import SwiftUI

struct MatchingGameView: View {
    @State private var cards: [WordCard] = []
    @State private var selectedCards: [WordCard] = []
    @State private var score = 0
    @State private var showResetAlert = false
    @State private var effects: [UUID: CardEffects] = [:]
    @State private var showConfetti = false
    @State private var isCheckingMatch = false

    let pairs: [(word: String, meaning: String)] = [
        ("peach", "복숭아"), ("apple", "사과"), ("fig", "무화과"), ("grape", "포도"),
        ("melon", "멜론"), ("banana", "바나나"), ("cherry", "체리"), ("lemon", "레몬"),
        ("strawberry", "딸기"), ("kiwi", "키위"), ("pineapple", "파인애플"), ("watermelon", "수박"),
        ("orange", "오렌지"), ("blueberry", "블루베리"), ("raspberry", "라즈베리"), ("blackberry", "블랙베리")
    ]

    var body: some View {
        NavigationStack {
            VStack {
                Text("점수: \(score)")
                    .font(.largeTitle)
                    .padding(.top, 20)
                Spacer()
                gameGrid
                Spacer()
                resetButton
            }
            .padding()
            .navigationTitle("단어 맞추기")
            .alert(isPresented: $showResetAlert) {
                resetAlert
            }
            .onAppear {
                initializeCards()
            }
        }
    }

    var gameGrid: some View {
        GeometryReader { geometry in
            let gridSize = min(geometry.size.width, geometry.size.height) * 0.8
            let cardSize = gridSize / 4 - 10
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(cardSize), spacing: 10), count: 4),
                spacing: 10
            ) {
                ForEach(cards) { card in
                    WordCardView(
                        card: card,
                        effects: effects[card.id] ?? .init(),
                        action: { selectCard(card) },
                        cardSize: CGSize(width: cardSize, height: cardSize * 1.2)
                    )
                }
            }
            .frame(width: gridSize, height: gridSize, alignment: .center)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }

    var resetButton: some View {
        Button("RESET") {
            showResetAlert = true
        }
        .font(.headline)
        .padding()
        .background(Color.red)
        .foregroundColor(.white)
        .cornerRadius(10)
    }

    var resetAlert: Alert {
        Alert(
            title: Text("게임재시작"),
            message: Text("게임을 재시작하시겠습니까?"),
            primaryButton: .destructive(Text("리셋")) { resetGame() },
            secondaryButton: .cancel()
        )
    }

    func initializeCards() {
        let shuffledPairs = pairs.shuffled()
        let selectedPairs = shuffledPairs.prefix(8)
        
        cards = selectedPairs.flatMap { pair in
            [WordCard(text: pair.word, isWord: true),
             WordCard(text: pair.meaning, isWord: false)]
        }.shuffled()
    }

    func selectCard(_ card: WordCard) {
        guard !isCheckingMatch else { return }
        guard selectedCards.count < 2 else { return }
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard !cards[index].isSelected else { return }
        cards[index].isSelected = true
        selectedCards.append(cards[index])

        if selectedCards.count == 2 {
            checkMatch()
        }
    }

    func checkMatch() {
        isCheckingMatch = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let first = selectedCards[0]
            let second = selectedCards[1]

            if isMatchingPair(first: first, second: second) {
                updateMatchedCards(first: first, second: second)
                checkAllMatched()
            } else {
                handleMismatch(first: first, second: second)
            }
            selectedCards.removeAll()
            isCheckingMatch = false
        }
    }

    func isMatchingPair(first: WordCard, second: WordCard) -> Bool {
        (first.isWord != second.isWord) &&
        pairs.contains { ($0.word == first.text && $0.meaning == second.text) || ($0.word == second.text && $0.meaning == first.text) }
    }

    func updateMatchedCards(first: WordCard, second: WordCard) {
        score += 10
        markAsMatched(card: first)
        markAsMatched(card: second)
    }

    func handleMismatch(first: WordCard, second: WordCard) {
        effects[first.id] = CardEffects(showSiren: true, isRed: true)
        effects[second.id] = CardEffects(showSiren: true, isRed: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            effects[first.id] = .init()
            effects[second.id] = .init()
            deselectCard(first)
            deselectCard(second)
        }
    }

    func checkAllMatched() {
        if cards.allSatisfy({ $0.isMatched }) {
            showConfetti = true
        }
    }

    func resetGame() {
        score = 0
        selectedCards.removeAll()
        effects.removeAll()
        showConfetti = false
        initializeCards()
    }

    func markAsMatched(card: WordCard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isMatched = true
        }
    }

    func deselectCard(_ card: WordCard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isSelected = false
        }
    }
}


struct WordCard: Identifiable {
    let id = UUID()
    let text: String
    let isWord: Bool
    var isMatched: Bool = false
    var isSelected: Bool = false
}

struct CardEffects {
    var showSiren: Bool = false
    var isRed: Bool = false
}

struct WordCardView: View {
    var card: WordCard
    var effects: CardEffects
    var action: () -> Void
    var cardSize: CGSize

    var body: some View {
        Button(action: { action() }) {
            Text(card.isMatched ? "✅" : card.text)
                .font(.title3)
                .frame(width: cardSize.width, height: cardSize.height)
                .background(effects.isRed ? Color.red : (card.isSelected ? Color.blue : Color.gray))
                .foregroundColor(.white)
                .cornerRadius(10)
                .overlay(effects.showSiren ? AnimatedSirenView() : nil)
        }
        .disabled(card.isMatched || card.isSelected)
    }
}

struct AnimatedSirenView: View {
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Text("🚨")
            .font(.largeTitle)
            .foregroundColor(.red)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.5).repeatCount(4, autoreverses: true)) {
                    opacity = 0.0
                    scale = 1.2
                }
            }
    }
}

struct ConfettiView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            ForEach(0..<50) { _ in
                Circle()
                    .fill(Color.random)
                    .frame(width: 10, height: 10)
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                              y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
                    .opacity(isAnimating ? 0 : 1)
            }
        }
        .onAppear {
            withAnimation(Animation.easeOut(duration: 3)) {
                isAnimating = true
            }
        }
    }
}

extension Color {
    static var random: Color {
        Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }
}
