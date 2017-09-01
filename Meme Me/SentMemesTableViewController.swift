//
//  SentMemesTableViewController.swift
//  Meme Me
//
//  Created by Pete Barnes on 8/30/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController {

    // MARK: Properties
    var memes: [Meme]!
    var deleteMemeIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }


    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        memes = Meme.getSavedMemes()
        self.tableView.reloadData()
    }
    
    @IBAction func goToMemeEditor(_ sender: Any) {
        
        // Grab the view controller from Storyboard
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        
        // Present the view controller
        present(viewController, animated: true, completion: nil)
    }
    
    
    // Mark: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Grab the DetailVC from Storyboard
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "SentMemeDetailViewController") as! SentMemeDetailViewController
        
        //Populate view controller with data from the selected item
        detailController.meme = memes[indexPath.row]
        
        // Present the view controller using navigation
        navigationController!.pushViewController(detailController, animated: true)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return memes.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentMemesTableViewCell", for: indexPath)

        cell.textLabel?.text = memes[indexPath.row].topText + " " + memes[indexPath.row].bottomText
        cell.imageView?.image = memes[indexPath.row].memedImage

        return cell
    }


    // The code for the delete functionality is based on information found at the following URL:
    // https://www.andrewcbancroft.com/2015/07/16/uitableview-swipe-to-delete-workflow-in-swift/
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteMemeIndexPath = indexPath
            let memeToDelete = Meme.getMemeAtIndex(indexPath.row)
            confirmDelete()
        }
    }
    
    func confirmDelete() {
        let alert = UIAlertController(title: "Delete Meme", message: "Are you sure you want to permanently delete this meme?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteMeme)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteMeme)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.size.width / 2.0, y: view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        present(alert, animated: true, completion: nil)
    }
    
    func handleDeleteMeme(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteMemeIndexPath {
            tableView.beginUpdates()
            
            Meme.removeAtIndex(indexPath.row)
            
            memes = Meme.getSavedMemes()
            
            // Note that indexPath is wrapped in an array:  [indexPath]
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            deleteMemeIndexPath = nil
            
            tableView.endUpdates()
        }
    }
    
    func cancelDeleteMeme(alertAction: UIAlertAction!) {
        deleteMemeIndexPath = nil
    }

}
