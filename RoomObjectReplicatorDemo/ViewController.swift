//
//  ViewController.swift
//  RoomObjectReplicatorDemo
//
//  Created by Jack Mousseau on 6/7/22.
//

import ARKit
import RealityKit
import RoomPlan
import UIKit

class ViewController: UIViewController, RoomCaptureViewDelegate {
    

  @IBOutlet var arView: ARView!

  var replicator = RoomObjectReplicator()

  @IBOutlet var exportButton: UIButton?
  @IBOutlet var doneButton: UIBarButtonItem?
  @IBOutlet var cancelButton: UIBarButtonItem?
    @IBOutlet var activityIndicator: UIActivityIndicatorView?

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
        
        // Set up after loading the view.
        setupRoomCaptureView()
        activityIndicator?.stopAnimating()
    }

    private func setupRoomCaptureView() {
        if #available(iOS 17.0, *) {
            let roomCaptureARSession = ARSession()
            //let configuration = ARWorldTrackingConfiguration()
            //roomCaptureARSession.run(configuration)

            roomCaptureView = RoomCaptureView(frame: view.bounds, arSession: roomCaptureARSession)
            roomCaptureView.captureSession.delegate = self
            roomCaptureView.delegate = self
            
            roomCaptureView.alpha = 0.3
            roomCaptureView.isOpaque = false
            
            arView.addSubview(roomCaptureView)
            
            NSLayoutConstraint.activate([
                roomCaptureView.topAnchor.constraint(equalTo: arView.topAnchor),
                roomCaptureView.leadingAnchor.constraint(equalTo: arView.leadingAnchor),
                roomCaptureView.trailingAnchor.constraint(equalTo: arView.trailingAnchor),
                roomCaptureView.bottomAnchor.constraint(equalTo: arView.bottomAnchor)
            ])
        } else {
            // Fallback on earlier versions
        }
    }
    
    /*
    override func viewDidLoad() {
       super.viewDidLoad()

         arView.alpha = 1
        
        roomCaptureView = RoomCaptureView(frame: view.bounds)
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
        roomCaptureView.alpha = 0.7
        
        arView.addSubview(roomCaptureView)
        
         let containerView = UIView()
         containerView.translatesAutoresizingMaskIntoConstraints = false
         containerView.addSubview(roomCaptureView)
         arView.addSubview(containerView)
        
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
         
        
        activityIndicator?.stopAnimating()


        // start room capture session
        //startSession()
     }
     */

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
        roomCaptureView?.captureSession.stop()
        
        setCompleteNavBar()
    }

    // Decide to post-process and show the final results.
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        return true
    }

    // Access the final post-processed results.
    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        finalResults = processedResult
        self.exportButton?.isEnabled = true
        self.activityIndicator?.stopAnimating()
    }

    @IBAction func doneScanning(_ sender: UIBarButtonItem) {
        if isScanning { stopSession() } else { cancelScanning(sender) }
        self.exportButton?.isEnabled = false
        self.activityIndicator?.startAnimating()
    }

    @IBAction func cancelScanning(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true)
    }

    // Export the USDZ output by specifying the `.parametric` export option.
    // Alternatively, `.mesh` exports a nonparametric file and `.all`
    // exports both in a single USDZ.
    @IBAction func exportResults(_ sender: UIButton) {
        let destinationFolderURL = FileManager.default.temporaryDirectory.appending(path: "Export")
        let destinationURL = destinationFolderURL.appending(path: "Room.usdz")
        let capturedRoomURL = destinationFolderURL.appending(path: "Room.json")
        do {
            try FileManager.default.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true)
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(finalResults)
            try jsonData.write(to: capturedRoomURL)
            try finalResults?.export(to: destinationURL, exportOptions: .parametric)
            
            let activityVC = UIActivityViewController(activityItems: [destinationFolderURL], applicationActivities: nil)
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
      self.doneButton?.title = "Done"
      self.exportButton?.alpha = 1.0
    }
  }

}


extension ViewController: ARSessionDelegate {
    
    
  func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    arView.scene.addRoomObjectEntities(for: anchors)
  }

  func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    arView.scene.updateRoomObjectEntities(for: anchors)
  }

}
