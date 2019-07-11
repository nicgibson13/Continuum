//
//  Post.swift
//  Continuum
//
//  Created by Nic Gibson on 7/9/19.
//  Copyright © 2019 Nic Gibson. All rights reserved.
//

import Foundation
import UIKit

class Post: SearchableRecord {
    
    var caption: String
    var timestamp: Date
    var comments: [Comment]
    var photoData: Data?
    var photo: UIImage? {
        get {
            guard let photoData = photoData else
            {return nil}
            return UIImage(data: photoData)
        }
        
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    init(photo: UIImage, caption: String, timestamp: Date = Date(), comments: [Comment] = []) {
        self.caption = caption
        self.timestamp = timestamp
        self.comments = comments
        self.photo = photo
    }
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        if caption.lowercased().contains(searchTerm.lowercased()) {
            return true
        } else {
            for comment in comments {
                if comment.text.lowercased().contains(searchTerm.lowercased()) {
                    return true
                }
            }
        }
        return false
    }
}

class Comment: SearchableRecord {
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        return text == searchTerm ? true : false
    }
    
    var text: String
    var timestamp: Date
    weak var post: Post?
    
    init(text: String, timestamp: Date = Date(), post: Post?) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
}
