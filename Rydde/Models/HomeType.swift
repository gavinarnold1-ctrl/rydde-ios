import Foundation

enum HomeType: String, CaseIterable, Identifiable {
    case studio
    case apartment
    case house
    case dorm
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .studio: return "Studio"
        case .apartment: return "Apartment"
        case .house: return "House"
        case .dorm: return "Dorm"
        case .other: return "Other"
        }
    }

    var defaultRooms: [String] {
        switch self {
        case .studio:
            return ["Kitchen", "Bathroom", "Living Area", "Closet"]
        case .apartment:
            return ["Kitchen", "Bathroom", "Bedroom", "Living Room", "Hallway"]
        case .house:
            return ["Kitchen", "Bathroom", "Bedroom", "Living Room", "Hallway", "Garage", "Laundry Room", "Dining Room"]
        case .dorm:
            return ["Bedroom", "Bathroom", "Closet"]
        case .other:
            return ["Kitchen", "Bathroom", "Bedroom", "Living Room"]
        }
    }
}
