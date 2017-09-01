//
//  SavedMemesCollectionViewDelegateFlowLayout.swift
//  Meme Me
//
//  Created by Pete Barnes on 9/1/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import UIKit

class SavedMemesCollectionViewDelegateFlowLayout: UICollectionViewFlowLayout {

    
    var view: UIView?
    let space:CGFloat = 3.0 // Minimum line and interim spacing
    
    // MARK:  UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var dimension: CGFloat = 100.0
        
        if let width = view?.frame.size.width {
            
            dimension = (width - (2 * space)) / 3.0
        }
        
        // dimension = ((view?.frame.size.width)! - (2 * space)) / 3.0
        

        return CGSize(width: dimension, height: dimension)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return space
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return space
        
    }
    
}
