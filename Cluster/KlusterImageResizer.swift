//
//  KlusterImageResizer.swift
//  Cluster
//
//  Created by Michael Fellows on 11/13/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import Foundation



class KlusterImageResizer: NSObject {
    let UploadWidth = 640
    
    class func resizeImageToWidth(image: UIImage, width: CGFloat) -> NSData? {
        let height = (width * image.size.height) / image.size.width
        UIGraphicsBeginImageContext(CGSizeMake(width, height))
        image.drawInRect(CGRectMake(0, 0, width, height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImagePNGRepresentation(resizedImage)
    }
}
