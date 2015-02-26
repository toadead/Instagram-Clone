//
//  UserTableViewController.swift
//  Instagram
//
//  Created by Yu Andrew - andryu on 2/19/15.
//  Copyright (c) 2015 Andrew Yu. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {
    
    var users = [PFUser]()  // without current user
    var usersFollowedByCurrentUser = [PFUser]()

    override func viewDidLoad() {
        super.viewDidLoad()
        findOtherUsersAndFollowedUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func findOtherUsersAndFollowedUsers() {
        var findUsersQuery = PFQuery(className: "_User")
        findUsersQuery.whereKey("username", notEqualTo: PFUser.currentUser().username)
        findUsersQuery.findObjectsInBackgroundWithBlock() {
            (otherUsers: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                if otherUsers.count > 0 {
                    self.users = otherUsers as [PFUser]
                    self.tableView.reloadData()
                    // find users followed by current user
                    var findFollowedUsersQuery = PFQuery(className: "Following")
                    findFollowedUsersQuery.whereKey("from", equalTo: PFUser.currentUser())
                    findFollowedUsersQuery.findObjectsInBackgroundWithBlock() {
                        (objects: [AnyObject]!, error: NSError!) -> Void in
                        if error == nil {
                            for object in objects as [PFObject] {
                                self.usersFollowedByCurrentUser.append(object.objectForKey("to") as PFUser)
                            }
                            self.tableView.reloadData()
                        } else {
                            println("No PFUser objects were found!")
                        }
                    }
                } else {
                    println(error)
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = users[indexPath.row].username
        for user in usersFollowedByCurrentUser {
            if user.objectId == users[indexPath.row].objectId {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            cell.accessoryType = UITableViewCellAccessoryType.None
            letCurrentUserUnfollowUserAtIndexPath(indexPath)
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            letCurrentUserfollowUserAtIndexPath(indexPath)
        }
    }
    
    func letCurrentUserfollowUserAtIndexPath(path: NSIndexPath) {
        var following = PFObject(className: "Following")
        following.setObject(PFUser.currentUser(), forKey: "from")
        following.setObject(users[path.row], forKey: "to")
        
        // find any duplicate objects
        var query = PFQuery(className: "Following")
        query.whereKey("from", equalTo: following.objectForKey("from"))
        query.whereKey("to", equalTo: following.objectForKey("to"))
        query.findObjectsInBackgroundWithBlock() {
            (foundDuplicateObjects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                if foundDuplicateObjects?.count > 0 {
                    println("\(PFUser.currentUser().username) already follows user \(self.users[path.row].username)")
                } else {
                    following.saveEventually() {
                        (success: Bool, error: NSError!) -> Void in
                        success ? println("\(PFUser.currentUser().username) now follows user \(self.users[path.row].username)") : println(error)
                    }
                }
            } else {
                println(error)
            }
        }
    }
    
    func letCurrentUserUnfollowUserAtIndexPath(path: NSIndexPath) {
        var query = PFQuery(className: "Following")
        query.whereKey("from", equalTo: PFUser.currentUser())
        query.whereKey("to", equalTo: users[path.row])
        query.findObjectsInBackgroundWithBlock() {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                if objects.count == 0 {
                    println("\(PFUser.currentUser().username) doesn't follow user \(self.users[path.row].username) yet")
                } else {
                    PFObject.deleteAllInBackground(objects, block: {
                        (success: Bool, error2: NSError!) -> Void in
                        success ? println("\(PFUser.currentUser().username) now doesn't follow user \(self.users[path.row].username)") : println(error2)
                    })
                }
            } else {
                println(error)
            }
        }
    }

}
