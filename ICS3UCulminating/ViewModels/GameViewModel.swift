import Foundation
import Observation

@Observable
class GameViewModel {
    // MARK: - Stored properties
    
    // AI Mode properties
    var rootNode: DecisionNode
    var currentNode: DecisionNode
    var history: [DecisionNode] = []
    
    // User Mode properties
    var secretObject: SecretObject?
    var userQuestionCount: Int = 0
    var userModeHistory: [String] = []
    var availableSecretObjects: [SecretObject] = []
    
    // Common state
    var isGameOver: Bool = false
    var gameMessage: String = ""
    
    // MARK: - Initializer
    
    init() {
        // Initialize with a simple tree
        let dogNode = DecisionNode(text: "a dog")
        let catNode = DecisionNode(text: "a cat")
        let initialRoot = DecisionNode(text: "Does it bark?", yesChild: dogNode, noChild: catNode)
        
        self.rootNode = initialRoot
        self.currentNode = initialRoot
        
        // Setup User Mode data
        setupSampleObjects()
        loadTree()
    }
    
    // MARK: - Functions
    
    // MARK: AI Mode Logic
    
    func answerYes() {
        if let nextNode = currentNode.yesChild {
            history.append(currentNode)
            currentNode = nextNode
        } else {
            // It was a guess and it was correct!
            isGameOver = true
            gameMessage = "I guessed it! I am so smart."
        }
    }
    
    func answerNo() {
        if let nextNode = currentNode.noChild {
            history.append(currentNode)
            currentNode = nextNode
        } else {
            // It was a guess and it was wrong. Need to learn.
            gameMessage = "I give up. What was it?"
            // Transition to learning state would happen in the view
        }
    }
    
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
    
    func resetGame() {
        currentNode = rootNode
        history = []
        isGameOver = false
        gameMessage = ""
        userQuestionCount = 0
        userModeHistory = []
        selectRandomSecretObject()
    }
    
    // MARK: User Mode Logic
    
    func selectRandomSecretObject() {
        if availableSecretObjects.isEmpty == false {
            let randomIndex = Int.random(in: 0..<availableSecretObjects.count)
            secretObject = availableSecretObjects[randomIndex]
        }
    }
    
    func askUserQuestion(_ question: String) {
        guard let secret = secretObject, userQuestionCount < 20 else { return }
        
        userQuestionCount += 1
        let traitKey = QuestionBank.questions[question] ?? ""
        let answer = secret.hasTrait(traitKey) ? "Yes" : "No"
        
        userModeHistory.append("\(question) - \(answer)")
        
        if userQuestionCount >= 20 {
            isGameOver = true
            gameMessage = "Game Over! You've used all 20 questions. The object was \(secret.name)."
        }
    }
    
    func makeUserGuess(_ guess: String) {
        guard let secret = secretObject else { return }
        
        userQuestionCount += 1
        if guess.lowercased() == secret.name.lowercased() {
            isGameOver = true
            gameMessage = "Correct! You guessed it in \(userQuestionCount) questions."
        } else if userQuestionCount >= 20 {
            isGameOver = true
            gameMessage = "Wrong guess! And you're out of turns. The object was \(secret.name)."
        } else {
            userModeHistory.append("Guess: \(guess) - No")
        }
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
    
    // MARK: Data Setup
    
    private func setupSampleObjects() {
        let dog = SecretObject(name: "Dog", traits: ["isAnimal": true, "makesNoise": true, "isLarge": true])
        let cat = SecretObject(name: "Cat", traits: ["isAnimal": true, "makesNoise": true])
        let apple = SecretObject(name: "Apple", traits: ["isPlant": true, "isEdible": true])
        let car = SecretObject(name: "Car", traits: ["isManMade": true, "isLarge": true, "makesNoise": true])
        
        availableSecretObjects = [dog, cat, apple, car]
        selectRandomSecretObject()
    }
}
