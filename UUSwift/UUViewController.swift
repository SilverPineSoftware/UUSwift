//
//  UUViewController.swift
//  Useful Utilities - Extensions for UIViewController
//
//    License:
//  You are free to use this code for whatever purposes you desire.
//  The only requirement is that you smile everytime you use it.
//

#if os(iOS)

import UIKit

public extension UIViewController
{
    func uuFindControllerOfType(_ clazz : AnyClass) -> UIViewController?
    {
        var foundVc : UIViewController? = nil
        
        var navController : UINavigationController? = (self as? UINavigationController)
        if (navController == nil)
        {
            navController = self.navigationController
        }
        
        if (navController != nil)
        {
            for vc in navController!.viewControllers
            {
                if (object_getClass(vc) == clazz)
                {
                    foundVc = vc
                    break
                }
            }
        }
        
        return foundVc
    }
    
    func uuPopToControllerOfType(_ clazz : AnyClass, animated : Bool = true) -> Bool
    {
        let vcToPopTo = uuFindControllerOfType(clazz)
        
        let didFindController = (vcToPopTo != nil)
        
        if (didFindController)
        {
            navigationController?.popToViewController(vcToPopTo!, animated: animated)
        }
        
        return didFindController
    }
    
    func uuPopToController(at index: Int, animated : Bool = true) -> Bool
    {
        guard let navVc = self.navigationController, index >= 0 && index < navVc.viewControllers.count else
        {
            return false
        }
        
        let vcToPopTo = navVc.viewControllers[index]
        navVc.popToViewController(vcToPopTo, animated: animated)
        return true
    }
}

#endif

