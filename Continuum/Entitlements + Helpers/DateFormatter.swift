//
//  DateFormatter.swift
//  Continuum
//
//  Created by Nic Gibson on 7/9/19.
//  Copyright © 2019 Nic Gibson. All rights reserved.
//

import Foundation

extension Date {
    func formatDate() -> String {
        let formatter = DateFormatter()
//        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.setLocalizedDateFormatFromTemplate("MMMMdd")
        
        return formatter.string(from: self)
    }
}
