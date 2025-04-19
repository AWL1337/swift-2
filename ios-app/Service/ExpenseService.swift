import Foundation

protocol ExpenseService {
    func fetchExpenses(page: Int, perPage: Int, completion: @escaping (Result<[Expense], Error>) -> Void)
    func clearCache() throws
}

class NetworkExpenseService: ExpenseService {
    private let cache: ExpenseCache
    
    init(cache: ExpenseCache = ExpenseCache()) {
        self.cache = cache
    }
    
    func fetchExpenses(page: Int, perPage: Int, completion: @escaping (Result<[Expense], Error>) -> Void) {
        if let cachedExpenses = cache.load() {
            completion(.success(cachedExpenses))
            return
        }
        
        var components = URLComponents(string: "https://mp43e19ef9d53a116f40.free.beeceptor.com/expense")!
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        
        URLSession.shared.dataTask(with: components.url!) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let expenses = try JSONDecoder().decode([Expense].self, from: data)
                try? self?.cache.save(expenses)
                completion(.success(expenses))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func clearCache() throws {
        try cache.clear()
    }
}
