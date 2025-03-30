import Foundation

import UIKit

protocol AddExpenseController {
   
    func loadView()
    
    func viewDidLoad()
    
    func setupActions()
    
    func saveTapped()

    func showError(_ message: String)
}
