import SwiftUI

struct AIQuestionerView: View {
    // MARK: - Stored properties
    
    var viewModel: GameViewModel
    @State private var showingLearningView = false
    
    // MARK: - Computed properties
    
    var body: some View {
        VStack(spacing: 30) {
            Text("My Turn to Guess")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if viewModel.isGameOver {
                GameOverView(message: viewModel.gameMessage) {
                    viewModel.resetGame()
                }
            } else if viewModel.gameMessage == "I give up. What was it?" {
                VStack(spacing: 20) {
                    Text(viewModel.gameMessage)
                        .font(.title)
                        .multilineTextAlignment(.center)
                    
                    Button("Teach Me") {
                        showingLearningView = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                VStack(spacing: 20) {
                    if viewModel.currentNode.isGuess {
                        Text("Are you thinking of...")
                            .font(.headline)
                    }
                    
                    Text(viewModel.currentNode.text + (viewModel.currentNode.isGuess ? "?" : ""))
                        .font(.system(size: 32, weight: .medium))
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    HStack(spacing: 40) {
                        Button {
                            viewModel.answerYes()
                        } label: {
                            AnswerButton(title: "Yes", color: .green)
                        }
                        
                        Button {
                            viewModel.answerNo()
                        } label: {
                            AnswerButton(title: "No", color: .red)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingLearningView) {
            LearningView(viewModel: viewModel)
        }
    }
}

struct AnswerButton: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.title2.bold())
            .frame(width: 120, height: 60)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(15)
    }
}

struct GameOverView: View {
    let message: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text(message)
                .font(.title)
                .multilineTextAlignment(.center)
            
            Button("Play Again", action: action)
                .buttonStyle(.borderedProminent)
        }
    }
}
