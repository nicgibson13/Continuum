//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Nic Gibson on 7/9/19.
//  Copyright © 2019 Nic Gibson. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
    
    @IBOutlet weak var captionTextField: UITextField!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        let label = UILabel()
        label.text = "Pseudogram"
        label.font = UIFont(name: "TOMATOES", size: 30)
        label.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        label.textAlignment = .center
        label.sizeToFit()
        navigationItem.titleView = label
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captionTextField.text = ""
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let photo = selectedImage,
            let caption = captionTextField.text else { return }
        PostController.sharedInstance.createPostWith(image: photo, caption: caption) { (post) in }
        self.selectedImage = nil
        self.tabBarController?.selectedIndex = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerSegue" {
            let destinationVC = segue.destination as? PhotoSelectorViewController
            destinationVC?.delegate = self
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

extension AddPostTableViewController: AddPostTableViewControllerDelegate {
    func addPostTableViewControllerSelected(image: UIImage) {
        selectedImage = image
    }
}

protocol SearchableRecord {
    func matchesSearchTerm(searchTerm: String) -> Bool
}

