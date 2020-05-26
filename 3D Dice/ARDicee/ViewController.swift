//
//  ViewController.swift
//  ARDicee
//
//  Created by Dylan Kuster on 5/20/20.
//  Copyright © 2020 Dylan Kuster. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dice = [SCNNode]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touchLocation = touches.first?.location(in: sceneView)
        {
            if let hitTest = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent).first
            {
                createDice(at : hitTest)
            }
        }
    }
    
    @IBAction func rollButtonPressed(_ sender: UIBarButtonItem)
    {
        for die in dice
        {
            rollDice(for: die)
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?)
    {
        for die in dice
        {
            rollDice(for: die)
        }
    }
    
    func rollDice(for dice : SCNNode)
    {
        let randomAngleX = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        let randomAngleY = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        let randomAngleZ = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        print(randomAngleX, randomAngleY, randomAngleZ)
        
        let randomRotations = Float(arc4random_uniform(5) + 1)
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat((5 * randomRotations) * randomAngleX), y: CGFloat((5 * randomRotations) * randomAngleY), z: CGFloat((5 * randomRotations) * randomAngleZ), duration: 0.5))
    }
    
    @IBAction func trashButtonPressed(_ sender: UIBarButtonItem)
    {
        let alertC = UIAlertController(title: "Remove Dice?", message: "", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default)
        { (action) in
            self.deleteDice()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        { (action) in
            alertC.dismiss(animated: true, completion: nil)
        }
        alertC.addAction(yesAction)
        alertC.addAction(cancelAction)
        present(alertC, animated: true, completion: nil)
    }
    
    func deleteDice()
    {
        for die in dice
        {
            die.removeFromParentNode()
        }
    }
    
    func createDice(at hitTest : ARHitTestResult)
    {
        if let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
        {
            if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true)
            {
                dice.append(diceNode)
                diceNode.position = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)
                sceneView.scene.rootNode.addChildNode(diceNode)
                rollDice(for: diceNode)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}
