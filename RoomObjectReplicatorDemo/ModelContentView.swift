
import SwiftUI
import RealityKit
import ARKit
import FocusEntity

struct ModelContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement: Model?
    
    private var models: [Model] = {
        // Dynamically get our model filenames
        let filemanager = FileManager.default
        guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else {
            return []
        }
        var availableModels: [Model] = []
        for filename in files where filename.hasSuffix("usdz") {
            let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
            availableModels.append(model)
        }
        return availableModels
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            if self.isPlacementEnabled {
                PlacementButtonsView(isPlacementEnabled: $isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            } else {
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
            }
        }
        .ignoresSafeArea()
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: Model?
    
    func makeUIView(context: Context) -> CustomARView {
        let arView = CustomARView(frame: .zero)
        return arView
        
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {
        if let model = self.modelConfirmedForPlacement {
            if let modelEntity = model.modelEntity {
                print("DEBUG: adding model to scene - \(model.modelName)")
                let anchorEntity = AnchorEntity(plane: .any)
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                uiView.scene.addAnchor(anchorEntity)
            } else {
                print("DEBUG: Unable to load modelEntity for \(model.modelName)")
            }
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        }
    }
    
}

class CustomARView: ARView {
    enum FocusStyleChoices {
        case classic
        case material
        case color
    }

    /// Style to be displayed in the example
    let focusStyle: FocusStyleChoices = .classic
    var focusEntity: FocusEntity?
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
        self.setupConfig()

        switch self.focusStyle {
        case .color:
            self.focusEntity = FocusEntity(on: self, focus: .plane)
        case .material:
            do {
                let onColor: MaterialColorParameter = try .texture(.load(named: "Add"))
                let offColor: MaterialColorParameter = try .texture(.load(named: "Open"))
                self.focusEntity = FocusEntity(
                    on: self,
                    style: .colored(
                        onColor: onColor, offColor: offColor,
                        nonTrackingColor: offColor
                    )
                )
            } catch {
                self.focusEntity = FocusEntity(on: self, focus: .classic)
                print("DEBUG: Unable to load plane textures")
                print(error.localizedDescription)
            }
        default:
            self.focusEntity = FocusEntity(on: self, focus: .classic)
        }
    }

    func setupConfig() {
        let config = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        session.run(config)
    }

    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct ModelPickerView: View {
    @Binding var isPlacementEnabled : Bool
    @Binding var selectedModel: Model?
    var models: [Model]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(0 ..< self.models.count) { model in
                    Button(action: {
                        print("DEBUG: selected model with name \(self.models[model].modelName)")
                        self.isPlacementEnabled = true
                        self.selectedModel = self.models[model]
                    }) {
                        Image(uiImage: self.models[model].image)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled : Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    
    var body: some View {
        HStack {
            // Cancel Button
            Button(action: {
                print("DEBUG: Cancel model placement.")
                self.resetPlacementParameters()
            }) {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            
            // Confirm Button
            
            Button(action: {
                print("DEBUG: model placement confirm.")
                self.modelConfirmedForPlacement = self.selectedModel
                self.resetPlacementParameters()
            }) {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    
    func resetPlacementParameters() {
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}



/*
 
 
 PASSING MY OWN CUSTOM ARVIEW AS PARAM :
 

 import SwiftUI
 import RealityKit
 import ARKit
 import FocusEntity

 struct ModelContentView : View {
     @State private var isPlacementEnabled = false
     @State private var selectedModel: Model?
     @State private var modelConfirmedForPlacement: Model?
     
     private var models: [Model] = {
         // Dynamically get our model filenames
         let filemanager = FileManager.default
         guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else {
             return []
         }
         var availableModels: [Model] = []
         for filename in files where filename.hasSuffix("usdz") {
             let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
             let model = Model(modelName: modelName)
             availableModels.append(model)
         }
         return availableModels
     }()
     
     var arView: ARView

     init(arView: ARView) {
         self.arView = arView
     }
     
     var body: some View {
         ZStack(alignment: .bottom) {
             ARViewContainer(modelConfirmedForPlacement: self.$modelConfirmedForPlacement, arView: self.arView)
             if self.isPlacementEnabled {
                 PlacementButtonsView(isPlacementEnabled: $isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
             } else {
                 ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
             }
         }
         .ignoresSafeArea()
     }
 }

 struct ARViewContainer: UIViewRepresentable {
     @Binding var modelConfirmedForPlacement: Model?
     var arView: ARView
     
     func makeUIView(context: Context) -> ARView {
         return self.arView
     }
     
     func updateUIView(_ uiView: ARView, context: Context) {
         if let customARView = uiView as? CustomARView {
             if let model = self.modelConfirmedForPlacement {
                 if let modelEntity = model.modelEntity {
                     let anchorEntity = AnchorEntity(plane: .any)
                     anchorEntity.addChild(modelEntity.clone(recursive: true))
                     customARView.scene.addAnchor(anchorEntity)
                 } else {
                     print("DEBUG: Unable to load modelEntity for \(model.modelName)")
                 }
                 DispatchQueue.main.async {
                     self.modelConfirmedForPlacement = nil
                 }
             }
         }
     }
 }

 class CustomARView: ARView {
     enum FocusStyleChoices {
         case classic
         case material
         case color
     }

     let focusStyle: FocusStyleChoices = .classic
     var focusEntity: FocusEntity?
     
     required init(frame frameRect: CGRect) {
         super.init(frame: frameRect)
         
         self.setupConfig()

         switch self.focusStyle {
         case .color:
             self.focusEntity = FocusEntity(on: self, focus: .plane)
         case .material:
             do {
                 let onColor: MaterialColorParameter = try .texture(.load(named: "Add"))
                 let offColor: MaterialColorParameter = try .texture(.load(named: "Open"))
                 self.focusEntity = FocusEntity(
                     on: self,
                     style: .colored(
                         onColor: onColor, offColor: offColor,
                         nonTrackingColor: offColor
                     )
                 )
             } catch {
                 self.focusEntity = FocusEntity(on: self, focus: .classic)
                 print("DEBUG: Unable to load plane textures")
                 print(error.localizedDescription)
             }
         default:
             self.focusEntity = FocusEntity(on: self, focus: .classic)
         }
     }

     func setupConfig() {
             let config = ARWorldTrackingConfiguration()
             if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                 config.sceneReconstruction = .mesh
             }
             config.planeDetection = [.horizontal, .vertical]
             config.environmentTexturing = .automatic
             session.run(config)
         }

         @objc required dynamic init?(coder decoder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }
     }

     struct ModelPickerView: View {
         @Binding var isPlacementEnabled: Bool
         @Binding var selectedModel: Model?
         var models: [Model]
         
         var body: some View {
             ScrollView(.horizontal, showsIndicators: false) {
                 HStack(spacing: 10) {
                     ForEach(0 ..< self.models.count) { model in
                         Button(action: {
                             print("DEBUG: selected model with name \(self.models[model].modelName)")
                             self.isPlacementEnabled = true
                             self.selectedModel = self.models[model]
                         }) {
                             Image(uiImage: self.models[model].image)
                                 .resizable()
                                 .frame(height: 80)
                                 .aspectRatio(1/1, contentMode: .fit)
                                 .background(Color.white)
                                 .cornerRadius(12)
                         }.buttonStyle(PlainButtonStyle())
                     }
                 }
             }
             .padding(20)
             .background(Color.black.opacity(0.5))
         }
     }

     struct PlacementButtonsView: View {
         @Binding var isPlacementEnabled: Bool
         @Binding var selectedModel: Model?
         @Binding var modelConfirmedForPlacement: Model?
         
         var body: some View {
             HStack {
                 // Cancel Button
                 Button(action: {
                     print("DEBUG: Cancel model placement.")
                     self.resetPlacementParameters()
                 }) {
                     Image(systemName: "xmark")
                         .frame(width: 60, height: 60)
                         .font(.title)
                         .background(Color.white.opacity(0.75))
                         .cornerRadius(30)
                         .padding(20)
                 }
                 
                 // Confirm Button
                 
                 Button(action: {
                     print("DEBUG: model placement confirm.")
                     self.modelConfirmedForPlacement = self.selectedModel
                     self.resetPlacementParameters()
                 }) {
                     Image(systemName: "checkmark")
                         .frame(width: 60, height: 60)
                         .font(.title)
                         .background(Color.white.opacity(0.75))
                         .cornerRadius(30)
                         .padding(20)
                 }
             }
         }
         
         func resetPlacementParameters() {
             self.isPlacementEnabled = false
             self.selectedModel = nil
         }
     }
 
 
 
 
 */
