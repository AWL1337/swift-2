import Foundation

protocol SummaryViewController {
    
    func loadView()
    
    func viewDidLoad()
    
    func setupTableView()
    
    func setupPeriodTracking()
    
    func loadExpenses(startDate: Date?, endDate: Date?)
    
    func showError(_ message: String)
}
