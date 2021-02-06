//
//  RSSParser.swift
//  LanguageClasses
//
//  Created by Григорий Бойко on 31.10.2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import Foundation

struct RSSItem {
    var title: String
    var description: String
    var link: String
    var pubDate: String
}

class RSSParser: NSObject, XMLParserDelegate {
    
    var rssItems: [RSSItem] = []
    //Название XML тега
    private var currentElement = ""
    //Значение тега
    //private var foundCaracters = ""
    private var currentTitle = ""
    private var currentDescription = ""
    private var currentLink = ""
    private var currentPubDate = ""
    //Ключ - Значение
    private var currentData = [String:String]()
    //Все значения
    //var parsedData = [[String:String]]()
    private var inItem = false
    //let needElements = ["title", "description", "link", "pubDate"]
    
    func startParsingWithContentsOfURL(rssUrl: URL, with completion: (Bool)->()) {
        
        let parser = XMLParser(contentsOf: rssUrl)
        parser?.delegate = self
        
        //В случае успешного парсинга, совершаем дальнейшую обработку в вызываемом методе
        if let isSuccessful = parser?.parse() {
            completion(isSuccessful)
        }else { completion(false) }
    }
    
    // MARK: - XML Parser Delegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        if currentElement == "item"{
            inItem = true
            currentTitle = ""
            currentDescription = ""
            currentPubDate = ""
            currentLink = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if inItem {
            //Удаляем лишние пробелы и переносы строки
            let foundCharacters = string.trimmingCharacters(in: .whitespacesAndNewlines)
            switch currentElement {
            case "title":
                currentTitle += foundCharacters
            case "description":
                currentDescription += foundCharacters
            case "link":
                currentLink += foundCharacters
            case "pubDate":
                currentPubDate += foundCharacters
            default:
                return
            }
            //foundCaracters = foundCaracters.deleteHT
        }
        
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
//        if inItem{
//            // Добавляем элемент - значение
//            currentData[currentElement] = foundCaracters
//            foundCaracters = ""
//
//        }
        if elementName == "item"{
            //parsedData.append(currentData)
            let item = RSSItem(title: currentTitle, description: currentDescription, link: currentLink, pubDate: currentPubDate)
            rssItems.append(item)
            inItem = false
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error){
        print(parseError.localizedDescription)
    }
}

