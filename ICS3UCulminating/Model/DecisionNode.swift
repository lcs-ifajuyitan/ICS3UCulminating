import Foundation

/// A node in the binary decision tree for the Twenty Questions game.
/// It can either be a question (with yes/no children) or a final guess (leaf).
class DecisionNode: Codable, Identifiable {
    // MARK: - Stored properties
    
    /// Unique identifier for the node, used for editing in the Knowledge Base.
    var id: UUID
    
    /// The text for the node (either a question or an object name).
    var text: String
    
    /// The node to move to if the answer is 'Yes'.
    var yesChild: DecisionNode?
    
    /// The node to move to if the answer is 'No'.
    var noChild: DecisionNode?
    
    // MARK: - Computed properties
    
    /// Returns true if this node is a final guess (a leaf in the tree).
    var isGuess: Bool {
        return yesChild == nil && noChild == nil
    }
    
    // MARK: - Initializer
    
    init(text: String, yesChild: DecisionNode? = nil, noChild: DecisionNode? = nil) {
        self.id = UUID()
        self.text = text
        self.yesChild = yesChild
        self.noChild = noChild
    }
}
