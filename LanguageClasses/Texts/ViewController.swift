//
//  ViewController.swift
//  LanguageClasses
//
//  Created by Бойко Григорий on 02/06/2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    public typealias Parameters = [String: Any]
    var article: Text!
    var translate = NSMutableAttributedString()
    var word = ""
    public static var token = ""
    
    
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = article.text
        setupNavigationBar()
        
        // Распознователь нажатий
        let tap = UITapGestureRecognizer(target: self, action:#selector(tapResponse))
        //Устанавливаем наш класс делигатом распознователя нажатий
        tap.delegate = self
        textView.addGestureRecognizer(tap)
        
        let head: HTTPHeaders = ["Authorization": "Basic YzQ5MGM0ZDgtZGU2Ni00MDBmLThmNDYtNTEwMzc1YTMyYjJhOmFhOTE3MTY4ZWZhYTRmMzVhZmU0Mjk0YjNlYzJhOTI3"]
        AF.request("https://developers.lingvolive.com/api/v1.1/authenticate", method: .post, parameters: nil, headers: head).validate().responseString { response in
            print("token = \(response.value!)")
            ViewController.token = response.value!
            print(ViewController.token + "))")
        }
        
    }
    
    private func setupNavigationBar(){
        //Настраиваем кнопку назад
        if let topItem = navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            topItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
        //Название
        title = article.title
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "translateSegue" {
            let dvc = segue.destination as! TranslateCardViewController
            dvc.translate = translate
            dvc.word = word
        }
    }
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){
        
    }
    @objc func tapResponse(_ recognizer: UITapGestureRecognizer) {
        let location: CGPoint = recognizer.location(in: textView)
        let position: CGPoint = CGPoint(x: location.x, y: location.y)
        // Return the position in a document that is closest to a specified point.
        let tapPosition: UITextPosition? = textView.closestPosition(to: position)
        guard tapPosition != nil else { return }
        
        //Диапазон глубиной в слово от позиция нажатия
        let textRange: UITextRange? = textView.tokenizer.rangeEnclosingPosition(tapPosition!, with: UITextGranularity.word, inDirection: UITextDirection(rawValue: 1))
        
        // Если мы нажали на слово
        if let range = textRange{
            word = textView.text(in: range)!
            self.performSegue(withIdentifier: "translateSegue", sender: nil)
            print("Показал сигвей")
            
            
        }
        
        
    }
    
}
extension NSMutableAttributedString {
    var fontSize:CGFloat { return 20 }
    var boldFont:UIFont { return UIFont(name: "Georgia-Bold ", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont:UIFont { return UIFont(name: "Georgia", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}
    
    func bold(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    /* Other styling methods */
    func orangeHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.orange
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func blackHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.black
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func underlined(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}
//extension UIFont{
//    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont{
//        let d = fontDescriptor.withSymbolicTraits(traits)
//        return UIFont(descriptor: d!, size: 0)
//    }
//    func bold() -> UIFont{
//        return withTraits(.traitBold)
//    }
//}


