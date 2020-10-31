//
//  SensorListView.swift
//  Paku
//
//  Created by Kyle Bashour on 10/26/20.
//

import UIKit

class SensorListView: UIView, UITableViewDataSource, UITableViewDelegate {

    private let maximumHeight: CGFloat
    private let annotations: [SensorAnnotation]
    private let tableView = UITableView()

    private let onSelect: (SensorAnnotation) -> Void

    init(annotations: [SensorAnnotation], maximumHeight: CGFloat, onSelect: @escaping (SensorAnnotation) -> Void) {
        self.maximumHeight = maximumHeight
        self.annotations = annotations
        self.onSelect = onSelect

        super.init(frame: .zero)

        addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(cell: UITableViewCell.self)
        tableView.pinEdges(to: self, insets: .init(vertical: 10, horizontal: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.isScrollEnabled = tableView.contentSize.height > tableView.frame.height
    }

    override var intrinsicContentSize: CGSize {
        tableView.layoutIfNeeded()
        let height = min(tableView.contentSize.height, maximumHeight) + 20
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        annotations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(for: indexPath) as UITableViewCell
        cell.textLabel?.text = annotations[indexPath.row].sensor.info.label
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelect(annotations[indexPath.row])
    }
}
