//
//  AutoCompleteCell.swift
//  Autocomplete
//
//  Created by Amir Rezvani on 3/6/16.
//  Copyright © 2016 cjcoaxapps. All rights reserved.
//

import UIKit
public class AutoCompleteCell: UITableViewCell {
    //MARK: - outlets
    @IBOutlet private weak var lblTitle: UILabel!
    @IBOutlet private weak var imgIcon: UIImageView!

    //MARK: - public properties
    public var textImage: AutocompleteCellData? {
        didSet {
            self.lblTitle.text = textImage!.text
            self.imgIcon.image = textImage!.image
        }
    }
}
