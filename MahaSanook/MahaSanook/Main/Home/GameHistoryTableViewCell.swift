//
//  GameHistoryTableViewCell.swift
//  MahaSanook
//
//  Created by Napassorn V. on 6/12/2563 BE.
//

import UIKit

class GameHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var game: UILabel!
    @IBOutlet weak var img: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
