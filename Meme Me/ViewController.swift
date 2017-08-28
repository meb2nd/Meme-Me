//
//  MemeEditorViewController.swift
//  Meme Me
//
//  Created by Pete Barnes on 8/26/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK:  Properties
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: NSNumber.init(value: -3.0)]

    var memedImage: UIImage?
    
    // MARK:  Outlets
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var memeShareButton: UIBarButtonItem!
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        setupTextField(textField: topTextField, text: "TOP")
        setupTextField(textField: bottomTextField, text: "BOTTOM")
        
    }
    
    func setupTextField(textField: UITextField, text: String) {
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = text
        textField.textAlignment = .center
        textField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        memeShareButton.isEnabled = imagePickerView.image != nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK:  Actions
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        
        setUpImagePicker (sourceType: .savedPhotosAlbum)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        
        setUpImagePicker (sourceType: .camera)
    }
    
    func setUpImagePicker (sourceType: UIImagePickerControllerSourceType) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        if sourceType == .camera {
           imagePicker.cameraCaptureMode = .photo
        }
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme() {
        
        self.memedImage = generateMemedImage()
        if let image = self.memedImage {
            
            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            controller.completionWithItemsHandler = {
                (activity, success, items, error) in
                if(success && error == nil){
                    // Save copy of meme and close activity view
                    self.saveMeme()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    
                }
            }
            
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func resetMemeEditor(_ sender: Any) {
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.image = nil
        memeShareButton.isEnabled = false
        
    }
    
    
    // MARK: Image Picker Controller Delegate Methods

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            setUpMemeImageEditor(image)
            
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            setUpMemeImageEditor(image)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func setUpMemeImageEditor(_ image: UIImage) {
        imagePickerView.image = image
        memeShareButton.isEnabled = true
    }
    
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let currentText = textField.text
        
        if currentText == "TOP" || currentText == "BOTTOM" {
            
            textField.text = ""
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    // MARK:  Helper methods for keyboard handling
    
    func keyboardWillShow(_ notification:Notification) {
        
        // Only move the view when editing the bottom text
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        
        // Only move the view when editing the bottom text
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    

    // MARK: Meme Image Handling
    
    func saveMeme() {
        // Save the meme
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage!)
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide tool bar and navigation bar
        toolBar.isHidden = true
        navigationBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show tool bar and navigation bar
        toolBar.isHidden = false
        navigationBar.isHidden = false
        
        return memedImage
    }
    

    
    

}

