//
//  Task.swift
//  To-Img-Do
//
//  Created by Ege Sucu on 24.07.2020.
//  Copyright © 2020 Ege Sucu. All rights reserved.
//

import Foundation


/// Task is a custom model that defines which members task needs to have.
/// - parameter taskName : Name of the task. It contains the title of the task. Empty for default.
/// - parameter taskImageData : Image of the task that the user provides. Default icon if user doesn't provide.
/// - parameter isTaskDone : A boolean value  holds the status of the task. False by default.
struct Task {
    var taskName : String = ""
    var taskImageData : Data? = nil
    var isTaskDone = false

}
