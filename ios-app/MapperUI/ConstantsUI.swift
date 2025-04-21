import UIKit

// Типы вьюшек для маппинга
enum DSViewType: String {
    case contentView
    case stackView
    case label
    case button
    case textInput
    case cardView
}

// Токены отступов
enum DSSpacingToken: String {
    case small
    case medium
    case large
    
    var value: CGFloat {
        switch self {
        case .small: return DSTokens.Spacing.small
        case .medium: return DSTokens.Spacing.medium
        case .large: return DSTokens.Spacing.large
        }
    }
}

// Токены цветов
enum DSColorToken: String {
    case primary
    case secondary
    case background
    case error
    
    var color: UIColor {
        switch self {
        case .primary: return DSTokens.Color.primary
        case .secondary: return DSTokens.Color.secondary
        case .background: return DSTokens.Color.background
        case .error: return DSTokens.Color.error
        }
    }
}
