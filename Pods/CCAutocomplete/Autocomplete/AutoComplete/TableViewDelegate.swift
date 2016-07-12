//
//  TableViewDelegate.swift
//  Autocomplete
//
//  Created by Amir Rezvani on 3/6/16.
//  Copyright © 2016 cjcoaxapps. All rights reserved.
//

import UIKit

extension AutoCompleteViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.cellHeight!
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = self.autocompleteItems![indexPath.row]
        self.textField?.text = selectedItem.text
        UIView.animateWithDuration(self.animationDuration, animations: { () -> Void in
                self.view.frame.size.height = 0.0
                self.textField?.endEditing(true)
            }) { (completed) -> Void in
                self.delegate!.didSelectItem(selectedItem)
        }
    }
}
