//
//  TableViewController.swift
//  Instagram
//
//  Created by Richard Guerci on 24/09/2015.
//  Copyright © 2015 Richard Guerci. All rights reserved.
//

import UIKit
import Parse

struct InstagramUser {
	var username = ""
	var objectId = ""
	var isFollowed = false
}

class TableViewController: UITableViewController {

	var users : [InstagramUser]!
	var refresher : UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		users = [InstagramUser()]
		refresher = UIRefreshControl()
		refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
		self.tableView.addSubview(refresher)
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		refresh()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        cell.textLabel?.text = users[indexPath.row].username
		if users[indexPath.row].isFollowed {
			cell.accessoryType = UITableViewCellAccessoryType.Checkmark
		}
		else {
			cell.accessoryType = UITableViewCellAccessoryType.None
		}

        return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath)!
		
		if !users[indexPath.row].isFollowed{ //not followed yet -> add to db
			users[indexPath.row].isFollowed = true
			//Add checkmark in the tableview
			cell.accessoryType = UITableViewCellAccessoryType.Checkmark
			
			//Add follower
			let followers = PFObject(className:"Followers")
			followers["following"] = users[indexPath.row].objectId
			followers["follower"] = PFUser.currentUser()?.objectId
			followers.saveInBackgroundWithBlock {
				(success: Bool, error: NSError?) -> Void in
				if (success) {
					// The object has been saved.
				} else {
					// There was a problem, check error.description
					print("Error while saving")
				}
			}
		}
		else { //already followed -> remove from db
			users[indexPath.row].isFollowed = false
			//Remove checkmark
			cell.accessoryType = UITableViewCellAccessoryType.None
			
			//Remove follower
			let query = PFQuery(className: "Followers")
			query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
			query.whereKey("following", equalTo: users[indexPath.row].objectId)
			query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
				if error != nil {
					print("Error finding object")
				}
				else {
					if let objects = objects {
						for obj in objects {
							obj.deleteInBackground()
						}
					}
				}
			})

		}
	}
	
	func refresh(){
		let query = PFUser.query()
		query?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
			//clear array
			self.users.removeAll()
			
			if error != nil {
				print("Error finding object")
			}
			else if let users = objects{
				for object in users {
					if let user = object as? PFUser {
						if user.objectId != PFUser.currentUser()?.objectId { //only fetch other user (not me)
							var userToAdd = InstagramUser(username: user.username!, objectId: user.objectId!, isFollowed: false)
							
							//check if already followed
							let query = PFQuery(className: "Followers")
							query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
							query.whereKey("following", equalTo: user.objectId!)
							query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
								if error != nil {
									print("Error finding object")
								}
								else {
									if let obj = objects {
										if obj.count > 0 {
											userToAdd.isFollowed = true
										}
									}
									self.users.append(userToAdd)
									self.tableView.reloadData()
								}
							})
							
						}
					}
				}
			}
		}
		
		refresher.endRefreshing()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showFeed" {
			let controller = (segue.destinationViewController as! UITableViewController) as! FeedTableViewController
			controller.users = users
		}
		else if segue.identifier == "logout" {
			PFUser.logOut()
			self.navigationController?.setNavigationBarHidden(true, animated: false)
		}
	}
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
