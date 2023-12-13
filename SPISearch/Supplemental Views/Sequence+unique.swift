import Foundation

// from https://www.avanderlee.com/swift/unique-values-removing-duplicates-array/
extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
