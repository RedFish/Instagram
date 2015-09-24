//
//  ViewController.swift
//  Instagram
//
//  Created by Richard Guerci on 24/09/2015.
//  Copyright © 2015 Richard Guerci. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var submitButton: UIButton!
	@IBOutlet weak var switchButton: UIButton!
	@IBOutlet weak var question: UILabel!
	@IBOutlet weak var username: UITextField!
	@IBOutlet weak var password: UITextField!
	var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
	var logInActive = true

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		username.delegate = self
		password.delegate = self
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	@IBAction func switchAction(sender: AnyObject) {
		logInActive = !logInActive
		if logInActive {
			submitButton.setTitle("Login", forState: UIControlState.Normal)
			switchButton.setTitle("Sign Up", forState: UIControlState.Normal)
			question.text = "Not registered ?"
		}
		else{
			submitButton.setTitle("Sign Up", forState: UIControlState.Normal)
			switchButton.setTitle("Login", forState: UIControlState.Normal)
			question.text = "Already registered ?"
		}
	}
	
	@IBAction func submitAction(sender: AnyObject) {
		//check if form is field
		if username.text == "" && password.text == "" {
			displayAlert("Error in form", message: "Please enter a username and a password")
		}
		else{
			
			//start spinner
			activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
			activityIndicator.center = self.view.center
			activityIndicator.hidesWhenStopped = true
			activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
			view.addSubview(activityIndicator)
			//ignore interaction events
			activityIndicator.startAnimating()
			UIApplication.sharedApplication().beginIgnoringInteractionEvents()
			
			//set default error message
			var errorMessage = "Please try again"
			
			if logInActive {
				//login with parse
				PFUser.logInWithUsernameInBackground(username.text!, password:password.text!) {
					(user: PFUser?, error: NSError?) -> Void in
					//enable interaction events
					self.activityIndicator.stopAnimating()
					UIApplication.sharedApplication().endIgnoringInteractionEvents()
					
					if user != nil {//Successful login.
						print("Logged in")
					} else {
						if let errorString = error!.userInfo["error"] as? String {
							errorMessage = errorString
						}
						self.displayAlert("Failed to login", message: errorMessage)
					}
				}
			}
			else{
				//signup with parse
				let user = PFUser()
				user.username = username.text
				user.password = password.text
				
				user.signUpInBackgroundWithBlock {
					(succeeded: Bool, error: NSError?) -> Void in
					//enable interaction events
					self.activityIndicator.stopAnimating()
					UIApplication.sharedApplication().endIgnoringInteractionEvents()
					
					if error != nil {
						if let errorString = error!.userInfo["error"] as? String {
							errorMessage = errorString
						}
						self.displayAlert("Failed to login", message: errorMessage)
					} else {
						// Hooray! Let them use the app now.
					}
				}
			}
		}
	}
	
	//Remove keyboard when touch ouside the keyboard
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	//Remove keyboard when clic 'return'
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return true
	}
	
	func displayAlert(title:String, message:String){
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
			self.dismissViewControllerAnimated(true, completion: nil)
		}))
		self.presentViewController(alert, animated: true, completion: nil)
	}
}

