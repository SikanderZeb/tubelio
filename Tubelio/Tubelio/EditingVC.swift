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

class EditingVC: BaseVC {
    
    var selectedPHAsset: PHAsset!
    var playerVC: AVPlayerViewController!
    var mediaItems: [MPMediaItem] = []
    var audioAsset: AVAsset!
    var firstAsset: AVAsset!
    var exportedAsset: AVURLAsset!
    var textOverVideo = ""
    
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
                    self.navigationController?.popToRootViewController(animated: true)
                })
            }
        }
        
        //activityMonitor.stopAnimating()
        firstAsset = nil
        //secondAsset = nil
        audioAsset = nil
    }
    
    func addText(composition: AVMutableVideoComposition, size: CGSize) {
        // 1 - Set up the text layer
        let subtitle1Text = CATextLayer()
        subtitle1Text.font = UIFont(name: "Helvetica-Bold", size: 15)
        subtitle1Text.frame = CGRect(x: 0, y: 0, width: size.width, height: 100)
        subtitle1Text.string = textOverVideo
        subtitle1Text.alignmentMode = kCAAlignmentCenter
        subtitle1Text.foregroundColor = UIColor.red.cgColor
        subtitle1Text.backgroundColor = UIColor.white.cgColor
        
        // 2 - The usual overlay
        let overlayLayer = CALayer()
        overlayLayer.addSublayer(subtitle1Text)
        overlayLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        overlayLayer.masksToBounds = true
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        //return AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
    }
    
    func addTiltEffect(composition: AVMutableVideoComposition, size: CGSize) {
        // 1 - Layer setup
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
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
            } catch  {
                print("Failed to load audio track \(error)")
            }
        }
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstAsset.duration)
        let instructionLayer = AVMutableVideoCompositionLayerInstruction(assetTrack: firstTrack)
        
        var videoAssetOrientation_ : UIImageOrientation  = UIImageOrientation.up
        var isVideoAssetPortrait_  = false
        let videoTransform: CGAffineTransform = firstTrack.preferredTransform;
        if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
            videoAssetOrientation_ = .right;
            isVideoAssetPortrait_ = true;
        }
        if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
            videoAssetOrientation_ =  .left;
            isVideoAssetPortrait_ = true;
        }
        if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
            videoAssetOrientation_ =  .up;
        }
        if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
            videoAssetOrientation_ = .down;
        }
        
        var naturalSize: CGSize;
        if(isVideoAssetPortrait_){
            
            naturalSize = CGSize(width: firstTrack.naturalSize.height, height: firstTrack.naturalSize.width);
        } else {
            naturalSize = firstTrack.naturalSize;
        }
        
        instructionLayer.setTransform(firstTrack.preferredTransform, at: kCMTimeZero)
        instructionLayer.setOpacity(0.0, at: firstAsset.duration)
    
        instruction.layerInstructions = [instructionLayer]
        
        let compositionIns = AVMutableVideoComposition()
        compositionIns.instructions = [instruction]
        compositionIns.renderSize = CGSize(width: naturalSize.width, height: naturalSize.height)
        compositionIns.frameDuration = CMTimeMake(1, 30)
        if textOverVideo.count > 0 {
            addText(composition: compositionIns, size: naturalSize)
        }
        else {
            addTiltEffect(composition: compositionIns, size: naturalSize)
        }
        
        // 4 - Get path
        let url = getExportURL()
        
        // 5 - Create Exporter
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.videoComposition = compositionIns
        
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
    
    @IBAction func tabChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            let alert = UIAlertController(title: "Enter text for video", message: "", preferredStyle: .alert)
            alert.addTextField { (textfield) in
                
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                let textfield = alert.textFields![0]
                self.textOverVideo = textfield.text!
            }))
            self.present(alert, animated: true, completion: nil)
        }
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
