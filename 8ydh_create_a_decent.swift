// Imported Libraries
import Foundation
import Swiftsoup
import CryptoKit

// Chatbot Generator Class
class DecentChatbotGenerator {
    var botName: String
    var botDescription: String
    var botIntents: [Intent]
    var botResponses: [Response]
    
    init(name: String, description: String, intents: [Intent], responses: [Response]) {
        self.botName = name
        self.botDescription = description
        self.botIntents = intents
        self.botResponses = responses
    }
    
    func generateChatbot() -> String {
        // Create a new chatbot template
        let template = """
        {
            "name": "\(botName)",
            "description": "\(botDescription)",
            "intents": [\(botIntents.map { $0.intentTemplate }.joined(separator: ","))],
            "responses": [\(botResponses.map { $0.responseTemplate }.joined(separator: ","))]
        }
        """
        
        return template
    }
}

// Intent Class
class Intent {
    var intentName: String
    var intentDescription: String
    var intentExamples: [String]
    
    init(name: String, description: String, examples: [String]) {
        self.intentName = name
        self.intentDescription = description
        self.intentExamples = examples
    }
    
    var intentTemplate: String {
        return """
        {
            "name": "\(intentName)",
            "description": "\(intentDescription)",
            "examples": [\(intentExamples.map { "\"\($0)\"" }.joined(separator: ","))]
        }
        """
    }
}

// Response Class
class Response {
    var responseText: String
    var responseType: String
    
    init(text: String, type: String) {
        self.responseText = text
        self.responseType = type
    }
    
    var responseTemplate: String {
        return """
        {
            "text": "\(responseText)",
            "type": "\(responseType)"
        }
        """
    }
}

// Blockchain Class (for decentralized storage)
class Blockchain {
    var blocks: [Block]
    
    init() {
        self.blocks = [Block]
    }
    
    func addBlock(block: Block) {
        self.blocks.append(block)
    }
    
    func getBlock(byIndex index: Int) -> Block? {
        return self.blocks[safe: index]
    }
}

// Block Class (for blockchain)
class Block {
    var index: Int
    var data: String
    var previousBlockHash: String
    var blockHash: String
    
    init(index: Int, data: String, previousBlockHash: String) {
        self.index = index
        self.data = data
        self.previousBlockHash = previousBlockHash
        self.blockHash = generateHash()
    }
    
    func generateHash() -> String {
        let input = "\(index)\(data)\(previousBlockHash)"
        let hash = SHA256.hash(data: input.data(using: .utf8)!)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// Load Chatbot Template from Blockchain
func loadChatbot(from blockchain: Blockchain, blockIndex: Int) -> DecentChatbotGenerator? {
    if let block = blockchain.getBlock(byIndex: blockIndex) {
        let data = block.data
        let jsonData = data.data(using: .utf8)!
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            if let dictionary = json as? [String: Any] {
                let botName = dictionary["name"] as? String ?? ""
                let botDescription = dictionary["description"] as? String ?? ""
                var intents: [Intent] = []
                var responses: [Response] = []
                
                if let intentArray = dictionary["intents"] as? [[String: Any]] {
                    for intent in intentArray {
                        let intentName = intent["name"] as? String ?? ""
                        let intentDescription = intent["description"] as? String ?? ""
                        let intentExamples = intent["examples"] as? [String] ?? []
                        intents.append(Intent(name: intentName, description: intentDescription, examples: intentExamples))
                    }
                }
                
                if let responseArray = dictionary["responses"] as? [[String: Any]] {
                    for response in responseArray {
                        let responseText = response["text"] as? String ?? ""
                        let responseType = response["type"] as? String ?? ""
                        responses.append(Response(text: responseText, type: responseType))
                    }
                }
                
                return DecentChatbotGenerator(name: botName, description: botDescription, intents: intents, responses: responses)
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
    
    return nil
}

// Main Function
func main() {
    // Create a new blockchain
    let blockchain = Blockchain()
    
    // Create a new chatbot generator
    let chatbotGenerator = DecentChatbotGenerator(name: "MyChatbot", description: "A decentralized chatbot", intents: [
        Intent(name: "greeting", description: "Greeting intent", examples: ["hello", "hi"]),
        Intent(name: "goodbye", description: "Goodbye intent", examples: ["bye", "see you later"]),
    ], responses: [
        Response(text: "Hello! How can I assist you today?", type: "greeting"),
        Response(text: "Goodbye! It was nice chatting with you.", type: "goodbye"),
    ])
    
    // Generate chatbot template
    let chatbotTemplate = chatbotGenerator.generateChatbot()
    
    // Create a new block and add it to the blockchain
    let block = Block(index: 0, data: chatbotTemplate, previousBlockHash: "")
    blockchain.addBlock(block: block)
    
    // Load chatbot from blockchain
    if let loadedChatbot = loadChatbot(from: blockchain, blockIndex: 0) {
        print("Loaded chatbot: \(loadedChatbot.botName)")
    } else {
        print("Failed to load chatbot")
    }
}

main()