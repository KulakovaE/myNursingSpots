//
//  InteractiveModalPresentationController.swift
//  CustomPresentation
//
//  Created by Elena Kulakova on 2019-07-06.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit

enum ModalScaleState {
    case presentation
    case interaction
}

final class InteractiveModalPresentationController: UIPresentationController {
    private var presentedYOffset: CGFloat {
        get {
            return UIScreen.main.bounds.height * 0.25
        }
    }
    
    private var direction: CGFloat = 0
    private var state: ModalScaleState = .interaction
    
    private lazy var dimmingView: UIView! = {
        guard let container = containerView else { return nil }
    
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 10000, height: 10000))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTap(tap:)))
        )
    
        return view
    }()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        presentedViewController.view.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(didPan(pan:)))
        )
    }
    
    override func containerViewWillLayoutSubviews() {
       presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    @objc func didTap(tap: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc func didPan(pan: UIPanGestureRecognizer) {
        guard let view = pan.view, let superView = view.superview,
            let presented = presentedView, let container = containerView else { return }
        
        let location = pan.translation(in: superView)
        
        switch pan.state {
        case .began:
            presented.frame.size.height = container.frame.height
        case .changed:
            let velocity = pan.velocity(in: superView)
            
            switch state {
            case .interaction:
                presented.frame.origin.y = location.y + presentedYOffset
            case .presentation:
                presented.frame.origin.y = location.y
            }
            direction = velocity.y
        case .ended:
            let maxPresentedY = container.frame.height - presentedYOffset
            switch presented.frame.origin.y {
            case 0...maxPresentedY:
                changeScale(to: .interaction)
            default:
                presentedViewController.dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    func changeScale(to state: ModalScaleState) {
        guard let presented = presentedView else { return }
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [weak self] in
            guard let self = self else { return }
            
            presented.frame = self.frameOfPresentedViewInContainerView
            
            }, completion: { (isFinished) in
                self.state = state
        })
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        
        return CGRect(x: 0, y: self.presentedYOffset, width: container.bounds.width, height: container.bounds.height - self.presentedYOffset)
    }
    
    override func presentationTransitionWillBegin() {
        guard let container = containerView,
                let coordinator = presentingViewController.transitionCoordinator else { return }
        
        dimmingView.alpha = 0
        container.addSubview(dimmingView)
        dimmingView.addSubview(presentedViewController.view)
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let self = self else { return }
            
            self.dimmingView.alpha = 1
            }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        
        coordinator.animate(alongsideTransition: { [weak self] (context) -> Void in
            guard let self = self else { return }
            
            self.dimmingView.alpha = 0
            }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
}
