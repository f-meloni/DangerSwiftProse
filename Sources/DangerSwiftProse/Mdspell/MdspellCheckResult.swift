import Foundation

struct MdspellCheckResult {
    private let checkResult: String
    let file: String

    init(file: String, checkResult: String) {
        self.file = file
        self.checkResult = checkResult
    }

    func violations() -> [MdspellCheckViolation] {
        return checkResult.split(separator: "\n").compactMap {
            let splittedLine = $0.split(separator: "|")

            guard splittedLine.count == 2 else {
                return nil
            }

            let splittedIndex = splittedLine[0].trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ":")
            let line = splittedIndex[0]
            let typoIndex = Int(splittedIndex[1]) ?? 0

            guard let fileContent = try? String(contentsOfFile: file),
                let typo = fileContent[String.Index(encodedOffset: typoIndex) ..< fileContent.endIndex]
                .components(separatedBy: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "[]()")))
                .first else {
                return nil
            }

            return MdspellCheckViolation(line: String(line), typo: String(typo))
        }
    }

    func toMarkdown() -> String? {
        let violations = self.violations()
        guard !violations.isEmpty else {
            return nil
        }

        let mdSpellReport = """
        ### Mdspell report on \(file):
        | Line | Typo |
        | ---- | ---- |\n
        """

        return violations.reduce(mdSpellReport) { result, violation in
            result + "| \(violation.line) | \(violation.typo) |\n"
        }
    }
}

extension MdspellCheckResult: Equatable {
    static func == (lhs: MdspellCheckResult, rhs: MdspellCheckResult) -> Bool {
        return lhs.file == rhs.file &&
            lhs.checkResult == rhs.checkResult
    }
}

struct MdspellCheckViolation {
    let line: String
    let typo: String
}

extension Array where Element == MdspellCheckResult {
    func toMarkdown() -> String {
        return compactMap { $0.toMarkdown() }.joined(separator: "\n")
    }
}

extension String {
    subscript(i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

    subscript(bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }

    subscript(bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }

    subscript(bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }

    subscript(bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }

    subscript(bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}

extension Substring {
    subscript(i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

    subscript(bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }

    subscript(bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }

    subscript(bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }

    subscript(bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }

    subscript(bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}