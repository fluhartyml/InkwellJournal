import SwiftData
import Foundation
import UIKit

@Model
class JournalEntry {
    var title: String = ""
    var content: String = ""
    var dateCreated: Date = Date()
    var mood: String = "Neutral"
    var imageData: Data? = nil
    
    init(title: String = "", content: String = "", mood: String = "Neutral", imageData: Data? = nil) {
        self.title = title
        self.content = content
        self.dateCreated = Date()
        self.mood = mood
        self.imageData = imageData
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dateCreated)
    }
    
    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
}

