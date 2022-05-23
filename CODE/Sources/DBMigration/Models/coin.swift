//
//  File.swift
//  
//
//  Created by Benny De Bock on 19/04/2022.
//

import Foundation

struct Coin {
    let id: UUID
    let source: String
    let to: String
    let from: String
    let reason: String
    let value: Int
    let createdAt: Date
}