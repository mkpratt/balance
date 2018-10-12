//
//  LocationTableCell.swift
//  Balance
//
//  Created by Michael on 3/30/18.
//  Copyright © 2018 poshbaboon. All rights reserved.
//

import UIKit

class LocationTableCell: UITableViewCell {

    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
