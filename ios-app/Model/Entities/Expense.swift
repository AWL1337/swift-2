import Foundation

struct Expense {
    let id: UUID
    let userId: UUID
    let amount: Double
    let category: String
    let date: Date
    let note: String?
}
