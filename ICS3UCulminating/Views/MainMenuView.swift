import SwiftUI

struct MainMenuView: View {
    // MARK: - Stored properties
    
    @State private var viewModel = GameViewModel()
    
    // MARK: - Computed properties
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Twenty Questions")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.top, 50)
                
                Spacer()
                
                VStack(spacing: 20) {
                    NavigationLink {
                        AIQuestionerView(viewModel: viewModel)
                    } label: {
                        MenuButton(title: "App Guesses", subtitle: "I try to guess your object", color: .blue)
                    }
                    
                    NavigationLink {
                        UserQuestionerView(viewModel: viewModel)
                    } label: {
                        MenuButton(title: "You Guess", subtitle: "Try to guess my secret object", color: .green)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Text("Project by ICS3U Student")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
            .onAppear {
                viewModel.resetGame()
            }
        }
    }
}

struct MenuButton: View {
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color, lineWidth: 2)
        )
    }
}

#Preview {
    MainMenuView()
}
