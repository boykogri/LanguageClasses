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
    var translate: NSMutableAttributedString!
    var word: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .background).async {
            print("Запрос пошел")
            self.getResponse()
            DispatchQueue.main.async {
                print("Меняю значения")
                self.translateTV.attributedText = self.translate
            }
        }
        self.wordTF.text = self.word
        
        addButton.isEnabled = false
        //Добавляем слушателя
        translateTF.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        // Распознователь нажатий
        let tap = UITapGestureRecognizer(target: self, action:#selector(tapResponse))
        //Устанавливаем наш класс делигатом распознователя нажатий
        tap.delegate = self
        translateTV.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addWord(_ sender: Any) {
        StorageManager.saveObject(Card(wordTF.text!, translateTF.text!))
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
    func getResponse(){
        let url = "https://developers.lingvolive.com/api/v1/Translation"
        let parameters: [String: Any] = [
            "text": word!,
            "srcLang": 1033,
            "dstLang": 1049
        ]
        
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(ViewController.token)",
            //"Accept": "application/json"
        ]

        AF.request(url, method: .get, parameters: parameters, headers: headers).validate().responseJSON { responseJSON in
            self.translate = NSMutableAttributedString()
            switch responseJSON.result {
            case .success(let value):
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
// Mark: — Text Field Delegate
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
