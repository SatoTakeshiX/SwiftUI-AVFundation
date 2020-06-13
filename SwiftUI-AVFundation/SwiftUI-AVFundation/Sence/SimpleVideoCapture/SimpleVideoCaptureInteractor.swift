//
//  SimpleVideoCaptureInteractor.swift
//  SwiftUI-AVFundation
//
//  Created by satoutakeshi on 2020/06/13.
//  Copyright © 2020 satoutakeshi. All rights reserved.
//

import Foundation
import AVKit

final class SimpleVideoCaptureInteractor: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureDevice: AVCaptureDevice?

    /// - Tag: CreateCaptureSession
     func setupAVCaptureSession() {
         print(#function)
         captureSession.sessionPreset = .photo
         if let availableDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first {
             captureDevice = availableDevice
         }

         do {
             let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice!)
             captureSession.addInput(captureDeviceInput)
         } catch let error {
             print(error.localizedDescription)
         }

         let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
         self.previewLayer = previewLayer

         let dataOutput = AVCaptureVideoDataOutput()
         dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA]

         if captureSession.canAddOutput(dataOutput) {
             captureSession.addOutput(dataOutput)
         }
         captureSession.commitConfiguration()
     }

    func startSettion() {
        if captureSession.isRunning { return }
        captureSession.startRunning()
    }

    func stopSettion() {
        if !captureSession.isRunning { return }
        captureSession.stopRunning()
    }
}


extension SimpleVideoCaptureInteractor: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

    }
}
