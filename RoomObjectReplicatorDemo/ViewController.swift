//
//  ViewController.swift
//  RoomObjectReplicatorDemo
//
//  Created by Gauthier Bocquet
//

import ARKit
import RealityKit
import RoomPlan
import UIKit
import SwiftUI
import Combine

class ViewController: UIViewController, RoomCaptureViewDelegate {
    

  @IBOutlet var arView: ARView!
    let parentView = UIView()
    var hostingController: UIHostingController<ModelContentView>?
    //var containerView = ARSCNView()

  var replicator = RoomObjectReplicator()

  @IBOutlet var importButton: UIBarButtonItem? // import virtual object
  @IBOutlet var exportButton: UIButton?
  @IBOutlet var doneButton: UIBarButtonItem?
  @IBOutlet var cancelButton: UIBarButtonItem?

    
    private var roomCaptureView: RoomCaptureView!
  private var isScanning: Bool = false
  private var roomCaptureSessionConfig: RoomCaptureSession.Configuration =
    RoomCaptureSession.Configuration()
  private var finalResults: CapturedRoom?

}

extension ViewController: RoomCaptureSessionDelegate {
    

  func captureSession(_ session: RoomCaptureSession, didAdd room: CapturedRoom) {
    replicator.anchor(objects: room.objects, in: session)
  }

  func captureSession(_ session: RoomCaptureSession, didChange room: CapturedRoom) {
    replicator.anchor(objects: room.objects, in: session)
  }

  func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
    replicator.anchor(objects: room.objects, in: session)
  }

  func captureSession(_ session: RoomCaptureSession, didRemove room: CapturedRoom) {
    replicator.anchor(objects: room.objects, in: session)
  }

  func captureSession(
    _ session: RoomCaptureSession, didStartWith configuration: RoomCaptureSession.Configuration
  ) {
    arView.session.pause()
    arView.session = session.arSession
    arView.session.delegate = self
  }

  override func viewDidLoad() {
    super.viewDidLoad()
      
      
      arView.alpha = 1
      
      roomCaptureView = RoomCaptureView(frame: view.bounds)
      //roomCaptureView.translatesAutoresizingMaskIntoConstraints = false
      roomCaptureView.layoutSubviews()
      roomCaptureView.alpha = 0.7
      roomCaptureView.delegate = self
      roomCaptureView.captureSession.delegate = self
      
      // Create and add ContentView Container
      let containerView = UIView()
      //containerView.translatesAutoresizingMaskIntoConstraints = false
      containerView.addSubview(roomCaptureView)
      arView.addSubview(containerView)
      
      /*
      NSLayoutConstraint.activate([
          containerView.topAnchor.constraint(equalTo: arView.topAnchor),
          containerView.leadingAnchor.constraint(equalTo: arView.leadingAnchor),
          containerView.trailingAnchor.constraint(equalTo: arView.trailingAnchor),
          containerView.bottomAnchor.constraint(equalTo: arView.bottomAnchor),
          roomCaptureView.topAnchor.constraint(equalTo: containerView.topAnchor),
          roomCaptureView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
          roomCaptureView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
          roomCaptureView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
      ])
       */
      
      //parentView.translatesAutoresizingMaskIntoConstraints = false
      arView.addSubview(parentView)
        
      /*
        NSLayoutConstraint.activate([
            parentView.topAnchor.constraint(equalTo: arView.topAnchor),
            parentView.leadingAnchor.constraint(equalTo: arView.leadingAnchor),
            parentView.trailingAnchor.constraint(equalTo: arView.trailingAnchor),
            parentView.bottomAnchor.constraint(equalTo: arView.bottomAnchor)
        ])
       */
        
        //...
        
        parentView.addSubview(containerView)
        
      /*
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: parentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            roomCaptureView.topAnchor.constraint(equalTo: containerView.topAnchor),
            roomCaptureView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            roomCaptureView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            roomCaptureView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
       */
     
      // start room capture session
      startSession()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    startSession()
  }

  override func viewWillDisappear(_ flag: Bool) {
    super.viewWillDisappear(flag)
    stopSession()
  }

  private func startSession() {
    isScanning = true
    roomCaptureView?.captureSession.run(configuration: roomCaptureSessionConfig)
    setActiveNavBar()
  }

  private func stopSession() {
    isScanning = false
    roomCaptureView?.captureSession?.stop()

    setCompleteNavBar()
  }
    
    @IBAction func importButton(_ sender: UIBarButtonItem) {
            print("Import button log")

            let modelContentView = ModelContentView(arView: arView)
            hostingController = UIHostingController(rootView: modelContentView)
            
            if let hostView = hostingController?.view {
                parentView.addSubview(hostView)
                
                // Activate constraints...
                /*
                NSLayoutConstraint.activate([
                        host.view.topAnchor.constraint(equalTo: arView.topAnchor),
                        host.view.leadingAnchor.constraint(equalTo: arView.leadingAnchor),
                        host.view.trailingAnchor.constraint(equalTo: arView.trailingAnchor),
                        host.view.bottomAnchor.constraint(equalTo: arView.bottomAnchor)
                    ])*/
            }
        }
    


  @IBAction func doneScanning(_ sender: UIBarButtonItem) {
    if isScanning { stopSession() } else { cancelScanning(sender) }
  }

  @IBAction func cancelScanning(_ sender: UIBarButtonItem) {
    navigationController?.dismiss(animated: true)
  }

  @IBAction func exportResults(_ sender: UIButton) {
    let destinationURL = FileManager.default.temporaryDirectory.appending(path: "Room.usdz")
    do {
      try finalResults?.export(to: destinationURL)

      let activityVC = UIActivityViewController(
        activityItems: [destinationURL], applicationActivities: nil)
      activityVC.modalPresentationStyle = .popover

      present(activityVC, animated: true, completion: nil)
      if let popOver = activityVC.popoverPresentationController {
        popOver.sourceView = self.exportButton
      }
    } catch {
      print("Error = \(error)")
    }
  }

  private func setActiveNavBar() {
    UIView.animate(
      withDuration: 1.0,
      animations: {
        self.cancelButton?.tintColor = .white
        self.doneButton?.tintColor = .white
          self.importButton?.tintColor = .white
        self.exportButton?.alpha = 0.0
      },
      completion: { complete in
        self.exportButton?.isHidden = true
      })
  }

  private func setCompleteNavBar() {
    self.exportButton?.isHidden = false
    UIView.animate(withDuration: 1.0) {
      self.cancelButton?.tintColor = .systemBlue
      self.doneButton?.tintColor = .systemBlue
        self.importButton?.tintColor = .systemBlue
      self.doneButton?.title = "Done"
      self.exportButton?.alpha = 1.0
    }
  }

}

extension ViewController: ARSessionDelegate {
    
    
  func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    print("ARSessionDelegate add anchor log...")
    arView.scene.addRoomObjectEntities(for: anchors)
      
      /*
       for anchor in anchors {
          arView.session.remove(anchor: anchor)
      }
      
      for anchor in arView.scene.anchors {
          arView.scene.removeAnchor(anchor)
      }
      
    
      print("ARSessionDelegate log, count ARAnchor size : ", anchors.count)
      print("ARSessionDelegate log, arView.scene.anchors.count size : ", arView.scene.anchors.count)
       */
      
  }

  func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    print("ARSessionDelegate update anchor log...")
    arView.scene.updateRoomObjectEntities(for: anchors)
  }

}
