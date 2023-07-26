//
//  ViewController.swift
//  LH
//
//  Created by 김종혁의 MacBook Pro on 2023/07/07.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    var planeNode = [SCNNode]()
    var texture: [UIImage?] = []
    var j = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        for i in 0..<5 {
            texture.append(UIImage(named: "\(i + 1).png"))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
//        configuration.planeDetection = [.horizontal, .vertical]
        
        configuration.planeDetection = [.horizontal]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func undoPlane(_ sender: Any) {
        guard let tempPlane: SCNNode = planeNode.last else {return}

        planeNode.removeLast()
        
        tempPlane.removeFromParentNode()
        
        j = j - 1
        
        if j < 0 {
            j = 0
        }
//        print("Test")
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 4 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
            
        }
        
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResult.first{
                addDot(at: hitResult)
            }
        }
        
        func addDot(at hitResult : ARHitTestResult){
            let dotGeometry = SCNSphere(radius: 0.0025)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            
            dotGeometry.materials = [material]
            
            let dotNode = SCNNode(geometry: dotGeometry)
            
            dotNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y, z: hitResult.worldTransform.columns.3.z)
            
            sceneView.scene.rootNode.addChildNode(dotNode)
            
            dotNodes.append(dotNode)
            
//            if dotNodes.count >= 2 {
//                calculate()
//            }
            
            if dotNodes.count >= 4 {
                drawPlane(Points: dotNodes)
                
                for dot in dotNodes {
                    dot.removeFromParentNode()
                }
                dotNodes = [SCNNode]()
            }
        }
        
//        func calculate (){
//            let start = dotNodes[0]
//            let end = dotNodes[1]
//
//            print(start.position)
//            print(end.position)
//
//            let distance = sqrt(
//                pow(end.position.x - start.position.x, 2) +
//                pow(end.position.y - start.position.y,2) +
//                pow(end.position.z - start.position.z, 2))
//            //distance = √ ((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
//
//            updateText(text : "\(abs(distance))", atPosition: end.position)
//
//
//        }
        
//        func updateText(text: String, atPosition position: SCNVector3){
//
//            textNode.removeFromParentNode()
//
//            let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
//
//            textGeometry.firstMaterial?.diffuse.contents = UIColor.white
//
//            textNode = SCNNode(geometry: textGeometry)
//
//            textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
//
//            textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
//
//            sceneView.scene.rootNode.addChildNode(textNode)
//
//        }
        
//        func updatePlane(Points: [SCNNode]) {
//            let width = calculateWidthHeight(start: Points[0], end: Points[3])
//            let height = calculateWidthHeight(start: Points[0], end: Points[1])
//            let planeGeometry = SCNPlane(width: width, height: height)
////            var nodeAnchor: [CGFloat]! = nil
//
////            planeNode.removeFromParentNode()
//
////            planeNode = SCNNode(geometry: planeGeometry)
//
////            nodeAnchor = calculatePlaneCenter(start: Points[0], end: Points[2])
//
////            planeNode.rotation =
//
////            planeNode.position = SCNVector3(nodeAnchor[0], nodeAnchor[1], nodeAnchor[2])
//
////            let angle = calculateAngleBetweenPoints(x1: Points[0], x2: Points[2])
//
////            planeNode.transform = SCNMatrix4MakeRotation(angle, 0.0, 0.0, 0.0)
////            planeNode.eulerAngles = SCNVector3(Double.pi/2, 0, 0)
//
////            planeNode.eulerAngles.x = -.pi / 2
////            planeNode.eulerAngles.y = -angle
//
////            sceneView.scene.rootNode.addChildNode(planeNode)
//        }
        
        func draw(Points: [SCNNode]) -> SCNGeometry {
            let verticesPosition = [
                Points[0].position,
                Points[1].position,
                Points[2].position,
                Points[3].position
            ]

            let textureCord = [
                CGPoint(x: 1, y: 1),
                CGPoint(x: 0, y: 1),
                CGPoint(x: 0, y: 0),
                CGPoint(x: 1, y: 0),
            ]

            let indices: [CInt] = [
                0, 2, 3,
                0, 1, 2
            ]

            let vertexSource = SCNGeometrySource(vertices: verticesPosition)
            let srcTex = SCNGeometrySource(textureCoordinates: textureCord)
            let date = NSData(bytes: indices, length: MemoryLayout<CInt>.size * indices.count)

            let scngeometry = SCNGeometryElement(data: date as Data,
    primitiveType: SCNGeometryPrimitiveType.triangles, primitiveCount: 2,
    bytesPerIndex: MemoryLayout<CInt>.size)

            let geometry = SCNGeometry(sources: [vertexSource,srcTex],
    elements: [scngeometry])

            return geometry
        }
        
        func drawPlane(Points: [SCNNode]){

            let polyDraw = draw(Points: Points)
            
            let (min, max) = polyDraw.boundingBox

            let width = CGFloat(max.x - min.x)
            let height = CGFloat(max.y - min.y)

//            quad.firstMaterial?.diffuse.contents = UIImage(named: "wallpaper.jpg")
            polyDraw.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), 3)
//            quad.firstMaterial?.diffuse.wrapS = SCNWrapMode.repeat
//            quad.firstMaterial?.diffuse.wrapT = SCNWrapMode.repeat

            let node = SCNNode()
            node.geometry = polyDraw
            planeNode.append(node)
            
            let material =  SCNMaterial()
            
            if j >= 5 {
                j = 0
                
                material.diffuse.contents = texture[j]
            } else {
                material.diffuse.contents = texture[j]
                
                j = j + 1
            }
            
            node.geometry?.materials = [material]
            
            sceneView.scene.rootNode.addChildNode(node)

//            let material = SCNMaterial()
//            material.diffuse.contents = UIColor.green
//            material.isDoubleSided = true
//            polyDraw.materials = [material]
//
//            let node = SCNNode(geometry: polyDraw)
//            node.scale =  SCNVector3(x: 200, y: 200, z: 200)
//            node.eulerAngles.x = -.pi / 2
//            sceneView.scene.rootNode.addChildNode(node)
    
        }
        
//        func calculateAngleBetweenPoints(x1: SCNNode, x2: SCNNode) -> Float {
//            let x1_x = x1.position.x
//            let x1_y = x1.position.y
//            let x1_z = x1.position.z
//
//            let x2_x = x2.position.x
//            let x2_y = x2.position.y
//            let x2_z = x2.position.z
//
//            return acos((x1_x * x2_x + x1_y * x2_y + x1_z * x2_z) / sqrt((x1_x * x1_x + x1_y * x1_y + x1_z * x1_z) * (x2_x * x2_x + x2_y * x2_y + x2_z * x2_z)))
//        }
        
//        func calculateWidthHeight(start: SCNNode, end: SCNNode) -> CGFloat {
//            return CGFloat(sqrt(
//                pow(end.position.x - start.position.x, 2) +
//                pow(end.position.y - start.position.y,2) +
//                pow(end.position.z - start.position.z, 2)))
//        }
        
//        func calculatePlaneCenter(start: SCNNode, end: SCNNode) -> [CGFloat] {
//            var middlePoints: [CGFloat] = []
//
//            middlePoints.append(CGFloat((start.position.x + end.position.x) / 2))
//            middlePoints.append(CGFloat((start.position.y + end.position.y) / 2))
//            middlePoints.append(CGFloat((start.position.z + end.position.z) / 2))
//
//            return middlePoints
//        }
        
    }
    // MARK: - ARSCNViewDelegate
    
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
//        let pnode = createFloorNode(anchor: planeAnchor)
//
//        node.addChildNode(pnode)
//    }
//
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
//
//        node.enumerateChildNodes { (node, _) in
//            node.removeFromParentNode()
//        }
//        let pnode = createFloorNode(anchor: planeAnchor)
//
//        node.addChildNode(pnode)
//    }
//
//    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
//        guard let _ = anchor as? ARPlaneAnchor else {return}
//        node.enumerateChildNodes { (node, _) in
//            node.removeFromParentNode()
//        }
//    }
//
//    fileprivate func createFloorNode(anchor: ARPlaneAnchor) -> SCNNode {
//        let floorNode = SCNNode(geometry: SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z)))
//        floorNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
//        floorNode.eulerAngles = SCNVector3(Double.pi/2, 0, 0)
//
//        return floorNode
//    }
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
     */
}
