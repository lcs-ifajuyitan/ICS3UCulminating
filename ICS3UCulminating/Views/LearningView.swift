import SwiftUI

struct LearningView: View {
    // MARK: - Stored properties
    
    var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var objectName = ""
    @State private var newQuestion = ""
    @State private var isYesForNewObject = true
    
    // MARK: - Computed properties
    
    var body: some View {
        NavigationStack {
            Form {
                Section("What were you thinking of?") {
                    TextField("e.g. A goldfish", text: $objectName)
                }
                
                Section("Help me distinguish") {
                    Text("Give me a question that would be YES for \(objectName.isEmpty ? "your object" : objectName) but NO for \(viewModel.currentNode.text).")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("e.g. Does it live in water?", text: $newQuestion)
                    
                    Toggle("Is the answer YES for \(objectName.isEmpty ? "your object" : objectName)?", isOn: $isYesForNewObject)
                }
                
                Button("Update My Knowledge") {
                    viewModel.learnNewObject(
                        name: objectName,
                        distinguishingQuestion: newQuestion,
                        correctAnswerForNewObject: isYesForNewObject
                    )
                    dismiss()
                }
                .disabled(objectName.isEmpty || newQuestion.isEmpty)
            }
            .navigationTitle("Teach Me")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
