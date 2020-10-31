//
//  SettingsViewController.swift
//  Paku
//
//  Created by Kyle Bashour on 10/30/20.
//

import UIKit
import SafariServices

class SettingsViewController: UITableViewController {

    struct Item {
        var name: String
        var setting: String?
        var accessory: UITableViewCell.AccessoryType
        var action: (() -> Void)?
    }

    struct Section {
        var header: String?
        var items: [Item]
        var footer: String?
    }

    private lazy var settings = buildSettings() {
        didSet { tableView.reloadData() }
    }

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: .init(handler: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settings = buildSettings()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        settings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settings[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        let item = settings[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.setting
        cell.accessoryType = item.accessory
        return cell
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        settings[indexPath.section].items[indexPath.row].action != nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settings[indexPath.section].items[indexPath.row].action?()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        settings[section].header
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        settings[section].footer
    }

    private func buildSettings() -> [Section] {
        [
            Section(
                header: "AQI Settings",
                items: [
                    Item(
                        name: "Normalization",
                        setting: UserDefaults.shared.settings.conversion.name,
                        accessory: .disclosureIndicator,
                        action: {
                            print("Normalization")
                        }
                    ),
                    Item(
                        name: "Location Type",
                        setting: UserDefaults.shared.settings.location.name,
                        accessory: .disclosureIndicator,
                        action: {
                            print("Location Type")
                        }
                    )
                ]
            ),

            Section(header: "App Settings",
                items: [
                    Item(
                        name: "Hidden Sensors",
                        setting: "0",
                        accessory: .disclosureIndicator
                    ),
                    Item(
                        name: "App Icon",
                        setting: AppIconOption.name(for: UIApplication.shared.alternateIconName),
                        accessory: .disclosureIndicator,
                        action: { [weak self] in
                            self?.show(AppIconPickerViewController(), sender: self)
                        }
                    ),
                ]
            ),

            Section(
                items: [
                    Item(
                        name: "Privacy Policy",
                        accessory: .disclosureIndicator,
                        action: { [weak self] in
                            let url = URL(string: "https://paku.app/privacy")!
                            self?.present(SFSafariViewController(url: url), animated: true)
                        }
                    ),
                ],
                footer: "Version \(Bundle.main.version())"
            )
        ]
    }
}
