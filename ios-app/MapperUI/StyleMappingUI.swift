import Foundation

// Маппинг стилей для компонентов дизайн-системы
extension DSLabelViewModel.Style {
    static func fromString(_ string: String?) -> Self {
        switch string {
        case "title": return .title
        case "caption": return .caption
        default: return .body
        }
    }
}

extension DSButtonViewModel.Style {
    static func fromString(_ string: String?) -> Self {
        switch string {
        case "primary": return .primary
        case "secondary": return .secondary
        case "destructive": return .destructive
        default: return .primary
        }
    }
}

extension DSTextInputViewModel.Style {
    static func fromString(_ string: String?) -> Self {
        switch string {
        case "default": return .default
        case "secure": return .secure
        case "error": return .error
        default: return .default
        }
    }
}

extension DSCardViewModel.Style {
    static func fromString(_ string: String?) -> Self {
        switch string {
        case "default": return .default
        case "highlighted": return .highlighted
        case "disabled": return .disabled
        default: return .default
        }
    }
}
