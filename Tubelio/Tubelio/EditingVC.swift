//
//  EditingVC.swift
//  Tubelio
//
//  Created by Sikander Zeb on 3/4/18.
//  Copyright © 2018 Sikander. All rights reserved.
//

import UIKit
import Photos
import AVKit
import MediaPlayer
import AssetsLibrary

class EditingVC: UIViewController {
    
    var selectedPHAsset: PHAsset!
    var playerVC: AVPlayerViewController!
    var mediaItems: [MPMediaItem] = []
    var audioAsset: AVAsset!
    var firstAsset: AVAsset!
    var exportedAsset: AVURLAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHImageManager.default().requestAVAsset(forVideo: selectedPHAsset, options: PHVideoRequestOptions()) { (avasset, audioMix, info) in
            self.firstAsset = avasset
            print("got asset \(self.firstAsset)")
        }
    }

    @IBAction func pickMedia(_ sender: UIButton) {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        present(mediaPicker, animated: true, completion: nil)
    }
    
    func exportDidFinish(session: AVAssetExportSession) {
        if session.status == AVAssetExportSessionStatus.completed {
            let outputURL = session.outputURL
            let library = ALAssetsLibrary()
            if library.videoAtPathIs(compatibleWithSavedPhotosAlbum: outputURL) {
                library.writeVideoAtPath(toSavedPhotosAlbum: outputURL, completionBlock: { (assetURL, error) in
                    
                    self.exportedAsset = AVURLAsset(url: session.outputURL!)
                    self.performSegue(withIdentifier: "shareSegue", sender: self)
                    var title = ""
                    var message = ""
                    if error != nil {
                        title = "Error"
                        message = "Failed to save video"
                    } else {
                        title = "Success"
                        message = "Video saved"
                    }
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
        
        //activityMonitor.stopAnimating()
        firstAsset = nil
        //secondAsset = nil
        audioAsset = nil
    }
    
    func addText(composition: AVMutableVideoComposition) {
        // 1 - Set up the text layer
        let subtitle1Text = CATextLayer()
        subtitle1Text.font = UIFont(name: "Helvetica-Bold", size: 15)
        subtitle1Text.frame = CGRect(x: 0, y: 0, width: 320, height: 100)
        subtitle1Text.string = "Hello World"
        subtitle1Text.alignmentMode = kCAAlignmentCenter
        subtitle1Text.foregroundColor = UIColor.red.cgColor
        subtitle1Text.backgroundColor = UIColor.white.cgColor
        
        // 2 - The usual overlay
        let overlayLayer = CALayer()
        overlayLayer.addSublayer(subtitle1Text)
        overlayLayer.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        overlayLayer.masksToBounds = true
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        videoLayer.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        
        // 4 - Get path
        let url = getExportURL()
        
        // 5 - Create Exporter
        
//        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
//        exporter.outputURL = url
//        exporter.outputFileType = AVFileTypeQuickTimeMovie
//        exporter.shouldOptimizeForNetworkUse = true
//        
//        // 6 - Perform the Export
//        exporter.exportAsynchronously() {
//            DispatchQueue.main.async {
//                self.exportDidFinish(session: exporter)
//            }
//        }
    }
    
    func addTiltEffect(composition: AVMutableVideoComposition) {
        // 1 - Layer setup
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        videoLayer.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        parentLayer.addSublayer(videoLayer)
        
        // 2 - Set up the transform
        var identityTransform = CATransform3DIdentity;
        
        // 3 - Pick the direction
       // if (_tiltSegment.selectedSegmentIndex == 0) {
            identityTransform.m34 = 1.0 / 1000; // greater the denominator lesser will be the transformation
       // } else if (_tiltSegment.selectedSegmentIndex == 1) {
       //     identityTransform.m34 = 1.0 / -1000; // lesser the denominator lesser will be the transformation
       // }
        
        // 4 - Rotate
        videoLayer.transform = CATransform3DRotate(identityTransform, .pi/6.0, 1.0, 0.0, 0.0);
        
        // 5 - Composition
        
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
    }
    
    func merge() {
        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        
        // 2 - Video track
        let firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try firstTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAsset.duration),
                                           of: firstAsset.tracks(withMediaType: AVMediaTypeVideo)[0] ,
                                           at: kCMTimeZero)
        } catch _ {
            print("Failed to load first track")
        }
//
//        let secondTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo,
//                                                                      preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
//        do {
//            try secondTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration),
//                                            ofTrack: secondAsset.tracksWithMediaType(AVMediaTypeVideo)[0] ,
//                                            atTime: firstAsset.duration)
//        } catch _ {
//            print("Failed to load second track")
//        }
        
        // 3 - Audio track
        if let loadedAudioAsset = audioAsset {
            let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
            do {
                try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, /*CMTimeAdd(*/firstAsset.duration/*secondAsset.duration)*/),
                                               of: loadedAudioAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                               at: kCMTimeZero)
            } catch _ {
                print("Failed to load audio track")
            }
        }
        
        let compositionIns = AVMutableVideoCompositionInstruction()
        
        //addText(composition: compositionIns)
        
        // 4 - Get path
        let url = getExportURL()
        
        // 5 - Create Exporter
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = url
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        exporter.shouldOptimizeForNetworkUse = true
        
        // 6 - Perform the Export
        exporter.exportAsynchronously() {
            DispatchQueue.main.async {
                self.exportDidFinish(session: exporter)
            }
        }
    }
    
    func getExportURL() -> URL {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: NSDate() as Date)
        let savePath = (documentDirectory as NSString).appendingPathComponent("mergeVideo-\(date).mov")
        
        return NSURL(fileURLWithPath: savePath) as URL
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AVPlayerViewController {
            playerVC = vc
        }
        if segue.identifier == "shareSegue" {
            let vc = segue.destination as? ShareVC
            vc?.asset = self.exportedAsset
        }
    }
}

extension EditingVC: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaItems = mediaItemCollection.items
        
        let selectedSongs = mediaItemCollection.items
        if selectedSongs.count > 0 {
            let song = selectedSongs[0]
            
            if let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
                audioAsset = AVAsset(url: url)
                self.merge()
            }
            
        }
        
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        
    }
}
