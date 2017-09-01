//
//  SentMemesCollectionViewController.swift
//  Meme Me
//
//  Created by Pete Barnes on 8/30/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import UIKit

private let reuseIdentifier = "SentMemesCollectionViewCell"

class SentMemesCollectionViewController: UICollectionViewController {
    
    // MARK: Properties
    
    var memes: [Meme]!
    
    // MARK: Outlets
    
    @IBOutlet weak var sentMemesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        memes = Memes.getSavedMemes()
        self.collectionView?.reloadData()
    }
    
    // MARK:  Layout handling
    
    func setupLayout() {
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        sentMemesCollectionViewFlowLayout.minimumInteritemSpacing = space
        sentMemesCollectionViewFlowLayout.minimumLineSpacing = space
        sentMemesCollectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        if ((self.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass)
            || (self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass)) {
            
            setupLayout()
            
        }
    }
    
    
    // MARK: Actions

    @IBAction func goToMemeEditor(_ sender: Any) {
        
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController

        present(viewController, animated: true, completion: nil)
    }



    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SentMemesCollectionViewCell
    
        cell.sentMemeImageView.image = memes[indexPath.row].memedImage
    
        return cell
    }


    // MARK: UICollectionViewDelegate
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        // Grab the DetailVC from Storyboard
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "SentMemeDetailViewController") as! SentMemeDetailViewController
        
        //Populate view controller with data from the selected item
        detailController.meme = memes[indexPath.row]
        
        // Present the view controller using navigation
        navigationController!.pushViewController(detailController, animated: true)
        
    }

}
