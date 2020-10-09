import UIKit

protocol Reusable {}

extension Reusable {
    static var reuseIdentifier: String { return String(describing: self) }
}
