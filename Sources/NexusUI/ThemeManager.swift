import SwiftUI

public enum AppTheme: String, CaseIterable, Identifiable {
    case blue = "Corporate Blue"
    case gold = "Vibrant Gold"
    
    public var id: String { rawValue }
    
    public var primaryColor: Color {
        switch self {
        case .blue:
            return Color(hex: 0x15354f)
        case .gold:
            return Color(hex: 0xfac855)
        }
    }
    
    public var accentColor: Color {
        switch self {
        case .blue:
            return Color(hex: 0x4a90e2) // Lighter blue accent
        case .gold:
            return Color(hex: 0xffe082) // Lighter gold accent
        }
    }
}

public class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") public var currentTheme: AppTheme = .blue
    
    public static let shared = ThemeManager()
    
    private init() {}
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
