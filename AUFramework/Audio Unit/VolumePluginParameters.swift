//
//  VolumePluginParameters.swift
//  VolumePlugin
//
//  Created by Michael Borgmann on 09.01.20.
//  Copyright © 2020 Michael Borgmann. All rights reserved.
//

import Foundation
import AudioToolbox

/// Manages the VolumePlugin object's paramOne.
class VolumePluginParameters {

    private enum VolumePluginParam: AUParameterAddress {
        case paramOne
    }

    /// Example parameter
    var paramOne: AUParameter = {
        let parameter =
            AUParameterTree.createParameter(withIdentifier: "paramOne",
                                            name: "paramOne",
                                            address: VolumePluginParam.paramOne.rawValue,
                                            min: 0.0,
                                            max: 100.0,
                                            unit: .percent,
                                            unitName: nil,
                                            flags: [.flag_IsReadable,
                                                    .flag_IsWritable],
                                            valueStrings: nil,
                                            dependentParameters: nil)
        // Set default value
        parameter.value = 50.0

        return parameter
    }()

    let parameterTree: AUParameterTree

    init(kernelAdapter: VolumePluginDSPKernelAdapter) {

        // Create the audio unit's tree of parameters
        parameterTree = AUParameterTree.createTree(withChildren: [paramOne])

        // Closure observing all externally-generated parameter value changes.
        parameterTree.implementorValueObserver = { param, value in
            kernelAdapter.setParameter(param, value: value)
        }

        // Closure returning state of requested parameter.
        parameterTree.implementorValueProvider = { param in
            return kernelAdapter.value(for: param)
        }

        // Closure returning string representation of requested parameter value.
        parameterTree.implementorStringFromValueCallback = { param, value in
            switch param.address {
            case VolumePluginParam.paramOne.rawValue:
                return String(format: "%.f", value ?? param.value)
            default:
                return "?"
            }
        }
    }
}
