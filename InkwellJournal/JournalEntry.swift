import SwiftData
import Foundation
import UIKit

@Model
class JournalEntry {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var dateCreated: Date
    var modifiedAt: Date? // Make optional to handle existing entries
    var mood: String
    var imageData: Data?
    
    init(title: String = "", content: String = "", mood: String = "Neutral") {
        self.id = UUID()
        self.title = title
        self.content = content
        let now = Date()
        self.dateCreated = now
        self.modifiedAt = now
        self.mood = mood
        self.imageData = nil
    }
    
    convenience init(title: String, content: String, date: Date, mood: String, imageData: Data?) {
        self.init(title: title, content: content, mood: mood)
        self.dateCreated = date
        self.modifiedAt = date
        self.imageData = imageData
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dateCreated)
    }
    
    var image: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    // Helper to get modification date with fallback
    var effectiveModifiedAt: Date {
        return modifiedAt ?? dateCreated
    }
}

