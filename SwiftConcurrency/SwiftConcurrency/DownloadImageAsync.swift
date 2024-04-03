//
//  DownloadImageAsync.swift
//  SwiftConcurrency
//
//  Created by Pin Lu on 3/29/24.
//

import Combine
import SwiftUI

class DownloadImageAsyncImageLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data = data,
        let image = UIImage(data: data),
        let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        
        return image
    }
    
    /*
    func downloadWithEscaping(completion: @escaping (UIImage?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let image = handleResponse(data: data, response: response) else {
                completion(nil, error)
                return
            }
            
            completion(image, nil)
        }
        .resume()
    }
    */
    
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            let image = handleResponse(data: data, response: response)
            return image
        } catch {
            throw error
        }
    }
}

@MainActor
class DownloadImageAsyncViewModel: ObservableObject {
    
    @Published var image : UIImage? = nil
    let loader = DownloadImageAsyncImageLoader()
    
    var subscriptions = Set<AnyCancellable>()
    
   func fetchImage() async {
       
        /*
        loader.downloadWithEscaping { [weak self] image, error in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
        */
        
        
        /* Combine
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] image in
                    self?.image = image
            }
            .store(in: &subscriptions)
         */
        
         
        if let image = try? await loader.downloadWithAsync() {
            Task {
                self.image = image
            }
        }
        
    }
}

struct DownloadImageAsync: View {
    
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .task {
            await viewModel.fetchImage()
        }
    }
}

#Preview {
    DownloadImageAsync()
}
