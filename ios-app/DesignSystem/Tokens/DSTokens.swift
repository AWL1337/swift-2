import UIKit

enum DSTokens {
    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
    
    enum CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
    }
    
    enum Font {
        static let title = UIFont.systemFont(ofSize: 18, weight: .bold)
        static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let caption = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    enum Color {
        static let primary = UIColor.systemBlue
        static let secondary = UIColor.systemGray
        static let background = UIColor.white
        static let text = UIColor.black
        static let error = UIColor.systemRed
    }
}