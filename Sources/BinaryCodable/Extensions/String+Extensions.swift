import Foundation

extension String {

    func indented(by indentation: String = "  ") -> String {
        components(separatedBy: "\n")
            .map { $0.trimmed == "" ? $0 : indentation + $0 }
            .joined(separator: "\n")
    }

    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
