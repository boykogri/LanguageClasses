//
//  TranslateCardViewController.swift
//  LanguageClasses
//
//  Created by Бойко Григорий on 06/06/2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import UIKit
import Alamofire

class TranslateCardViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var translateTV: UITextView!

    @IBOutlet weak var translateTF: UITextField!
    @IBOutlet weak var wordTF: UITextField!
    @IBOutlet weak var addButton: UIButton!
    var translate = NSMutableAttributedString().normal("Получение перевода...")
    var word: String!
    let token = TextViewController.token
    let tokenYA = TextsViewController.token

    override func viewDidLoad() {
        super.viewDidLoad()
        
        translateTV.attributedText = translate
        print("Запрос пошел")
        //self.getResponse()
        self.getTranslateFromYaDict()
        
        
        self.wordTF.text = self.word
        
        addButton.isEnabled = false
        //Добавляем слушателя
        translateTF.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        // Распознователь нажатий
        let tap = UITapGestureRecognizer(target: self, action:#selector(tapResponse))
        //Устанавливаем наш класс делигатом распознователя нажатий
        tap.delegate = self
        translateTV.addGestureRecognizer(tap)

    }
    
    //MARK: - Touch Actions
    @IBAction func addWord(_ sender: Any) {

        DispatchQueue.main.async {
            StorageManager.saveObject(Card(self.wordTF.text!, self.translateTF.text!))
        }
    }
    @objc func tapResponse(_ recognizer: UITapGestureRecognizer) {
        
        let location: CGPoint = recognizer.location(in: translateTV)
        let position: CGPoint = CGPoint(x: location.x, y: location.y)
        // Return the position in a document that is closest to a specified point.
        let tapPosition: UITextPosition? = translateTV.closestPosition(to: position)
        guard tapPosition != nil else { return }
        //Диапазон глубиной в слово от позиция нажатия
        // inDirection??? направление текста?
        let textRange: UITextRange? = translateTV.tokenizer.rangeEnclosingPosition(tapPosition!, with: UITextGranularity.word, inDirection: UITextDirection(rawValue: 1))
        // Если мы нажали на слово
        
        if let range = textRange{
            let tappedWord: String? = translateTV.text(in: range)
            translateTF.text = tappedWord!
            touchOnTheWord()
        }
        
    }
    
    //MARK: - Яндекс Словарь
    func getTranslateFromYaDict(){

        let parameters: [String: String] = [
            "key" : "dict.1.1.20201201T144656Z.9be9b4db4fdb8683.8c833ba38cf16fcd45cdd0fa2f3ddef5009ad8e8",
            "lang" : "en-ru",
            "text" : word!
        ]
        let url = "https://dictionary.yandex.net/api/v1/dicservice.json/lookup"
        AF.request(url, method: .get, parameters: parameters).responseDecodable(of: Translations.self, queue: .global(qos: .userInteractive)) {
            response in
            //debugPrint(response)
            switch response.result {
            case .success(_):
//                DispatchQueue.main.async {
//                    self.translate = NSMutableAttributedString(string: "")
//                }
                self.translate = NSMutableAttributedString(string: "")
                self.printTranslate(translations: response.value!.def)
                
                print("Меняю значения")
                DispatchQueue.main.async {
                    self.translateTV.attributedText = self.translate
                }
                
                
            case .failure(let error):
                debugPrint(response)
                print("Неудача \(error)")
                DispatchQueue.main.async {
                    self.translateTV.attributedText = NSMutableAttributedString().normal("Не удалось перевести")
                }
            }
        }
    }
    func printTranslate(translations: [Translation]){

        for translate in translations{
            //Наше слово
            let text = translate.text
            self.translate.append(NSMutableAttributedString().normal(text, 26))
            //Выводим часть речи, если только основные блоки перевода (если есть)
            if let pos = translate.pos {
                 let s = NSMutableAttributedString().normal(" \(pos)")
                 self.translate.append(s)
            }
            //Выводим транскрипцию (если есть)
            if let ts = translate.ts {
                let s = NSMutableAttributedString().normal(" [\(ts)]", 18)
                self.translate.append(s)
            }
            //Вызываем рекурсию для вывода переводов
            if let tr = translate.tr {
            
                for t in tr {
                    var str = ""
                    str.append("\(t.text) ")
                    //Выводим пол (если есть)
                    if let gen = t.gen { str.append(" \(gen)") }
                    //Если есть синонимы – выводим
                    if let syn = t.syn {
                        for s in syn {
                            str.append(" \(s.text)")
                        }
                    }
                    self.translate.append(NSMutableAttributedString().bold("\n\(str)"))
                    
                    //Выводим англ перевод различных переводов
                    if let mean = t.mean {
                        str = ""
                        for m in mean {
                            str.append("\(m.text) ")
                        }
                        //str = str.trimmingCharacters(in: CharacterSet)
                        var s = NSMutableAttributedString()
                        s = s.normal("\n(\(str))")
                        self.translate.append(s)
                    }
                    
                    //Выводим примеры
                    if let ex = t.ex {
                        //Перенос строки
//                        var s = NSMutableAttributedString()
//                        s = s.normal("\n")
//                        self.translate.append(s)
                        
                        str = ""
                        for e in ex {
                            str.append("\(e.text) –")
                            //Выводим перевод примеров
                            if let tr = e.tr {
                                for t in tr {
                                    str.append(" \(t.text)")
                                }
                            }
                            var s = NSMutableAttributedString()
                            s = s.normal("\n    \(str)", 18)
                            self.translate.append(s)
                        }

                    }
                    
                }
                var s = NSMutableAttributedString()
                s = s.normal("\n\n")
                self.translate.append(s)
                //str = str.trimmingCharacters(in: CharacterSet)
                //var s = NSMutableAttributedString()
                //s = s.normal("\n(\(str))")
                
                
                //Если пришли из Примеров, то оставляем стиль вывода
                //Иначе выводим как основные переводы
                //let str = node == "examples" ? node : "translate"
                //printTranslate(translations: tr, str)
            }

            
        }
    }
    
    //MARK: - Яндекс переводчик
    func getResponseFromYaTranslate(){

        struct Translation: Decodable {
            let text: String
            let detectedLanguageCode: String
        }
        struct Translations: Decodable {
            let translations: [Translation]
        }
        let parameters: [String: Any] = [
            "folder_id": "",
            "texts": ["\(word!)"],
            "targetLanguageCode": "ru"
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(tokenYA)",
            "Content-Type": "application/json"
        ]
        print("tokenYA = \(tokenYA)")
        let url = "https://translate.api.cloud.yandex.net/translate/v2/translate"
        var request = URLRequest(url: URL(string: url)!)
        //Иначе не работает :(
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpMethod = "POST"
        request.headers = headers
        //
        AF.request(request).validate().responseDecodable(of: Translations.self) {
            response in
            debugPrint(response)
            switch response.result {
            case .success(_):
                print(response.value!.translations.first?.text ?? "Error value")
            case .failure(let error):
                print(error)
            }
        }
    }
    //MARK: - Networking with ABBYY
    func getResponse(){
        let url = "https://developers.lingvolive.com/api/v1/Translation"
        let parameters: [String: Any] = [
            "text": word!,
            "srcLang": 1033,
            "dstLang": 1049
        ]
        
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            //"Accept": "application/json"
        ]

        AF.request(url, method: .get, parameters: parameters, headers: headers).validate().responseJSON { responseJSON in
            self.translate = NSMutableAttributedString()
            switch responseJSON.result {
            case .success(let value):
                //print(value)
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
                print("Выполнил перевод")
                self.translateTV.attributedText = self.translate
            case .failure(let error):
                print(error)
            }
            
        }
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
        
}
//MARK: — Text Field Delegate
extension TranslateCardViewController: UITextFieldDelegate{
    //Если есть текст в текстовом поле, то активна кнопка add word
    // По нажатию на слово
    func touchOnTheWord(){
        if translateTF.text?.isEmpty == false {
            addButton.isEnabled = true
        }else{
            addButton.isEnabled = false
        }
    }
    //Если есть текст в текстовом поле, то активна кнопка add word
    @objc private func textFieldChange() {
        if translateTF.text?.isEmpty == false {
            addButton.isEnabled = true
        }else{
            addButton.isEnabled = false
        }
    }
}
