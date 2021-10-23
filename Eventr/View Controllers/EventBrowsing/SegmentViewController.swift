//
//  SegmentViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 27/09/2021.
//

import UIKit
import MapKit

class SegmentViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localEventsViewController.delegate = joinedEventsViewController
        joinedEventsViewController.delegate = localEventsViewController

        setupView()
    }
    
    lazy var localEventsViewController: LocalEventsViewController = {
        // Load storyboard
        let storyboard = UIStoryboard(name: "EventBrowsing", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "LocalEventsViewController") as! LocalEventsViewController
        
        self.embed(viewController, inView: containerView)
        
        return viewController
    }()
    
    lazy var joinedEventsViewController: JoinedEventsViewController = {
        let storyboard = UIStoryboard(name: "EventBrowsing", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "JoinedEventsViewController") as! JoinedEventsViewController
        
        self.embed(viewController, inView: containerView)
        
        return viewController
    }()
    
    func setupView() {
        setupSegmentedControl()
        
        updateView()
    }
    
    func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Local", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Joined", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
    }
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }
    
    func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.remove(child: joinedEventsViewController)
            self.embed(localEventsViewController, inView: containerView)
        } else {
            self.remove(child: localEventsViewController)
            self.embed(joinedEventsViewController, inView: containerView)
        }
    }
}

protocol EventCrossReferenceDelegate {
    func didChangeParticipation(_ eventViewController: EventViewController, for event: Event)
}
