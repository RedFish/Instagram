//
//  FeedTableViewController.swift
//  Instagram
//
//  Created by Richard Guerci on 28/09/2015.
//  Copyright © 2015 Richard Guerci. All rights reserved.
//

import UIKit
import Parse

struct post {
	var username = ""
	var message = ""
	var image = PFFile()
}

class FeedTableViewController: UITableViewController {

	var posts : [post]!
	var users : [InstagramUser]!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		posts = [post]()
		
		//fetch posts
		for user in users {
			if user.isFollowed {
				let getPost = PFQuery(className: "Post")
				getPost.whereKey("userId", equalTo: user.objectId)
				getPost.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
					if error != nil {
						print("Error finding post")
					}
					else {
						if let objects = objects {
							for obj in objects {
								self.posts.append(post(username: user.username, message: obj["message"] as! String, image: obj["imageFile"] as! PFFile))
							}
						}
						self.tableView.reloadData()
					}
				})
			}
		}
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
        return posts.count
    }

	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! Cell

		posts[indexPath.row].image.getDataInBackgroundWithBlock { (data, error) -> Void in
			if let dlImage = UIImage(data: data!){
				myCell.postedImage.image = dlImage
			}
		}
		myCell.username.text = posts[indexPath.row].username
		if posts[indexPath.row].message != "" {
			myCell.message.text = posts[indexPath.row].message
			myCell.message.alpha = 1.0
		}
		else{
			myCell.message.alpha = 0.0
		}
		
        return myCell
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
