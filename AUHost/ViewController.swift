//
//  ViewController.swift
//  AUHost
//
//  Created by Michael Borgmann on 08.01.20.
//  Copyright © 2020 Michael Borgmann. All rights reserved.
//

import Cocoa
import AUFramework

class ViewController: NSViewController {
    
    private var audioPlayer: AudioPlayer!
    private var pluginVC: AudioUnitViewController!
    
    @IBOutlet weak var auContainer: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = Bundle.main.url(forResource: "At Night", withExtension: "m4a") else {
            fatalError("can't create url from resource")
        }

        audioPlayer = AudioPlayer(url)
        addPluginView()
        connectAudioUnitWithPlayer()
        audioPlayer.play()
    }
    
    private func addPluginView() {
        let builtInPluginsURL = Bundle.main.builtInPlugInsURL
        guard let pluginURL = builtInPluginsURL?.appendingPathComponent("VolumePlugin.appex") else {
            fatalError("cannot get plugin URL")
        }
        let appExtensionBundle = Bundle(url: pluginURL)
        
        pluginVC = AudioUnitViewController(nibName: "AudioUnitViewController", bundle: appExtensionBundle)
        let auView = pluginVC.view
        auView.frame = auContainer.bounds
        auContainer.addSubview(auView)
    }
    
    private func connectAudioUnitWithPlayer() {
        var componentDescription = AudioComponentDescription()
        componentDescription.componentType = kAudioUnitType_Effect
        // used https://codebeautify.org/string-hex-converter to convert strings to fourCC hex
        componentDescription.componentSubType = 0x64656d6f // "demo"
        componentDescription.componentManufacturer = 0x64656d6f // "demo"
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0
            
        AUAudioUnit.registerSubclass(VolumePluginAudioUnit.self, as: componentDescription, name: "demo: VolumePlugin", version: UInt32.max)
        audioPlayer.selectAudioUnitWithComponentDescription(componentDescription) {
            guard let audioUnit = self.audioPlayer.audioUnit as? VolumePluginAudioUnit else {
                fatalError("playEngine.testAudioUnit nil or cast failed")
            }
            self.pluginVC.audioUnit = audioUnit
        }
    }
    
}
