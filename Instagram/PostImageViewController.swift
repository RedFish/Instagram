//
//  PostImageViewController.swift
//  Instagram
//
//  Created by Richard Guerci on 27/09/2015.
//  Copyright © 2015 Richard Guerci. All rights reserved.
//

import UIKit
import Parse

extension UIImage {
	var highestQualityJPEGNSData:NSData { return UIImageJPEGRepresentation(self, 1.0)! }
	var highQualityJPEGNSData:NSData    { return UIImageJPEGRepresentation(self, 0.75)!}
	var mediumQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.5)! }
	var lowQualityJPEGNSData:NSData     { return UIImageJPEGRepresentation(self, 0.25)!}
	var lowestQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.0)! }
}

class PostImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var textField: UITextField!
	var isPictureSelected = false
	var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func chooseImageAction(sender: AnyObject) {
		
		let controller = UIAlertController()
		controller.title = "Select image source"
		
		let libraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default){
			action in
			self.getPicture(UIImagePickerControllerSourceType.PhotoLibrary)
		}
		let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default){
			action in
			self.getPicture(UIImagePickerControllerSourceType.Camera)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default){
			action in
		}
		
		controller.addAction(libraryAction)
		controller.addAction(cameraAction)
		controller.addAction(cancelAction)
		
		self.presentViewController(controller, animated:true,completion:nil)
		
	}
	
	func getPicture(opt:UIImagePickerControllerSourceType){
		let image = UIImagePickerController()
		image.delegate = self
		image.allowsEditing = false
		image.sourceType = opt
		self.presentViewController(image, animated: true, completion: nil)

	}

	@IBAction func postImageAction(sender: AnyObject) {
		if isPictureSelected {
			
			if let imageToPost = imageView.image {
				//Start spinner
				activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
				activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
				activityIndicator.center = self.view.center
				activityIndicator.hidesWhenStopped = true
				activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
				view.addSubview(activityIndicator)
				activityIndicator.startAnimating()
				UIApplication.sharedApplication().beginIgnoringInteractionEvents()
				
				//Publish post
				let post = PFObject(className: "Post")
				post["message"] = textField.text
				post["userId"] = PFUser.currentUser()?.objectId
				let imageData = imageToPost.mediumQualityJPEGNSData
				let imageFile = PFFile(name: "image.png", data: imageData)
				post["imageFile"] = imageFile
				post.saveInBackgroundWithBlock { (succsess, error) -> Void in
					if error == nil {
						//Success
						self.activityIndicator.stopAnimating()
						UIApplication.sharedApplication().endIgnoringInteractionEvents()
						self.displayAlert("Success", message: "Image successfully updated")
						//reset view
						self.imageView.image = UIImage(named: "image-placeholder.jpg")
						self.textField.text = ""
					}
					else {
						self.displayAlert("Fail to post", message: "Try again later")
					}
				}
			}
		}
		else{
			displayAlert("Fail to post", message: "Select an image fist")
		}
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
		self.dismissViewControllerAnimated(true, completion: nil)
		isPictureSelected = true
		imageView.image = image
	}
	
	func displayAlert(title:String, message:String){
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
			//self.dismissViewControllerAnimated(true, completion: nil)
		}))
		self.presentViewController(alert, animated: true, completion: nil)
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
