//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Simon Italia on 5/12/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    //MARK:- Properties
    var audioRecorder: AVAudioRecorder!
    var audioSession: AVAudioSession!
    
    
    //MARK:- outlets
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    

    //MARK:- Actions
    @IBAction func recordAudio(_ sender: Any) {
        configureUI(isRecording: true)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        print(filePath ?? "Error: filePath not found")

        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() { [weak self] allowed in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if allowed {
                        do {
                            try self.audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
                            self.audioRecorder.delegate = self
                                //this was omoitted from vid or I missed in the vid when this was set
                            self.audioRecorder.isMeteringEnabled = true
                            self.audioRecorder.prepareToRecord()
                            self.audioRecorder.record()
                        } catch {
                            print("Error! Failed to create auidoRecorder")
                        }
                        
                    } else {
                        print("Error! User denied Recording permission")
                    }
                }
            }

        } catch {
            print("Error! Failed to create AVAuidoSession")
        }
    }
    
    
    @IBAction func stopRecording(_ sender: Any) {
        configureUI(isRecording: false)
        
        audioRecorder.stop()
        do {
            try audioSession.setActive(false)
            
        } catch {
            print("Error! Failed to stop recoding AVAuidoSession")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI(isRecording: false)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    //prepare destination VC for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let vc = segue.destination as! PlaySoundsViewController
            let audioURL = sender as! URL
            vc.recordedAudioURL = audioURL
        }
    }
    
    //set UIButton states
    func configureUI(isRecording: Bool) {
        if isRecording {
            recordingLabel.text = "Now Recording"
            stopRecordingButton.isEnabled = true
            recordButton.isEnabled = false
        
        } else {
            recordingLabel.text = "Tap to Record"
            stopRecordingButton.isEnabled = false
            recordButton.isEnabled = true
        }
    }
    
    
    //MARK:- AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            
            //execute segue
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
            
        } else {
            print("Error! Audio recording failed.")
        }
    }
}

