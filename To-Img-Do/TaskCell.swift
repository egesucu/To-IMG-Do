//
//  TaskCell.swift
//  To-Img-Do
//
//  Created by Ege Sucu on 11.05.2018.
//  Copyright © 2018 Ege Sucu. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
    //TasksViewController ViewController'dan geliyor
    @IBOutlet weak var taskImageView: UIImageView!
    @IBOutlet weak var taskNameLabel: UILabel!
    //CompletedTaskViewController ViewController'dan geliyor.
    @IBOutlet weak var completedTaskImageView: UIImageView!
    @IBOutlet weak var completedTaskLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
