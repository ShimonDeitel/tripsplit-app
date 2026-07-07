import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Expense] = []
    @Published var isProUnlocked: Bool = false

    /// Free tier item cap. Deliberately kept above the seed data count
    /// so a fresh install never opens directly into the paywall.
    static let freeLimit = 8

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("tripsplit_items.json")
        load()
    }

    var canAddMore: Bool {
        isProUnlocked || items.count < Store.freeLimit
    }

    func add(_ item: Expense) {
        guard canAddMore else { return }
        items.append(item)
        save()
    }

    func update(_ item: Expense) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Expense) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            items = decoded
        } else {
            items = [
        Expense(tripName: "Sample Tripname 1", description_: "Sample Description_ 1", amount: 12.50, paidBy: "Sample Paidby 1", date: Date().addingTimeInterval(-259200)),
        Expense(tripName: "Sample Tripname 2", description_: "Sample Description_ 2", amount: 25.00, paidBy: "Sample Paidby 2", date: Date().addingTimeInterval(-518400)),
        Expense(tripName: "Sample Tripname 3", description_: "Sample Description_ 3", amount: 37.50, paidBy: "Sample Paidby 3", date: Date().addingTimeInterval(-777600))
            ]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
