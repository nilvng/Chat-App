//
//  FlickrPhotoStore.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/13/21.
//

import UIKit

enum PhotoError : Error {
    case imageCreationError
    case missingImageURL
}

class PhotoStore{

    static let shared = PhotoStore()
    private init(){}
    
    let cachedStore = CachedStore()

    private let session : URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchImage(url: URL, completion: @escaping (Result<UIImage, Error>) -> Void){
        // check for cached image
        if let image = cachedStore.image(forKey: url.absoluteString) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        // If it has not been cached, fetch image
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request){ (data, response, error) in
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .success(image) = result {
                // cache image
                print("Image to be cached")
                    self.cachedStore.setImage(image, forKey: url.absoluteString)                
            }
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        
        task.resume()
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> (Result<UIImage, Error>) {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {

                // Couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }

        return .success(image)
    }
}
