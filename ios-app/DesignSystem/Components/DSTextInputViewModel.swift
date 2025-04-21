import UIKit

struct DSTextInputViewModel {
    enum Style {
        case `default`
        case secure
        case error
    }
    
    let placeholder: String
    let style: Style
    let text: String?
    let onTextChanged: ((String) -> Void)?
    
    init(placeholder: String, style: Style = .default, text: String? = nil, onTextChanged: ((String) -> Void)? = nil) {
        self.placeholder = placeholder
        self.style = style
        self.text = text
        self.onTextChanged = onTextChanged
    }
}

class DSTextInput: UITextField {
    private var viewModel: DSTextInputViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        font = DSTokens.Font.body
        borderStyle = .roundedRect
        layer.borderWidth = 1
        layer.cornerRadius = DSTokens.CornerRadius.small
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    func configure(with viewModel: DSTextInputViewModel) {
        self.viewModel = viewModel
        placeholder = viewModel.placeholder
        text = viewModel.text
        
        switch viewModel.style {
        case .default:
            layer.borderColor = DSTokens.Color.secondary.cgColor
            isSecureTextEntry = false
        case .secure:
            layer.borderColor = DSTokens.Color.secondary.cgColor
            isSecureTextEntry = true
        case .error:
            layer.borderColor = DSTokens.Color.error.cgColor
            isSecureTextEntry = false
        }
    }
    
    @objc private func textDidChange() {
        viewModel?.onTextChanged?(text ?? "")
    }
}