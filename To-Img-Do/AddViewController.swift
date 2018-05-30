//
//  AddViewController.swift
//  To-Img-Do
//
//  Created by Ege Sucu on 9.05.2018.
//  Copyright © 2018 Ege Sucu. All rights reserved.
//

import UIKit
import CoreData

class AddViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var todoTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(gesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    @objc func imageTapped(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        // Dismiss the picker.
        self.dismiss(animated: true, completion: nil)
    }
    
    
    

   
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newToDo = NSEntityDescription.insertNewObject(forEntityName: "ToDoEntity", into: context)
        
        newToDo.setValue(todoTextField.text, forKey: "text")
        
        
        let data = UIImageJPEGRepresentation(imageView.image!, 0.5)
        newToDo.setValue(data, forKey: "image")
        newToDo.setValue(false, forKey: "isDone")
        
        do {
            try context.save()
            print("Successfull")
        } catch {
            print("error...")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newToDo"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
        
        
    }
    
}
