import UIKit

// Протокол для маппера Backend Driven UI
public protocol MapperUIProtocol {
    func map(from model: ViewModelUI) -> UIView
}

// Базовая реализация маппера
public final class MapperUI: MapperUIProtocol {
    var textInputHandlers: [String: (String) -> Void] = [:]
    
    public init() {}
    
    public func map(from model: ViewModelUI) -> UIView {
        guard let viewType = DSViewType(rawValue: model.type) else {
            return UIView()
        }
        
        switch viewType {
        case .contentView:
            return configureContentView(model)
        case .stackView:
            return configureStackView(model)
        case .label:
            return configureLabel(model)
        case .button:
            return configureButton(model)
        case .textInput:
            return configureTextInput(model)
        case .cardView:
            return configureCardView(model)
        }
    }
    
    func configureSubviews(for view: UIView, subviews: [ViewModelUI]?) -> DSStackView {
        guard let subviews = subviews, !subviews.isEmpty else {
            return DSStackView()
        }
        
        let stackView: DSStackView = {
            if let stack = view as? DSStackView {
                return stack
            }
            let stack = DSStackView()
            stack.configure(with: DSStackViewModel(
                axis: .vertical,
                alignment: .fill,
                spacing: DSTokens.Spacing.medium,
                views: []
            ))
            view.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: view.topAnchor, constant: DSTokens.Spacing.small),
                stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DSTokens.Spacing.small),
                stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DSTokens.Spacing.small),
                stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -DSTokens.Spacing.small)
            ])
            return stack
        }()
        
        subviews.forEach { subviewModel in
            let subview = map(from: subviewModel)
            stackView.addArrangedSubview(subview)
        }
        
        return stackView
    }
}
