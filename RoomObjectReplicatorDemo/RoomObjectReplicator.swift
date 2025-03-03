//
//  RoomObjectReplicator.swift
//  RoomObjectReplicator
//
//  Created by Jack Mousseau on 6/6/22.
//
import ARKit
import RoomPlan

public class RoomObjectAnchor: ARAnchor {

    public override var identifier: UUID {
        roomObjectIdentifier
    }

    public override var transform: simd_float4x4 {
        roomObjectTransform
    }

    public private(set) var dimensions: simd_float3
    public private(set) var category: CapturedRoom.Object.Category

    private let roomObjectIdentifier: UUID
    private var roomObjectTransform: simd_float4x4

    public required init(anchor: ARAnchor) {
        guard let anchor = anchor as? RoomObjectAnchor else {
            fatalError("RoomObjectAnchor can only copy other RoomObjectAnchor instances")
        }

        roomObjectIdentifier = anchor.roomObjectIdentifier
        roomObjectTransform = anchor.roomObjectTransform
        dimensions = anchor.dimensions
        category = anchor.category

        super.init(anchor: anchor)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Unavailable")
    }

    public init(_ object: CapturedRoom.Object) {
        roomObjectIdentifier = object.identifier
        roomObjectTransform = object.transform
        dimensions = object.dimensions
        category = object.category
        super.init(transform: object.transform)
    }

    fileprivate func update(_ object: CapturedRoom.Object) {
        roomObjectTransform = object.transform
        dimensions = object.dimensions
        category = object.category
    }

}

public class RoomObjectReplicator {

    private var trackedAnchors: Set<RoomObjectAnchor>
    private var trackedAnchorsByIdentifier: [UUID: RoomObjectAnchor]
    private var inflightAnchors: Set<RoomObjectAnchor>

    public init() {
        trackedAnchors = Set<RoomObjectAnchor>()
        trackedAnchorsByIdentifier = [UUID: RoomObjectAnchor]()
        inflightAnchors = Set<RoomObjectAnchor>()
    }

    public func anchor(objects: [CapturedRoom.Object], in session: RoomCaptureSession) {
        for object in objects {
            if let existingAnchor = trackedAnchorsByIdentifier[object.identifier] {
                existingAnchor.update(object)
                inflightAnchors.insert(existingAnchor)
                session.arSession.delegate?.session?(session.arSession, didUpdate: [existingAnchor])
            } else {
                let anchor = RoomObjectAnchor(object)
                inflightAnchors.insert(anchor)
                session.arSession.add(anchor: anchor)
            }
        }

        trackInflightAnchors(in: session)
    }

    private func trackInflightAnchors(in session: RoomCaptureSession) {
        trackedAnchors.subtracting(inflightAnchors).forEach(session.arSession.remove)
        trackedAnchors.removeAll(keepingCapacity: true)
        trackedAnchors.formUnion(inflightAnchors)
        inflightAnchors.removeAll(keepingCapacity: true)
        trackedAnchorsByIdentifier.removeAll(keepingCapacity: true)

        for trackedAnchor in trackedAnchors {
            trackedAnchorsByIdentifier[trackedAnchor.identifier] = trackedAnchor
        }
    }

}
