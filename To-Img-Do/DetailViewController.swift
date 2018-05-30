//
//  DetailViewController.swift
//  To-Img-Do
//
//  Created by Ege Sucu on 9.05.2018.
//  Copyright © 2018 Ege Sucu. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var todoText: UILabel!
    var chosenText = ""
    var chosenImage = UIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = chosenImage
        todoText.text = chosenText

        
    }

    
}
