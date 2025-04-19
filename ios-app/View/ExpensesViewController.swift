import UIKit
import Combine

protocol ExpensesViewControllerDelegate: AnyObject {
    func didRequestLogout()
}

protocol ExpensesViewControllerProtocol: AnyObject {
    var tableView: UITableView { get }
    
    func reloadData()
    func showError(_ message: String)
    func setLoading(_ isLoading: Bool)
    func logout()
}

class ExpensesViewController: UIViewController, ExpensesViewControllerProtocol {
    private let viewModel: ExpensesViewModel
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: ExpensesViewControllerDelegate?
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "ExpenseCell")
        return tv
    }()
    
    private let logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Logout", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    init(viewModel: ExpensesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchExpenses()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Expenses"
        
        view.addSubview(tableView)
        view.addSubview(logoutButton)
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -16),
            
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.expenses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] expenses in
                print("Loaded expenses: \(expenses.count)")
                self?.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                print("Loading: \(isLoading)")
                self?.setLoading(isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message {
                    print("Error: \(message)")
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
        print("Set loading state: \(isLoading)")
    }
    
    func logout() {
        delegate?.didRequestLogout()
    }
    
    @objc private func logoutTapped() {
        logout()
    }
}

extension ExpensesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.expenses.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath)
        let expense = viewModel.expenses.value[indexPath.row]
        cell.textLabel?.text = "\(expense.amount) - \(expense.category) (\(expense.date))"
        return cell
    }
}
