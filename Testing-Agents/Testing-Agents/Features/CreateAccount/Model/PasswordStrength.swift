import SwiftUI

enum PasswordStrength {
    case weak
    case fair
    case strong

    var label: LocalizedStringKey {
        switch self {
        case .weak: "Weak"
        case .fair: "Fair"
        case .strong: "Strong"
        }
    }

    var color: Color {
        switch self {
        case .weak: Color(red: 192.0 / 255.0, green: 57.0 / 255.0, blue: 43.0 / 255.0)
        case .fair: Color(red: 212.0 / 255.0, green: 106.0 / 255.0, blue: 0.0 / 255.0)
        case .strong: Color(red: 26.0 / 255.0, green: 122.0 / 255.0, blue: 74.0 / 255.0)
        }
    }

    static func evaluate(_ password: String) -> PasswordStrength? {
        guard !password.isEmpty else { return nil }

        let hasUppercase = password.contains(where: \.isUppercase)
        let hasNumber = password.contains(where: \.isNumber)
        let hasSpecial = password.contains(where: { "!@#$%^&*()_+-=[]{}|;':\",./<>?".contains($0) })
        let isLongEnough = password.count >= 8

        let criteriaMet = [hasUppercase, hasNumber, hasSpecial, isLongEnough].filter { $0 }.count

        if criteriaMet >= 4 {
            return .strong
        } else if password.count >= 4 && criteriaMet >= 2 {
            return .fair
        } else {
            return .weak
        }
    }
}
