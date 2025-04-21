import Foundation

// Модель для декодирования JSON, описывающая вьюшку и её сабвьюшки
public struct ViewModelUI: Codable {
    let type: String
    let content: Content
    let subviews: [ViewModelUI]?
    
    struct Content: Codable {
        let style: String?
        let backgroundColor: String?
        let spacing: String?
        let text: String?
        let placeholder: String?
        let action: Action?
        let isHidden: Bool?
        
        struct Action: Codable {
            let type: String
            let context: String
        }
        
        enum CodingKeys: String, CodingKey {
            case style, backgroundColor, spacing, text, placeholder, action, isHidden
        }
    }
}
