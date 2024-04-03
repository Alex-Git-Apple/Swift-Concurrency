//
//  SwiftConcurrencyApp.swift
//  SwiftConcurrency
//
//  Created by Pin Lu on 3/28/24.
//

import SwiftUI

@main
struct SwiftConcurrencyApp: App {
    var body: some Scene {
        WindowGroup {
            DownloadImageAsync()
        }
    }
}
