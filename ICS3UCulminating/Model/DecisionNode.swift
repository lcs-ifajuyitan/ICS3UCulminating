import Foundation

/// A node in the binary decision tree for the Twenty Questions game.
/// It can either be a question (with yes/no children) or a final guess (leaf).
class DecisionNode: Codable {
    // MARK: - Stored properties
    
    var text: String
    var yesChild: DecisionNode?
    var noChild: DecisionNode?
    
    // MARK: - Computed properties
    
    /// Returns true if this node is a final guess (a leaf in the tree).
    var isGuess: Bool {
        return yesChild == nil && noChild == nil
    }
    
    // MARK: - Initializer
    
    init(text: String, yesChild: DecisionNode? = nil, noChild: DecisionNode? = nil) {
        self.text = text
        self.yesChild = yesChild
        self.noChild = noChild
    }
}
