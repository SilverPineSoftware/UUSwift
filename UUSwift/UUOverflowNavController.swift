//
//  UUOverflowNavController.swift
//  UUSwift
//
// UUOverflowNavController contains a simple base class and storyboard segue that can be used as
// an overflow or 'hamburger' slide out view controller
//
//

#if os(iOS)

import UIKit

@available(iOS 9.0, *)
open class UUOverflowNavController: UIViewController
{
    var dimmerView: UIView!
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint?

    open override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        let v = UIView()
        v.frame = view.bounds
        view.insertSubview(v, at: 0)
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        v.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        if let vs = v.superview
        {
            v.leadingAnchor.constraint(equalTo: vs.leadingAnchor).isActive = true
            v.trailingAnchor.constraint(equalTo: vs.trailingAnchor).isActive = true
            v.topAnchor.constraint(equalTo: vs.topAnchor).isActive = true
            v.bottomAnchor.constraint(equalTo: vs.bottomAnchor).isActive = true
        }
        
        dimmerView = v;
    }
    
    @objc func handleDismiss(_ sender: Any? = nil)
    {
        dismiss(animated: true, completion: nil)
    }
}

@available(iOS 9.0, *)
public class UUOverflowNavSegue: UIStoryboardSegue, UIViewControllerTransitioningDelegate
{
    private var selfRetainer: UUOverflowNavSegue? = nil
    
    public override func perform()
    {
        destination.transitioningDelegate = self
        selfRetainer = self
        destination.modalPresentationStyle = .overCurrentContext
        source.present(destination, animated: true, completion: nil)
    }
    
    private class Presenter: NSObject, UIViewControllerAnimatedTransitioning
    {
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
        {
            return 0.5
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
        {
            let container = transitionContext.containerView
            
            guard let toView = transitionContext.view(forKey: .to) else
            {
                return
            }
            
            guard let toViewController = transitionContext.viewController(forKey: .to) as? UUOverflowNavController else
            {
                return
            }
            
            toViewController.contentViewLeadingConstraint?.constant = -toViewController.view.bounds.size.width
            toViewController.dimmerView.alpha = 0
            container.addSubview(toView)
            toViewController.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.5, animations:
            {
                toViewController.dimmerView.alpha = 1
                
                toViewController.contentViewLeadingConstraint?.constant = 0
                toViewController.view.layoutIfNeeded()
                
            })
            { (completed) in
                
                transitionContext.completeTransition(completed)
            }
        }
    }
    
    private class Dismisser: NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
        {
            return 0.2
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
        {
            guard let fromViewController = transitionContext.viewController(forKey: .from) as? UUOverflowNavController else
            {
                return
            }
            
            UIView.animate(withDuration: 0.5, animations:
            {
                fromViewController.dimmerView.alpha = 0
                fromViewController.contentViewLeadingConstraint?.constant = -fromViewController.view.bounds.size.width
                fromViewController.view.layoutIfNeeded()
            })
            { (completed) in
                
                transitionContext.completeTransition(completed)
            }
        }
    }
    
    
    // MARK: UIViewControllerTransitioningDelegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Presenter()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        selfRetainer = nil
        return Dismisser()
    }
}

#endif
