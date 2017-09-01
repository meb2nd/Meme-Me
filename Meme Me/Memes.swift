//
//  Memes.swift
//  Meme Me
//
//  Created by Pete Barnes on 9/1/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import UIKit

class Memes: NSObject {

    
    // Conveneince method to save a meme
    static func addToSavedMemes(meme: Meme) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    // Convenience method to get copy of the saved memes
    static func getSavedMemes() -> [Meme] {
        
        return (UIApplication.shared.delegate as! AppDelegate).memes
    }
    
    // Conveneince method to remove meme from saved collection
    static func removeAtIndex(_ index: Int) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let memes = appDelegate.memes
        
        if memes.indices.contains(index) {
            appDelegate.memes.remove(at: index)
        }
        
    }
    
    // Conveneince method to retrieve meme from saved collection
    static func getMemeAtIndex(_ index: Int) -> Meme? {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let memes = appDelegate.memes
        
        return memes.indices.contains(index) ? memes[index] : nil
    }
}
