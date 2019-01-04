//
//  UUImage.swift
//  UUSwift
//
//  Created by Jonathan Hays on 12/11/18.
//  Copyright © 2018 Jonathan Hays. All rights reserved.
//

#if os(iOS)

import UIKit

public extension UIImage
{

	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	// MARK: - Resizing functions
	/////////////////////////////////////////////////////////////////////////////////////////////////////////

	public func uuCropToSize(targetSize : CGSize) -> UIImage {
		UIGraphicsBeginImageContext(targetSize)
		
		var thumbnailRect : CGRect = .zero
		thumbnailRect.origin = CGPoint(x: 0, y: 0)
		thumbnailRect.size = CGSize(width: self.size.width, height: self.size.height)
		
		self.draw(in: thumbnailRect)
		
		if let newImage = UIGraphicsGetImageFromCurrentImageContext()
		{
			UIGraphicsEndImageContext()
			return newImage
		}
		
		return self
	}
	
	public func uuScaleToSize(targetSize : CGSize) -> UIImage {
		let imageSize = self.size
		let width : CGFloat = imageSize.width
		let height : CGFloat = imageSize.height
		
		let targetWidth : CGFloat = targetSize.width
		let targetHeight : CGFloat = targetSize.height
		
		var scaleFactor : CGFloat = 0.0
		var scaledWidth : CGFloat = targetWidth
		var scaledHeight : CGFloat = targetHeight
		
		var thumbnailPoint = CGPoint(x: 0.0, y: 0.0)
		
		if imageSize != targetSize
		{
			let widthFactor : CGFloat = targetWidth / width
			let heightFactor : CGFloat = targetHeight / height
			
			if widthFactor < heightFactor
			{
				scaleFactor = widthFactor
			}
			else
			{
				scaleFactor = heightFactor
			}
			
			scaledWidth = width * scaleFactor
			scaledHeight = height * scaleFactor
			
			if (widthFactor < heightFactor)
			{
				thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
			}
			else if (widthFactor > heightFactor)
			{
				thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
			}
		}
		
		UIGraphicsBeginImageContext(targetSize)
		var thumbnailRect : CGRect = .zero
		thumbnailRect.origin = thumbnailPoint
		thumbnailRect.size.width = scaledWidth
		thumbnailRect.size.height = scaledHeight
		
		self.draw(in: thumbnailRect)
		
		if let newImage = UIGraphicsGetImageFromCurrentImageContext()
		{
			UIGraphicsEndImageContext()
			return newImage
		}
	
		return self
	}
	
	public func uuScaleToWidth(targetWidth: CGFloat) -> UIImage {
		let destSize = self.uuCalculateScaleToWidth(width: targetWidth)
		
		UIGraphicsBeginImageContext(destSize)
		
		var destRect : CGRect = .zero
		destRect.size = destSize
		
		self.draw(in: destRect)
		
		if let newImage = UIGraphicsGetImageFromCurrentImageContext()
		{
			UIGraphicsEndImageContext()
			return newImage
		}
		
		return self
	}
	
	public func uuScaleToHeight(targetHeight : CGFloat) -> UIImage {
		let destSize = self.uuCalculateScaleToHeight(height: targetHeight)
		
		UIGraphicsBeginImageContext(destSize)
		
		var destRect : CGRect = .zero
		destRect.size = destSize
		
		self.draw(in: destRect)
		
		if let newImage = UIGraphicsGetImageFromCurrentImageContext()
		{
			UIGraphicsEndImageContext()
			return newImage
		}
		
		return self
	}
	
	
	public func uuScaleSmallestDimensionToSize(size : CGFloat) -> UIImage
	{
		if (self.size.width < self.size.height)
		{
			return self.uuScaleToWidth(targetWidth: size)
		}
		else
		{
			return self.uuScaleToHeight(targetHeight : size)
		}
	}
	
	public func uuScaleAndCropToSize(targetSize : CGSize) -> UIImage
	{
		let deviceScale = UIScreen.main.scale
		let sourceImage = self
		let imageSize = sourceImage.size
		let width : CGFloat = imageSize.width
		let height : CGFloat = imageSize.height
		let targetWidth : CGFloat = targetSize.width * deviceScale
		let targetHeight : CGFloat = targetSize.height * deviceScale
		var scaleFactor : CGFloat = 0.0
		var scaledWidth : CGFloat = targetWidth
		var scaledHeight : CGFloat = targetHeight
		var thumbnailPoint = CGPoint(x: 0.0, y: 0.0)
		
		if (imageSize != targetSize)
		{
			let widthFactor = targetWidth / width
			let heightFactor = targetHeight / height
			if (widthFactor > heightFactor)
			{
				scaleFactor = widthFactor
			}
			else
			{
				scaleFactor = heightFactor
			}
			
			scaledWidth = width * scaleFactor
			scaledHeight = height * scaleFactor
			
			if (widthFactor > heightFactor)
			{
				thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
			}
			else if (widthFactor < heightFactor)
			{
				thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
			}
		}
		
		let targetSize = CGSize(width: targetWidth, height: targetHeight)
		UIGraphicsBeginImageContext(targetSize)
		
		var thumbnailRect : CGRect = .zero
		thumbnailRect.origin = thumbnailPoint
		thumbnailRect.size = CGSize(width: scaledWidth, height: scaledHeight)
		
		sourceImage.draw(in: thumbnailRect)
		
		if let newImage = UIGraphicsGetImageFromCurrentImageContext()
		{
			UIGraphicsEndImageContext()
			return newImage
		}
		
		return self
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	// MARK: - Solid color image functions
	/////////////////////////////////////////////////////////////////////////////////////////////////////////

	public static func uuSolidColorImage(color : UIColor) -> UIImage?
	{
		let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
		
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()
		
		context?.setFillColor(color.cgColor)
		context?.fill(rect)
		
		if let image = UIGraphicsGetImageFromCurrentImageContext()
		{
			UIGraphicsEndImageContext()
			
			return image
		}
		
		return nil
	}
	
	public static func uuSolidColorImage(color : UIColor, cornerRadius : CGFloat, borderColor : UIColor, borderWidth : CGFloat) -> UIImage?
	{
		let rect = CGRect(x: 0.0, y: 0.0, width: 2.0 * ((cornerRadius * 2.0) + 1), height: 2.0 * ((cornerRadius * 2.0) + 1))
		let view = UIView(frame: rect)
		view.backgroundColor = color
		view.layer.borderColor = borderColor.cgColor
		view.layer.cornerRadius = cornerRadius
		view.layer.masksToBounds = true
		view.layer.borderWidth = borderWidth
		if let image = UIImage.uuViewToImage(view)
		{
			return image.resizableImage(withCapInsets: UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius))
		}
		
		return nil
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	// MARK: - Misc
	/////////////////////////////////////////////////////////////////////////////////////////////////////////

	public func uuRemoveOrientation() -> UIImage {
		if self.imageOrientation == .up
		{
			return self
		}
		
		var affineTransformation : CGAffineTransform = .identity
		
		switch self.imageOrientation
		{
			case .up, .upMirrored:
			break

			case .down, .downMirrored:
				affineTransformation = affineTransformation.translatedBy(x: self.size.width, y: self.size.height)
				affineTransformation = affineTransformation.rotated(by: .pi)
			break
			
			case .left, .leftMirrored:
				affineTransformation = affineTransformation.translatedBy(x: self.size.width, y: 0.0)
				affineTransformation = affineTransformation.rotated(by: 2.0 * .pi)
			break
			
			case .right, .rightMirrored:
				affineTransformation = affineTransformation.translatedBy(x: 0.0, y: self.size.height)
				affineTransformation = affineTransformation.rotated(by: -2.0 * .pi)
			break
		}
		
		if (self.imageOrientation == .upMirrored || self.imageOrientation == .downMirrored)
		{
			affineTransformation = affineTransformation.translatedBy(x: self.size.width, y: 0.0)
			affineTransformation = affineTransformation.scaledBy(x: -1.0, y: 1.0)
		}
		if (self.imageOrientation == .leftMirrored || self.imageOrientation == .rightMirrored)
		{
			affineTransformation = affineTransformation.translatedBy(x: self.size.height, y: 0.0)
			affineTransformation = affineTransformation.scaledBy(x: -1.0, y: 1.0)
		}

		let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

		if let cgImageRef = self.cgImage,
			let contextRef = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
		{
			contextRef.concatenate(affineTransformation)
		
			if (self.imageOrientation == .left ||
				self.imageOrientation == .leftMirrored ||
				self.imageOrientation == .right ||
				self.imageOrientation == .rightMirrored)
			{
				contextRef.draw(cgImageRef, in: CGRect(x: 0.0, y: 0.0, width: self.size.height, height: self.size.width))
			}
			else
			{
				contextRef.draw(cgImageRef, in: CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height))
			}
			
			if let imageRef = contextRef.makeImage()
			{
				return UIImage(cgImage: imageRef)
			}
		}
		
		return self
	}


	public static func uuViewToImage(_ view : UIView) -> UIImage?
	{
		UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
		if let outputContext = UIGraphicsGetCurrentContext()
		{
			view.layer.render(in: outputContext)
		
			if let image = UIGraphicsGetImageFromCurrentImageContext()
			{
				UIGraphicsEndImageContext()
				return image
			}
		}
		
		return nil
	}

	public static func uuMakeStretchableImage(imageName : String, insets : UIEdgeInsets) -> UIImage?
	{
		return UIImage(named: imageName)?.resizableImage(withCapInsets: insets)
	}
	

	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	// MARK: - Private helper functions
	/////////////////////////////////////////////////////////////////////////////////////////////////////////

	private func uuCalculateScaleToFitDestSize(size : CGFloat) -> CGSize
	{
		if self.size.width < self.size.height
		{
			return self.uuCalculateScaleToWidth(width:size)
		}
		else
		{
			return self.uuCalculateScaleToHeight(height:size)
		}
	}

	private static func uuCalculateScaleToWidthDestSize(width : CGFloat, srcSize : CGSize) -> CGSize
	{
		let srcWidth = srcSize.width
		let srcHeight = srcSize.height
		let srcAspectRatio = srcHeight / srcWidth
		
		let targetWidth = width * UIScreen.main.scale
		let targetHeight = targetWidth * srcAspectRatio
		
		return CGSize(width: targetWidth, height: targetHeight)
	}
	
	private static func uuCalculateScaleToHeightDestSize(height : CGFloat, srcSize : CGSize) -> CGSize
	{
		let srcWidth = srcSize.width
		let srcHeight = srcSize.height
		let srcAspectRatio = srcWidth / srcHeight

		let targetHeight = height * UIScreen.main.scale
		let targetWidth = targetHeight * srcAspectRatio
		
		return CGSize(width: targetWidth, height: targetHeight)
	}
	
	private func uuCalculateScaleToWidth(width : CGFloat) -> CGSize
	{
		return UIImage.uuCalculateScaleToWidthDestSize(width: width, srcSize: self.size)
	}
	
	private func uuCalculateScaleToHeight(height : CGFloat) -> CGSize
	{
		return UIImage.uuCalculateScaleToHeightDestSize(height: height, srcSize: self.size)
	}
}

#endif
