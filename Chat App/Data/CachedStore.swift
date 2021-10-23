//
//  CachedStore.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/13/21.
//

import UIKit

class AvatarModel {
    var roundedImage : UIImage!
    var fullsizeImage : UIImage

    init(image: UIImage) {
        self.fullsizeImage = image
    }
    
    func makeRoundedImage(){
        // create roundedImage from this fullsize image
        let size = CGSize(width: 70, height: 70) // proposed size
        let aspectWidth = size.width / fullsizeImage.size.width
        let aspectHeight = size.height / fullsizeImage.size.height

        let aspectRatio = max(aspectWidth, aspectHeight)

        let sizeIm = CGSize(width: fullsizeImage.size.width * aspectRatio, height: fullsizeImage.size.height * aspectRatio)
        let circleX = aspectWidth > aspectHeight ? 0 :  sizeIm.width/2 - sizeIm.height/2
        let circleY = aspectWidth > aspectHeight ? sizeIm.height/2 - sizeIm.width/2 : 0
        
        let renderer = UIGraphicsImageRenderer(size: sizeIm)
        self.roundedImage = renderer.image { _ in
            UIBezierPath(ovalIn: CGRect(x: circleX,
                                                y: circleY,
                                                width: size.width,
                                                height: size.width)).addClip()
            fullsizeImage.draw(in: CGRect(origin: .zero, size: sizeIm))
        }
    }
}

class CachedStore {
    
    let cache = NSCache<NSString, AvatarModel>()
    let photoRequest = PhotoRequest()
    
    static let shared = CachedStore()
    private init(){
    }
        
    func setImage(_ image: UIImage, forKey key: String) {
        // Save in memory
        let avatarModel = AvatarModel(image: image)
        avatarModel.makeRoundedImage()
        cache.setObject(avatarModel, forKey: key as NSString)
        
        // Save to disk
        /// Create full URL for image
        let url = imageURL(forKey: key)

        /// Turn image into JPEG data
        if let data = image.jpegData(compressionQuality: 0.5) {
            try? data.write(to: url)
        }
    }

    func getImage(forKey key: String, isRounded: Bool = true, completion: @escaping (Result<UIImage, Error>) -> Void) {
        // Find in memo
        if let existingImage = cache.object(forKey: key as NSString) {
            let image = isRounded ? existingImage.roundedImage : existingImage.fullsizeImage
            completion(.success(image!))
        }
        
        // Find on disk
        let url = imageURL(forKey: key)
        if let imageFromDisk = UIImage(contentsOfFile: url.path) {
            let model = AvatarModel(image: imageFromDisk)
            cache.setObject(model, forKey: key as NSString)
            completion(.success(imageFromDisk))
        }
        
        // Finally, request to the server
        guard let remoteURL = URL(string: key) else {
            completion(.failure(PhotoError.brokenURL))
            return
        }
        photoRequest.fetchImage(url: remoteURL){ res in
            if case let .success(im) = res {
                self.setImage(im, forKey: key)
                if let existingImage = self.cache.object(forKey: key as NSString) {
                    let image = isRounded ? existingImage.roundedImage : existingImage.fullsizeImage
                    completion(.success(image!))
                }
            } else{
            completion(res)
            }
        }
    }

    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        
        let url = imageURL(forKey: key)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error removing the image from disk: \(error)")
        }
    }
    
    func imageURL(forKey key: String) -> URL {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!

        return documentDirectory.appendingPathComponent(key)
    }
    
    
}
