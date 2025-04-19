import Foundation
import Combine

class ExpensesViewModel {
    private let expenseService: ExpenseService
    private var cancellables = Set<AnyCancellable>()
    
    let expenses = CurrentValueSubject<[ExpenseItem], Never>([])
    let isLoading = CurrentValueSubject<Bool, Never>(false)
    let errorMessage = CurrentValueSubject<String?, Never>(nil)
    private var currentPage = 1
    private let perPage = 10
    
    init(expenseService: ExpenseService) {
        self.expenseService = expenseService
    }
    
    func fetchExpenses() {
        isLoading.send(true)
        expenseService.fetchExpenses(page: currentPage, perPage: perPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading.send(false)
                switch result {
                case .success(let newExpenses):
                    let newItems = newExpenses.map { ExpenseItem(from: $0) }
                    self?.expenses.value.append(contentsOf: newItems)
                    self?.currentPage += 1
                case .failure(let error):
                    self?.errorMessage.send(error.localizedDescription)
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
