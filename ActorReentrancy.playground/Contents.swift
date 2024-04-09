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
    
    func getImage(from url: URL) async throws -> UIImage? {
        if let cachedEntry = cache[url] {
            switch cachedEntry {
            case .finished(let image):
                return image
            case .inProgress(let task):
                try await task.value
            }
        }
        
        let task =  Task {
            try await download(from: url)
        }
        
        cache[url] = .inProgress(task)
        
        do {
            let image = try await task.value
            cache[url] = .finished(image)
            return image
        } catch {
            cache[url] = nil
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
