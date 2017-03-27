//
//  KlusterImageResizer.swift
//  Cluster
//
//  Created by Michael Fellows on 11/13/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import Foundation

// MARK: - KlusterImageResizer

class KlusterImageResizer: NSObject {
    let UploadWidth = 640
    
    
    // MARK: Class functions
    
    class func resizeImageToWidth(_ image: UIImage, width: CGFloat) -> Data? {
        let height = (width * image.size.height) / image.size.width
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImagePNGRepresentation(resizedImage!)
    }
}
