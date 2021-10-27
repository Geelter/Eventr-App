//
//  SegmentViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 27/09/2021.
//

import UIKit
import MapKit

class SegmentViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localEventsViewController.crossReferenceDelegate = joinedEventsViewController
        joinedEventsViewController.crossReferenceDelegate = localEventsViewController

        setupView()
    }
    
    //MARK: - Child ViewControllers setup
    private lazy var localEventsViewController: LocalEventsViewController = {
        let storyboard = UIStoryboard(name: "EventBrowsing", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "LocalEventsViewController") as! LocalEventsViewController
        
        self.embed(viewController, inView: containerView)
        
        return viewController
    }()
    
    private lazy var joinedEventsViewController: JoinedEventsViewController = {
        let storyboard = UIStoryboard(name: "EventBrowsing", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "JoinedEventsViewController") as! JoinedEventsViewController
        
        self.embed(viewController, inView: containerView)
        
        return viewController
    }()
    
    private func setupView() {
        setupSegmentedControl()
        
        updateView()
    }
    
    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Local", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Joined", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
    }
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }
    
    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.remove(child: joinedEventsViewController)
            self.embed(localEventsViewController, inView: containerView)
        } else {
            self.remove(child: localEventsViewController)
            self.embed(joinedEventsViewController, inView: containerView)
        }
    }
}

//MARK: - Protocol for communication between child view controllers
protocol EventCrossReferenceDelegate {
    func didChangeParticipation(_ eventViewController: UIViewController, for event: Event)
}
