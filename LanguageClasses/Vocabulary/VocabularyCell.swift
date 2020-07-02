//
//  VocabularyCell.swift
//  LanguageClasses
//
//  Created by Бойко Григорий on 07/06/2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import UIKit

class VocabularyCell: UITableViewCell {
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
