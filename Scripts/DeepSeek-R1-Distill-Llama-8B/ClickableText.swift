// ClickableText.swift
import SwiftUI

// Custom class to mimic MonoBehaviour
class ClickableText: Identifiable {
    @IBOutlet private var textComponent: Text
    @IBOutlet private var clickableText: ClickableText
    private var originalColor: Color
    private var hoverColor: Color
    private var sceneName: String
    private var soundClip: AudioClip?
    private var outputMixer: AudioMixerGroup?
    private var audioSource: AudioSource?
    private var isButtonOn = false

    // Initialize the component
    init() {
        originalColor = textComponent.color
        audioSource = gameObject.addComponent(type: AudioSourceComponent.self)
        if let source = audioSource {
            source.outputAudioMixerGroup = outputMixer
        }
    }

    // Handle pointer enter
    public func onPointerEnter(_ event: PointerEvent) {
        if let source = audioSource {
            source.playOneShot(soundClip)
        }
        textComponent.color = hoverColor
        isButtonOn = true
    }

    // Handle pointer exit
    public func onPointerExit(_ event: PointerEvent) {
        textComponent.color = originalColor
        isButtonOn = false
    }

    // Handle pointer click
    public func onPointerClick(_ event: PointerEvent) {
        if let sceneManager = SceneManager {
            sceneManager.loadScene(sceneName)
        }
    }

    // MARK: - Platform-specific Input Handling

    // macOS: Handle mouse events
    func handleMouseEvents() {
        let mouseDown = MainWindow.mainWindow?.target(for: .mouseDown, in: .mainMenu)
        let mouseUp = MainWindow.mainWindow?.target(for: .mouseUp, in: .mainMenu)
        
        if let mouseDown = mouseDown {
            mouseDown.addEvent(.pointerDown { _ in
                onPointerEnter(nil)
            })
            mouseDown.addEvent(.pointerDrag { _ in
                if isButtonOn && !textComponent.color == hoverColor {
                    onPointerEnter(nil)
                }
            })
            mouseDown.addEvent(.pointerUp { _ in
                onPointerExit(nil)
            })
        }
        if let mouseUp = mouseUp {
            mouseUp.addEvent(.pointerUp { _ in
                onPointerExit(nil)
            })
        }
    }

    // iOS: Handle touch events
    func handleTouchEvents() {
        let view = MainWindow.mainWindow?.mainContent?.view
        view?.addGestureRecognizer(GestureRecognizer(
            target: self,
            action: #selector(onPointerClick(_:)),
            forControlEvents: [.touchUpInside]
        ))
    }

    // VisionOS: Handle gaze input
    func handleGazeInput() {
        // TODO [Migrate] - Implement gaze input handling for VisionOS
    }

    // Initialize platform-specific input handling
    public func initializePlatformInputs() {
        // macOS
        handleMouseEvents()
        
        // iOS
        handleTouchEvents()
        
        // VisionOS
        handleGazeInput()
    }
}