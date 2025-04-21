import UIKit

struct DSLabelViewModel {
    enum Style {
        case title
        case body
        case caption
    }
    
    let text: String
    let style: Style
    let textColor: UIColor
    
    init(text: String, style: Style = .body, textColor: UIColor = DSTokens.Color.text) {
        self.text = text
        self.style = style
        self.textColor = textColor
    }
}

class DSLabel: UILabel {
    private var viewModel: DSLabelViewModel?
    
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
    }
    
    func configure(with viewModel: DSLabelViewModel) {
        self.viewModel = viewModel
        text = viewModel.text
        textColor = viewModel.textColor
        
        switch viewModel.style {
        case .title:
            font = DSTokens.Font.title
        case .body:
            font = DSTokens.Font.body
        case .caption:
            font = DSTokens.Font.caption
        }
    }
}