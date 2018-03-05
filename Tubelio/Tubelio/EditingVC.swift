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
        
        // 4 - Get path
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: NSDate() as Date)
        let savePath = (documentDirectory as NSString).appendingPathComponent("mergeVideo-\(date).mov")
        let url = NSURL(fileURLWithPath: savePath)
        
        // 5 - Create Exporter
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = url as URL
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        exporter.shouldOptimizeForNetworkUse = true
        
        // 6 - Perform the Export
        exporter.exportAsynchronously() {
            DispatchQueue.main.async {
                self.exportDidFinish(session: exporter)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AVPlayerViewController {
            playerVC = vc
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
