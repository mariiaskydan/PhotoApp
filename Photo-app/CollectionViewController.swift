//
//  ViewController.swift
//  Photo-app
//
//  Created by Mariya Dychko on 20.02.16.
//  Copyright © 2016 Mariya Dychko. All rights reserved.
//

import UIKit
import Photos

class CollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet var takePhotoButton: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!

    static let albomName = "Photo-app"
    class image {
        var image: UIImage!
        var dateOfCreation: NSDate!
        init(date: NSDate, image: UIImage) {
            self.image = image
            self.dateOfCreation = date
        }
    }
    var imageList: [image]!
    var activityIndicator:UIActivityIndicatorView!
    var blurEffectView: UIVisualEffectView!
    override func viewDidLoad() {
        super.viewDidLoad()
        PhotoAlbum.sharedInstance.loadData()
        PhotoAlbum.sharedInstance.collectionViewController = self
        imageList = [image]()
        if nil != PhotoAlbum.sharedInstance.assetCollection {
            self.createImageCollection()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    @IBAction func refresh(sender: AnyObject) {
        PhotoAlbum.sharedInstance.loadData()
        self.imageList.removeAll()
        if nil != PhotoAlbum.sharedInstance.assetCollection {
            self.createImageCollection()
        }
        self.collectionView?.reloadData()
    }
    // MARK: collection delegate
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (PhotoAlbum.sharedInstance.assetCollection == nil) {
            return 0
        } else {
            return self.imageList.count
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoAppCell
        let image = imageList[indexPath.row]
        cell.backgroundColor = UIColor.whiteColor()
        cell.image.image = image.image
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        cell.date.text = dateFormatter.stringFromDate(image.dateOfCreation)
        return cell
    }
    func createImageCollection() {
       let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let collectionOfAssets = PHAsset.fetchAssetsInAssetCollection(PhotoAlbum.sharedInstance.assetCollection, options: fetchOptions)
        collectionOfAssets.enumerateObjectsUsingBlock { (object: AnyObject!, count:Int, stop:UnsafeMutablePointer<ObjCBool>) in
            if object is PHAsset {
                let asset = object as! PHAsset
                let dateOfCreation = asset.creationDate
                let manager = PHImageManager.defaultManager()
                let options = PHImageRequestOptions()
                options.synchronous = true
                manager.requestImageDataForAsset(asset, options: options, resultHandler:  {(result,dataUTI,orientation, info)->Void in
                    let imageFull = UIImage(data: result!)
                    let imageClass = image(date: dateOfCreation!,image: imageFull!)
                    self.imageList.append(imageClass)
                })
            }
        }
    }
    
    // MARK: camera delegate
    @IBAction func takePhoto(sender: AnyObject) {
        let cameraPicker = UIImagePickerController()
        cameraPicker.sourceType = .Camera
        cameraPicker.delegate = self
        self.presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        PhotoAlbum.sharedInstance.saveImage(info[UIImagePickerControllerOriginalImage] as! UIImage, metadata: info[UIImagePickerControllerMediaMetadata] as! NSDictionary)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

