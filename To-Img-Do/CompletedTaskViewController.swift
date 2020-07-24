//
//  CompletedTaskViewController.swift
//  To-Img-Do
//
//  Created by Ege Sucu on 9.05.2018.
//  Copyright © 2018 Ege Sucu. All rights reserved.
//

import UIKit
import CoreData

class CompletedTaskViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
   
    private var taskList = [Task]()
    private var selectedTask = Task()
    
    lazy var refreshControl = UIRefreshControl()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        tableView.delegate = self
        tableView.dataSource = self
        fetchList()
        
        refreshControl.addTarget(self, action: #selector(fetchList), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
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
        taskList.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskModel")
        fetchRequest.returnsObjectsAsFaults = false
        
        
        let predicate = NSPredicate(format: "isTaskDone == %@", NSNumber(value: true))
        fetchRequest.predicate = predicate
        
        do {
            let tasks = try context.fetch(fetchRequest)
            
            if tasks.count > 0 {
                for task in tasks as! [NSManagedObject] {
                    loadTask(task: task)
 
                }
                self.tableView.reloadData()
                
            }
            refreshControl.endRefreshing()
        } catch {
            print("error")
        }
    }
    
    private func loadTask(task: NSManagedObject){
        
        if let taskName = task.value(forKey: "taskName") as? String,
            let taskImageData = task.value(forKey: "taskImageData") as? Data{
            
            self.taskList.append(Task(taskName: taskName, taskImageData: taskImageData, isTaskDone: true))
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath) as! TaskCell
        if taskList.count > 0 {
            let index = indexPath.row
            cell.completedTaskImageView.image = UIImage(data: taskList[index].taskImageData ?? Data())
            cell.completedTaskLabel.text = taskList[index].taskName
        } else {
            cell.completedTaskImageView.image = #imageLiteral(resourceName: "second")
            cell.completedTaskLabel.text = "No To-Do Item Here. Do some."
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        //Delete Swipe
        let modifyAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskModel")
            fetchRequest.returnsObjectsAsFaults = false
            let predicate = NSPredicate(format: "isTaskDone == %@", NSNumber(value: true))
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
                    self.taskList.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    
                }
            } catch {
                print("Update got error. See the detail \(error.localizedDescription)")
            }
            success(true)
        })
        modifyAction.image = UIImage(systemName: "xmark-seal")
        modifyAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

}

