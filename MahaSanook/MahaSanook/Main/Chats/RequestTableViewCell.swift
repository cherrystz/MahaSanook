//
//  RequestTableViewCell.swift
//  MahaSanook
//
//  Created by Napassorn V. on 5/12/2563 BE.
//

import UIKit

class RequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var addRequest: UIButton!
    @IBOutlet weak var removeRequest: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        photo.cornerRadius()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
