//
//  VideoCell.swift
//  VideoRecording
//
//  Created by mac on 09/09/2020.
//  Copyright © 2020 Private. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {

    
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var lblDuration: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
