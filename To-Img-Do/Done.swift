//
//  Done.swift
//  To-Img-Do
//
//  Created by Ege Sucu on 9.05.2018.
//  Copyright © 2018 Ege Sucu. All rights reserved.
//

import UIKit
import CoreData

class Done: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var listImages = [UIImage]()
    var listText = [String]()
    var isDone = true
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        tableView.delegate = self
        tableView.dataSource = self
        fetchList()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchList()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchList()
        self.tableView.reloadData()
        
    }
    
    @objc func fetchList(){
        listText.removeAll(keepingCapacity: false)
        listImages.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDoEntity")
        fetchRequest.returnsObjectsAsFaults = false
        
        
        let predicate = NSPredicate(format: "isDone == %@", NSNumber(value: true))
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listText.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "todoItem", for: indexPath) as! CellTableViewCell
        if listImages.count > 0 {
            cell.doneImage.image = listImages[indexPath.row]
            cell.doneCell.text = listText[indexPath.row]
            cell.doneCell.textColor = .gray
            
        } else {
            cell.doneImage.image = #imageLiteral(resourceName: "favicon")
            cell.doneCell.text = "No To-Do Item Here. Do some."
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        //Delete Swipe
        let modifyAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDoEntity")
            fetchRequest.returnsObjectsAsFaults = false
            let predicate = NSPredicate(format: "isDone == %@", NSNumber(value: true))
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

}

