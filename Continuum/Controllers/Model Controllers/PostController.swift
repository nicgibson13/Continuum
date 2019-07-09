//
//  PostController.swift
//  Continuum
//
//  Created by Nic Gibson on 7/9/19.
//  Copyright © 2019 Nic Gibson. All rights reserved.
//

import Foundation
import UIKit

class PostController {
    
    //Singleton
    static let sharedInstance = PostController()
    
    // S. O. T.
    var posts: [Post] = []
    
    // CRUD Functions
    
    // Create
    func addComment(text: String, post: Post, completion: @escaping (Comment) -> Void) {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
    }
    
    func createPostWith(image: UIImage, caption: String, completion: @escaping (Post?) -> Void) {
        let post = Post(photo: image, caption: caption)
        posts.append(post)
    }
    
    // Read
    
    // Update
    
    // Delete
    
}
