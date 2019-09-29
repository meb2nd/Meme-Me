//
//  MemeEditorViewController.swift
//  Meme Me
//
//  Created by Pete Barnes on 8/26/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK:  Properties
    var memeTextAttributes:[String:Any] = [
        convertFromNSAttributedStringKey(NSAttributedString.Key.strokeColor): UIColor.black,
        convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.white,
        convertFromNSAttributedStringKey(NSAttributedString.Key.strokeWidth): NSNumber.init(value: -3.0)]

    var memedImage: UIImage?
    var savedMeme: Meme?
    var memeDetailController: SentMemeDetailViewController?
    
    // MARK:  Outlets
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var memeShareButton: UIBarButtonItem!
    @IBOutlet weak var restoreButton: UIBarButtonItem!
    override var prefersStatusBarHidden: Bool{return true}
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        if let meme = savedMeme {
            
            UserDefaults.standard.set(meme.font, forKey: "memeFont")
            setupTextField(textField: topTextField, text: meme.topText)
            setupTextField(textField: bottomTextField, text: meme.bottomText)
            setUpMemeImageEditor(meme.originalImage)
            
        } else {
            
            setupTextField(textField: topTextField, text: "TOP")
            setupTextField(textField: bottomTextField, text: "BOTTOM")
        }
        
    }
    
    func setupTextField(textField: UITextField, text: String) {
        
        textField.defaultTextAttributes = convertToNSAttributedStringKeyDictionary(memeTextAttributes)
        textField.text = text
        textField.textAlignment = .center
        textField.delegate = self
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        let memeFont = UIFont(name: UserDefaults.standard.string(forKey: "memeFont") ?? "Impact", size: 40)
        topTextField.font = memeFont
        bottomTextField.font = memeFont
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        memeShareButton.isEnabled = imagePickerView.image != nil
        restoreButton.isEnabled = shouldEnableRestore()
    }
    
    func shouldEnableRestore() -> Bool {
        
        if let savedMeme = self.savedMeme {
            return !savedMeme.originalImage.isEqual(imagePickerView.image) || topTextField.text != savedMeme.topText || bottomTextField.text != savedMeme.bottomText
        } else {
            return imagePickerView.image != nil || topTextField.text != "TOP" || bottomTextField.text != "BOTTOM"
        }
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
    
    func setUpImagePicker (sourceType: UIImagePickerController.SourceType) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        if sourceType == .camera {
           imagePicker.cameraCaptureMode = .photo
        }
        //imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func chooseFont (_ sender: Any) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "FontPickerViewController") as! FontPickerViewController
        
        controller.textFieldsToUpdate = [topTextField, bottomTextField]
        present(controller, animated: true, completion: nil)
        
    }
    
    // Code for the completionWithItemsHandler in the following method is based upon information found at the following URL
    // http://seanwernimont.weebly.com/blog/december-02nd-2015
    
    @IBAction func shareMeme() {
        
        memedImage = generateMemedImage()
        if let image = memedImage {
            
            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            controller.completionWithItemsHandler = {
                (activity, success, items, error) in
                if(success && error == nil){
                    // Save copy of meme and close activity view
                    self.saveMeme()
                    
                    // If edited a saved meme update the detail view
                    self.memeDetailController?.meme = Memes.getSavedMemes().last
                    
                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    
                    let controller = UIAlertController()
                    controller.title = "Meme Share Incomplete"
                    controller.message = "Share was either cancelled or failed."
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { action in controller.dismiss(animated: true, completion: nil)
                    }
                    
                    controller.addAction(okAction)
                    self.present(controller, animated: true, completion: nil)
                    
                }
            }
            
            present(controller, animated: true, completion: nil)

        }
        
    }
    
    
    @IBAction func resetMemeEditor(_ sender: Any) {
        
        if let meme = savedMeme {
            
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            imagePickerView.image = meme.originalImage
            memeShareButton.isEnabled = true
            
        } else {
        
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            imagePickerView.image = nil
            memeShareButton.isEnabled = false
        }
        
        restoreButton.isEnabled = false
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    // MARK:  Helper methods for keyboard handling
    
    @objc func keyboardWillShow(_ notification:Notification) {

        view.frame.origin.y = 0 - getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        
        // Only move the view when editing the bottom text
        if bottomTextField.isFirstResponder {
            return keyboardSize.cgRectValue.height
        } else {
            return 0
        }
        
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    

    // MARK: Meme Image Handling
    
    func saveMeme() {
        
        // Save the meme
        if let topText = topTextField.text,
            let bottomText = bottomTextField.text,
            let originalImage = imagePickerView.image,
            let memedImage = memedImage,
            let font = topTextField.font?.fontName {
            
            let meme = Meme(topText: topText, bottomText: bottomText, originalImage: originalImage, memedImage: memedImage, font: font)
            
            // Add it to the memes array in the Application Delegate
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.append(meme)
        }
        
        
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide tool bar and navigation bar
        memeEditorControlBars(areHidden: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show tool bar and navigation bar
        memeEditorControlBars(areHidden: false)
        
        return memedImage
    }
    
    func memeEditorControlBars(areHidden isHidden: Bool) {
        
        toolBar.isHidden = isHidden
        navigationBar.isHidden = isHidden
    }
    

}


// MARK: - UIImagePickerControllerDelegate
extension MemeEditorViewController: UIImagePickerControllerDelegate {

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            
            setUpMemeImageEditor(image)
            
        } else if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            
            setUpMemeImageEditor(image)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func setUpMemeImageEditor(_ image: UIImage) {
        imagePickerView.image = image
        memeShareButton.isEnabled = true
    }
}


// MARK: Text Field Delegate Methods
extension MemeEditorViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let currentText = textField.text
        
        if currentText == "TOP" || currentText == "BOTTOM" {
            
            textField.text = ""
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        restoreButton.isEnabled = shouldEnableRestore()
        return true
    }
}




// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
