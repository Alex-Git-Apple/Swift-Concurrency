//: [Previous](@previous)

import UIKit

actor ImageDownloader {
    enum CachedEntry {
        case finished(UIImage)
        case inProgress(Task<UIImage, Error>)
    }
    private var cache: [URL: CachedEntry] = [:]
    
    nonisolated private func download(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        if let image = UIImage(data: data) {
            return image
        } else {
            throw URLError(.badURL)
        }
    }
    
    private func setCacheEntry(entry: CachedEntry?, url: URL) {
        cache[url] = entry
    }
    
    nonisolated func getImage(from url: URL) async throws -> UIImage? {
        if let cachedEntry = await cache[url] {
            switch cachedEntry {
            case .finished(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }
        
        let task =  Task {
            try await download(from: url)
        }
        
        await setCacheEntry(entry: .inProgress(task), url: url)
        
        do {
            let image = try await task.value
            await setCacheEntry(entry: .finished(image), url: url)
            return image
        } catch {
            await setCacheEntry(entry: nil, url: url)
            throw error
        }
    }
}


let imageLoader = ImageDownloader()
let url = URL(string: "https://picsum.photos/200")!
Task {
    let image = try? await imageLoader.getImage(from: url)
    print(image != nil)
}

//: [Next](@next)
