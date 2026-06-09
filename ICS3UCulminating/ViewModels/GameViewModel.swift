import Foundation
import Observation
import SwiftUI

struct HistoryEntry: Identifiable {
    let id = UUID()
    let text: String
}

@Observable
class GameViewModel {
    // MARK: - Stored properties
    
    // AI Mode properties
    var rootNode: DecisionNode
    var currentNode: DecisionNode
    var history: [DecisionNode] = []
    
    // User Mode properties
    var secretObject: DecisionNode?
    var userQuestionCount: Int = 0
    var userModeHistory: [HistoryEntry] = []
    
    // Common state
    var isGameOver: Bool = false
    var gameMessage: String = ""
    
    // MARK: - Computed properties
    
    var allObjects: [DecisionNode] {
        return findAllLeaves(from: rootNode)
    }
    
    var allQuestions: [DecisionNode] {
        return findAllQuestions(from: rootNode)
    }
    
    // MARK: - Initializer
    
    init() {
        // Initialize with a simple tree
        let dogNode = DecisionNode(text: "a dog")
        let catNode = DecisionNode(text: "a cat")
        let initialRoot = DecisionNode(text: "Does it bark?", yesChild: dogNode, noChild: catNode)
        
        self.rootNode = initialRoot
        self.currentNode = initialRoot
        
        loadTree()
        selectRandomSecretObject()
    }
    
    // MARK: - Functions
    
    // MARK: Tree Traversal Helpers
    
    /// Recurse through the tree to find all leaf nodes (objects).
    private func findAllLeaves(from node: DecisionNode) -> [DecisionNode] {
        if node.isGuess {
            return [node]
        }
        
        var leaves: [DecisionNode] = []
        if let yes = node.yesChild {
            leaves.append(contentsOf: findAllLeaves(from: yes))
        }
        if let no = node.noChild {
            leaves.append(contentsOf: findAllLeaves(from: no))
        }
        return leaves
    }
    
    /// Recurse through the tree to find all question nodes.
    private func findAllQuestions(from node: DecisionNode) -> [DecisionNode] {
        if node.isGuess {
            return []
        }
        
        var questions: [DecisionNode] = [node]
        if let yes = node.yesChild {
            questions.append(contentsOf: findAllQuestions(from: yes))
        }
        if let no = node.noChild {
            questions.append(contentsOf: findAllQuestions(from: no))
        }
        
        // Return unique questions (by text) to avoid duplicates if same question used elsewhere
        var uniqueQuestions: [DecisionNode] = []
        var seenTexts: Set<String> = []
        for question in questions {
            if seenTexts.contains(question.text) == false {
                uniqueQuestions.append(question)
                seenTexts.insert(question.text)
            }
        }
        return uniqueQuestions
    }
    
    /// Determines if a specific object node exists anywhere within the subtree of another node.
    /// This is used to determine 'Yes' or 'No' answers in User Mode.
    private func isObject(_ object: DecisionNode, inSubtreeOf node: DecisionNode) -> Bool {
        if node.id == object.id {
            return true
        }
        
        var foundInYes = false
        if let yes = node.yesChild {
            foundInYes = isObject(object, inSubtreeOf: yes)
        }
        
        if foundInYes {
            return true
        }
        
        if let no = node.noChild {
            return isObject(object, inSubtreeOf: no)
        }
        
        return false
    }
    
    // MARK: AI Mode Logic
    
    /// Moves the AI to the 'yes' branch of the current decision node.
    /// If the node is a leaf, it triggers the game over state with a success message.
    func answerYes() {
        withAnimation {
            if let nextNode = currentNode.yesChild {
                history.append(currentNode)
                currentNode = nextNode
            } else {
                // It was a guess and it was correct!
                isGameOver = true
                gameMessage = "I guessed it! I am so smart."
            }
        }
    }
    
    /// Moves the AI to the 'no' branch of the current decision node.
    /// If the node is a leaf, it triggers the 'give up' message to initiate learning.
    func answerNo() {
        withAnimation {
            if let nextNode = currentNode.noChild {
                history.append(currentNode)
                currentNode = nextNode
            } else {
                // It was a guess and it was wrong. Need to learn.
                gameMessage = "I give up. What was it?"
            }
        }
    }
    
    /// Updates the tree with a new object and a question to distinguish it from the current guess.
    /// - Parameters:
    ///   - name: The name of the new object.
    ///   - distinguishingQuestion: A question that separates the new object from the old one.
    ///   - correctAnswerForNewObject: Whether the answer to the new question is 'Yes' for the new object.
    func learnNewObject(name: String, distinguishingQuestion: String, correctAnswerForNewObject: Bool) {
        let newNode = DecisionNode(text: name)
        let oldNode = DecisionNode(text: currentNode.text)
        
        currentNode.text = distinguishingQuestion
        if correctAnswerForNewObject {
            currentNode.yesChild = newNode
            currentNode.noChild = oldNode
        } else {
            currentNode.yesChild = oldNode
            currentNode.noChild = newNode
        }
        
        saveTree()
        resetGame()
    }
    
    /// Resets the game state to the root of the tree and clears user mode history.
    func resetGame() {
        withAnimation {
            currentNode = rootNode
            history = []
            isGameOver = false
            gameMessage = ""
            userQuestionCount = 0
            userModeHistory = []
            selectRandomSecretObject()
        }
    }
    
    // MARK: User Mode Logic
    
    /// Randomly selects an object from the tree for the user to guess.
    func selectRandomSecretObject() {
        let objects = allObjects
        if objects.isEmpty == false {
            let randomIndex = Int.random(in: 0..<objects.count)
            secretObject = objects[randomIndex]
        }
    }
    
    /// Evaluates a user's question against the current secret object.
    /// - Parameter questionNode: The node representing the question asked.
    func askUserQuestion(_ questionNode: DecisionNode) {
        guard let secret = secretObject, userQuestionCount < 20 else { return }
        
        withAnimation {
            userQuestionCount += 1
            
            // Find if the secret object is in the 'yes' branch of this question
            let answer: String
            if let yesChild = questionNode.yesChild, isObject(secret, inSubtreeOf: yesChild) {
                answer = "Yes"
            } else {
                answer = "No"
            }
            
            userModeHistory.append(HistoryEntry(text: "\(questionNode.text) - \(answer)"))
            
            if userQuestionCount >= 20 {
                isGameOver = true
                gameMessage = "Game Over! You've used all 20 questions. The object was \(secret.text)."
            }
        }
    }
    
    /// Checks a user's guess against the secret object name using normalized comparison.
    func makeUserGuess(_ guess: String) {
        guard let secret = secretObject else { return }
        
        withAnimation {
            userQuestionCount += 1
            
            let normalizedGuess = normalize(guess)
            let normalizedSecret = normalize(secret.text)
            
            if normalizedGuess == normalizedSecret {
                isGameOver = true
                gameMessage = "Correct! You guessed it in \(userQuestionCount) questions."
            } else if userQuestionCount >= 20 {
                isGameOver = true
                gameMessage = "Wrong guess! And you're out of turns. The object was \(secret.text)."
            } else {
                userModeHistory.append(HistoryEntry(text: "Guess: \(guess) - No"))
            }
        }
    }
    
    // MARK: Knowledge Management
    
    /// Updates the text of a specific node in the tree.
    /// - Parameters:
    ///   - id: The unique ID of the node to update.
    ///   - newText: The new text (question or object name) for the node.
    func updateNodeText(id: UUID, newText: String) {
        if let node = findNode(with: id, startingAt: rootNode) {
            node.text = newText
            saveTree()
        }
    }
    
    /// Wipes the learned tree and restores the starting default tree.
    func resetKnowledge() {
        let dogNode = DecisionNode(text: "a dog")
        let catNode = DecisionNode(text: "a cat")
        let initialRoot = DecisionNode(text: "Does it bark?", yesChild: dogNode, noChild: catNode)
        
        self.rootNode = initialRoot
        saveTree()
        resetGame()
    }
    
    /// Recursively searches the tree to find a node with the matching ID.
    private func findNode(with id: UUID, startingAt node: DecisionNode) -> DecisionNode? {
        if node.id == id {
            return node
        }
        
        if let yes = node.yesChild, let found = findNode(with: id, startingAt: yes) {
            return found
        }
        
        if let no = node.noChild, let found = findNode(with: id, startingAt: no) {
            return found
        }
        
        return nil
    }
    
    private func normalize(_ text: String) -> String {
        let lowercased = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let articles = ["a ", "an ", "the "]
        var result = lowercased
        
        for article in articles {
            if result.hasPrefix(article) {
                result = String(result.dropFirst(article.count))
                break
            }
        }
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: Persistence
    
    private func saveTree() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(rootNode) {
            let url = getDocumentsDirectory().appendingPathComponent("decision_tree.json")
            try? data.write(to: url)
        }
    }
    
    private func loadTree() {
        let url = getDocumentsDirectory().appendingPathComponent("decision_tree.json")
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(DecisionNode.self, from: data) {
                rootNode = decoded
                currentNode = rootNode
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
