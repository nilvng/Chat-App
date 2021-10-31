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

class ImageStore {
    
    let cache = NSCache<NSString, AvatarModel>()
    let cacheSizeLimit = 4500000
    let photoRequest = PhotoRequest()
    
    static let shared = ImageStore()
    private init(){
        cache.totalCostLimit = 20
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
            if let imageFromDisk = UIImage(contentsOfFile: url.path) {
                targetAvatarModel = self.setImage(imageFromDisk, forKey: pKey, inMemOnly: true)
                print("Found on disk..")
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

    func clearCacheOnDisk(){
  
        // get folder size
        let cacheURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        var sizeOnDisk : Int?
        do {
            let cacheDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            sizeOnDisk = fileManager.directorySize(cacheDirectory)
            if sizeOnDisk != nil  {
                print("Size:", sizeOnDisk ?? -1) //
            }
        } catch {
            print(error)
        }
        // Actually clear cache
        do {
            /// Get the directory contents urls (including subfolders urls)
            var directoryContents = try FileManager.default.contentsOfDirectory( at: cacheURL, includingPropertiesForKeys: [.contentAccessDateKey], options: [])
            /// sort item by its latest access date -> remove the oldest avatar only
            do{
            try directoryContents.sort(by: { (u1, u2) in
                let ua1  = try u1.resourceValues(forKeys:[.contentAccessDateKey])
                let ua2  = try u2.resourceValues(forKeys:[.contentAccessDateKey])
                return ua1.contentAccessDate! < ua2.contentAccessDate!
            }) } catch {
                print("Cannot sort cache file .. abort clearing")
                return
            }
            
            /// clear cache until meet the limit size
            for file in directoryContents {
                do {
                    // calculate amount if file/data to remove
                    guard let fileSize = file.fileSize else {
                        print("Cannot get size of this file: \(file)")
                        continue
                    }
                    if sizeOnDisk! - fileSize > self.cacheSizeLimit {
                        print("Remove file: \(file)")
                        try fileManager.removeItem(at: file)
                        sizeOnDisk! -= fileSize
                    } else {
                        break
                    }
                }
                catch let error as NSError {
                    debugPrint("Ooops! Something went wrong: \(error)")
                }

            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

extension URL {
    var fileSize: Int? { // in bytes
        do {
            let val = try self.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey])
            return val.totalFileAllocatedSize ?? val.fileAllocatedSize
        } catch {
            print(error)
            return nil
        }
    }
}

extension FileManager {
    func directorySize(_ dir: URL) -> Int? { // in bytes
        if let enumerator = self.enumerator(at: dir, includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey], options: [], errorHandler: { (_, error) -> Bool in
            print(error)
            return false
        }) {
            var bytes = 0
            for case let url as URL in enumerator {
                bytes += url.fileSize ?? 0
            }
            return bytes
        } else {
            return nil
        }
    }
}
