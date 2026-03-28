import Foundation

struct Supply: Codable, Identifiable {
    let id: UUID?
    let name: String
    let category: String
    var isCustom: Bool
    var active: Bool
}

struct SuppliesResponse: Decodable {
    let supplies: [Supply]
}

struct SuppliesRequest: Encodable {
    let supplies: [SupplyInput]
}

struct SupplyInput: Encodable {
    let name: String
    let category: String
    let active: Bool
    let isCustom: Bool
}
