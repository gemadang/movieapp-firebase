//
//  File.swift
//  MovieListApp2
//
//  Created by Geri Elise Madanguit on 4/16/18.
//  Copyright © 2018 GeriMadanguit. All rights reserved.
//

import UIKit

class LoginView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    func setup(){
        //backgroundColor = .red
        backgroundImageView.setAnchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
    }
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "loginBG")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
