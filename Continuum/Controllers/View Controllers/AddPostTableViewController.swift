//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Nic Gibson on 7/9/19.
//  Copyright © 2019 Nic Gibson. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
    
    
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        selectImageButton.setTitle("Select Image", for: .normal)
        imageView.image = nil
        captionTextField.text = ""
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func imageButtonTapped(_ sender: Any) {
        selectImageButton.setTitle("", for: .normal)
        imageView.image = UIImage(named: "spaceEmptyState")
    }
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let caption = captionTextField.text else {return}
        if imageView.image != nil {
            guard let photo = imageView.image else {return}
            PostController.sharedInstance.createPostWith(image: photo, caption: caption) { (post) in
            }
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
