//
//  PopTransitionAnimator.swift
//  Interests
//
//  Created by lsecrease on 11/7/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

class PopTransitionAnimator: NSObject {
 
    
    var duration = 1.0
    private var isPresenting = false
    
}

extension PopTransitionAnimator : UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
}



extension PopTransitionAnimator : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let containerView = transitionContext.containerView()//!
        
        
        // transforms
        let minimize = CGAffineTransformMakeScale(0, 0)
        let offScreenDown = CGAffineTransformMakeTranslation(0, containerView!.frame.height)
        let shiftDown = CGAffineTransformMakeTranslation(0, 15)
        let scaleDown = CGAffineTransformScale(shiftDown, 0.95, 0.95)
        
        toView.transform = minimize
        
        if isPresenting {
            containerView!.addSubview(fromView)
            containerView!.addSubview(toView)
        } else {
            containerView!.addSubview(toView)
            containerView!.addSubview(fromView)
        }
        
        
         //In Swift 2.0 make options: []
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.75, options: [], animations: { () -> Void in
            
            if self.isPresenting {
                fromView.transform = scaleDown
                fromView.alpha = 0.5
                toView.transform = CGAffineTransformIdentity
            } else {
                fromView.transform = offScreenDown
                toView.alpha = 1.0
                toView.transform = CGAffineTransformIdentity
            }
            
            }) { (finished) -> Void in
                transitionContext.completeTransition(true)
        }
    }
}
