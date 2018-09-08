//
//  ViewController.swift
//  ARShooter
//
//  Created by Victor Hernandez-Urbina on 06/09/2018.
//  Copyright © 2018 Herurbi. All rights reserved.
//

import UIKit
import ARKit

enum bitMaskCategory: Int{
    case bullet = 2
    case target = 3
}

class ViewController: UIViewController, SCNPhysicsContactDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    var power: Float = 50
    var target: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.session.run(configuration)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.scene.physicsWorld.contactDelegate = self
        
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfView = sceneView.pointOfView else {return}
        
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        
        bullet.position = position
        bullet.physicsBody?.categoryBitMask = bitMaskCategory.bullet.rawValue
        
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
        body.isAffectedByGravity = false
        bullet.physicsBody = body
        
        bullet.physicsBody?.applyForce(SCNVector3(orientation.x * power, orientation.y * power, orientation.z * power), asImpulse: true)
        
        bullet.physicsBody?.contactTestBitMask = bitMaskCategory.target.rawValue
        self.sceneView.scene.rootNode.addChildNode(bullet)
        
        bullet.runAction(SCNAction.sequence([SCNAction.wait(duration: 2.0), SCNAction.removeFromParentNode()]))
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addTargets(_ sender: Any) {
        self.addEgg(x: 5, y: 0, z: -40)
        self.addEgg(x: 0, y: 0, z: -40)
        self.addEgg(x: -5, y: 0, z: -40)
    }
    
    func addEgg(x: Float, y: Float, z: Float){
        let eggScene = SCNScene(named: "Media.scnassets/egg.scn")
        let eggNode = eggScene?.rootNode.childNode(withName: "egg", recursively: false)
        eggNode?.position = SCNVector3(x, y, z)
        eggNode?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: eggNode!, options: nil))
        
        eggNode?.categoryBitMask = bitMaskCategory.target.rawValue
        eggNode?.physicsBody?.contactTestBitMask = bitMaskCategory.bullet.rawValue
        
        self.sceneView.scene.rootNode.addChildNode(eggNode!)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("came into contact")
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if nodeA.physicsBody?.categoryBitMask == bitMaskCategory.target.rawValue {
            self.target = nodeA
        } else if nodeB.physicsBody?.categoryBitMask == bitMaskCategory.target.rawValue {
            self.target = nodeB
        }
        
        let confetti = SCNParticleSystem(named: "Media.scnassets/Confetti.scnp", inDirectory: nil)
        confetti?.loops = false
        confetti?.particleLifeSpan = 4
        
        confetti?.emitterShape = target?.geometry
        
        let confettiNode = SCNNode()
        confettiNode.addParticleSystem(confetti!)
        
        confettiNode.position = contact.contactPoint
        
        self.sceneView.scene.rootNode.addChildNode(confettiNode)
        target?.removeFromParentNode()
        
        
    }
    
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

