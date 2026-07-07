import XCTest
@testable import tripsplit

@MainActor
final class ExpenseStoreTests: XCTestCase {
    var store: Store!

    override func setUp() async throws {
        store = Store()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        XCTAssertLessThan(store.items.count, Store.freeLimit)
    }

    func testCanAddMoreWhenUnderLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testAddIncreasesCount() {
        let before = store.items.count
        store.add(Expense(tripName: "Sample Tripname 10", description_: "Sample Description_ 10", amount: 125.00, paidBy: "Sample Paidby 10", date: Date().addingTimeInterval(-2592000)))
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testAddBeyondFreeLimitIsBlocked() {
        while store.canAddMore {
            store.add(Expense(tripName: "Sample Tripname 2", description_: "Sample Description_ 2", amount: 25.00, paidBy: "Sample Paidby 2", date: Date().addingTimeInterval(-518400)))
        }
        let countAtLimit = store.items.count
        store.add(Expense(tripName: "Sample Tripname 3", description_: "Sample Description_ 3", amount: 37.50, paidBy: "Sample Paidby 3", date: Date().addingTimeInterval(-777600)))
        XCTAssertEqual(store.items.count, countAtLimit)
    }

    func testProUnlockBypassesLimit() {
        while store.canAddMore {
            store.add(Expense(tripName: "Sample Tripname 2", description_: "Sample Description_ 2", amount: 25.00, paidBy: "Sample Paidby 2", date: Date().addingTimeInterval(-518400)))
        }
        store.isProUnlocked = true
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteRemovesItem() {
        let item = store.items[0]
        store.delete(item)
        XCTAssertFalse(store.items.contains(item))
    }

    func testUpdateModifiesItem() {
        var item = store.items[0]
        item.tripName = "Sample Tripname 6"
        store.update(item)
        XCTAssertEqual(store.items.first(where: { $0.id == item.id })?.tripName, item.tripName)
    }

    func testDeleteAtOffsetsRemovesCorrectItem() {
        let target = store.items[0]
        store.delete(at: IndexSet(integer: 0))
        XCTAssertFalse(store.items.contains(target))
    }
}
