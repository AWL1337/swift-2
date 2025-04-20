import UIKit

protocol TableManagerProtocol {
    func setDataSource(for tableView: UITableView)
    func update(with items: [ExpenseItem])
}

protocol TableManagerDelegate: AnyObject {
    func didSelectExpense(_ expense: ExpenseItem)
}

class TableManager: NSObject, TableManagerProtocol, UITableViewDataSource, UITableViewDelegate {
    private var items: [ExpenseItem] = []
    weak var delegate: TableManagerDelegate?
    
    func setDataSource(for tableView: UITableView) {
        tableView.register(GenericCell<ExpenseView>.self, forCellReuseIdentifier: "ExpenseCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func update(with items: [ExpenseItem]) {
        self.items = items
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("TableManager: Table view rows: \(items.count)")
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as! GenericCell<ExpenseView>
        let item = items[indexPath.row]
        cell.configure(with: item)
        print("TableManager: Configuring cell for expense: \(item.amount) - \(item.category)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        print("TableManager: Selected expense: \(item.amount) - \(item.category)")
        delegate?.didSelectExpense(item)
    }
}
