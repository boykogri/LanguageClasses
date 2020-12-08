//
//  Token.swift
//  LanguageClasses
//
//  Created by Григорий Бойко on 30.11.2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

struct Token: Decodable {
    var iamToken: String
    var expiresAt: String
}
