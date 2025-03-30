import Foundation

protocol SummaryView {
   
    func reloadTableView()
    
    func updateTotal(_ total: Double)
    
    func setupUI()
    
    func setupActions()
    
    func datePickerChanged()
}
