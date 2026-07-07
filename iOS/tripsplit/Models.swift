import Foundation

struct Expense: Identifiable, Codable, Equatable {
    let id: UUID
    var tripName: String
    var description_: String
    var amount: Double
    var paidBy: String
    var date: Date

    init(id: UUID = UUID(), tripName: String, description_: String, amount: Double, paidBy: String, date: Date) {
        self.id = id
        self.tripName = tripName
        self.description_ = description_
        self.amount = amount
        self.paidBy = paidBy
        self.date = date
    }
}
