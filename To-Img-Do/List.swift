//
//  List.swift
//  To-Img-Do
//
//  Created by Ege Sucu on 9.05.2018.
//  Copyright © 2018 Ege Sucu. All rights reserved.
//

import UIKit
import CoreData

class List: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    //MARK: - Variable Definitions
    @IBOutlet weak var tableView: UITableView!
    var listImages = [UIImage]()
    var listText = [String]()
    var selectedImage = UIImage()
    var selectedText = String()
    var isDone = false
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Main Method
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchList()
    }
    //MARK: - Method for observing data changes.
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchList), name: NSNotification.Name(rawValue: "newToDo"), object: nil)
        self.tableView.reloadData()
    }
    
    //MARK: - Fetching Data from CoreData
    @objc func fetchList(){
        
        //Clear arrays before filling them.
        listText.removeAll(keepingCapacity: false)
        listImages.removeAll(keepingCapacity: false)
        
        //Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDoEntity")
        fetchRequest.returnsObjectsAsFaults = false
        
        //Filter Entry by showing only items that are not done yet.
        let predicate = NSPredicate(format: "isDone == %@", NSNumber(value: false))
        fetchRequest.predicate = predicate
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let text = result.value(forKey: "text") as? String{
                        self.listText.append(text)
                    }
                    
                    if let imageData = result.value(forKey: "image") as? Data{
                        let image = UIImage(data: imageData)
                        self.listImages.append(image!)
                    }
                    
                    self.tableView.reloadData()
                    
                }
            }
            
        } catch {
            print("error")
        }
    }
    
    
    //MARK: - TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listText.count
    }
    //Custom Swipe Actions
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Check Done Swipe
        let closeAction = UIContextualAction(style: .normal, title:  "Close", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let setDone = true
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDoEntity")
            fetchRequest.returnsObjectsAsFaults = false
            let predicate = NSPredicate(format: "isDone == %@", NSNumber(value: false))
            fetchRequest.predicate = predicate
            do {
                let fetchResults = try self.context.fetch(fetchRequest) as? [NSManagedObject]
                
                if fetchResults?.count != 0{
                    
                    let managedObject = fetchResults![0]
                    managedObject.setValue(setDone, forKey: "isDone");
                    
                    try self.context.save()
                    
                }
            } catch {
                print("Update got error. See the detail \(error.localizedDescription)")
            }
            self.listImages.remove(at: indexPath.row)
            self.listText.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            success(true)
        })
        closeAction.image = #imageLiteral(resourceName: "tick")
        closeAction.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [closeAction])
        
    }
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        //Delete Swipe
        let modifyAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDoEntity")
            fetchRequest.returnsObjectsAsFaults = false
            let predicate = NSPredicate(format: "isDone == %@", NSNumber(value: false))
            fetchRequest.predicate = predicate
            
            
            do {
                let fetchResults = try self.context.fetch(fetchRequest) as? [NSManagedObject]
                
                if fetchResults?.count != 0{
                    
                    for object in fetchResults! {
                        self.context.delete(object)
                    }
                    do {
                        try self.context.save()
                    } catch {
                        print("Error")
                    }
                    self.listImages.remove(at: indexPath.row)
                    self.listText.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    
                }
            } catch {
                print("Update got error. See the detail \(error.localizedDescription)")
            }
            success(true)
        })
        modifyAction.image = #imageLiteral(resourceName: "delete")
        modifyAction.backgroundColor = UIColor.red
        
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "todoItem", for: indexPath) as! CellTableViewCell
        if listImages.count > 0 {
            cell.cellImage.image = listImages[indexPath.row]
            cell.cellItem.text = listText[indexPath.row]
        } else {
            cell.cellImage.image = #imageLiteral(resourceName: "favicon")
            cell.cellItem.text = "No To-Do Item Here. Create one."
        }
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedText = listText[indexPath.row]
        selectedImage = listImages[indexPath.row]
       performSegue(withIdentifier: "see", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "see"{
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.chosenImage = selectedImage
            destinationVC.chosenText = selectedText
        }
    }
    
    
}

