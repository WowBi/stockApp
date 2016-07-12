//
//  TableViewDatasource.swift
//  Autocomplete
//
//  Created by Amir Rezvani on 3/6/16.
//  Copyright © 2016 cjcoaxapps. All rights reserved.
//

import UIKit

//MARK: UITableViewDataSource extension
extension AutoCompleteViewController: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let items = self.autocompleteItems where items.count > 0 {
            return 1
        }
        return 0
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = self.autocompleteItems {
            return items.count
        }
        return 0
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        assert(self.autocompleteItems != nil, "item array was unexpectedlly nil")
        let items = self.autocompleteItems!
        let cell = tableView.dequeueReusableCellWithIdentifier("autocompleteCell", forIndexPath: indexPath)
        let data = items[indexPath.row]
        self.cellDataAssigner!(cell: cell, data: data)
        return cell
    }
}