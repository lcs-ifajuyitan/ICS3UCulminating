import SwiftUI

struct KnowledgeBaseView: View {
    // MARK: - Stored properties
    
    var viewModel: GameViewModel
    @State private var editingNode: DecisionNode?
    @State private var newText: String = ""
    @State private var showingResetAlert = false
    
    // MARK: - Computed properties
    
    var body: some View {
        List {
            Section {
                Text("Tap any item to edit its name or question text. This will update both game modes.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("Learned Objects") {
                ForEach(viewModel.allObjects) { object in
                    Button {
                        startEditing(object)
                    } label: {
                        HStack {
                            Text(object.text)
                            Spacer()
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            
            Section("Questions") {
                ForEach(viewModel.allQuestions) { question in
                    Button {
                        startEditing(question)
                    } label: {
                        HStack {
                            Text(question.text)
                            Spacer()
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            
            Section {
                Button("Reset All Knowledge", role: .destructive) {
                    showingResetAlert = true
                }
                .frame(maxWidth: .infinity)
            } footer: {
                Text("This will delete all learned objects and restore the default starting tree.")
            }
        }
        .navigationTitle("Knowledge Base")
        .alert("Edit Text", isPresented: Binding(
            get: { editingNode != nil },
            set: { if !$0 { editingNode = nil } }
        )) {
            TextField("New text", text: $newText)
            Button("Cancel", role: .cancel) { editingNode = nil }
            Button("Save") {
                if let node = editingNode {
                    viewModel.updateNodeText(id: node.id, newText: newText)
                }
                editingNode = nil
            }
        }
        .alert("Reset Everything?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetKnowledge()
            }
        } message: {
            Text("Are you sure you want to delete everything I've learned?")
        }
    }
    
    // MARK: - Functions
    
    private func startEditing(_ node: DecisionNode) {
        newText = node.text
        editingNode = node
    }
}

#Preview {
    NavigationStack {
        KnowledgeBaseView(viewModel: GameViewModel())
    }
}
