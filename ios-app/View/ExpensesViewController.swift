import UIKit
import Combine

protocol ExpensesViewControllerDelegate: AnyObject {
    func didRequestLogout()
}

protocol ExpenseSelectionDelegate: AnyObject {
    func didSelectExpense(_ expense: ExpenseItem)
}

protocol ExpensesViewControllerProtocol: AnyObject {
    var tableView: UITableView { get }
    
    func reloadData()
    func showError(_ message: String)
    func setLoading(_ isLoading: Bool)
    func logout()
}

class ExpensesViewController: UIViewController, ExpensesViewControllerProtocol, TableManagerDelegate {
    private let viewModel: ExpensesViewModel
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: ExpensesViewControllerDelegate?
    weak var selectionDelegate: ExpenseSelectionDelegate?
    private let tableManager: TableManagerProtocol
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Logout", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        return rc
    }()
    
    init(viewModel: ExpensesViewModel, tableManager: TableManagerProtocol = TableManager()) {
        self.viewModel = viewModel
        self.tableManager = tableManager
        super.init(nibName: nil, bundle: nil)
        (tableManager as? TableManager)?.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        tableManager.setDataSource(for: tableView)
        viewModel.fetchExpenses()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Expenses"
        
        view.addSubview(tableView)
        view.addSubview(logoutButton)
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -16),
            
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.expenses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] expenses in
                print("ExpensesViewController: Loaded expenses: \(expenses.count)")
                self?.tableManager.update(with: expenses)
                self?.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                print("ExpensesViewController: Loading: \(isLoading)")
                self?.setLoading(isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message {
                    print("ExpensesViewController: Error: \(message)")
                    self?.showError(message)
                }
            }
            .store(in: &cancellables)
    }
    
    func reloadData() {
        print("ExpensesViewController: Reloading table with \(viewModel.expenses.value.count) expenses")
        tableView.reloadData()
    }
    
    func showError(_ message: String) {
        print("ExpensesViewController: Showing error: \(message)")
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func setLoading(_ isLoading: Bool) {
        print("ExpensesViewController: Set loading state: \(isLoading)")
        if isLoading {
            refreshControl.beginRefreshing()
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    func logout() {
        delegate?.didRequestLogout()
    }
    
    @objc private func logoutTapped() {
        print("ExpensesViewController: Logout button tapped")
        logout()
    }
    
    @objc private func refreshData() {
        print("ExpensesViewController: Pull-to-Refresh triggered")
        viewModel.fetchExpenses()
    }
    
    func didSelectExpense(_ expense: ExpenseItem) {
        print("ExpensesViewController: Delegate selected expense: \(expense.amount) - \(expense.category)")
        selectionDelegate?.didSelectExpense(expense)
    }
}
