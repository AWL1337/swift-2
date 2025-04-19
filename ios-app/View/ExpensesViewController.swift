import UIKit

class ExpensesViewController: UIViewController {
    private let viewModel: ExpensesViewModel
    
    init(viewModel: ExpensesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Expenses"
        
        bindViewModel()
        viewModel.fetchExpenses()
    }
    
    private func bindViewModel() {
        viewModel.expenses.bind { [weak self] expenses in
            print("Loaded expenses: \(expenses.count)")
        }
        
        viewModel.isLoading.bind { [weak self] isLoading in
            print("Loading: \(isLoading)")
        }
        
        viewModel.errorMessage.bind { [weak self] message in
            if let message = message {
                print("Error: \(message)")
            }
        }
    }
}
