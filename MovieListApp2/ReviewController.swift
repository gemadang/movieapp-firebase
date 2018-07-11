//
//  ReviewController.swift
//  MovieListApp2
//
//  Created by Geri Elise Madanguit on 4/16/18.
//  Copyright © 2018 GeriMadanguit. All rights reserved.
//

import UIKit
import Firebase


protocol ReviewControllerDelegate: class {
    func reviewControllerDidGoBack(_ controller: ReviewController)
    //func ViewController(_ controller: ViewController, didFinishAdding list: ToDoList)
    //func ViewController(_ controller: ViewController, didFinishEditing list: ToDoList)
}

class ReviewController: UIViewController, UITextFieldDelegate {
    // why weak?
    weak var delegate: ReviewControllerDelegate?
    var detailViewController: ViewController?
    var movieId = ""
    var movieTitle = ""
    
    let textField:UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    func setupNavBar(){
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
        //navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func setupViews(){
        view.addSubview(textField)

        view.addSubview(separatorView)
        
        textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        textField.delegate = self
        
        separatorView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 5).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    @objc func handleCancel(){
        print("Cancel touched")
        //dismiss(animated: true, completion: nil)
        delegate?.reviewControllerDidGoBack(self)
    }
    // call delegate methods which are implemented on MyTopListViewController!
    @objc func handleDone() {
        print("Done tapped")
        
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        

        self.registerReviewIntoMovieDatabase(uid)
    }
    
    fileprivate func registerReviewIntoMovieDatabase(_ uid: String) {
        
        let ref = Database.database().reference()
        let moviesReference = ref.child("movies").child(movieId).child("reviews").child(uid)
       
        let values = ["movie title" : movieTitle, "review description": textField.text] as [String : Any]
        
        moviesReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err ?? "")
                return
            }
            
            //self.myTopListViewController?.fetchUserAndSetupNavBarTitle()
            //self.detailViewController?.fetchUserAndSetupNavBarTitle()
            //self.detailViewController?.navigationController?.popViewController(animated: true)
            self.delegate?.reviewControllerDidGoBack(self)
        })
 
    }
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        navigationItem.rightBarButtonItem?.isEnabled = !newText.isEmpty
        
        return true
    }
    
}
