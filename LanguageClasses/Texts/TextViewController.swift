//
//  ViewController.swift
//  LanguageClasses
//
//  Created by Бойко Григорий on 02/06/2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup
//import WebKit

class TextViewController: UIViewController {
    public typealias Parameters = [String: Any]
    var article: Text!
    var newItem: RSSItem!
    var translate = NSMutableAttributedString()
    var word = ""
    var html: URL!
    var tokenYa: String!
    private let head: HTTPHeaders = [
        "Authorization": "Basic "]

    public static var token = ""
    
//    var webView = WKWebView()
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchBBC()

        }
        setupNavigationBar()
        self.view.setActivityIndicator()
        self.view.activityStartAnimating()
    
//       Распознователь нажатий
        let tap = UITapGestureRecognizer(target: self, action:#selector(tapResponse))
        //Устанавливаем наш класс делигатом распознователя нажатий
        tap.delegate = self
        textView.addGestureRecognizer(tap)

//        AF.request("https://developers.lingvolive.com/api/v1.1/authenticate", method: .post, parameters: nil, headers: head).validate().responseString { response in
//            switch response.result{
//            case .success(let s):
//                print("tokenABBYY = \(response.value!)")
//                TextViewController.token = response.value!
//            case .failure(let error):
//                print(error)
//            }
//
//        }
        print("Yandex token = \(tokenYa!)")
        
    }

    //MARK: - Parse page
    private func fetchBBC(){
        guard let url = URL(string: newItem.link) else { return }
        print(url)
        guard let html = try? String(contentsOf: url, encoding: .utf8) else {
            problemWithParcing()
            return
        }

        do {
            let doc: Document = try SwiftSoup.parseBodyFragment(html)

            let main = try doc.select("article p, article h1, article h2, article h3, article img")
            // elements to remove, in this case images
//            var undesiredElements: Elements? = try main.select("button")
//            try undesiredElements?.remove()

            var tempHtmlStr = ""
            let mutStr = NSMutableAttributedString(string: "")
            for el in main {
                //Если изображение
                if el.tagName() == "img"{
                    let url = try el.attr("src")
                    
                    if let image = getImage(url) {
                        let strBeforeImg = getHtmlAttributedStr(string: tempHtmlStr)
                        let imageAttachment = NSTextAttachment()
                        imageAttachment.image = image
                        DispatchQueue.main.async {
                            let maxWidth = self.view.bounds.size.width
                            imageAttachment.setImageSIze(maxWidth: maxWidth)
                        }
                        let imgStr = NSAttributedString(attachment: imageAttachment)
                        mutStr.append(strBeforeImg)
                        mutStr.append(imgStr)
                        tempHtmlStr = "<br>"
                    }
                //Любой другой тег
                }else {
                    try el.append("<br>")
                    tempHtmlStr.append(try el.html())
                }
                
            }
            //String в Attributed string
            mutStr.append(getHtmlAttributedStr(string: tempHtmlStr))
            DispatchQueue.main.async {
              
                //let atrStr = self.getHtmlAttributedStr(string: str)
                self.view.activityStopAnimating()
                self.textView.attributedText = mutStr
            }
        } catch Exception.Error(let type, let message) {
            print("Message: \(message)")
        } catch {
            print("error")
        }
    }
    
    //MARK: - Text handling
    func getHtmlAttributedStr(string : String) -> NSAttributedString{
        // Почему то проблема с  “ as â
//        let data = string.data(using: .utf8)!
//        let att = try? NSAttributedString.init(
//            data: data1,
//            options: [.documentType: NSAttributedString.DocumentType.html],
//            documentAttributes: nil)
        let data = Data(string.utf8)
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let att = try? NSAttributedString(data: data,
                                            options: options,
                                            documentAttributes: nil)
        else {return NSAttributedString(string: "")}
        let matt = NSMutableAttributedString(attributedString:att)
        matt.enumerateAttribute(
            NSAttributedString.Key.font,
            in:NSMakeRange(0,matt.length),
            options:.longestEffectiveRangeNotRequired) { value, range, stop in
                let f1 = value as! UIFont
                guard let customFont = UIFont(name: "Roboto-Regular", size: 20) else {return}
                //Объединяем все старые стили и новые
                if let f3 = self.applyTraitsFromFont(f1, to:customFont) {
                    matt.addAttribute(
                        NSAttributedString.Key.font, value:f3, range:range)
                }
        }
        let paragrah = NSMutableParagraphStyle()
        paragrah.alignment = .left
        paragrah.paragraphSpacing = 12
        matt.addAttributes([.paragraphStyle: paragrah], range: NSMakeRange(0, matt.length))
        return matt
    }
    
    func applyTraitsFromFont(_ f1: UIFont, to f2: UIFont) -> UIFont? {
        let t = f1.fontDescriptor.symbolicTraits
        if let fd = f2.fontDescriptor.withSymbolicTraits(t) {
            return UIFont.init(descriptor: fd, size: 0)
        }
        return nil
    }
    
    
    func getImage(_ url: String) -> UIImage?{
        let group = DispatchGroup()
        var image: UIImage? = nil
        group.enter() // указываем, что блок вошел в группу для синхронизации потоков
        AF.request(url).response { (response) in
            //debugPrint(response)
            
            switch response.result{
            case .success(let data):
                if let img = UIImage(data: data!){
                    print("Распарсили изображение")
                    image = img
                    print("Image1 = \(image)")
                }
            case .failure(let error):
                debugPrint(response)
            }
            group.leave() // указывает, что блок закончил выполнение
        }
        // Ожидаем, пока блок завершит работу
        group.wait()
        
        print("Image2 = \(image)")
        return image
    }

    func showImage(_ image: UIImage){
        DispatchQueue.main.async {
            let imgView = UIImageView(image: image)
            imgView.center = self.view.center
//            imgView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//            imgView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            self.view.addSubview(imgView)
        }
    }
    private func fetchNew(){
        
        guard let url = URL(string: newItem.link) else { return }
        print(url)
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { return }

            if let data = data{
                
                //print(String(data: data, encoding: .utf8)!)
                do {
                    let html = String(data: data, encoding: .utf8 )
                    let doc: Document = try SwiftSoup.parse(html!)
                    let body = try doc.body()!.text()
                    let linkInnerH: String = try doc.body()!.html()
                    let main = try doc.select("main article")

                    var str = ""
                    var resultStr = NSMutableAttributedString(string: "")
                    let articleElements = main.first()!.children()
                    for element in articleElements{
                        
                        str.append(try element.html())
                        print("element = \(element.tagName())")
                        for textNode in element.textNodes() {
                            print("textNode = \(textNode)")
                        }
                    }
                    
                    let mainHtml = try main.html()
                    if let attributedString = try? NSAttributedString(data: mainHtml.data(using: .utf8)!,
                                                                      options: [.documentType: NSAttributedString.DocumentType.html],
                                                                      documentAttributes: nil) {
                        DispatchQueue.main.async {
                            self.view.activityStopAnimating()
                            self.textView.attributedText = attributedString
                        }
                        
                    }
                } catch Exception.Error(let type, let message) {
                    print(message)
                } catch {
                    print("error")
                }
                
            }
        }.resume()
        
        
    }
    
    private func problemWithParcing(){
        
        DispatchQueue.main.async {
            self.view.activityStopAnimating()
            let str = NSMutableAttributedString(string: "Не удалость получить новость")
            self.textView.attributedText = str
            
        }
    }
    private func setupNavigationBar(){
        //Настраиваем кнопку назад
        if let topItem = navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            topItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
        //Название
        title = newItem.title
        //Padding
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10)
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

//MARK: - UIGestureRecognizerDelegate
extension TextViewController: UIGestureRecognizerDelegate{
    
    @objc func tapResponse(_ recognizer: UITapGestureRecognizer) {
        print("Пытаюсь найти слово")
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
    
    //Так как WKWebView имеет свой собственный gestureRecognizer(КАКОЙ?)
    //Разрешаем использовать оновременно 2
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print("Пытаюсь найти слово")
        return true
    }
    @objc func tapResponse1(_ recognizer: UITapGestureRecognizer) {
        print("Пытаюсь найти слово")
        
    }
}
//MARK: - Work with Images

func getImage(_ url: String) -> UIImage?{
    
    guard let url = URL(string: url) else { return nil}
    var image: UIImage? = nil
    let group = DispatchGroup()
    group.enter()

    AF.request(url).response { (response) in
        //debugPrint(response)
        switch response.result{
        case .success(let data):
            if let img = UIImage(data: data!){
                //print("Распарсили изображение")
                image = img
                group.leave()
                print("Image1 = \(image)")
            }
        case .failure(let error):
            debugPrint(response)
            print("Error = \(error)")
        }
        
    }
    // wait ...
    group.wait()
    print("Image2 = \(image)")
    return image
}

extension NSTextAttachment {
    func setImageSIze(maxWidth: CGFloat) {
        guard let image = image else { return }
        let ratio = maxWidth/image.size.width
        let height = ratio * image.size.height
        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: maxWidth, height: height)
    }

}
//MARK: - NSMutableAttributedString
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



