import Foundation

protocol ExpenseService {
    func fetchExpenses(page: Int, perPage: Int, completion: @escaping (Result<[Expense], Error>) -> Void)
}

class NetworkExpenseService: ExpenseService {
    private let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("expenses.json")
    private let cacheExpiration: TimeInterval = 3600
    
    func fetchExpenses(page: Int, perPage: Int, completion: @escaping (Result<[Expense], Error>) -> Void) {
        if let cachedData = try? Data(contentsOf: cacheURL),
           let cachedExpenses = try? JSONDecoder().decode([Expense].self, from: cachedData),
           let cacheDate = try? FileManager.default.attributesOfItem(atPath: cacheURL.path)[.modificationDate] as? Date,
           Date().timeIntervalSince(cacheDate) < cacheExpiration {
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
                try? data.write(to: self?.cacheURL ?? URL(fileURLWithPath: ""))
                completion(.success(expenses))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
