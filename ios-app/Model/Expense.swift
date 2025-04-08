import Foundation

struct Expense: Codable {
    let id: UUID
    let userId: UUID
    let amount: Double
    let category: String
    let date: Date
    let note: String?
}
