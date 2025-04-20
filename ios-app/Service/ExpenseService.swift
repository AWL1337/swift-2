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
            print("NetworkExpenseService: Loaded \(cachedExpenses.count) expenses from cache")
            completion(.success(cachedExpenses))
            return
        }
        
        var components = URLComponents(string: "https://mp43e19ef9d53a116f40.free.beeceptor.com/expense")!
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        
        print("NetworkExpenseService: Fetching expenses from URL: \(components.url?.absoluteString ?? "Invalid URL")")
        
        URLSession.shared.dataTask(with: components.url!) { [weak self] data, response, error in
            if let error = error {
                print("NetworkExpenseService: Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("NetworkExpenseService: No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("NetworkExpenseService: Server response: \(responseString)")
            } else {
                print("NetworkExpenseService: Failed to decode response as string")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("NetworkExpenseService: HTTP status code: \(httpResponse.statusCode)")
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601 // Настройка для ISO 8601
                let expenses = try decoder.decode([Expense].self, from: data)
                print("NetworkExpenseService: Decoded \(expenses.count) expenses")
                try? self?.cache.save(expenses)
                completion(.success(expenses))
            } catch {
                print("NetworkExpenseService: Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func clearCache() throws {
        try cache.clear()
    }
}
