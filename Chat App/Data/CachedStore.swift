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
        
    func setImage(_ image: UIImage, forKey key: String, inMemOnly: Bool = true) -> AvatarModel{
        // Save in memory
        let avatarModel = AvatarModel(image: image)
        avatarModel.makeRoundedImage()
        cache.setObject(avatarModel, forKey: key as NSString)
        if !inMemOnly{
            // Save to disk
            /// Create full URL for image
            let url = imageURL(forKey: key)
            
            /// Turn image into JPEG data
            if let data = image.jpegData(compressionQuality: 0.5) {
                try? data.write(to: url)
            }
            
        }
        return avatarModel
    }

    func getImage(forKey key: String, isRounded: Bool = true, completion: @escaping (Result<UIImage, Error>) -> Void) {
        // Case1: Find in memo
        var targetAvatarModel : AvatarModel? = nil
        let pKey = processURLforFilename(key: key)
        if let existingModel = cache.object(forKey: pKey as NSString) {
            targetAvatarModel = existingModel
        } else {
            // Case2: Find on disk
            let url = imageURL(forKey: pKey)
            print("Find on disk..\(url)")
            if let imageFromDisk = UIImage(contentsOfFile: url.path) {
                targetAvatarModel = self.setImage(imageFromDisk, forKey: pKey, inMemOnly: true)
                
            } else {
                print("From server")
                // Case3: Finally, request to the server
                getImageFromServer(forKey: key, isRounded: isRounded, completion: completion)
                
            }}
        guard let model = targetAvatarModel else {
            completion(.failure(PhotoError.imageCreationError))
            return
        }
        let image = isRounded ? model.roundedImage : model.fullsizeImage
        completion(.success(image!))

    }
    
    private func processURLforFilename(key: String) -> String{
        if let url = URL(string: key){
            return url.lastPathComponent
        } else {
            return key
        }
    }
    
    func getImageFromDisk(forKey key: String, isRounded: Bool = true, completion: @escaping (Result<UIImage, Error>) -> Void) {
        
    }
    
    func getImageFromServer(forKey key: String, isRounded: Bool = true, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let remoteURL = URL(string: key) else {
            completion(.failure(PhotoError.brokenURL))
            return
        }
        
        photoRequest.fetchImage(url: remoteURL){ res in
            if case let .success(im) = res {
                let pKey = self.processURLforFilename(key: key)
                let targetAvatarModel = self.setImage(im, forKey: pKey,inMemOnly: false)
                let image = isRounded ? targetAvatarModel.roundedImage : targetAvatarModel.fullsizeImage
                completion(.success(image!))
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
            FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!

        return documentDirectory.appendingPathComponent(key)
    }
    
    
}
