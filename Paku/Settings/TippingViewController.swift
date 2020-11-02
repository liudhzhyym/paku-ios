//
//  TippingViewController.swift
//  Paku
//
//  Created by Kyle Bashour on 11/1/20.
//

import UIKit
import StoreKit

private let priceFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter
}()

class TippingViewController: UITableViewController {

    private class DataSource: UITableViewDiffableDataSource<Section, Item> {
        var message: String?

        override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
            message
        }
    }

    private struct Metadata {
        let emoji: String
        let message: String
    }

    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private lazy var dataSource = makeDataSource()

    private let productIdentifiers: Set<String> = [
        "coffee_tip",
        "burrito_tip",
        "pizza_tip",
    ]

    private let metadata = [
        "coffee_tip": Metadata(emoji: "☕️", message: "Thanks for your support! Morning me appreciates it."),
        "burrito_tip": Metadata(emoji: "🌯", message: "Wow, that means a lot! Thanks for the meal."),
        "pizza_tip": Metadata(emoji: "🍕", message: "A whole pizza?! Thank you so much! Can’t wait to split it with the roomie :)"),
    ]


    private enum Section: Hashable {
        case storefront
    }

    private enum Item: Hashable {
        case product(SKProduct)
        case loading
    }

    private var products: [SKProduct] = [] {
        didSet { reload() }
    }

    private var purchasing: String? {
        didSet { reload() }
    }

    private var message: String? {
        didSet {
            dataSource.message = message
            tableView.reloadData()
        }
    }

    init() {
        super.init(style: .grouped)

        navigationItem.title = "Tip Jar"

        dataSource.message = "† Prices are in San Francisco dollars. Insane, right?"
        setLoading()

        tableView.register(cell: PurchaseCell.self)
        tableView.register(cell: LoadingCell.self)
        tableView.dataSource = dataSource
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        SKPaymentQueue.default().add(self)

        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeDataSource() -> DataSource {
        return .init(tableView: tableView) { [unowned self] tableView, indexPath, item -> UITableViewCell? in
            switch item {
            case .product(let product):
                let cell = tableView.dequeue(for: indexPath) as PurchaseCell
                cell.display(
                    product: product,
                    emoji: self.metadata[product.productIdentifier]!.emoji,
                    purchasing: product.productIdentifier == self.purchasing
                )
                return cell
            case .loading:
                return tableView.dequeue(for: indexPath) as LoadingCell
            }
        }
    }

    private func setLoading() {
        var snapshot = Snapshot()
        snapshot.appendSections([.storefront])
        snapshot.appendItems([.loading])
        dataSource.apply(snapshot)
    }

    private func reload() {
        var snapshot = Snapshot()
        snapshot.appendSections([.storefront])

        snapshot.appendItems(
            products
                .sorted(by: { $0.price.doubleValue < $1.price.doubleValue })
                .map(Item.product)
        )

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .loading: return false
        default: return true
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch dataSource.itemIdentifier(for: indexPath) {
        case .product(let product):
            purchase(product: product)
        default:
            break
        }
    }

    private func purchase(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

extension TippingViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        logger.error("StoreKit failed with error: \(error.localizedDescription)")
    }
}

extension TippingViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async {
            self.purchasing = nil

            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased:
                    self.message = self.metadata[transaction.payment.productIdentifier]!.message

                case .purchasing:
                    self.purchasing = transaction.payment.productIdentifier

                default:
                    break
                }

                if transaction.transactionState != .purchasing {
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            }
        }
    }
}

private class PurchaseCell: UITableViewCell {
    private lazy var priceLabel = UILabel(font: textLabel!.font, color: .secondaryLabel)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private static let emojiLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(priceLabel)
        priceLabel.trailingAnchor.pin(to: contentView.layoutMarginsGuide.trailingAnchor)
        priceLabel.centerYAnchor.pin(to: contentView.centerYAnchor)

        contentView.addSubview(activityIndicator)
        activityIndicator.trailingAnchor.pin(to: contentView.layoutMarginsGuide.trailingAnchor)
        activityIndicator.centerYAnchor.pin(to: contentView.centerYAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func display(product: SKProduct, emoji: String, purchasing: Bool) {
        textLabel?.text = product.localizedTitle
        detailTextLabel?.text = product.localizedDescription

        purchasing ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()

        priceFormatter.locale = product.priceLocale
        priceLabel.isHidden = purchasing
        priceLabel.text = priceFormatter.string(from: product.price)

        Self.emojiLabel.text = emoji
        Self.emojiLabel.sizeToFit()

        let renderer = UIGraphicsImageRenderer(bounds: Self.emojiLabel.bounds)
        imageView?.image = renderer.image { rendererContext in
            Self.emojiLabel.layer.render(in: rendererContext.cgContext)
        }
    }
}

private class LoadingCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()

        contentView.addSubview(indicator)
        indicator.pinCenter(to: contentView)
        indicator.pinEdges([.top, .bottom], to: contentView, insets: .init(all: 12))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
