//2025 SEP 28 - 1534 - JournalEntry.swift Clean Working
import SwiftData
import Foundation

@Model
class JournalEntry {
    var title: String = ""
    var content: String = ""
    var dateCreated: Date = Date()
    var mood: String = "Neutral"
    
    init(title: String = "", content: String = "", mood: String = "Neutral") {
        self.title = title
        self.content = content
        self.dateCreated = Date()
        self.mood = mood
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dateCreated)
    }
}

