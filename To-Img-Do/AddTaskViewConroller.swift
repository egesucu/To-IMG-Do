//
//  AddTaskViewConroller.swift
//  To-Img-Do
//
//  Created by Ege Sucu on 9.05.2018.
//  Copyright © 2018 Ege Sucu. All rights reserved.
//

import UIKit
import CoreData

class AddTaskViewConroller: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var todoTextField: UITextField!
    @IBOutlet weak var addTaskButton: UIButton!
    
    private var currentTask = Task()
    
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTaskButton.layer.cornerRadius = addTaskButton.bounds.height / 2
        todoTextField.delegate = self
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(gesture)
        
        
    }
    
    @objc func imageTapped(){
        let picker = UIImagePickerController()
        let selectionAlert = UIAlertController(title: nil, message: "Which way would you add an image?", preferredStyle: .actionSheet)
        let selections = [
            UIAlertAction(title: "Camera Roll", style: .default, handler: { (_) in
                picker.sourceType = .camera
                self.pickImage(picker: picker)
            }), UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in
                picker.sourceType = .photoLibrary
                self.pickImage(picker: picker)
                
            }), UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            })
            
        ]
        for selection in selections {
            selectionAlert.addAction(selection)
        }
        self.present(selectionAlert, animated: true,completion: nil)
        
        
        
    }
    
    private func pickImage(picker: UIImagePickerController){
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            self.imageView.image = image
            self.currentTask.taskImageData = image.pngData()
            self.dismiss(animated: true, completion: nil)
        } else {
            let noImageAlert = UIAlertController(title: "Error", message: "Couldn't get your image. Please allow your camera preferences in Settings", preferredStyle: .alert)
            let goSettingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                self.navigateToSettings()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            noImageAlert.addAction(goSettingsAction)
            noImageAlert.addAction(cancelAction)
            self.present(noImageAlert, animated: true, completion: nil)
        }
        
    }
    
    
    private func navigateToSettings(){
        if let url = URL(string: UIApplication.openSettingsURLString){
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    
    
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        let newTask = NSEntityDescription.insertNewObject(forEntityName: "TaskModel", into: viewContext)
        
        saveTask(taskObject: newTask, taskName: currentTask.taskName, taskImageData: currentTask.taskImageData)
        
        
    }
    
    private func saveTask(taskObject: NSManagedObject, taskName: String, taskImageData: Data?){
        
        if let taskImageData = taskImageData {
            taskObject.setValue(taskImageData, forKey: "taskImageData")
        } else {
            let infoSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 100, weight: .black)
            let image = UIImage(systemName: "info.circle.fill",withConfiguration: infoSymbolConfiguration)?.pngData()
            taskObject.setValue(image, forKey: "taskImageData")
        }
        taskObject.setValue(taskName, forKey: "taskName")
        
        taskObject.setValue(false, forKey: "isTaskDone")
        
        do {
            try viewContext.save()
            print("Successfull")
            
            //        Notify Main View on Added Data
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newTask"), object: nil)
            
            //        Navigate back to Tasks Page
            self.dismiss(animated: true, completion: nil)
        } catch let error {
            let databaseErrorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            databaseErrorAlert.addAction(dismissAction)
            self.present(databaseErrorAlert, animated: true, completion: nil)
        }
        
    }
    
}

extension AddTaskViewConroller : UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.currentTask.taskName = textField.text ?? ""
        return true
    }
}
