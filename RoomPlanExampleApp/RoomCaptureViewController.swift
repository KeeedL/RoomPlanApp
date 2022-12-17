/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's main view controller that manages the scanning process.
*/

import RealityKit
import UIKit
import ARKit
import RoomPlan

class RoomCaptureViewController: UIViewController, RoomCaptureViewDelegate, RoomCaptureSessionDelegate {
    
    
    // 1
        private var label: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.preferredFont(forTextStyle: .title1)
            label.text = "Hello, UIKit!"
            label.textAlignment = .center
            
            return label
        }()
    
    @IBOutlet var exportButton: UIButton?
    
    @IBOutlet var doneButton: UIBarButtonItem?
    @IBOutlet var cancelButton: UIBarButtonItem?
    
    private var isScanning: Bool = false
    
    private var roomCaptureView: RoomCaptureView!
    private var roomCaptureSessionConfig: RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()
    
    private var finalResults: CapturedRoom?
    
    //func captureSession(_ session: RoomCaptureSession, didAdd room: CapturedRoom) {
        
        
        
    //    self.scene.anchors.removeAll()
        
        //session.arSession.add(anchor: <#T##ARAnchor#>)
    

        
    //}
    
    
    
    func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
        
        print("update scan log")
        
        DispatchQueue.main.async {
            
        for wall in room.walls {
            self.drawBox(session: session, dimensions: wall.dimensions,
                                transform: wall.transform, confidence: wall.confidence)
        }
            
            for object in room.objects {
                print("Trying to add anchorText for category : ", object.category)
                self.drawBox(session: session, dimensions: object.dimensions,
                             transform: object.transform, confidence: object.confidence)
            }
        }
    }
    
    func drawBox(session: RoomCaptureSession, dimensions: simd_float3, transform: float4x4, confidence: CapturedRoom.Confidence) {
        
        print("update scan log DRAWBOX")
        
        //let box = MeshResource.generateBox(size: 1)
        
        // Depth is 0 for surfaces, in which case we set it to 0.1 for visualization
        let box = MeshResource.generateBox(width: dimensions.x,
                                           height: dimensions.y,
                                          depth: dimensions.z > 0 ? dimensions.z : 0.1)
        
        let boxEntity = ModelEntity(mesh: box)

        
        let textEntity = ModelEntity(mesh: .generateText("AR",
                              extrusionDepth: 0.01,
                                font: .init(name: "Helvetica", size: 0.5)!,
                              containerFrame: .zero,
                                   alignment: .center,
                               lineBreakMode: .byWordWrapping))
         

        //let shader = UnlitMaterial(color: .yellow)
        //let textEntity = ModelEntity(mesh: .generateText("RealityKit",
          //                           font: .init(name: "Helvetica", size: 0.5)!))
        textEntity.position.z += 0.6
            
        // Changing a position, orientation and scale of the parent
        boxEntity.addChild(textEntity)
        boxEntity.transform = Transform(pitch: .pi/8, yaw: .pi/8, roll: .pi/8)
        boxEntity.position.x = -0.5
        boxEntity.scale /= 2
                
        
        let anchor = AnchorEntity()
        anchor.transform = Transform(matrix: transform)
        
        boxEntity.setParent(anchor)
        
        let arAnchor = ARAnchor(transform: anchor.transformMatrix(relativeTo: anchor))
        
        session.arSession.add(anchor: arAnchor)
        
        /*
            var color: UIColor = confidence == .low ? .red : (confidence == .medium ? .yellow : .green)
            color = color.withAlphaComponent(0.8)
            
            let anchor = AnchorEntity()
            anchor.transform = Transform(matrix: transform)
            
            // Depth is 0 for surfaces, in which case we set it to 0.1 for visualization
            let box = MeshResource.generateBox(width: dimensions.x,
                                               height: dimensions.y,
                                              depth: dimensions.z > 0 ? dimensions.z : 0.1)
        
            let material = SimpleMaterial(color: color, roughness: 1, isMetallic: false)
            
            let entity = ModelEntity(mesh: box, materials: [material])
            anchor.addChild(entity);
                
                //anchor.
            
            let arAnchor = ARAnchor(transform: anchor.transformMatrix(relativeTo: entity))
            
                //self.scene.addAnchor(anchor)
                session.arSession.add(anchor: arAnchor)
         */
        
    }

    
    /*func captureSession(_ session: RoomCaptureSession, didAdd room: CapturedRoom) {
        //session.arSession.currentFrame.
        //room.objects[0].
        //session.arSession.
        
        for element in room.objects {
            try
            
                print(element.category)
            
                //let categoryTxt = element.category
            

                //let category = String(categoryTxt)
            
                let position = element.transform
                print(position)
                        
                //let categoryTextAnchor = ARAnchor(name: "Category",
                  //                            transform: position)
            
                    
                //session.arSession.add(anchor: categoryTextAnchor)
            
            let box = MeshResource.generateBox(size: 1)
            let boxEntity = ModelEntity(mesh: box)
                
            let anchor = AnchorEntity()
            boxEntity.setParent(anchor)
            //arView.scene.addAnchor(anchor)
            session.arSession.add(anchor: anchor)
                
            let text = MeshResource.generateText("AR",
                                  extrusionDepth: 0.01,
                                            font: .systemFont(ofSize: 0.25),
                                  containerFrame: .zero,
                                       alignment: .center,
                                   lineBreakMode: .byWordWrapping)

            let shader = UnlitMaterial(color: .yellow)
            let textEntity = ModelEntity(mesh: text, materials: [shader])
            textEntity.position.z += 0.6
                
            // Changing a position, orientation and scale of the parent
            boxEntity.addChild(textEntity)
            boxEntity.transform = Transform(pitch: .pi/8, yaw: .pi/8, roll: .pi/8)
            boxEntity.position.x = -0.5
            boxEntity.scale /= 2
        }
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.backgroundColor = .systemPink

        // 3
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
        
        // Set up after loading the view.
        //setupRoomCaptureView()
    }
    
    private func setupRoomCaptureView() {
        roomCaptureView = RoomCaptureView(frame: view.bounds)
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
        
        view.insertSubview(roomCaptureView, at: 0)
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
        
        /*for element in processedResult.objects {
            try print(element.category)
        }*/
        
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
            
            let activityVC = UIActivityViewController(activityItems: [destinationURL], applicationActivities: nil)
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
        UIView.animate(withDuration: 1.0, animations: {
            self.cancelButton?.tintColor = .white
            self.doneButton?.tintColor = .white
            self.exportButton?.alpha = 0.0
        }, completion: { complete in
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

