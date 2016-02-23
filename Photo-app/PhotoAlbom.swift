//
//  PhotoAlbom.swift
//  Photo-app
//
//  Created by Mariya Dychko on 20.02.16.
//  Copyright © 2016 Mariya Dychko. All rights reserved.
//

import Photos

class PhotoAlbum: NSObject {
    static let albumName = "Photo-app"
    static let sharedInstance = PhotoAlbum()
    var collectionViewController: CollectionViewController!
    var assetCollection: PHAssetCollection!
    
    override init() {
        super.init()
    }
    func loadData() {
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.Authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                status
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized {
            self.createAlbum()
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized {
            self.createAlbum()
        } else {
            // need to make popUp
            
        }
    }
    
    func createAlbum() {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(PhotoAlbum.albumName)   // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                } else {
                    print("error \(error)")
                }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject as! PHAssetCollection
        }
        return nil
    }
    
    func saveImage(image: UIImage, metadata: NSDictionary) {
        if assetCollection == nil {
            return                          // if there was an error upstream, skip the save
        }
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
        let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
        let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
        let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceHolder!])}) { (success, error) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionViewController.refresh(self)
                    }
                } else {
                    print(error)
                }
        }
    }
}