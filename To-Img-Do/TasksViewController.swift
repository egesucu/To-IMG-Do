//
//  TasksViewController.swift
//  To-Img-Do
//
//  Created by Ege Sucu on 9.05.2018.
//  Copyright © 2018 Ege Sucu. All rights reserved.
//

import UIKit
import CoreData

enum TaskActions : String {
    case showTask,addTask
    
    func value() -> String {return self.rawValue}

}

class TasksViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    //MARK: - Variable Definitions
    @IBOutlet weak var tableView: UITableView!
    
    private var taskList = [Task]()
    private var selectedTask = Task()
    
    lazy var refreshControl = UIRefreshControl()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Main Method
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchList()
        
        
        refreshControl.addTarget(self, action: #selector(fetchList), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        
    }
    //MARK: - Method for observing data changes.
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchList), name: NSNotification.Name(rawValue: "newTask"), object: nil)
        self.tableView.reloadData()
    }
    
    
    
    //MARK: - Fetching Data from CoreData
    @objc func fetchList(){
        
        //Clear arrays before filling them.
        taskList.removeAll()
        
        //Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskModel")
        fetchRequest.returnsObjectsAsFaults = false
        
        //Filter Entry by showing only items that are not done yet.
        let predicate = NSPredicate(format: "isTaskDone == %@", NSNumber(value: false))
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
            print(error.localizedDescription)
        }
    }
    
    private func loadTask(task: NSManagedObject){
        
        if let taskName = task.value(forKey: "taskName") as? String,
            let taskImageData = task.value(forKey: "taskImageData") as? Data{
            
            self.taskList.append(Task(taskName: taskName, taskImageData: taskImageData, isTaskDone: false))
        }
        
    }
    
    
    //MARK: - TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    //Custom Swipe Actions
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Check Done Swipe
        let closeAction = UIContextualAction(style: .normal, title:  "Complete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let setDone = true
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskModel")
            fetchRequest.returnsObjectsAsFaults = false
            let predicate = NSPredicate(format: "isTaskDone == %@", NSNumber(value: false))
            fetchRequest.predicate = predicate
            do {
                let fetchResults = try self.context.fetch(fetchRequest) as? [NSManagedObject]
                
                if fetchResults?.count != 0{
                    
                    let managedObject = fetchResults![0]
                    managedObject.setValue(setDone, forKey: "isTaskDone");
                    
                    try self.context.save()
                    
                }
            } catch {
                print("Update got error. See the detail \(error.localizedDescription)")
            }
            
            self.taskList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            success(true)
        })
        closeAction.image = UIImage(systemName: "checkmark.seal")
        closeAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [closeAction])
        
    }
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        //Delete Swipe
        let modifyAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskModel")
            fetchRequest.returnsObjectsAsFaults = false
            let predicate = NSPredicate(format: "isTaskDone == %@", NSNumber(value: false))
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
        modifyAction.image = UIImage(named:"􀇼")
        modifyAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath) as! TaskCell
        if taskList.count > 0 {
            let index = indexPath.row
            cell.taskImageView.image = UIImage(data: taskList[index].taskImageData ?? Data())
            cell.taskNameLabel.text = taskList[index].taskName
        } else {
            cell.taskImageView.image = nil
            cell.taskNameLabel.text = "No To-Do Item Here. Create one."
        }
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTask = taskList[indexPath.row]
        performSegue(withIdentifier: TaskActions.showTask.value(), sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TaskActions.showTask.value(){
            let destinationVC = segue.destination as! SingleTaskViewController
            destinationVC.selectedTask = selectedTask
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: TaskActions.addTask.value(), sender: nil)
    }
    
}

