//
//  ImagePickerController.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 24/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import Foundation
import Photos

// MARK: Properties

private let enlargementAnimationDuration = 0.3
private let tableViewRowHeight: CGFloat = 50.0
private let tableViewPreviewRowHeight: CGFloat = 140.0
private let tableViewEnlargedPreviewRowHeight: CGFloat = 243.0
private let collectionViewInset: CGFloat = 5.0
private let collectionViewCheckmarkInset: CGFloat = 3.5


// MARK: - sImagePickerSheetController 

open class ImagePickerSheetController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = false
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.register(ImagePreviewTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ImagePreviewTableViewCell.self))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        
        return tableView
    }()
    
    fileprivate lazy var collectionView: ImagePickerCollectionView = {
        let collectionView = ImagePickerCollectionView()
        collectionView.backgroundColor = .clear
        collectionView.imagePreviewLayout.sectionInset = UIEdgeInsetsMake(collectionViewInset, collectionViewInset, collectionViewInset, collectionViewInset)
        collectionView.imagePreviewLayout.showsSupplementaryViews = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ImageCollectionViewCell.self))
        collectionView.register(PreviewSupplementaryView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(PreviewSupplementaryView.self))
        
        return collectionView
    }()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.3961)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ImagePickerSheetController.cancel)))
        
        return view
    }()
    
    fileprivate(set) var actions = [ImageAction]()
    fileprivate var assets = [PHAsset]()
    fileprivate var selectedPhotoIndices = [Int]()
    fileprivate(set) var enlargedPreviews = false
    
    fileprivate var supplementaryViews = [Int: PreviewSupplementaryView]()
    
    fileprivate let imageManager = PHCachingImageManager()
    
    // MARK: - Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initialize()
    }
    
    fileprivate func initialize() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    // MARK: - View Lifecycle
    
    override open func loadView() {
        super.loadView()
        
        view.addSubview(backgroundView)
        view.addSubview(tableView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAssets()
    }
    
    // MARK: - UITableViewDataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return actions.count
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if assets.count > 0 {
                return enlargedPreviews ? tableViewEnlargedPreviewRowHeight : tableViewPreviewRowHeight
            }
            
            return 0
        }
        
        return tableViewRowHeight
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ImagePreviewTableViewCell.self), for: indexPath) as! ImagePreviewTableViewCell
            cell.collectionView = collectionView
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
            
            return cell
        }
        
        let action = actions[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath) as UITableViewCell
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = tableView.tintColor
        cell.textLabel?.font = UIFont.systemFont(ofSize: 21)
        cell.textLabel?.text = selectedPhotoIndices.count > 0 ? action.secondaryTitle(selectedPhotoIndices.count) : action.title
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        presentingViewController?.dismiss(animated: true, completion: nil)
        
        actions[indexPath.row].handle(selectedPhotoIndices.count)
    }
    
    // MARK: - UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return assets.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ImageCollectionViewCell.self), for: indexPath) as! ImageCollectionViewCell
        
        let asset = assets[indexPath.section]
        let size = sizeForAsset(asset)
        
        requestImageForAsset(asset, size: size) { image in
            cell.imageView.image = image
        }
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(PreviewSupplementaryView.self), for: indexPath) as! PreviewSupplementaryView
        view.isUserInteractionEnabled = false
        view.buttonInset = UIEdgeInsetsMake(0.0, collectionViewCheckmarkInset, collectionViewCheckmarkInset, 0.0)
        view.selected = selectedPhotoIndices.contains(indexPath.section)
        
        supplementaryViews[indexPath.section] = view
        
        return view
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let asset = assets[indexPath.section]
        
        return sizeForAsset(asset)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let inset = 2.0 * collectionViewCheckmarkInset
        let size = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: IndexPath(row: 0, section: section))
        let imageWidth = PreviewSupplementaryView.checkmarkImage?.size.width ?? 0
        
        return CGSize(width: imageWidth  + inset, height: size.height)
    }
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let nextIndex = indexPath.row+1
        if nextIndex < assets.count {
            let asset = assets[nextIndex]
            let size = sizeForAsset(asset)
            
            self.prefetchImagesForAsset(asset, size: size)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = selectedPhotoIndices.contains(indexPath.section)
        
        if !selected {
            selectedPhotoIndices.removeAll(keepingCapacity: false)
            selectedPhotoIndices.append(indexPath.section)
            
            if !enlargedPreviews {
                enlargedPreviews = true
                
                self.collectionView.imagePreviewLayout.invalidationCenteredIndexPath = indexPath
                
                view.setNeedsLayout()
                UIView.animate(withDuration: enlargementAnimationDuration, animations: {
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                    self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.reloadButtonTitles()
                    self.collectionView.imagePreviewLayout.showsSupplementaryViews = true
                })
            }
            else {
                if let cell = collectionView.cellForItem(at: indexPath) {
                    var contentOffset = CGPoint(x: cell.frame.midX - collectionView.frame.width / 2.0, y: 0.0)
                    contentOffset.x = max(contentOffset.x, -collectionView.contentInset.left)
                    contentOffset.x = min(contentOffset.x, collectionView.contentSize.width - collectionView.frame.width + collectionView.contentInset.right)
                    
                    collectionView.setContentOffset(contentOffset, animated: true)
                }
                
                reloadButtonTitles()
            }
        }
        else {
            selectedPhotoIndices.remove(at: selectedPhotoIndices.index(of: indexPath.section)!)
            reloadButtonTitles()
        }
        
        for (section, sectionView) in supplementaryViews {
            if sectionView.selected {
                sectionView.selected = false
            }
        }
        
        if let sectionView = supplementaryViews[indexPath.section] {
            sectionView.selected = !selected
        }
    }
    
    // MARK: - Actions
    
    open func addAction(_ action: ImageAction) {
        let cancelActions = actions.filter { $0.style == ImageActionStyle.cancel }
        if action.style == .cancel && cancelActions.count > 0 {
            // precondition() would be more swifty here, but that's not really testable as of now
            NSException(name: NSExceptionName.internalInconsistencyException, reason: "ImagePickerSheetController can only have one action with a style of .Cancel", userInfo: nil).raise()
        }
        
        actions.append(action)
    }
    
    // MARK: - Photos
    
    fileprivate func sizeForAsset(_ asset: PHAsset) -> CGSize {
        let proportion = CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)
        
        let height: CGFloat = {
            let rowHeight = self.enlargedPreviews ? tableViewEnlargedPreviewRowHeight : tableViewPreviewRowHeight
            return rowHeight-2.0*collectionViewInset
        }()
        
        return CGSize(width: CGFloat(floorf(Float(proportion*height))), height: height)
    }
    
    fileprivate func targetSizeForAssetOfSize(_ size: CGSize) -> CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: scale*size.width, height: scale*size.height)
    }
    
    fileprivate func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: .image, options: options)
        
        result.enumerateObjects({ obj, _, _ in
            if let asset = obj as? PHAsset, self.assets.count < 50 {
                self.assets.append(asset)
            }
        })
    }
    
    fileprivate func requestImageForAsset(_ asset: PHAsset, size: CGSize? = nil, deliveryMode: PHImageRequestOptionsDeliveryMode = .opportunistic, completion: @escaping (_ image: UIImage?) -> Void) {
        var targetSize = PHImageManagerMaximumSize
        if let size = size {
            targetSize = targetSizeForAssetOfSize(size)
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = deliveryMode;
        
        // Workaround because PHImageManager.requestImageForAsset doesn't work for burst images
        if asset.representsBurst {
            imageManager.requestImageData(for: asset, options: options) { data, _, _, _ in
                let image = UIImage(data: data!)
                completion(image)
            }
        }
        else {
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                completion(image)
            }
        }
    }
    
    fileprivate func prefetchImagesForAsset(_ asset: PHAsset, size: CGSize) {
        // Not necessary to cache image because PHImageManager won't return burst images
        if !asset.representsBurst {
            let targetSize = targetSizeForAssetOfSize(size)
            imageManager.startCachingImages(for: [asset], targetSize: targetSize, contentMode: .aspectFill, options: nil)
        }
    }
    
    open func getSelectedImagesWithCompletion(_ completion: @escaping (_ images:[UIImage?]) -> Void) {
        var images = [UIImage?]()
        var counter = selectedPhotoIndices.count
        
        for index in selectedPhotoIndices {
            let asset = assets[index]
            
            requestImageForAsset(asset, deliveryMode: .highQualityFormat) { image in
                images.append(image)
                counter -= 1
                
                if counter <= 0 {
                    completion(images)
                }
            }
        }
    }
    
    // MARK: - Buttons
    
    fileprivate func reloadButtonTitles() {
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
    }
    
    @objc fileprivate func cancel() {
        presentingViewController?.dismiss(animated: true, completion: nil)
        
        let cancelActions = actions.filter { $0.style == ImageActionStyle.cancel }
        if let cancelAction = cancelActions.first {
            cancelAction.handle(selectedPhotoIndices.count)
        }
    }
    
    // MARK: - Layout
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        backgroundView.frame = view.bounds
        
        let tableViewHeight = Array(0..<tableView.numberOfRows(inSection: 1)).reduce(tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0))) { total, row in
            total + tableView(tableView, heightForRowAt: IndexPath(row: row, section: 1))
        }

        tableView.frame = CGRect(x: view.bounds.minX, y: view.bounds.maxY-tableViewHeight, width: view.bounds.width, height: tableViewHeight)
    }
    
    // MARK: - Transitioning
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(imagePickerSheetController: self, presenting: true)
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(imagePickerSheetController: self, presenting: false)
    }
    
}
