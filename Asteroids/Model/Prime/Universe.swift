enum Universe: Int, CaseIterable {
    case freeFly = 1
    case center
    case big
    case horizontal
    case vertical
    case dark
    
    // Function to get the next universe, wraps around if it's the last one
    func nextUniverse() -> Universe {
        let nextValue = rawValue + 1
        return Universe(rawValue: nextValue) ?? .freeFly
    }
}

// Function to get all enum values
func getEnumValues() -> [Int] {
    return Universe.allCases.map { $0.rawValue }
}

// Function to get the enum name for a given raw value
func getEnumName(for value: Int) -> String? {
    return Universe(rawValue: value)?.description
}

// Extension to provide string descriptions for Universe enum
extension Universe: CustomStringConvertible {
    var description: String {
        switch self {
        case .freeFly:
            return "FREE FLY"
        case .center:
            return "CENTER"
        case .big:
            return "BIG"
        case .horizontal:
            return "HORIZONTAL"
        case .vertical:
            return "VERTICAL"
        case .dark:
            return "DARK"
        }
    }
}
