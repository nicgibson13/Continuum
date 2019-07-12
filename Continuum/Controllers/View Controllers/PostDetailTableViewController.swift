//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by Nic Gibson on 7/9/19.
//  Copyright © 2019 Nic Gibson. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController, UITextFieldDelegate {
    
    var postLandingPad: Post? {
        didSet {
            loadViewIfNeeded()
            self.updateViews()
        }
    }
    
    @IBOutlet weak var followButtonTapped: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let post = postLandingPad else {return}
        PostController.sharedInstance.fetchComments(for: post) { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func commentButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Leave a comment 🤪", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) -> Void in
            textField.delegate = self
            textField.placeholder = "Insert comment..."
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
        }
        
        let addComment = UIAlertAction(title: "OK", style: .default) { (_) in
            guard let comment = alertController.textFields?.first?.text,
                let post = self.postLandingPad else {return}
            if comment != "" {
                PostController.sharedInstance.createComment(text: comment, post: post, completion: { (comment) in
                })
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title:"Cancel", style: .destructive)
        
        alertController.addAction(addComment)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let photo = postLandingPad?.photo,
            let caption = postLandingPad?.caption else { return }
        let shareAlert = UIActivityViewController(activityItems: [photo, caption], applicationActivities: nil)
        present(shareAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func followPostButtonTapped(_ sender: Any) {
        
    }
    
    @ objc func updateViews() {
        guard let post = postLandingPad else { return }
        photoImageView.image = postLandingPad?.photo
        self.tableView.reloadData()
        updateFollowPostButtonText()
    }
    
    func updateFollowPostButtonText() {
        guard let post = postLandingPad else {return}
        PostController.sharedInstance.checkSubscription(to: post) { (found) in
            DispatchQueue.main.async {
                let followPostButtonText = found ? "Unfollow Post" : "FollowPost"
                self.followButtonTapped.setTitle(followPostButtonText, for: .normal)
                
            }
        }
    }
    
    @IBAction func followButton(_ sender: Any) {
        guard let post = postLandingPad else { return }
        PostController.sharedInstance.toggleSubscriptionTo(commentsForPost: post, completion: { (success, error) in
            if let error = error{
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                return
            }
            self.updateFollowPostButtonText()
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let comments = postLandingPad?.comments else {return 0}
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let comments = postLandingPad?.comments[indexPath.row]
        cell.textLabel?.text = comments?.text
        cell.detailTextLabel?.text = comments?.timestamp.formatDate()
        
        
        return cell
    }
}

