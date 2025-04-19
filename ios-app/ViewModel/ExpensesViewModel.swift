import Foundation

class ExpensesViewModel {
    private let expenseService: ExpenseService
        var expenses: Observable<[ExpenseItem]> = Observable([])
        var isLoading: Observable<Bool> = Observable(false)
        var errorMessage: Observable<String?> = Observable(nil)
        private var currentPage = 1
        private let perPage = 10
    
    init(expenseService: ExpenseService) {
        self.expenseService = expenseService
    }
    
    func fetchExpenses() {
            isLoading.value = true
            expenseService.fetchExpenses(page: currentPage, perPage: perPage) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading.value = false
                    switch result {
                    case .success(let newExpenses):
                        let newItems = newExpenses.map { ExpenseItem(from: $0) }
                        self?.expenses.value.append(contentsOf: newItems)
                        self?.currentPage += 1
                    case .failure(let error):
                        self?.errorMessage.value = error.localizedDescription
                    }
                }
            }
        }
}

// Модель для отображения
struct ExpenseItem {
    let id: UUID
    let amount: String
    let category: String
    let date: String 
    let note: String?
    
    init(from expense: Expense) {
        self.id = expense.id
        self.amount = String(format: "%.2f", expense.amount)
        self.category = expense.category
        self.date = DateFormatter.localizedString(from: expense.date, dateStyle: .medium, timeStyle: .none)
        self.note = expense.note
    }
}
