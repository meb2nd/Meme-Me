//
//  Meme.swift
//  Meme Me
//
//  Created by Pete Barnes on 8/27/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    
    var topText: String
    var bottomText: String
    var originalImage: UIImage
    var memedImage: UIImage
    var font: String
    
    // Conveneince method to save a meme
    func addToSavedMemes(meme: Meme) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    // Convenience method to get immutable copy of the saved memes
    static func getSavedMemes() -> [Meme] {
        return (UIApplication.shared.delegate as! AppDelegate).memes
    }
    
    // Conveneince method to remove meme from saved collection
    func removeFromSavedMemes(meme: Meme) {
        
        /*
         
         Here is how to compare images
         
         let image1 = UIImage(named: "MyImage")
         let image2 = UIImage(named: "MyImage")
         if image1 != nil && image1!.isEqual(image2) {
         // Correct. This technique compares the image data correctly.
         }
 
 
         This is the way to create a custom compare function
         
         infix operator <==> { precedence 130 }
         func <==> (lhs: CGPoint, rhs: CGPoint) -> Bool {
         return lhs.x == rhs.x && lhs.y == rhs.y
         }
         
         let point1 = CGPoint(x: 1.0, y: 1.0)
         let point2 = CGPoint(x: 1.0, y: 1.0)
         point1 <==> point2 // true
 
 
         */
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
}
