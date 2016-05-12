//
//  CatchTableViewCell.swift
//  Fishing Buddy
//
//  Created by Ed Ballington on 5/5/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import UIKit

class CatchTableViewCell: UITableViewCell {

    @IBOutlet weak var catchImage: UIImageView!
    @IBOutlet weak var species: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var lureTypeAndColor: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
