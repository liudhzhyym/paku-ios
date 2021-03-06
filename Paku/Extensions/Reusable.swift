import UIKit

protocol Reusable {}

extension Reusable {
    static var reuseIdentifier: String { return String(describing: self) }
}

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}

extension UITableView {
    func register(cell: UITableViewCell.Type) {
        register(cell, forCellReuseIdentifier: cell.reuseIdentifier)
    }

    func register(view: UITableViewHeaderFooterView.Type) {
        register(view, forHeaderFooterViewReuseIdentifier: view.reuseIdentifier)
    }

    func dequeue<T>(for indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Register cell of type \(T.self) before dequeueing")
        }

        return cell
    }

    func dequeue<T>() -> T where T: UITableViewHeaderFooterView {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("Register table view header footer view of type \(T.self) before dequeueing")
        }

        return view
    }
}
