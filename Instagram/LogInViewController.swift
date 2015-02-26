//
//  ViewController.swift
//  Instagram
//
//  Created by Yu Andrew - andryu on 2/6/15.
//  Copyright (c) 2015 Andrew Yu. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    var needSignUp = true
    var signUpOrLogInSuccess = false
    var activeField: UITextField?     // keep track where UITextField is active
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var memberButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfimField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        needSignUp = true
        toggleSignUpAndLogIn(sender as UIButton)
    }
    
    @IBAction func memberButtonPressed(sender: AnyObject) {
        needSignUp = false
        toggleSignUpAndLogIn(sender as UIButton)
    }
    
    @IBAction func submitPressed(sender: AnyObject) {
        signUpOrLogInUser()
    }
    
    @IBAction func logInWithFBPressed(sender: AnyObject) {
        println("logInWithFBPressed")
    }
    
    func toggleSignUpAndLogIn(button: UIButton) {
        //clearTextFieldsInputs()
        button.setBackgroundImage(UIImage(named: "button.png"), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        if needSignUp {
            passwordConfimField.hidden = false
            welcomeLabel.text = "Sign up to see photos and videos from your friends."
            memberButton.setBackgroundImage(nil, forState: UIControlState.Normal)
            memberButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            submitButton.setTitle("Join", forState: UIControlState.Normal)
            passwordField.returnKeyType = UIReturnKeyType.Default
        } else {
            passwordConfimField.hidden = true
            welcomeLabel.text = "Log in to see photos and videos from your friends."
            signUpButton.setBackgroundImage(nil, forState: UIControlState.Normal)
            signUpButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            submitButton.setTitle("Log In", forState: UIControlState.Normal)
            passwordField.returnKeyType = UIReturnKeyType.Go
        }
    }
    
    func signUpOrLogInUser() {
        if textFieldsAreValidInputs() {
            needSignUp ? signUpUser() : logInUser()
        }
    }
    
    func clearTextFieldsInputs() {
        emailField.text = ""
        passwordField.text = ""
        passwordConfimField.text = ""
    }
    
    func textFieldsAreValidInputs() -> Bool {
        var title = "", message = ""
        if (emailField.text == "") {
            title = "Invalid Email"
            message = "Please enter email address."
        } else if (passwordField.text == "") {
            title = "Invalid Password"
            message = "Please enter password for you account."
        } else if needSignUp {
            if (countElements(passwordField.text)<8 || passwordField.text.rangeOfCharacterFromSet(NSCharacterSet.letterCharacterSet()) == nil) {
                title = "Invalid Password"
                message = "Please make sure you password's length is at least 8 and contains letters."
                passwordField.text = ""
                passwordConfimField.text = ""
            } else if !confirmedPasswordOnSignUp() {
                title = "Password Mismatch"
                message = "Password entered 2nd time doesn't match 1st time. Please enter again."
                passwordField.text = ""
                passwordConfimField.text = ""
            }
        }
        
        if (title != "" && message != "") {
            var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func confirmedPasswordOnSignUp() -> Bool {
        return passwordField.text == passwordConfimField.text
    }
    
    func signUpUser() {
        let spinner = UIActivityIndicatorView()
        spinner.center = self.view.center
        spinner.hidesWhenStopped = true
        self.view.addSubview(spinner)
        spinner.startAnimating()
        
        var user = PFUser()
        user.username = emailField.text
        user.password = passwordField.text
        user.email = emailField.text
        user.signUpInBackgroundWithBlock() {
            (success: Bool!, error: NSError!) -> Void in
            var title = "", message = ""
            if (error == nil) {
                self.signUpOrLogInSuccess = true
                title = "SignUp Success"
                message = "Successfully signed up user \(user.username)."
            } else {
                self.signUpOrLogInSuccess = false
                title = "SignUp Error"
                message = error!.userInfo?["error"] as String
            }
            spinner.stopAnimating()
            self.clearTextFieldsInputs()
            var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction!) -> Void in
                if self.signUpOrLogInSuccess {
                    self.performSegueWithIdentifier("ShowUsersSegue", sender: self)
                }
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func logInUser() {
        let spinner = UIActivityIndicatorView()
        spinner.center = self.view.center
        spinner.hidesWhenStopped = true
        self.view.addSubview(spinner)
        spinner.startAnimating()

        PFUser.logInWithUsernameInBackground(emailField.text, password: passwordField.text, block: {
            (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                self.signUpOrLogInSuccess = true
                spinner.stopAnimating()
                println("logged in successfully")
                self.performSegueWithIdentifier("ShowUsersSegue", sender: self)
            } else {
                self.signUpOrLogInSuccess = false
                spinner.stopAnimating()
                self.clearTextFieldsInputs()
                var alert = UIAlertController(title: "LogIn Error", message: error.userInfo?["error"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollViewAndKeyboardNotification()
        completeSetupForTextField(emailField, withImageNamed: "mail-icon.png")
        completeSetupForTextField(passwordField, withImageNamed: "lock-icon.png")
        emailField.delegate = self
        passwordField.delegate = self
        if needSignUp {
            completeSetupForTextField(passwordConfimField, withImageNamed: "lock-icon.png")
            passwordConfimField.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupScrollViewAndKeyboardNotification() {
        scrollView.contentSize = CGSizeMake(1000, 1000)
        registerForKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardDidHideNotification, object: nil)
    }
    
    // scrollView adjustment with and without keyboard
    func keyboardWasShown(notification: NSNotification) {
        var keyboardHeight: CGFloat?
        if let info = notification.userInfo {
            if let keyboard: AnyObject = info[UIKeyboardFrameEndUserInfoKey] {
                keyboardHeight = keyboard.CGRectValue().height
            }
        }
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight!, right: 0)
        scrollView.contentInset = contentInsets
        
        var aRect = self.view.frame
        aRect.size.height -= keyboardHeight!
        if !CGRectContainsPoint(aRect, activeField!.frame.origin) {
            scrollView.scrollRectToVisible(activeField!.frame, animated: true)
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
    func completeSetupForTextField(textField: UITextField!, withImageNamed imageName: String) {
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        textField.backgroundColor = UIColor.clearColor()
        textField.layer.borderColor = UIColor.lightGrayColor().CGColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 16
        textField.leftView = UIImageView(image: UIImage(named: imageName))
        textField.leftViewMode = UITextFieldViewMode.Always
    }

    // UITextFieldDelegate method implementation
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if emailField.text == "" {
            emailField.becomeFirstResponder()
        } else if passwordField.text == "" {
            passwordField.becomeFirstResponder()
        } else if needSignUp && passwordConfimField.text == "" {
            passwordConfimField.becomeFirstResponder()
        } else {
            signUpOrLogInUser()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
    
    // UIResponder method override
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
}

