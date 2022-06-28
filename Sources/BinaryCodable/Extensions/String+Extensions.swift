import Foundation

extension String {

    func indented(by indentation: String = "  ") -> String {
        components(separatedBy: "\n")
            .map { indentation + $0 }
            .joined(separator: "\n")
    }
}
