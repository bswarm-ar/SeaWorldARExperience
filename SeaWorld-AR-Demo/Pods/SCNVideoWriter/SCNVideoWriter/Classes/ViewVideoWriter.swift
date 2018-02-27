//
//  ViewVideoWriter
//  Cbieniak
//
//  Created by Christian Bieniak on 10/01/2018.
//  Based on SCNVideoWriter
//

import UIKit
import ARKit
import AVFoundation

/// Records a view by snapshotting this screen on each display link call
public class ViewVideoWriter {
    private let writer: AVAssetWriter
    private let input: AVAssetWriterInput
    private let pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor
    private let view: UIView
    private let options: SCNVideoWriter.Options
    
    private let frameQueue = DispatchQueue(label: "com.papercloud.ViewVideoWriter.frameQueue")
    private static let renderQueue = DispatchQueue(label: "com.papercloud.ViewVideoWriter.renderQueue")
    private static let renderSemaphore = DispatchSemaphore(value: 3)
    private var displayLink: CADisplayLink?
    private var initialTime: CFTimeInterval = 0.0
    private var currentTime: CFTimeInterval = 0.0
    
    public var updateFrameHandler: ((_ image: UIImage, _ time: CMTime) -> Void)?
    private var finishedCompletionHandler: ((_ url: URL) -> Void)?
    
    public init?(view: UIView, options: SCNVideoWriter.Options = .default) throws {
        self.options = SCNVideoWriter.Options.defaults(with: view.frame.size)
        self.view = view
        self.writer = try AVAssetWriter(outputURL: options.outputUrl,
                                        fileType: AVFileType(rawValue: options.fileType))
        self.input = AVAssetWriterInput(mediaType: AVMediaType.video,
                                        outputSettings: options.assetWriterInputSettings)
        self.pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input,
                                                                       sourcePixelBufferAttributes: options.sourcePixelBufferAttributes)
        self.prepare(with: options)
    }
    
    private func prepare(with options: SCNVideoWriter.Options) {
        if options.deleteFileIfExists {
            FileController.delete(file: options.outputUrl)
        }
        writer.add(input)
    }
    
    public func startWriting() {
        ViewVideoWriter.renderQueue.async { [weak self] in
            ViewVideoWriter.renderSemaphore.wait()
            self?.startDisplayLink()
            self?.startInputPipeline()
        }
    }
    
    public func finishWriting(completionHandler: (@escaping (_ url: URL) -> Void)) {
        let outputUrl = options.outputUrl
        input.markAsFinished()
        writer.finishWriting(completionHandler: { [weak self] in
            completionHandler(outputUrl)
            self?.stopDisplayLink()
            ViewVideoWriter.renderSemaphore.signal()
        })
    }
    
    private func startDisplayLink() {
        currentTime = 0.0
        initialTime = CFAbsoluteTimeGetCurrent()
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplayLink))
        displayLink?.preferredFramesPerSecond = options.fps
        displayLink?.add(to: .main, forMode: .commonModes)
    }
    
    @objc private func updateDisplayLink() {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, 0)
        self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: false)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            frameQueue.async { [weak self] in
                guard let safeSelf = self else { return }
                guard safeSelf.input.isReadyForMoreMediaData else { return }
                guard let pool = safeSelf.pixelBufferAdaptor.pixelBufferPool else { return }
                safeSelf.renderSnapshot(with: pool, image: image, renderSize: safeSelf.options.renderSize, videoSize: safeSelf.options.videoSize)
            }
        }
        UIGraphicsEndImageContext()
        
    }
    
    private func startInputPipeline() {
        writer.startWriting()
        writer.startSession(atSourceTime: kCMTimeZero)
        input.requestMediaDataWhenReady(on: frameQueue, using: {})
    }
    
    private func renderSnapshot(with pool: CVPixelBufferPool, image: UIImage, renderSize: CGSize, videoSize: CGSize) {
        autoreleasepool {
            currentTime = CFAbsoluteTimeGetCurrent() - initialTime
            guard let croppedImage = image.fill(at: videoSize) else { return }
            guard let pixelBuffer = PixelBufferFactory.make(with: videoSize, from: croppedImage, usingBuffer: pool) else { return }
            let value: Int64 = Int64(currentTime * CFTimeInterval(options.timeScale))
            let presentationTime = CMTimeMake(value, options.timeScale)
            pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
            updateFrameHandler?(croppedImage, presentationTime)
        }
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
}
