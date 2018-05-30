//
//  CellTableViewCell.swift
//  To-Img-Do
//
//  Created by Ege Sucu on 11.05.2018.
//  Copyright © 2018 Ege Sucu. All rights reserved.
//

import UIKit

class CellTableViewCell: UITableViewCell {
    //List ViewController'dan geliyor
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellItem: UILabel!
    //Done ViewController'dan geliyor.
    @IBOutlet weak var doneImage: UIImageView!
    @IBOutlet weak var doneCell: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
