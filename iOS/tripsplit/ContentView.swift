import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingItem: Expense?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.items) { item in
                    Button {
                        editingItem = item
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(item.tripName)")
                                .font(Theme.headingFont)
                                .foregroundStyle(Theme.ink)
                            Text("\(item.description_)")
                                .font(Theme.captionFont)
                                .foregroundStyle(Theme.secondaryInk)
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityIdentifier("itemRow_\(item.id)")
                }
                .onDelete { offsets in
                    store.delete(at: offsets)
                }
                .listRowBackground(Theme.cardBackground)
            }
            .scrollContentBackground(.hidden)
            .themedBackground()
            .navigationTitle("Tripmate Split")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryEditorView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                EntryEditorView(mode: .edit(item))
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

enum EditorMode: Identifiable, Equatable {
    case add
    case edit(Expense)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct EntryEditorView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let mode: EditorMode

    @State private var draftTripname: String = ""
    @State private var draftDescription_: String = ""
    @State private var draftAmount: Double = 0
    @State private var draftPaidby: String = ""
    @State private var draftDate: Date = Date()

    init(mode: EditorMode) {
        self.mode = mode
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Expense Details") {
                TextField("Tripname", text: $draftTripname)
                    .accessibilityIdentifier("field_tripName")
                TextField("Description", text: $draftDescription_)
                    .accessibilityIdentifier("field_description_")
                TextField("Amount", value: $draftAmount, format: .number)
                    .keyboardType(.decimalPad)
                    .accessibilityIdentifier("field_amount")
                TextField("Paidby", text: $draftPaidby)
                    .accessibilityIdentifier("field_paidBy")
                DatePicker("Date", selection: $draftDate, displayedComponents: .date)
                    .accessibilityIdentifier("field_date")
                }

                if case .edit(let item) = mode {
                    Section {
                        Button("Delete", role: .destructive) {
                            store.delete(item)
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .themedBackground()
            .scrollContentBackground(.hidden)
            .navigationTitle(isEditing ? "Edit" : "New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onAppear { loadIfEditing() }
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func loadIfEditing() {
        if case .edit(let item) = mode {
        draftTripname = item.tripName
        draftDescription_ = item.description_
        draftAmount = item.amount
        draftPaidby = item.paidBy
        draftDate = item.date
        } else {
        draftTripname = ""
        draftDescription_ = ""
        draftAmount = 0
        draftPaidby = ""
        draftDate = Date()
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.add(Expense(tripName: draftTripname, description_: draftDescription_, amount: draftAmount, paidBy: draftPaidby, date: draftDate))
        case .edit(let item):
            var updated = item
            updated.tripName = draftTripname
            updated.description_ = draftDescription_
            updated.amount = draftAmount
            updated.paidBy = draftPaidby
            updated.date = draftDate
            store.update(updated)
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
