//
//  SettingsViewController.swift
//  Paku
//
//  Created by Kyle Bashour on 10/30/20.
//

import StoreKit
import UIKit
import SafariServices

class SettingsViewController: UITableViewController {

    static var sessionID: String?

    struct Item {
        enum Detail {
            case none
            case text(String)
        }

        var name: String
        var detail: Detail = .none
        var icon: UIImage?
        var iconTint: UIColor?
        var accessory: UITableViewCell.AccessoryType
        var action: (() -> Void)?
    }

    struct Section {
        var header: String?
        var items: [Item]
        var footer: String?
    }

    private var settings: [Section] = [] {
        didSet { tableView.reloadData() }
    }

    init() {
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let sessionID = Self.sessionID {
           if UserDefaults.standard.string(forKey: "rating-session") != sessionID,
              let scene = view.window?.windowScene {
                SKStoreReviewController.requestReview(in: scene)
                UserDefaults.standard.setValue(Self.sessionID, forKey: "rating-session")
           }
        } else {
            Self.sessionID = UUID().uuidString
        }
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
        cell.accessoryType = item.accessory
        cell.imageView?.image = item.icon
        cell.imageView?.tintColor = item.iconTint

        cell.detailTextLabel?.text = ""

        switch item.detail {
        case .none:
            break
        case .text(let text):
            cell.detailTextLabel?.text = text
        }

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
//                header: "Air Quality",
//                items: [
//                    Item(
//                        name: "Correction",
//                        detail: .text(UserDefaults.shared.settings.conversion.name),
//                        icon: UIImage(systemName: "equal.circle"),
//                        iconTint: .systemBlue,
//                        accessory: .disclosureIndicator
//                    ),
//                ]
//            ),
//
//            Section(
//                header: "Map",
                items: [
//                    Item(
//                        name: "Location Type",
//                        detail: .text(UserDefaults.shared.settings.location.name),
//                        icon: UIImage(systemName: UserDefaults.shared.settings.location.symbolName),
//                        iconTint: UserDefaults.shared.settings.location.tint,
//                        accessory: .disclosureIndicator
//                    ),
//
//                    Item(
//                        name: "Group Sensors",
//                        detail: .none,
//                        icon: UIImage(systemName: "circlebadge.2.fill"),
//                        iconTint: .systemGreen,
//                        accessory: .none
//                    ),
                    Item(
                        name: "App Icon",
                        detail: .text(AppIconOption.option(for: UIApplication.shared.alternateIconName).name),
                        icon: appIcon(),
                        iconTint: .systemPurple,
                        accessory: .disclosureIndicator,
                        action: { [weak self] in
                            self?.show(AppIconPickerViewController(), sender: self)
                        }
                    ),
                    Item(
                        name: "Hidden Sensors",
                        detail: .text("\(UserDefaults.shared.settings.hiddenSensors.count)"),
                        icon: UIImage(systemName: "eye.slash.fill"),
                        iconTint: .systemFill,
                        accessory: .disclosureIndicator,
                        action: { [weak self] in
                            self?.show(HiddenSensorsViewController(), sender: self)
                        }
                    ),
                ],
                footer: "Hidden sensors will not be used in the widget."
            ),

            Section(
                header: "Show the love",
                items: [
                    Item(
                        name: "Tip Jar",
                        icon: UIImage(systemName: "heart.fill"),
                        iconTint: .systemRed,
                        accessory: .disclosureIndicator,
                        action: { [weak self] in
                            self?.show(TippingViewController(), sender: self)
                        }
                    ),
                    Item(
                        name: "Leave a Review",
                        icon: UIImage(systemName: "star.fill"),
                        iconTint: .systemYellow,
                        accessory: .disclosureIndicator,
                        action: { [weak self] in
                            self?.review()
                        }
                    ),
                    Item(
                        name: "Share a link to Paku",
                        icon: UIImage(systemName: "square.and.arrow.up"),
                        iconTint: .systemBlue,
                        accessory: .disclosureIndicator,
                        action: { [weak self] in
                            self?.share()
                        }
                    ),
                ]
            ),

            Section(
                header: "Boring stuff",
                items: [
                    Item(
                        name: "Privacy Policy",
                        icon: UIImage(systemName: "doc.plaintext.fill"),
                        iconTint: .systemGray,
                        accessory: .disclosureIndicator,
                        action: { [weak self] in
                            let url = URL(string: "https://paku.app/privacy")!
                            self?.present(SFSafariViewController(url: url), animated: true)
                        }
                    ),
                    Item(
                        name: "Version",
                        detail: .text(Bundle.main.version()),
                        icon: UIImage(systemName: "barcode"),
                        iconTint: .label,
                        accessory: .none
                    )
                ]
            ),
        ]
    }

    private func share() {
        clearSelection()
        let url = URL(string: "https://apps.apple.com/us/app/paku-for-purpleair/id1534130193")!
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }

    private func review() {
        clearSelection()
        let url = URL(string: "itms-apps://itunes.apple.com/us/app/id1534130193?action=write-review")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func appIcon() -> UIImage {
        let size = CGSize(width: 24, height: 24)
        let bounds = CGRect(origin: .zero, size: size)
        let imageView = UIImageView(frame: bounds)

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerCurve = .continuous
        imageView.layer.cornerRadius = size.height * 0.2237
        imageView.image = UIImage(named: AppIconOption.option(for: UIApplication.shared.alternateIconName).imageName)

        return UIGraphicsImageRenderer(bounds: bounds).image { context in
            imageView.layer.render(in: context.cgContext)
        }
    }
}
