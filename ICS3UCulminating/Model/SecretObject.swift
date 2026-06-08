import Foundation

/// Represents a secret object that the user tries to guess in "User Mode".
struct SecretObject: Codable, Identifiable {
    // MARK: - Stored properties
    
    var id = UUID()
    let name: String
    let traits: [String: Bool]
    
    // MARK: - Functions
    
    /// Checks if the object has a specific trait.
    func hasTrait(_ trait: String) -> Bool {
        return traits[trait] ?? false
    }
}

/// A bank of questions and their associated traits.
struct QuestionBank {
    static let questions: [String: String] = [
        "Is it an animal?": "isAnimal",
        "Is it a plant?": "isPlant",
        "Is it bigger than a breadbox?": "isLarge",
        "Can you eat it?": "isEdible",
        "Is it man-made?": "isManMade",
        "Does it make noise?": "makesNoise",
        "Can it fly?": "canFly",
        "Does it live in water?": "livesInWater"
    ]
}
