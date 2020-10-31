//
//  AppIconPickerViewController.swift
//  Paku
//
//  Created by Kyle Bashour on 10/30/20.
//

import UIKit

class AppIconPickerViewController: UITableViewController {

    init() {
        super.init(style: .grouped)
        tableView.register(cell: AppIconCell.self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AppIconOption.all.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = AppIconOption.all[indexPath.row]
        let cell = tableView.dequeue(for: indexPath) as AppIconCell
        cell.display(option: option, selected: UIApplication.shared.alternateIconName == option.key)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let option = AppIconOption.all[indexPath.row]

        UIApplication.shared.setAlternateIconName(option.key) { _ in
            self.tableView.reloadData()
        }
    }
}

private class AppIconCell: UITableViewCell {

    private let icon = UIImageView()
    private let label = UILabel(font: .systemFont(ofSize: 17, weight: .medium))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.spacing = 10

        contentView.addSubview(stack)
        stack.pinEdges(to: contentView.layoutMarginsGuide)

        icon.pinSize(to: 60)
        icon.layer.borderWidth = .pixel
        icon.layer.borderColor = UIColor.separator.cgColor
        icon.layer.masksToBounds = true
        icon.layer.cornerCurve = .continuous
        icon.layer.cornerRadius = 60 * 0.2237
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func display(option: AppIconOption, selected: Bool) {
        icon.image = UIImage(named: option.imageName)
        label.text = option.name
        accessoryType = selected ? .checkmark : .none
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        icon.layer.borderColor = UIColor.separator.cgColor
    }
}
