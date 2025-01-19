//
//  ImageCache.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/19/25.
//

import UIKit

class ImageCache {
    static let shared = ImageCache()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        cacheDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("ImageCache")
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    func saveImage(_ image: UIImage, withName name: String) {
        let fileURL = cacheDirectory.appendingPathComponent(name)
        guard let imageData = image.pngData() else { return }
        try? imageData.write(to: fileURL)
    }
    
    func loadImage(named name: String) -> UIImage? {
        let cleanName = name.replacingOccurrences(of: "static/", with: "")
        let fileURL = cacheDirectory.appendingPathComponent(cleanName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func imageExists(named name: String) -> Bool {
        let fileURL = cacheDirectory.appendingPathComponent(name)
        return fileManager.fileExists(atPath: fileURL.path)
    }
}
