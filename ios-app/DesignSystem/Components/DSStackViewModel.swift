import UIKit

struct DSStackViewModel {
    enum Axis {
        case horizontal
        case vertical
    }
    
    enum Alignment {
        case leading
        case center
        case trailing
        case fill
    }
    
    let axis: Axis
    let alignment: Alignment
    let spacing: CGFloat
    let views: [UIView]
    
    init(axis: Axis = .vertical, alignment: Alignment = .fill, spacing: CGFloat = DSTokens.Spacing.medium, views: [UIView]) {
        self.axis = axis
        self.alignment = alignment
        self.spacing = spacing
        self.views = views
    }
}

class DSStackView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(with viewModel: DSStackViewModel) {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        axis = viewModel.axis == .horizontal ? .horizontal : .vertical
        spacing = viewModel.spacing
        
        switch viewModel.alignment {
        case .leading:
            alignment = .leading
        case .center:
            alignment = .center
        case .trailing:
            alignment = .trailing
        case .fill:
            alignment = .fill
        }
        
        viewModel.views.forEach { addArrangedSubview($0) }
    }
}