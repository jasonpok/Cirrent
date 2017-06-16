//
//  Type.swift
//  Cirrent_New
//
//  Created by PSIHPOK on 12/17/16.
//

import Foundation

//Response Types

@objc public enum RESPONSE_ : Int {
    case SUCCESS
    case FAILED
    case FAILED_INVALID_TOKEN
    case FAILED_INVALID_DEVICE_ID
}

public typealias RESPONSE = RESPONSE_

@objc public enum FIND_DEVICE_RESULT_ : Int {
    case SUCCESS
    case FAILED_NETWORK_OFFLINE
    case FAILED_LOCATION_DISABLED
    case FAILED_UPLOAD_ENVIRONMENT
    case FAILED_NO_DEVICE
    case FAILED_UNEXPECTED_RESPONSE
    case FAILED_INVALID_TOKEN
}

/**
 ### Result from findDevice call - could be one of the following
 - SUCCESS - at least one nearby device was found from the Cirrent cloud - the list of nearby devices is returned.  If more than one, you can present the list to the user and have them select the one(s) they want to onboard
 - FAILED_NETWORK_OFFLINE - a nearby device could not be found because the phone is offline - prompt the user to connect their phone to the internet and try again.
 - FAILED_LOCATION_DISABLED - a nearby device could not be found because the phone is on cellular, and the location is not available - prompt the user to turn on location services or connect to Wi-Fi and try again
 - FAILED_UPLOAD_ENVIRONMENT - a nearby device could not be found because the SDK was unable to upload the environment to the Cirrent cloud (this is likely to be a temporary problem, so retry)
 - FAILED_NO_DEVICE - no nearby devices were found. This is most likely due to the device not being in range of a ZipKey network, or not being turned on recently. Go to SoftAP or other local onboarding instead.
 - FAILED_UNEXPECTED_RESPONSE - no response from the Cirrent cloud. This is most likely due to a network connectivity problem. Try moving to a better network.
 - FAILED_INVALID_TOKEN - the token being passed to the findDevice call was invalid, or was not a SEARCH token
*/
public typealias FIND_DEVICE_RESULT = FIND_DEVICE_RESULT_

@objc public enum JOINING_STATUS_ : Int {
    case JOINED
    case RECEIVED_CREDS
    case ATTEMPTING_TO_JOIN
    case OPTIMIZING_CONNECTION
    case TIMED_OUT
    case FAILED
    case SELECTED_DEVICE_NIL
    case FAILED_UNEXPECTED_RESPONSE
    case FAILED_INVALID_TOKEN
    case FAILED_REJOIN_SOFTAP_NEEDED
}
/**
 ### Result from getDeviceJoiningStatus call - could be one of the following
 - JOINED - the device successfully joined the private network
 - RECEIVED_CREDS - The device has downloaded the private network credentials from the Cirrent cloud
 - ATTEMPTING_TO_JOIN - The device is about to drop off the ZipKey network and attempt to join the private network
 - OPTIMIZING_CONNECTION - The device is confirming that the private network connection works
 - TIMED_OUT - the mobile app timed out while waiting for the device to  join the private network. This is most likely due to the device being unable to rejoin the ZipKey network to provide a status update.  Go to SoftAP or other local onboarding instead.
 - FAILED - The device failed to join the private network. This is most likely due to the credentials being invalid. Prompt the user to re-enter the private network credentials
 - SELECTED_DEVICE_NIL - there was no device to get status from
 - FAILED_UNEXPECTED_RESPONSE - there was no response or an unexpected response for the cloud
 - FAILED_INVALID_TOKEN - the token being presented is invalid, or does not have the right scope for the operation being performed.  getDeviceJoiningStatus requires a MANAGE token that includes this device
 - FAILED_REJOIN_SOFTAP_NEEDED - If joining via the SoftAP network, the phone fell off the SoftAP network. Prompt the user to put the phone back on the SoftAP network
 */
public typealias JOINING_STATUS = JOINING_STATUS_

@objc public enum LOG_EVENT_ : Int {
    case SEARCH_START
    case TOKEN_RECEIVED
    case TOKEN_ERROR
    case LOCATION
    case LOCATION_ERROR
    case WIFI_SCAN
    case WIFI_SCAN_ERROR
    case DEVICES_RECEIVED
    case DEVICE_SELECTED
    case DEVICE_BOUND
    case PROVIDER_CREDS
    case USER_CREDS
    case STATUS
    case STATUS_ERROR
    case SoftAP
    case SoftAP_ERROR
    case SoftAP_SCREEN
    case SoftAP_JOINED
    case SoftAP_DROP
    case SoftAP_LONG_DURATION
    case CREDS_TIMEOUT
    case CLOUD_CONNECTION_ERROR
    case JOINED_FAILED
    case SUCCESS
    case EXIT
    case DEBUG
}

public typealias LOG_EVENT = LOG_EVENT_

@objc public enum CREDENTIAL_RESPONSE_ : Int {
    case SUCCESS
    case FAILED
    case FAILED_INVALID_TOKEN
    case FAILED_REJOIN_SOFTAP_NEEDED
}

/**
 ### Result from putPrivateCredential call - could be one of the following
 - SUCCESS - credentials were written to Cirrent Cloud (or to device, if over SoftAP)
 - FAILED_NO_RESPONSE - no response received from Cirrent Cloud (or from device, if over SoftAP)
 - FAILED_INVALID_TOKEN - the token being presented is invalid, or does not have the right scope for the operation being performed. putPrivateCredentials requires a MANAGE token that includes this device.
 - NOT_SoftAP - phone fell off SoftAP network before credentials were sent to device
 */
public typealias CREDENTIAL_RESPONSE = CREDENTIAL_RESPONSE_

@objc public enum SoftAP_RESPONSE_ : Int {
    case SUCCESS
    case FAILED_NOT_SoftAP
    case FAILED_SoftAP_INVALID_RESPONSE
    case FAILED_SoftAP_NOT_SUPPORTED
}

/**
 ### Result from ProcessSoftAP call - could be one of the following
 - SUCCESS_WITH_SoftAP - phone is ready to talk to device over SoftAP network
 - FAILED_NOT_SoftAP - the mobile app wasn't able to associate to the SoftAP SSID.  Try moving the phone closer to the device.
 - FAILED_SoftAP_NO_RESPONSE - the mobile app did not get any response from the device over the SoftAP network.
 - FAILED_SoftAP_INVALID_STATUS - Unexpected http response
 - FAILED_SoftAP_NOT_SUPPORTED - device does not support SoftAP
 */
public typealias SoftAP_RESPONSE = SoftAP_RESPONSE_


@objc public enum TOKEN_TYPE_ : Int {
    case SEARCH
    case BIND
    case MANAGE
    case ANY
}

public typealias TOKEN_TYPE = TOKEN_TYPE_

//CallBack Handlers

public typealias LocationCompletionHandler = (Bool) -> Void
public typealias CompletionHandler = (RESPONSE) -> Void
public typealias CallBack = (Data?, URLResponse?, Error?) -> Void
public typealias UploadEnvironmentCallBack = (RESPONSE, Double) -> Void
public typealias FindDeviceCompletionHandler = (FIND_DEVICE_RESULT, [Device]?) -> Void
public typealias UserActionCompletionHandler = (Device) -> Void
public typealias DeviceStatusCompletionHandler = (RESPONSE, DeviceStatus?) -> Void
public typealias CredentialCompletionHadler = (CREDENTIAL_RESPONSE, [String]?) -> Void
public typealias JoiningHandler = (JOINING_STATUS) -> Void
public typealias SoftAPHandler = (SoftAP_RESPONSE) -> Void
public typealias GetNetworksCompletionHandler = ([KnownNetwork]?) -> Void
public typealias TokenHandler = (_ tokenType:TOKEN_TYPE, _ deviceID:String?, _ completion: @escaping (_ token:String?) -> Void) -> Void

//Alias Types

public typealias DeviceIDs = [String]
