import UIKit

struct DSCardViewModel {
    enum Style {
        case `default`
        case highlighted
        case disabled
    }
    
    let style: Style
    let contentView: UIView
    
    init(style: Style = .default, contentView: UIView) {
        self.style = style
        self.contentView = contentView
    }
}

class DSCardView: UIView {
    private let contentContainer = UIView()
    private var viewModel: DSCardViewModel?
    
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
        layer.cornerRadius = DSTokens.CornerRadius.medium
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentContainer)
        
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: topAnchor, constant: DSTokens.Spacing.small),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DSTokens.Spacing.small),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DSTokens.Spacing.small),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -DSTokens.Spacing.small)
        ])
    }
    
    func configure(with viewModel: DSCardViewModel) {
        self.viewModel = viewModel
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
        contentContainer.addSubview(viewModel.contentView)
        
        viewModel.contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewModel.contentView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            viewModel.contentView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            viewModel.contentView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            viewModel.contentView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
        
        switch viewModel.style {
        case .default:
            backgroundColor = DSTokens.Color.background
            alpha = 1.0
        case .highlighted:
            backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            alpha = 1.0
        case .disabled:
            backgroundColor = DSTokens.Color.background
            alpha = 0.5
        }
    }
}