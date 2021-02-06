//
//  ScrollableSegmentedControl.swift
//  LanguageClasses
//
//  Created by Григорий Бойко on 12.01.2021.
//  Copyright © 2021 Бойко Григорий. All rights reserved.
//

import UIKit

class ScrollableSegmentedControl: UISegmentedControl {

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

}
