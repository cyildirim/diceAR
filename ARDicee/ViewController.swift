//
//  ViewController.swift
//  ARDicee
//
//  Created by Can Yıldırım on 11/15/17.
//  Copyright © 2017 Can Yıldırım. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate,SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dicArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        self.sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.worldAlignment = .gravity
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let resutls = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResults = resutls.first {
                let diceScene = SCNScene(named:"art.scnassets/DicesV9.scn")!
            
            
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice_White-Pivot",recursively: true){
                    
                    diceNode.position = SCNVector3(
                        hitResults.worldTransform.columns.3.x,
                        hitResults.worldTransform.columns.3.y + 0.30,
                        hitResults.worldTransform.columns.3.z)
                    
                    
                    
                    let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                    physicsBody.restitution = 0
                    physicsBody.mass = 1
                    physicsBody.friction = 0.1
                    
//                    physicsBody.categoryBitMask = CollisionTypes.shape.rawValue
//
                    diceNode.physicsBody = physicsBody
                    
                    
                    dicArray.append(diceNode)
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    roll(dice: diceNode)
                    
                } // if diceNode End
                

            }
        }
    }
    
    struct CollisionTypes : OptionSet {
        let rawValue: Int
        
        static let bottom  = CollisionTypes(rawValue: 1 << 0)
        static let shape = CollisionTypes(rawValue: 1 << 1)
    }
    
    func rollAll() {
        if !dicArray.isEmpty{
            for dic in dicArray{
                roll(dice: dic)
            }
        }
    }
    func roll(dice:SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        var actionArray: Array = [SCNAction]()
//
        actionArray.append(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0 , z: CGFloat(randomZ * 5),duration: 0.5))
//        actionArray.append(SCNAction.moveBy(x: CGFloat(dice.position.x) , y: CGFloat(dice.boundingSphere.radius), z: CGFloat(dice.position.y), duration: 0.5))
        
        dice.runAction(SCNAction.group(actionArray))
    
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    
    @IBAction func refresButtonTapped(_ sender: Any) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeButtonTapped(_ sender: Any) {
        for childNode in dicArray{
            childNode.removeFromParentNode()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor{
            print("Plane detecged")
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNBox(width: CGFloat(planeAnchor.extent.x), height:0.02 ,length: CGFloat(planeAnchor.extent.z), chamferRadius: 0)
            
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3Make(planeAnchor.center.x,0,planeAnchor.center.z)
            
//            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named:"art.scnassets/green_surface.jpg")
            
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            let physicsBody =  SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeNode.geometry!, options: nil))
            physicsBody.restitution = 0
            physicsBody.friction = 1.0
            
            planeNode.physicsBody = physicsBody
        
            node.addChildNode(planeNode)
            
            
            
        }else{
            return
        }
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
