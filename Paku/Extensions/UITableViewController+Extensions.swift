//
//  UITableViewController+Extensions.swift
//  Paku
//
//  Created by Kyle Bashour on 11/2/20.
//

import UIKit

extension UITableViewController {
    func clearSelection(animated: Bool = true) {
        if let selection = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selection, animated: animated)
        }
    }
}
