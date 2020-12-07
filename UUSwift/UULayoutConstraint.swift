//
//  UULayoutConstraint.swift
//  Useful Utilities - Extensions for NSLayoutConstraint
//
//    License:
//  You are free to use this code for whatever purposes you desire.
//  The only requirement is that you smile everytime you use it.
//

import UIKit

public extension NSLayoutConstraint
{
    func uuCopy(with multiplier: CGFloat) -> NSLayoutConstraint
    {
        return NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
    }
}
