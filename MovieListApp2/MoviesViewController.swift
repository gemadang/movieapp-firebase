//
//  MoviesViewController.swift
//  MovieListApp
//
//  Created by Geri Elise Madanguit on 3/26/18.
//  Copyright © 2018 GeriMadanguit. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()
import Firebase

class MoviesViewController: UITableViewController {
    var results: MovieResults?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        checkIfUserIsLoggedIn()
        
        /*
        fetch_movies {
            print("JSON download successful!")
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            self.tableView.reloadData()
        }
         */
        
        navigationItem.title = "Popular Movies"
        tableView.register(ListCell.self, forCellReuseIdentifier: "cell_id")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupNavBar(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.title = "WOOOOO Movies"
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(editProfile))
    }
    @objc func handleLogout() {
        // Sign-out!!!
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        // Show Login Screen Modally!!!
        let loginController = LoginController()
        loginController.moviesViewController = self
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func editProfile(){
        
        //print(124)
        let profileController = ProfileController()
        //profileController.delegate = self
        
        navigationController?.pushViewController(profileController, animated: true)
 
    }
    
    func checkIfUserIsLoggedIn() {
        // if not sign in, display login screen!!!
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
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
                self.setupNavBarWithUser(user)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(_ user: User) {
        /*
        let titleView = TitleView(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        
        self.navigationItem.titleView = titleView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        titleView.isUserInteractionEnabled = true
        
        titleView.addGestureRecognizer(tap)
        
        if let profileImageUrl = user.profileurl {
            titleView.profileImageView.downloadImageUsingCacheWithLink(profileImageUrl)
            
        }
        */
        //titleView.nameLabel.text = user.name
        
        //fetchLists()
 
        fetch_movies {
            print("JSON download successful!")
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            self.tableView.reloadData()
        }
    }
    
    func fetch_movies(completed: @escaping () -> ()){
        let api_key = "eafa1ac83fa7dccea6df7b0d6e1c4f57"
        let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=\(api_key)")
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            guard let jsondata = data else { return }
            do {
                self.results = try JSONDecoder().decode(MovieResults.self, from: jsondata)
                DispatchQueue.main.async {
                    completed()}}
            catch{print("JSON Error")}
            }.resume()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let number = results?.movies.count {
            return number
        }
        return 0
    }
    
    func showDetailOfMovie(movie: MovieInfo){
        let detailController = ViewController()
        detailController.movie = movie
        navigationController?.pushViewController(detailController, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            results?.movies.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let movie = results?.movies[indexPath.row]{
            //print(movie)
            self.showDetailOfMovie(movie: movie)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let movie = results?.movies[indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_id", for: indexPath) as! ListCell
            let posterlink = "https://image.tmdb.org/t/p/w185/" + (movie.posterPath)!
            
            cell.iconImageView.downloadImageUsingCacheWithLink(posterlink)
            
            cell.textLabel?.text = movie.title
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

class ListCell: UITableViewCell{
    
    let iconImageView:UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let review_number:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupViews(){
        contentView.addSubview(iconImageView)
        
        iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2).isActive = true //leading = left, trailing = tright
        iconImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        contentView.addSubview(review_number)
        let number_of_reviews = 0
        review_number.text = "\(number_of_reviews) reviews"
        review_number.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        review_number.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -100).isActive = true
        review_number.heightAnchor.constraint(equalToConstant: 30).isActive = true
        review_number.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 70, y: 40, width: textLabel!.frame.width, height: 30)
    }
}
extension UIImageView {
    func downloadImageUsingCacheWithLink(_ urlLink: String){
        self.image = nil
        if urlLink.isEmpty {
            return
        }
        // check cache first
        if let cachedImage = imageCache.object(forKey: urlLink as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        // otherwise, download
        let url = URL(string: urlLink)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if let err = error {
                print(err)
                return
            }
            DispatchQueue.main.async {
                if let newImage = UIImage(data: data!) {
                    imageCache.setObject(newImage, forKey: urlLink as NSString)
                    self.image = newImage
                }
            }
        }).resume()
    }
}

