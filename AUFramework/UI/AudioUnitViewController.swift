//
//  AudioUnitViewController.swift
//  VolumePlugin
//
//  Created by Michael Borgmann on 09.01.20.
//  Copyright © 2020 Michael Borgmann. All rights reserved.
//

import CoreAudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    
    public var audioUnit: VolumePluginAudioUnit? {
        didSet {
            DispatchQueue.main.async {
                if self.isViewLoaded {
                    self.connectWithAU()
                }
            }
        }
    }

    private var volumeParam: AUParameter?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if audioUnit == nil {
            return
        }
        self.connectWithAU()
    }
    
    func connectWithAU() {
        guard let paramTree = audioUnit?.parameterTree else {
            fatalError("paramTree nil!")
        }
        volumeParam = paramTree.value(forKey: "param1") as? AUParameter
    }
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try VolumePluginAudioUnit(componentDescription: componentDescription, options: [])
        
        return audioUnit!
    }
    
    @IBAction func volumeSlider(_ sender: NSSliderCell) {
        volumeParam?.value = AUValue(sender.doubleValue)
    }
    
}
