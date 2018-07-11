//
//  ViewController.swift
//  MovieListApp
//
//  Created by Geri Elise Madanguit on 3/26/18.
//  Copyright © 2018 GeriMadanguit. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, ReviewControllerDelegate{
    var movieDetail : MovieData?
    
    let header:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let overview:UITextView = {
        let label = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let review:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let releaseDate:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailView: DetailViews = {
        let detailView = DetailViews()
        detailView.translatesAutoresizingMaskIntoConstraints = false
        return detailView
    }()

    var movie: MovieInfo? {
        didSet{
            let id = movie?.id
            detailView.movie = movie!
            print(id!)
            let link = "https://api.themoviedb.org/3/movie/\(id!)?api_key=eafa1ac83fa7dccea6df7b0d6e1c4f57"
            let url = URL(string: link)
            
            URLSession.shared.dataTask(with: url!){ (data, response, err) in
                if err == nil {
                    guard let jsondata = data else { return }
                    do {
                        self.movieDetail = try JSONDecoder().decode(MovieData.self, from: jsondata)
                        print(self.movieDetail?.title)
                        DispatchQueue.main.async {
                            self.setupViews()
                        }
                    }catch {
                        print("JSON DOWNLOADING ERROR!")
                    }
                }
                }.resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupNavBar()
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
        // fetch User info! Set up Navigation Bar!
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //                self.navigationItem.title = dictionary["name"] as? String
                
                let user = User(dictionary: dictionary)
//                self.setupNavBarWithUser(user)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBar(){
        /*
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.title = "WOOOOO Movies"
 
         */
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Review", style: .plain, target: self, action: #selector(addReview))
    }
    
    @objc func addReview(){
         let reviewController = ReviewController()
         reviewController.delegate = self
        
         reviewController.movieId = String((movieDetail?.id)!)
         reviewController.movieTitle = (movieDetail?.title)!
         navigationController?.pushViewController(reviewController, animated: true)
    }
    // when cancel button is tapped
    func reviewControllerDidGoBack(_ controller: ReviewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func setupViews(){
        view.backgroundColor = .white

        /*
        view.addSubview(releaseDate) //releaseDate
        releaseDate.text = movieDetail?.releaseDate
       
        releaseDate.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        releaseDate.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        releaseDate.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1).isActive = true
        releaseDate.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5).isActive = true
        */
        
        view.addSubview(detailView) //collectionview
        detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        detailView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        detailView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.4).isActive = true
        detailView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1.0).isActive = true
        
        //detailView.setUpViews()
        
        view.addSubview(header) //title
        header.text = movieDetail?.title
        header.topAnchor.constraint(equalTo: detailView.bottomAnchor, constant: 10).isActive = true
        header.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1).isActive = true
        header.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8).isActive = true
        
        view.addSubview(overview)
        overview.text = movieDetail?.overview
        overview.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        overview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        overview.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3).isActive = true
        overview.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8).isActive = true
        
        
        /*
        view.addSubview(review)
        review.text =
        review.topAnchor.constraint(equalTo: overview.bottomAnchor, constant: 5).isActive = true
        review.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        review.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1).isActive = true
        review.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8).isActive = true
        */
        
        
    }
    
}

