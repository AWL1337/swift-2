import UIKit

extension MapperUI {
    func configureContentView(_ model: ViewModelUI) -> UIView {
        let view = UIView()
        if let backgroundColor = model.content.backgroundColor,
           let colorToken = DSColorToken(rawValue: backgroundColor) {
            view.backgroundColor = colorToken.color
        }
        _ = configureSubviews(for: view, subviews: model.subviews)
        return view
    }
    
    func configureStackView(_ model: ViewModelUI) -> UIView {
        let spacing = model.content.spacing.flatMap { DSSpacingToken(rawValue: $0)?.value } ?? DSTokens.Spacing.medium
        let stackView = DSStackView()
        stackView.configure(with: DSStackViewModel(
            axis: .vertical,
            alignment: .fill,
            spacing: spacing,
            views: []
        ))
        _ = configureSubviews(for: stackView, subviews: model.subviews)
        return stackView
    }
    
    func configureLabel(_ model: ViewModelUI) -> UIView {
        let style = DSLabelViewModel.Style.fromString(model.content.style)
        let text = model.content.text ?? ""
        let isHidden = model.content.isHidden ?? false
        let viewModel = DSLabelViewModel(text: text, style: style)
        let label = DSLabel()
        label.configure(with: viewModel)
        label.isHidden = isHidden
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func configureButton(_ model: ViewModelUI) -> UIView {
        let title = model.content.text ?? "Button"
        let style = DSButtonViewModel.Style.fromString(model.content.style)
        let action: (() -> Void)? = {
            if let action = model.content.action, action.type == "print" {
                return { print(action.context) }
            }
            return nil
        }()
        let viewModel = DSButtonViewModel(title: title, style: style, action: action)
        let button = DSButton()
        button.configure(with: viewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        return button
    }
    
    func configureTextInput(_ model: ViewModelUI) -> UIView {
        let placeholder = model.content.placeholder ?? ""
        let text = model.content.text
        let style = DSTextInputViewModel.Style.fromString(model.content.style)
        let viewModel = DSTextInputViewModel(
            placeholder: placeholder,
            style: style,
            text: text,
            onTextChanged: { [weak self] text in
                if let action = model.content.action, action.type == "print" {
                    print("\(action.context): \(text)")
                }
                self?.textInputHandlers[model.type + (model.content.placeholder ?? "")]?(text)
            }
        )
        let textInput = DSTextInput()
        textInput.configure(with: viewModel)
        textInput.translatesAutoresizingMaskIntoConstraints = false
        return textInput
    }
    
    func configureCardView(_ model: ViewModelUI) -> UIView {
        let style = DSCardViewModel.Style.fromString(model.content.style)
        let contentView = UIView()
        let stackView = configureSubviews(for: contentView, subviews: model.subviews)
        let viewModel = DSCardViewModel(style: style, contentView: stackView)
        let cardView = DSCardView()
        cardView.configure(with: viewModel)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }
}
