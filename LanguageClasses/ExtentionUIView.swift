//
//  ExtentionUIView.swift
//  LanguageClasses
//
//  Created by Григорий Бойко on 26.11.2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import UIKit
extension UIView {
    
    func setActivityIndicator(){
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let indicator = UIActivityIndicatorView(frame: frame)
        indicator.tag = 475647
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.center
        indicator.backgroundColor = UIColor.white
        indicator.hidesWhenStopped = true
        //Игнорируем действия на View
        self.isUserInteractionEnabled = false
        self.addSubview(indicator)
    }
    
    func activityStartAnimating() {
        if let indicator = viewWithTag(475647) as? UIActivityIndicatorView{
            indicator.startAnimating()
        }
    }
    
    func activityStopAnimating() {
        if let indicator = viewWithTag(475647) as? UIActivityIndicatorView{
            indicator.stopAnimating()
        }
        self.isUserInteractionEnabled = true
    }
    
}

