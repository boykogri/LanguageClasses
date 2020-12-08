//
//  ViewController.swift
//  LanguageClasses
//
//  Created by Бойко Григорий on 02/06/2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import UIKit
import Alamofire

class TextViewController: UIViewController {
    public typealias Parameters = [String: Any]
    var article: Text!
    var newItem: RSSItem!
    var translate = NSMutableAttributedString()
    var word = ""
    var html: URL!
    var tokenYa: String!
    private let head: HTTPHeaders = [
        "Authorization": "Basic YzQ5MGM0ZDgtZGU2Ni00MDBmLThmNDYtNTEwMzc1YTMyYjJhOmFhOTE3MTY4ZWZhYTRmMzVhZmU0Mjk0YjNlYzJhOTI3"]

    public static var token = ""
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchNew()
        }
    
        setupNavigationBar()
        self.view.setActivityIndicator()
        self.view.activityStartAnimating()
        
        // Распознователь нажатий
        let tap = UITapGestureRecognizer(target: self, action:#selector(tapResponse))
        //Устанавливаем наш класс делигатом распознователя нажатий
        tap.delegate = self
        textView.addGestureRecognizer(tap)
        
        
        AF.request("https://developers.lingvolive.com/api/v1.1/authenticate", method: .post, parameters: nil, headers: head).validate().responseString { response in
            print("tokenABBYY = \(response.value!)")
            TextViewController.token = response.value!
        }
        print("Yandex token = \(tokenYa!)")
        
    }
    
    private func fetchNew(){
        
        guard let url = URL(string: newItem.link) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { return }
            if let data = data{
                //let html = Data(String(data: data, encoding: .utf8 )!.utf8)
                //print(String(data: data, encoding: .utf8)!)
                if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                    DispatchQueue.main.async {
                        self.view.activityStopAnimating()
                        self.textView.attributedText = attributedString
                    }
                    
                }
            }
        }.resume()
        
        
    }
    
    private func setupNavigationBar(){
        //Настраиваем кнопку назад
        if let topItem = navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            topItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
        //Название
        title = newItem.title
    }
    

    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "translateSegue" {
            let dvc = segue.destination as! TranslateCardViewController
            //dvc.translate = translate
            dvc.word = word
        }
    }
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){
        
    }
    
}
extension TextViewController: UIGestureRecognizerDelegate{
    
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
    var boldFont:UIFont { return UIFont(name: "Georgia-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont:UIFont { return UIFont(name: "Georgia", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}
    
    func getFont(_ type: String, _ size: CGFloat = 20) -> UIFont{
        switch type {
        case "bold":
            return UIFont(name: "Georgia-Bold ", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        case "normal":
            return UIFont(name: "Georgia", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        case "italic":
            return UIFont(name: "Georgia-Italic", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        default:
            return UIFont.boldSystemFont(ofSize: size)
        }
    }
    func bold(_ value:String, _ fontSize: CGFloat? = nil) -> NSMutableAttributedString {
        
        var font = UIFont()
        if let size = fontSize { font = getFont("bold", size) }
        else { font = boldFont }
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : font
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String, _ fontSize: CGFloat? = nil) -> NSMutableAttributedString {
        
        var font = UIFont()
        if let size = fontSize { font = getFont("normal", size) }
        else { font = normalFont }
        let attributes:[NSAttributedString.Key : Any] = [
            .font : font,
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func italic(_ value:String, _ fontSize: CGFloat? = nil) -> NSMutableAttributedString {
        
        var font = UIFont()
        if let size = fontSize { font = getFont("italic", size) }
        else { font = getFont("italic") }
        let attributes:[NSAttributedString.Key : Any] = [
            .font : font,
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



