import Foundation

protocol StorageProtocol {
    func authenticate(login: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func saveExpense(_ expense: Expense) throws
    func fetchExpenses(for period: DatePeriod) throws -> [Expense]
}
