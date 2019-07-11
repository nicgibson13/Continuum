//
//  PostController.swift
//  Continuum
//
//  Created by Nic Gibson on 7/9/19.
//  Copyright © 2019 Nic Gibson. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

let publicDB = CKContainer.default().publicCloudDatabase

class PostController {
    
    //Singleton
    static let sharedInstance = PostController()
    
    // S. O. T.
    var posts: [Post] = []
    
    // CRUD Functions
    
    // Create
    func createComment(text: String, post: Post, completion: @escaping (Comment) -> Void) {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
    }
    
    func createPostWith(image: UIImage, caption: String, completion: @escaping (Post?) -> Void) {
        let post = Post(photo: image, caption: caption)
        posts.append(post)
        let record = CKRecord(post: post)
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("There was an error in \(#function) : \(error) : \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let record = record,
                let post = Post(record: record) else { completion (nil) ; return }
            completion(post)
        }
    }
    
    // Read
    
    // Update
    
    // Delete
    
}
