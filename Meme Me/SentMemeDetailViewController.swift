//
//  SentMemeDetailViewController.swift
//  Meme Me
//
//  Created by Pete Barnes on 8/30/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import UIKit

class SentMemeDetailViewController: UIViewController {

    // MARK: Properties
    var meme: Meme!
    
    // MARK: Outlets
    @IBOutlet weak var sentMemeDetailImageView: UIImageView!
    
    // MARK:Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        sentMemeDetailImageView.image = meme.memedImage
    }

    @IBAction func goToMemeEditor(_ sender: Any) {
        
        // Grab the view controller from Storyboard
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        
        // Send the saved meme to the view controller
        viewController.savedMeme = meme
        viewController.memeDetailController = self
        
        // Present the view controller
        present(viewController, animated: true, completion: nil)
        
    }

}