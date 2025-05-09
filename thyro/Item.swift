//
//  Item.swift
//  thyro
//
//  Created by Areeb Khan on 5/8/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
