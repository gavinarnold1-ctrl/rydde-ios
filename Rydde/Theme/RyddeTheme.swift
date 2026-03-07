import SwiftUI

enum RyddeTheme {

    // MARK: - Colors

    enum Colors {
        // Light mode
        static let fjord = UIColor(hex: 0x1B3A4B)
        static let moss = UIColor(hex: 0x4A7A42)
        static let sage = UIColor(hex: 0xA8C4A0)
        static let meadow = UIColor(hex: 0xE2EDE0)
        static let dew = UIColor(hex: 0xD5E5D1)
        static let linen = UIColor(hex: 0xF0EDE6)
        static let snow = UIColor(hex: 0xF7F9F8)
        static let frost = UIColor(hex: 0xE8F0ED)
        static let mist = UIColor(hex: 0xC8D5CE)
        static let stone = UIColor(hex: 0x8B9A8E)
        static let midnight = UIColor(hex: 0x0F1F28)
        static let birch = UIColor(hex: 0xD4C5A9)

        // Dark mode
        static let darkBg = UIColor(hex: 0x0F1F28)
        static let darkCard = UIColor(hex: 0x1B3A4B)
        static let darkMoss = UIColor(hex: 0x5A9A52)
        static let darkSage = UIColor(hex: 0x7BA87A)

        // Adaptive colors — respect system setting, no manual toggle in V1
        static let background = UIColor { traits in
            traits.userInterfaceStyle == .dark ? darkBg : snow
        }

        static let cardBackground = UIColor { traits in
            traits.userInterfaceStyle == .dark ? darkCard : frost
        }

        static let primaryText = UIColor { traits in
            traits.userInterfaceStyle == .dark ? snow : fjord
        }

        static let secondaryText = UIColor { traits in
            traits.userInterfaceStyle == .dark ? mist : stone
        }

        static let accent = UIColor { traits in
            traits.userInterfaceStyle == .dark ? darkMoss : moss
        }

        static let border = UIColor { traits in
            traits.userInterfaceStyle == .dark ? darkCard : mist
        }

        static let surface = UIColor { traits in
            traits.userInterfaceStyle == .dark ? darkBg : snow
        }

        static let selectedBackground = UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: 0x2A5A34) : dew
        }

        static let rationaleBackground = UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: 0x1A3520) : meadow
        }
    }

    // MARK: - Fonts

    enum Fonts {
        static let headingLarge = Font.custom("DMSans-SemiBold", size: 32)
        static let headingMedium = Font.custom("DMSans-SemiBold", size: 24)
        static let headingSmall = Font.custom("DMSans-SemiBold", size: 20)
        static let headingTask = Font.custom("DMSans-SemiBold", size: 28)
        static let bodyLarge = Font.custom("DMSans-Regular", size: 17)
        static let bodyMedium = Font.custom("DMSans-Medium", size: 16)
        static let bodyMedium18 = Font.custom("DMSans-Medium", size: 18)
        static let bodyMedium12 = Font.custom("DMSans-Medium", size: 12)
        static let bodyMedium11 = Font.custom("DMSans-Medium", size: 11)
        static let body = Font.custom("DMSans-Regular", size: 15)
        static let bodySmall = Font.custom("DMSans-Regular", size: 13)
        static let bodySmall14 = Font.custom("DMSans-Regular", size: 14)
        static let caption = Font.custom("DMSans-Regular", size: 11)
        static let buttonLabel = Font.custom("DMSans-SemiBold", size: 17)
        static let timer = Font.custom("DMSans-Regular", size: 48)
        static let durationPicker = Font.custom("DMSans-Medium", size: 24)

        // Dynamic Type body variants
        static let bodyDynamic = Font.custom("DMSans-Regular", size: 15, relativeTo: .body)
        static let bodySmallDynamic = Font.custom("DMSans-Regular", size: 13, relativeTo: .footnote)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let card: CGFloat = 12
        static let button: CGFloat = 8
        static let bottomSheet: CGFloat = 24
    }

    // MARK: - Animation

    enum Animation {
        static let standard = SwiftUI.Animation.easeOut(duration: 0.3)
        static let major = SwiftUI.Animation.easeOut(duration: 0.5)
    }
}

// MARK: - UIColor Hex Extension

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: alpha
        )
    }
}
