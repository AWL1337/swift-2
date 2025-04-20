import UIKit

class ExpenseView: UIView, ConfigurableView {
    private let amountLabel = DSLabel()
    private let categoryLabel = DSLabel()
    private let dateLabel = DSLabel()
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        return iv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    private let contentStackView = DSStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        amountLabel.configure(with: DSLabelViewModel(text: "", style: .body))
        categoryLabel.configure(with: DSLabelViewModel(text: "", style: .body))
        dateLabel.configure(with: DSLabelViewModel(text: "", style: .caption))
        
        contentStackView.configure(with: DSStackViewModel(
            axis: .vertical,
            alignment: .leading,
            spacing: DSTokens.Spacing.small,
            views: [amountLabel, categoryLabel, dateLabel]
        ))
        
        let cardView = DSCardView()
        cardView.configure(with: DSCardViewModel(style: .default, contentView: contentStackView))
        
        addSubview(cardView)
        addSubview(imageView)
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            cardView.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -DSTokens.Spacing.medium),
            
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DSTokens.Spacing.medium),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    func configure(with viewModel: ExpenseItem) {
        amountLabel.configure(with: DSLabelViewModel(text: viewModel.amount, style: .body))
        categoryLabel.configure(with: DSLabelViewModel(text: viewModel.category, style: .body))
        dateLabel.configure(with: DSLabelViewModel(text: viewModel.date, style: .caption))
        
        imageView.image = nil
        activityIndicator.startAnimating()
        
        if let imageURL = viewModel.imageURL, let url = URL(string: imageURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    if let data = data, let image = UIImage(data: data) {
                        self?.imageView.image = image
                    } else {
                        self?.imageView.image = UIImage(named: "placeholder")
                    }
                }
            }.resume()
        } else {
            activityIndicator.stopAnimating()
            imageView.image = UIImage(named: "placeholder")
        }
    }
}
