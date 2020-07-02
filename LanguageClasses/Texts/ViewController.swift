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
    var token = ""
    
    
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
            self.token = response.value!
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
    //Получаем перевод
    func getTranslate(for value: Any, node: [String] = ["List"]){
        if let arr = value as? [ [String : Any] ]{
            for obj in arr {
                if let nodeObject = obj["Node"] as? String {
                    //Если пошли синонимы, то прерываемся
                    if nodeObject == "CardRef" {break}
                    if node.contains(nodeObject){
                        switch nodeObject {
                        case "List":
                            //print("1.", separator: "", terminator: " ")
                            getTranslate(for: obj["Items"]!, node: ["ListItem"])
                        case "ListItem":
                            getTranslate(for: obj["Markup"]!, node: ["Paragraph"])
                            getTranslate(for: obj["Markup"]!, node: ["List"])
                        case "Paragraph":
                            getTranslate(for: obj["Markup"]!, node: ["Abbrev", "Text"])
                        case "Abbrev":
                            var temp = obj["Text"] as! String
                            temp += " "
                            let s = NSMutableAttributedString().bold(temp)
                            translate.append(s)
                        case "Text":
                            var temp = obj["Text"] as! String
                            temp += " "
                            let s = NSMutableAttributedString().normal(temp)
                        translate.append(s)
                        default:
                            return
                        }
                    }
                    
                }
                
                
            }
            //Чтоб исключить множество переносов строки
            if (translate.string != "") && translate.string.last! != "\n"{
                translate.append(NSMutableAttributedString(string: "\n"))
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "translateSegue" {
            let dvc = segue.destination as! TranslateCardViewController
            dvc.translate = translate
            dvc.key = word
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
            
            let url = "https://developers.lingvolive.com/api/v1/Translation"
            let parameters: [String: Any] = [
                "text": word,
                "srcLang": 1033,
                "dstLang": 1049
            ]
            
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                //"Accept": "application/json"
            ]
            //let utilityQueue = DispatchQueue.global(qos: .utility)
            AF.request(url, method: .get, parameters: parameters, headers: headers).validate().responseJSON { responseJSON in
                
                switch responseJSON.result {
                case .success(let value):
                    self.translate = NSMutableAttributedString()
                    //Разбираемся с body JSON ответа
                    if let arr = value as? [ [String : Any] ]{
                        for obj in arr {
                            if obj["Dictionary"] as? String == "LingvoUniversal (En-Ru)" {
                                if let arr1 = obj["Body"] as? [ [String : Any] ] {
                                    self.getTranslate(for: arr1)
                                }
                            }
                            
                        }
                    }
                    //print(self.translate)
                    self.performSegue(withIdentifier: "translateSegue", sender: nil)
                    
                case .failure(let error):
                    print(error)
                }
                
            }
            
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


