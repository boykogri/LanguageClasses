//
//  Translations.swift
//  LanguageClasses
//
//  Created by Григорий Бойко on 03.12.2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

struct Translation: Decodable {
    let text: String
    let pos: String? // Часть речи (может отсутствовать)
    let ts: String? // Транскрипция
    let tr: [Translation]? // Массив переводов
    let gen: String? // Род
    let syn: [Translation]? // Массив синонимов
    let mean: [Translation]? // Массив значений
    let ex: [Translation]? // Массив примеров
}
struct Translations: Decodable {
    let def: [Translation]
}
