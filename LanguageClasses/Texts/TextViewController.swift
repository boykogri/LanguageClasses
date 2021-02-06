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
        setup()
        
        print("Yandex token = \(tokenYa!)")
        
    }
    
    //MARK: - Parse page
    private func fetchBBC(){

        guard let url = URL(string: newItem.link) else { return }
        print(url)
        guard let html = try? String(contentsOf: url, encoding: .utf8) else {
            DispatchQueue.main.async {
                self.view.activityStopAnimating()
                self.setUIWithInternetProblem()
            }
            return
        }
        let semaphore = DispatchSemaphore(value: 0)
        var tempEl: Element? = nil
        do {
            let doc: Document = try SwiftSoup.parseBodyFragment(html)
            
            let main = try doc.select("article p, article h1, article h2, article h3, article img, article ul")
            // elements to remove, in this case images
            //            var undesiredElements: Elements? = try main.select("button")
            //            try undesiredElements?.remove()
            
            let mutStr = NSMutableAttributedString(string: "")
            print("Всего элементов: \(main.count)")
            var count = 0
            for el in main {
                count += 1
                print("Получили элемент N\(count)")
                
                //Если изображение
                if el.tagName() == "img"{
                    var url = try el.attr("src")
                    //url += "1"
                    //print("Изображение: \(url)")
                    let strBeforeImg = getHtmlAttributedStr2("<p>.</p>")
                    mutStr.append(strBeforeImg)
                    let range = NSMakeRange(mutStr.length-2, 1)

                    //В фоне грузим картинку
                    DispatchQueue.global(qos: .userInteractive).async {
                        //print("Загрузка изображения")
                        guard let image = self.getImage1(url) else {return}
                        
                        print("Ждем сигнал")
                        //Ждем сигнал, когда текст прогружен, чтоб избежать ошибки
                        semaphore.wait()
                        //Так как UI
                        DispatchQueue.main.async {
                            self.insertImage(image, for: range)
                            print("Сигнал пошел")
                            semaphore.signal()
                        }
                    }
                    
                    //Любой другой тег
                }else {
                    if el.tagName() == "ul" {
                        tempEl = el
                    }
                    if el.tagName() == "p" {
                        //Для избежания дублирования текста (когда в ul хранятся p)
                        //Мы проверяем родителя, которого мы запомнили выше
                        //Если он совпадает, то значит мы уде обработали этот текст -> пропускаем
                        if let temp = tempEl {
                            if (el.parents().contains(temp)) {continue}
                        }
                    }            
                    //try el.append("<br>")
                    //tempHtmlStr.append(try el.html()+"<br>")
                    let html = getHtmlAttributedStr2(try el.html()+"<br>", tag: el.tagName())
                    mutStr.append(html)
                }
                
            }
            print("Я тут")
            //String в Attributed string
            //mutStr.append(getHtmlAttributedStr2(tempHtmlStr))
            DispatchQueue.main.async {
                self.view.activityStopAnimating()
                self.textView.attributedText = mutStr
                //Первый сигнал, сначла текст - потом изображение
                print("Первый сигнал пошел")
                semaphore.signal()
                print("Вставил текст")
            }
            
            
        } catch Exception.Error(let type, let message) {
            print("Message: \(message)")
        } catch {
            print("error")
        }
    }
    
    //MARK: - Text handling
    func getHtmlAttributedStr(_ html: String) -> NSMutableAttributedString{
        let modifiedFont = String(format:"<span style=\"font-family: 'Roboto-Regular', '-apple-system', 'HelveticaNeue'; font-size: 20\">%@</span>", html)
        let data = Data(modifiedFont.utf8)
        let attrStr = try! NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        
        let paragrah = NSMutableParagraphStyle()
        paragrah.alignment = .left
        paragrah.paragraphSpacing = 12
        attrStr.addAttributes([.paragraphStyle: paragrah], range: NSMakeRange(0, attrStr.length))
        return attrStr
    }
    
    func getHtmlAttributedStr2(_ string: String, tag: String = "p") -> NSAttributedString{
        let data = Data(string.utf8)
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let att = try? NSAttributedString(data: data,
                                                options: options,
                                                documentAttributes: nil)
        else {return NSAttributedString(string: "")}
        let mutAttStr = NSMutableAttributedString(attributedString:att)
        
        var useOwnTraits = false
        var customFont = UIFont(name: "Roboto-Regular", size: 20)
        switch tag{
        case "p":
            customFont = UIFont(name: "Roboto-Regular", size: 20)
        case "ul":
            customFont = UIFont(name: "Roboto-Regular", size: 20)
            useOwnTraits = true
        case "h1":
            customFont = UIFont(name: "Roboto-Bold", size: 26)
            useOwnTraits = true
        case "h2":
            customFont = UIFont(name: "Roboto-Bold", size: 24)
            useOwnTraits = true
        case "h3":
            customFont = UIFont(name: "Roboto-Bold", size: 22)
            useOwnTraits = true
        default:
            break
        }
        
        mutAttStr.enumerateAttribute(
            NSAttributedString.Key.font,
            in:NSMakeRange(0,mutAttStr.length),
            options:.longestEffectiveRangeNotRequired) { value, range, stop in
            let f1 = value as! UIFont //
            
            guard let newFont = customFont else {
                return
            }
            
            //Объединяем все старые стили и новые
            if let f3 = self.applyTraitsFromFont(f1, to:newFont, customTraits: useOwnTraits) {
                mutAttStr.addAttribute(
                    NSAttributedString.Key.font, value:f3, range:range)
            }
        }
        let paragrah = NSMutableParagraphStyle()
        paragrah.alignment = .left
        paragrah.paragraphSpacing = 12
        mutAttStr.addAttributes([.paragraphStyle: paragrah], range: NSMakeRange(0, mutAttStr.length))
        
        return mutAttStr
        
    }
    func applyTraitsFromFont(_ f1: UIFont, to f2: UIFont, customTraits: Bool = false) -> UIFont? {
        var t: UIFontDescriptor.SymbolicTraits
        if (customTraits) {
            t = f2.fontDescriptor.symbolicTraits
        }else {
            t = f1.fontDescriptor.symbolicTraits // bold/italic..
        }
        if let fd = f2.fontDescriptor.withSymbolicTraits(t) {
            return UIFont.init(descriptor: fd, size: 0)
        }
        return nil
    }

    
    //MARK: - Work with Images
    func insertImage(_ image: UIImage, for range: NSRange){
        print("Вставка изображения")
        let mutableAttr = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        let par = NSMutableParagraphStyle()
        par.paragraphSpacing = 12
        
        
        
        let maxWidth = self.textView.bounds.size.width
        imageAttachment.setImageSize(maxWidth: maxWidth-20)
        let imgStr = NSMutableAttributedString(attachment: imageAttachment)
        //imgStr.append(NSAttributedString(string: "\n"))
        mutableAttr.replaceCharacters(in: range, with: imgStr)
        mutableAttr.addAttributes([.paragraphStyle: par], range: range)
        
        textView.attributedText = mutableAttr
    }
    func getImage1(_ url: String) -> UIImage?{
        
        guard let url = URL(string: url) else { return nil}
        if let data = try? Data(contentsOf: url), let img = UIImage(data: data){
            print("Загрузили изображение")
            return img
        }
        print("Не удалось загрузить изображение")
        return nil
    }
    
    func getImage(_ url: String) -> UIImage?{
        
        let semaphore = DispatchSemaphore(value: 0)
        var image: UIImage? = nil
        
        AF.request(url).response { (response) in
            switch response.result{
            case .success(let data):
                if let img = UIImage(data: data!){
                    print("Распарсили изображение")
                    image = img
                    //print("Image1 = \(image)")
                }
            case .failure(let error):
                debugPrint(response)
            }
            semaphore.signal()
        }
        semaphore.wait()
        //print("Image2 = \(image)")
        return image
    }

    //MARK: - Work with UI
    //FIXME: - Дублирование кода
    private func setUIWithInternetProblem(){
        let internetErrorLabel = UILabel()
        internetErrorLabel.text = """
        Не удалость получить новость :(
        Проверьте соединение с интернетом
        """
        internetErrorLabel.numberOfLines = 0
        internetErrorLabel.sizeToFit()
        
        let button = UIButton()
        button.setTitle("Попробовать еще раз", for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(self.pressedButton), for: .touchUpInside)
        // Padding
        button.contentEdgeInsets = UIEdgeInsets(top: 10,left: 7,bottom: 10,right: 7)
        
        
        let stackView = UIStackView(arrangedSubviews: [internetErrorLabel, button])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 15
        stackView.tag = 525
        
        self.view.addSubview(stackView)
        // autolayout constraint
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
    }
    @objc func pressedButton(){
        if let stackView = self.view.viewWithTag(525){
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    stackView.removeFromSuperview()
                    self.view.activityStartAnimating()
                }
                self.fetchBBC()
            }
        }
    }
    //MARK: - Setup
    private func setup(){
        self.view.setActivityIndicator()
        self.view.activityStartAnimating()
        
        //       Распознователь нажатий
        let tap = UITapGestureRecognizer(target: self, action:#selector(tapResponse))
        //Устанавливаем наш класс делигатом распознователя нажатий
        tap.delegate = self
        textView.addGestureRecognizer(tap)
        
        setupNavigationBar()
        setupTextView()
        //Название
        title = newItem.title
    }
    private func setupNavigationBar(){
        //Настраиваем кнопку назад
        if let topItem = navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            topItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
    }
    private func setupTextView(){
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
}


extension NSTextAttachment {
    func setImageSize(maxWidth: CGFloat) {
        guard let image = image else { return }
        let ratio = maxWidth/image.size.width
        let height = ratio * image.size.height
        //bounds.origin.x/y что это
        bounds = CGRect(x: -10, y: 0, width: maxWidth, height: height)
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



