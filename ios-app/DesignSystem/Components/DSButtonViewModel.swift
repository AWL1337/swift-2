import UIKit

struct DSButtonViewModel {
    enum Style {
        case primary
        case secondary
        case destructive
    }
    
    let title: String
    let style: Style
    let action: (() -> Void)?
    
    init(title: String, style: Style = .primary, action: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.action = action
    }
}

class DSButton: UIButton {
    private var viewModel: DSButtonViewModel?
    
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
        titleLabel?.font = DSTokens.Font.body
        layer.cornerRadius = DSTokens.CornerRadius.medium
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    func configure(with viewModel: DSButtonViewModel) {
        self.viewModel = viewModel
        setTitle(viewModel.title, for: .normal)
        setTitleColor(.white, for: .normal)
        
        switch viewModel.style {
        case .primary:
            backgroundColor = DSTokens.Color.primary
        case .secondary:
            backgroundColor = DSTokens.Color.secondary
        case .destructive:
            backgroundColor = DSTokens.Color.error
        }
    }
    
    @objc private func buttonTapped() {
        viewModel?.action?()
    }
}