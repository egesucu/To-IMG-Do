//
//  SingleTaskViewController.swift
//  To-Img-Do
//
//  Created by Ege Sucu on 9.05.2018.
//  Copyright © 2018 Ege Sucu. All rights reserved.
//

import UIKit

class SingleTaskViewController: UIViewController {

//    MARK: Variable Definations
    @IBOutlet weak var taskImageView: UIImageView!
    @IBOutlet weak var taskTitleLabel: UILabel!
    
    var selectedTask = Task()
    
//    MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = selectedTask.taskImageData {
            self.taskImageView.image = UIImage(data: data)
        } else {
            self.taskImageView.image = UIImage(systemName: "info.circle.fill")
        }
        
        taskTitleLabel.text = selectedTask.taskName

        
    }

    
}
