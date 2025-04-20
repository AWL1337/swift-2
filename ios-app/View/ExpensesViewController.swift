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
    
    private let logoutButton = DSButton()
    private let stackView = DSStackView()
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
        view.backgroundColor = DSTokens.Color.background
        title = "Expenses"
        
        logoutButton.configure(with: DSButtonViewModel(
            title: "Logout",
            style: .secondary,
            action: { [weak self] in
                self?.logoutTapped()
            }
        ))
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        stackView.configure(with: DSStackViewModel(
            axis: .vertical,
            alignment: .fill,
            spacing: DSTokens.Spacing.medium,
            views: [tableView, logoutButton]
        ))
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: DSTokens.Spacing.large),
            logoutButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -DSTokens.Spacing.large)
        ])
    }
    
    private func bindViewModel() {
        viewModel.expenses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] expenses in
                self?.tableManager.update(with: expenses)
                self?.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.setLoading(isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message {
                    self?.showError(message)
                }
            }
            .store(in: &cancellables)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func setLoading(_ isLoading: Bool) {
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
        logout()
    }
    
    @objc private func refreshData() {
        viewModel.fetchExpenses()
    }
    
    func didSelectExpense(_ expense: ExpenseItem) {
        selectionDelegate?.didSelectExpense(expense)
    }
}
