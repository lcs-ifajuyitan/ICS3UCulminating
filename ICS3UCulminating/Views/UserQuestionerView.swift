import SwiftUI

struct UserQuestionerView: View {
    // MARK: - Stored properties
    
    var viewModel: GameViewModel
    @State private var showingGuessAlert = false
    @State private var userGuess = ""
    
    // MARK: - Computed properties
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Questions: \(viewModel.userQuestionCount)/20")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            if viewModel.isGameOver {
                GameOverView(message: viewModel.gameMessage) {
                    viewModel.resetGame()
                }
            } else {
                List {
                    Section("Ask a Question") {
                        ForEach(viewModel.allQuestions) { questionNode in
                            Button(questionNode.text) {
                                viewModel.askUserQuestion(questionNode)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    
                    if viewModel.userModeHistory.isEmpty == false {
                        Section("History") {
                            ForEach(viewModel.userModeHistory) { entry in
                                Text(entry.text)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Button("Make a Guess") {
                    showingGuessAlert = true
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .navigationTitle("Your Turn to Guess")
        .alert("What's your guess?", isPresented: $showingGuessAlert) {
            TextField("Object name", text: $userGuess)
            Button("Cancel", role: .cancel) { userGuess = "" }
            Button("Guess") {
                viewModel.makeUserGuess(userGuess)
                userGuess = ""
            }
        }
    }
}
