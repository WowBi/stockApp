//
//  FavoriteTableViewCell.swift
//  stockApp
//
//  Created by WangBi on 4/20/16.
//  Copyright © 2016 Bi Wang. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var symbolLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var changeLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var capLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
