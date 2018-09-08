//
//  ViewController.swift
//  ARShooter
//
//  Created by Victor Hernandez-Urbina on 06/09/2018.
//  Copyright © 2018 Herurbi. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.session.run(configuration)
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
        
        self.sceneView.scene.rootNode.addChildNode(eggNode!)
    }
    
}

