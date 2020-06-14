//
//  ContentView.swift
//  SwiftUI-AVFundation
//
//  Created by satoutakeshi on 2020/06/07.
//  Copyright © 2020 satoutakeshi. All rights reserved.
//

import SwiftUI
import AVKit

struct ErrorInfo: Error {
    var showError: Bool
    var message: String
}

struct ContentView: View {
    @State var errorInfo: ErrorInfo = ErrorInfo(showError: false, message: "")
    @State var onAppear: Bool = false
    var body: some View {
        ZStack {
            VideoView(showError: $errorInfo.showError, errorMessage: $errorInfo.message, onAppear: $onAppear)

                .alert(isPresented: $errorInfo.showError) { () -> Alert in
                    Alert(title: Text($errorInfo.message.wrappedValue))
            }
            Text("dddd")
        }
        .edgesIgnoringSafeArea(.all)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct VideoView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    typealias Coordinator = VideoCoordinator
    @Binding var showError: Bool
    @Binding var errorMessage: String
    @Binding var onAppear: Bool
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        context.coordinator.sessionStart()
        if let previewLayer = context.coordinator.previewLayer {
            viewController.view.layer.addSublayer(previewLayer)
            previewLayer.frame = viewController.view.layer.frame
            print("context.coordinator.previewLayer?.frame: make \(String(describing: context.coordinator.previewLayer?.frame))")
        }

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.previewLayer?.frame = uiViewController.view.layer.frame
        print("context.coordinator.previewLayer?.frame: update \(String(describing: context.coordinator.previewLayer?.frame))")
    }
    func makeCoordinator() -> VideoCoordinator {
        let coordinator = VideoCoordinator(parent: self)
        coordinator.setupAVCaptureSession()
        return coordinator
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: VideoCoordinator) {
        coordinator.stopSession()
    }
}

final class VideoCoordinator: NSObject {
    var parent: VideoView
    let session: AVCaptureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var videoDataOutputQueue: DispatchQueue?
    private var captureDevice: AVCaptureDevice?
    init(parent: VideoView) {
        self.parent = parent
    }

    func sessionStart() {
        if session.isRunning { return }
        print("session start")
        session.startRunning()
    }

    func stopSession() {
        if !session.isRunning { return }
        session.stopRunning()
    }

    /// - Tag: CreateCaptureSession
    func setupAVCaptureSession() {
        print(#function)
        session.sessionPreset = .photo
        if let availableDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first {
            captureDevice = availableDevice
        }

        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(captureDeviceInput)
        } catch let error {
            print(error.localizedDescription)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer = previewLayer

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA]

        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
        }

        session.commitConfiguration()

        let queue = DispatchQueue(label: "FromF.github.com.AVFoundationSwiftUI.AVFoundation")
        dataOutput.setSampleBufferDelegate(self, queue: queue)

//        let captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .photo
//
//        do {
//            let inputDevice = try self.configureFrontCamera(for: captureSession)
//            self.configureVideoDataOutput(for: inputDevice.device, resolution: inputDevice.resolution, captureSession: captureSession)
//            self.designatePreviewLayer(for: captureSession)
//            session = captureSession
//            return
//        } catch let executionError as NSError {
//            parent.showError = true
//            parent.errorMessage = executionError.localizedDescription
//        } catch {
//            parent.showError = true
//            parent.errorMessage = "An unexpected failure has occured"
//        }
//
//        self.teardownAVCapture()
//
//        session = nil
    }

    /// - Tag: DesignatePreviewLayer
    fileprivate func designatePreviewLayer(for captureSession: AVCaptureSession) {
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        videoPreviewLayer.name = "CameraPreview"
        videoPreviewLayer.backgroundColor = UIColor.black.cgColor
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer = videoPreviewLayer
    }

    /// - Tag: CreateSerialDispatchQueue
    fileprivate func configureVideoDataOutput(for inputDevice: AVCaptureDevice, resolution: CGSize, captureSession: AVCaptureSession) {

        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true

        // Create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured.
        // A serial dispatch queue must be used to guarantee that video frames will be delivered in order.
        let videoDataOutputQueue = DispatchQueue(label: "com.example.apple-samplecode.VisionFaceTrack")
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)

        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }

        videoDataOutput.connection(with: .video)?.isEnabled = true

        if let captureConnection = videoDataOutput.connection(with: AVMediaType.video) {
            if captureConnection.isCameraIntrinsicMatrixDeliverySupported {
                captureConnection.isCameraIntrinsicMatrixDeliveryEnabled = true
            }
        }

        self.videoDataOutput = videoDataOutput
        self.videoDataOutputQueue = videoDataOutputQueue
    }

    fileprivate func configureFrontCamera(for captureSession: AVCaptureSession) throws -> (device: AVCaptureDevice, resolution: CGSize) {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)

        if let device = deviceDiscoverySession.devices.first {
            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                }

                if let highestResolution = self.highestResolution420Format(for: device) {
                    try device.lockForConfiguration()
                    device.activeFormat = highestResolution.format
                    device.unlockForConfiguration()

                    return (device, highestResolution.resolution)
                }
            }
        }

        throw NSError(domain: "ViewController", code: 1, userInfo: nil)
    }

    /// - Tag: ConfigureDeviceResolution
    private func highestResolution420Format(for device: AVCaptureDevice) -> (format: AVCaptureDevice.Format, resolution: CGSize)? {
        var highestResolutionFormat: AVCaptureDevice.Format? = nil
        var highestResolutionDimensions = CMVideoDimensions(width: 0, height: 0)

        for format in device.formats {
            let deviceFormat = format as AVCaptureDevice.Format

            let deviceFormatDescription = deviceFormat.formatDescription
            if CMFormatDescriptionGetMediaSubType(deviceFormatDescription) == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange {
                let candidateDimensions = CMVideoFormatDescriptionGetDimensions(deviceFormatDescription)
                if (highestResolutionFormat == nil) || (candidateDimensions.width > highestResolutionDimensions.width) {
                    highestResolutionFormat = deviceFormat
                    highestResolutionDimensions = candidateDimensions
                }
            }
        }

        if highestResolutionFormat != nil {
            let resolution = CGSize(width: CGFloat(highestResolutionDimensions.width), height: CGFloat(highestResolutionDimensions.height))
            return (highestResolutionFormat!, resolution)
        }

        return nil
    }

    // Removes infrastructure for AVCapture as part of cleanup.
    fileprivate func teardownAVCapture() {

        if let previewLayer = self.previewLayer {
            previewLayer.removeFromSuperlayer()
            self.previewLayer = nil
        }
    }
}

extension VideoCoordinator: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

    }
}
