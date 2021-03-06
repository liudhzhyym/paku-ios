//
//  HiddenSensorsViewController.swift
//  Paku
//
//  Created by Kyle Bashour on 11/2/20.
//

import UIKit

class HiddenSensorsViewController: UITableViewController {

    class DataSource: UITableViewDiffableDataSource<String, Int> {
        override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
            return self.tableView(tableView, numberOfRowsInSection: section) == 0 ?
                "If a sensor seems like it’s misreporting, or you just don’t want it to show up, you can hide it from the map." : nil
        }
    }

    typealias Snapshot = NSDiffableDataSourceSnapshot<String, Int>

    private lazy var dataSource = makeDataSource()

    private var hiddenSensors = UserDefaults.shared.hiddenSensors {
        didSet { reload(animated: true) }
    }

    init() {
        super.init(style: .grouped)
        reload(animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Hidden Sensors"
        tableView.register(cell: Cell.self)
        tableView.dataSource = dataSource

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSettings),
            name: UserDefaults.didChangeNotification,
            object: nil)
    }

    @objc private func updateSettings() {
        if UserDefaults.shared.hiddenSensors != hiddenSensors {
            hiddenSensors = UserDefaults.shared.hiddenSensors
        }
    }

    private func reload(animated: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections(["Sensors"])
        snapshot.appendItems(UserDefaults.shared.hiddenSensors)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: animated)
        }
    }

    private func makeDataSource() -> DataSource {
        return .init(tableView: tableView) { tableView, indexPath, sensorID in
            let cell = tableView.dequeue(for: indexPath) as Cell
            cell.textLabel?.text = "Sensor ID \(sensorID)"
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sensor = dataSource.itemIdentifier(for: indexPath)!
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.clearSelection()
        })
        controller.addAction(UIAlertAction(title: "Show Sensor", style: .default) { _ in
            self.clearSelection()
            UserDefaults.shared.hiddenSensors.removeAll(where: { $0 == sensor })
        })

        controller.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)

        present(controller, animated: true, completion: nil)
    }
}

private class Cell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let font = textLabel!.font!
        textLabel?.font = .monospacedDigitSystemFont(ofSize: font.pointSize, weight: .regular)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
