import Foundation
import ARKit
import RealityKit
import RoomPlan

class CustomCaptureView: ARView, RoomCaptureSessionDelegate {
    let captureSession: RoomCaptureSession = RoomCaptureSession()
    private var roomCaptureSessionConfig: RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()

    let roomBuilder: RoomBuilder = RoomBuilder(options: [.beautifyObjects])
    
    var delegate: RoomCaptureViewDelegate?
    
    required init(frame: CGRect) {
    super.init(frame: frame)
               initSession()
           }
    
    @MainActor required dynamic init?(coder decoder: NSCoder) {
           super.init(coder: decoder)
               initSession()
    }
    
    func initSession() {
        self.cameraMode = .ar
        captureSession.delegate = self
        captureSession.run(configuration: roomCaptureSessionConfig)
        
        //self.session = captureSession.arSession
        
        //self.session.configuration(roomCaptureSessionConfig)
        
        //roomCaptureView?.captureSession.run(configuration: roomCaptureSessionConfig)
}
    
    func captureSession(_ session: RoomCaptureSession, didUpdate: CapturedRoom) {
        DispatchQueue.main.async {
        self.scene.anchors.removeAll()
        
        for wall in didUpdate.walls {
            self.drawBox(scene: self.scene, dimensions: wall.dimensions,
                                transform: wall.transform, confidence: wall.confidence)
        }
        
        for object in didUpdate.objects {
            self.drawBox(scene: self.scene, dimensions: object.dimensions,
                         transform: object.transform, confidence: object.confidence)
        }
    }
}
    
    func drawBox(scene: Scene, dimensions: simd_float3, transform: float4x4, confidence: CapturedRoom.Confidence) {
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
    
    self.scene.addAnchor(anchor)
}
    
    func captureSession(_ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: (Error)?) {
    Task {
        let finalRoom = try! await roomBuilder.capturedRoom(from: data)
        delegate?.captureView(didPresent: finalRoom, error: error)
    }
}
}
