import Foundation

class ExpenseCache {
    private let cacheURL: URL
    private let cacheExpiration: TimeInterval
    
    init(cacheFileName: String = "expenses.json", cacheExpiration: TimeInterval = 3600) {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheURL = cacheDirectory.appendingPathComponent(cacheFileName)
        self.cacheExpiration = cacheExpiration
    }
    
    func save(_ expenses: [Expense]) throws {
        let data = try JSONEncoder().encode(expenses)
        try data.write(to: cacheURL)
    }
    
    func load() -> [Expense]? {
        guard let data = try? Data(contentsOf: cacheURL),
              let cacheDate = try? FileManager.default.attributesOfItem(atPath: cacheURL.path)[.modificationDate] as? Date,
              Date().timeIntervalSince(cacheDate) < cacheExpiration,
              let expenses = try? JSONDecoder().decode([Expense].self, from: data) else {
            return nil
        }
        return expenses
    }
    
    func clear() throws {
        if FileManager.default.fileExists(atPath: cacheURL.path) {
            try FileManager.default.removeItem(at: cacheURL)
        }
    }
}