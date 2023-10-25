//
//  TerminalUtils.swift
//  Plugin
//
//  Created by Noah Prail on 6/28/20.
//  Copyright © 2020 eventOne, Inc. All rights reserved.
//

import Foundation
import StripeTerminal

public class StripeTerminalUtils {
    static func serializeReader(reader: Reader) -> [String: Any] {
        let jsonObject: [String: Any] = [
            "deviceType": reader.deviceType.rawValue,
            "simulated": reader.simulated,
            "stripeId": reader.stripeId as Any,
            "locationId": reader.locationId as Any,
            "locationStatus": reader.locationStatus.rawValue,
            "serialNumber": reader.serialNumber,
            // Bluetooth reader props
            "deviceSoftwareVersion": reader.deviceSoftwareVersion as Any,
            "isAvailableUpdate": reader.availableUpdate != nil,
            "batteryLevel": reader.batteryLevel?.decimalValue as Any,
            "batteryStatus": reader.batteryStatus.rawValue,
            "isCharging": reader.isCharging as Any,
            // Internet reader props
            "ipAddress": reader.ipAddress as Any,
            "status": reader.status.rawValue,
            "label": reader.label as Any,
        ]

        return jsonObject
    }

    static func serializeUpdate(update: ReaderSoftwareUpdate) -> [String: Any] {
        let jsonObject: [String: Any] = [
            "estimatedUpdateTimeString": ReaderSoftwareUpdate.string(from: update.estimatedUpdateTime),
            "estimatedUpdateTime": update.estimatedUpdateTime.rawValue,
            "deviceSoftwareVersion": update.deviceSoftwareVersion,
            "components": update.components.rawValue,
            "requiredAt": update.requiredAt.timeIntervalSince1970,
        ]

        return jsonObject
    }

    static func serializePaymentIntent(intent: PaymentIntent) -> [String: Any] {
        let chargesJson = intent.charges.map {
            (charge: Charge) -> [AnyHashable: Any] in
            charge.originalJSON
        }

        var jsonObject: [String: Any] = [
            "stripeId": intent.stripeId,
            "created": intent.created.timeIntervalSince1970,
            "status": intent.status.rawValue,
            "amount": intent.amount,
            "currency": intent.currency,
            "amountTip": intent.amountTip as Any,
            "statementDescriptor": intent.statementDescriptor as Any,
            "statementDescriptorSuffix": intent.statementDescriptorSuffix as Any,
            "charges": chargesJson,
            "metadata": intent.metadata as Any,
        ]

        if let amountDetails = intent.amountDetails {
            jsonObject["amountDetails"] = amountDetails.originalJSON
        }

        if let paymentMethod = intent.paymentMethod {
            jsonObject["paymentMethod"] = paymentMethod.originalJSON
        }

        return jsonObject
    }

    static func serializeSetupIntent(intent: SetupIntent) -> [String: Any] {
        var jsonObject: [String: Any] = [
            "stripeId": intent.stripeId,
            "created": intent.created.timeIntervalSince1970,
            "status": intent.status.rawValue,
            "clientSecret": intent.clientSecret,
            "currency": intent.currency,
            "metadata": intent.metadata,
            "usage": intent.usage.rawValue,
            "paymentMethodTypes": intent.paymentMethodTypes,
        ]

        // Handle optional properties
        if let paymentMethodDetails = intent.paymentMethod {
            switch paymentMethodDetails {
            case let method as String:
                jsonObject["paymentMethod"] = method
            case let method as PaymentMethod: // Assuming there's a PaymentMethod class or struct
                jsonObject["paymentMethod"] = method.originalJSON
            default:
                break
            }
        }

        if let customer = intent.customer {
            jsonObject["customer"] = customer
        }

        if let description = intent.description {
            jsonObject["description"] = description
        }

        if let lastSetupError = intent.lastSetupError {
            // You would need to determine how to serialize the Error, e.g., using a function
            jsonObject["lastSetupError"] = serializeError(lastSetupError)
        }

        if let nextAction = intent.nextAction {
            // You might want to serialize nextAction as well, depending on its structure
            jsonObject["nextAction"] = nextAction // or serializeNextAction(nextAction)
        }

        return jsonObject
    }

    static func serializeLocation(location: Location) -> [String: Any] {
        var jsonObject: [String: Any] = [
            "stripeId": location.stripeId,
            "displayName": location.displayName as Any,
            "livemode": location.livemode,
            "metadata": location.metadata as Any,
        ]

        if let address = location.address {
            jsonObject["address"] = serializeAddress(address: address)
        }

        return jsonObject
    }

    static func serializeAddress(address: Address) -> [String: Any] {
        let jsonObject: [String: Any] = [
            "city": address.city as Any,
            "country": address.country as Any,
            "line1": address.line1 as Any,
            "line2": address.line2 as Any,
            "postalCode": address.postalCode as Any,
            "state": address.state as Any,
        ]

        return jsonObject
    }

    static func serializeSimulatorConfiguration(simulatorConfig: SimulatorConfiguration) -> [String: Any] {
        let jsonObject: [String: Any] = [
            "availableReaderUpdate": simulatorConfig.availableReaderUpdate.rawValue,
            "simulatedCard": "\(simulatorConfig.simulatedCard)" as Any,
        ]

        return jsonObject
    }

    static func translateDiscoveryMethod(method: UInt) -> DiscoveryMethod {
        if (method == 0) {
            return DiscoveryMethod.bluetoothScan
        } else if (method == 1) {
            return DiscoveryMethod.bluetoothProximity
        } else if (method == 2) {
            return DiscoveryMethod.internet
        } else if (method == 7) {
            return DiscoveryMethod.localMobile
        } else {
            return DiscoveryMethod.bluetoothProximity
        }
    }
}
