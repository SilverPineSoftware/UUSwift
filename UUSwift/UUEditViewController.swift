//
//  UUEditViewController
//  Useful Utilities - Subclass of UIViewController that handles automatically
//  some common editing tasks
//
//    License:
//  You are free to use this code for whatever purposes you desire.
//  The only requirement is that you smile everytime you use it.
//
//  UUEditViewController has two main functions:
//
//  1) Handles taps to the root view and ends editing
//  2) Handles keyboard show/hide notifications and moves the view frame to
//     place the edit field right above the keyboard

#if os(iOS)

import UIKit

open class UUEditViewController : UIViewController
{
    var currentEditFieldFrame: CGRect? = nil
    var currentKeyboardFrame: CGRect? = nil
    var spaceToKeybaord : CGFloat = 10
    
    private var frameBeforeAdjust: CGRect? = nil
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
    }
    
    override open func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        registerNotificationHandlers()
    }
    
    override open func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        clearNotificationHandlers()
    }
    
    open func referenceViewForEditField(_ view: UIView) -> UIView
    {
        return view
    }
    
    func registerNotificationHandlers()
    {
		NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil, using: handleKeyboardWillShowNotification)
		NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil, using: handleKeyboardWillHideNotification)
		NotificationCenter.default.addObserver(forName: UITextView.textDidBeginEditingNotification, object: nil, queue: nil, using: handleEditingStarted)
		NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: nil, queue: nil, using: handleEditingStarted)
		NotificationCenter.default.addObserver(forName: UITextView.textDidEndEditingNotification, object: nil, queue: nil, using: handleEditingEnded)
		NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: nil, queue: nil, using: handleEditingEnded)
    }
    
    func clearNotificationHandlers()
    {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleBackgroundTap()
    {
        view.endEditing(true)
    }
    
    @objc func handleKeyboardWillShowNotification(_ notification: Notification)
    {
		currentKeyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        animateViewIfNeeded()
    }
    
    private func animateViewIfNeeded()
    {
        if (currentKeyboardFrame != nil &&
            currentEditFieldFrame != nil &&
            isViewLoaded &&
            !view.isHidden)
        {
            let keyboardTop = currentKeyboardFrame!.origin.y
            let fieldBottom = currentEditFieldFrame!.origin.y + currentEditFieldFrame!.size.height
            
            if (keyboardTop < fieldBottom)
            {
                let keyboardAdjust = fieldBottom - keyboardTop + spaceToKeybaord
                
                var f = view.frame
                frameBeforeAdjust = f
                
                f.origin.y = -keyboardAdjust
                
                UIView.animate(withDuration: 0.5, animations:
                {
                    self.view.frame = f
                })
            }
        }
    }
    
    @objc func handleKeyboardWillHideNotification(_ notification: Notification)
    {
        currentKeyboardFrame = nil
        
        var f = view.frame
        
        if (frameBeforeAdjust != nil && f.origin.y != frameBeforeAdjust!.origin.y)
        {
            f.origin.y = frameBeforeAdjust!.origin.y
            
            UIView.animate(withDuration: 0.5, animations:
            {
                self.view.frame = f
            })
        }
    }
    
    @objc func handleEditingStarted(_ notification: Notification)
    {
        if let view = notification.object as? UIView
        {
            let refView = referenceViewForEditField(view)
            currentEditFieldFrame = refView.convert(refView.frame, to: view)
            animateViewIfNeeded()
        }
    }
    
    @objc func handleEditingEnded(_ notification: Notification)
    {
        currentEditFieldFrame = nil
    }
}


public protocol UUEditViewReferenceLookup
{
    func referenceViewForEditField(_ view: UIView) -> UIView?
}

public class UUEditViewControllerHelper : NSObject
{
    var currentEditFieldFrame: CGRect? = nil
    var currentKeyboardFrame: CGRect? = nil
    var spaceToKeybaord : CGFloat = 10
    public var referenceViewLookup: UUEditViewReferenceLookup? = nil
    
    private var originFrame: CGRect = .zero
    
    private var viewController: UIViewController!
    
    public required init(_ viewController: UIViewController)
    {
        self.viewController = viewController
        
        super.init()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        gesture.cancelsTouchesInView = false
        viewController.view.addGestureRecognizer(gesture)
    }
    
    public func handleViewWillAppear()
    {
        originFrame = viewController.view.frame
        registerNotificationHandlers()
    }
    
    public func handleViewWillDisappear()
    {
        clearNotificationHandlers()
    }
    
    func referenceViewForEditField(_ view: UIView) -> UIView
    {
        let result = referenceViewLookup?.referenceViewForEditField(view)
        return result ?? view
    }
    
    func registerNotificationHandlers()
    {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil, using: handleKeyboardWillShowNotification)
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil, using: handleKeyboardWillHideNotification)
        NotificationCenter.default.addObserver(forName: UITextView.textDidBeginEditingNotification, object: nil, queue: nil, using: handleEditingStarted)
        NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: nil, queue: nil, using: handleEditingStarted)
        NotificationCenter.default.addObserver(forName: UITextView.textDidEndEditingNotification, object: nil, queue: nil, using: handleEditingEnded)
        NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: nil, queue: nil, using: handleEditingEnded)
    }
    
    func clearNotificationHandlers()
    {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleBackgroundTap()
    {
        viewController.view.endEditing(true)
    }
    
    @objc func handleKeyboardWillShowNotification(_ notification: Notification)
    {
        currentKeyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        animateViewIfNeeded()
    }
    
    private func animateViewIfNeeded()
    {
        guard viewController.isViewLoaded, !viewController.view.isHidden else
        {
            // Do Nothing if view is not loaded or hidden
            return
        }
        
        guard let keyboardFrame = currentKeyboardFrame,
              let editFrame = currentEditFieldFrame else
        {
            // Do nothing if we don't have frame's of reference to work with.
            return
        }
        
        let keyboardTop = keyboardFrame.origin.y
        let fieldBottom = editFrame.origin.y + editFrame.size.height
        //UUDebugLog("KeyboardTop: \(keyboardTop), FieldBottom: \(fieldBottom)")
        
        if (keyboardTop < fieldBottom)
        {
            let keyboardAdjust = fieldBottom - keyboardTop + spaceToKeybaord
            
            //var f = viewController.view.frame
            
            let sourceFrame = viewController.view.frame
            var destFrame = sourceFrame
            destFrame.origin.y = -keyboardAdjust
            
            //UUDebugLog("SourceFrame: \(sourceFrame), DestFrame: \(destFrame)")
            
            if (sourceFrame.origin.y != destFrame.origin.y)
            {
                //UUDebugLog("Source and Dest Y are different, let's animate")
                //UUDebugLog("FrameBeforeAdjust: \(sourceFrame), KeyboardAdjust: \(-keyboardAdjust)")
                
                //f.origin.y = -keyboardAdjust
                
                UIView.animate(withDuration: 0.5, animations:
                {
                    self.viewController.view.frame = destFrame
                    //UUDebugLog("FrameAfterAdjust: \(destFrame)")
                })
            }
        }
    }
    
    @objc func handleKeyboardWillHideNotification(_ notification: Notification)
    {
        currentKeyboardFrame = nil
        
        let sourceFrame = viewController.view.frame
        var destFrame = sourceFrame
        destFrame.origin.y = 0
        
        if (sourceFrame.origin.y != originFrame.origin.y)
        {
            //UUDebugLog("Origin Frame Y is different, need to animate back to origin")
            
            UIView.animate(withDuration: 0.5, animations:
            {
                self.viewController.view.frame = self.originFrame
                //UUDebugLog("FrameAfterAdjust: \(self.originFrame)")
            })
        }
    }
    
    @objc func handleEditingStarted(_ notification: Notification)
    {
        if let view = notification.object as? UIView
        {
            let refView = referenceViewForEditField(view)
            currentEditFieldFrame = refView.convert(refView.frame, to: viewController.view)
            animateViewIfNeeded()
        }
    }
    
    @objc func handleEditingEnded(_ notification: Notification)
    {
        currentEditFieldFrame = nil
    }
}



#endif
