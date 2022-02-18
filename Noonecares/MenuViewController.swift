//
//  MenuViewController.swift
//  Noonecares
//
//  Created by Lesterrry on 17.07.2021.
//

import Cocoa
import ORSSerial
import AVFoundation

class MenuViewController: NSViewController, ORSSerialPortDelegate {
    
    //*********************************************************************
    // MARK: STRUCTURES
    //*********************************************************************
    
    /// Universal routine step enum
    enum RoutineStep: Equatable {
        /// Checking two RoutineStep objects for equality
        /// - Parameters:
        ///   - lhs: Left-side object
        ///   - rhs: Right-side object
        /// - Returns: Whether two objects are equal
        static func == (lhs: MenuViewController.RoutineStep, rhs: MenuViewController.RoutineStep) -> Bool {
            switch lhs {
            case .Clock:
                if case .Clock = rhs { return true } else { return false }
            case .Text(let ltextStep):
                if case .Text(let rtextStep) = rhs { return ltextStep == rtextStep } else { return false }
            }
        }
        
        case Text(TextCycleStep)
        case Clock
        
        /// Step to use in main routine cycle
        struct TextCycleStep: Equatable {
            static func == (lhs: MenuViewController.RoutineStep.TextCycleStep, rhs: MenuViewController.RoutineStep.TextCycleStep) -> Bool {
                return lhs.text == rhs.text  // FIXME: Oh that's dumb af but I wont be using this anyway
            }
            
            /// Text to send to the device
            let text: String
            /// Color to paint the text. Pass String to the first element if specific coloring is being used, or NSColor to the second
            let color: (String?, NSColor?)
            /// Animation value. First element is the animation keyword, second is the delay.
            let animation: (String, Int)?
            /// Whether to apply fade animation
            var fade: Bool = false
        }
    }
    
    //*********************************************************************
    // MARK: OUTLETS & ACTIONS
    //*********************************************************************
    @IBOutlet weak var connectionStatusImageView: NSImageView!
    @IBOutlet weak var connectionStatusLabel: NSTextField!
    @IBOutlet weak var connectionStatusRefreshButton: NSButton!
    @IBAction func connectionStatusRefreshButtonClicked(_ sender: Any) {
        maintainConnection()
    }
    @IBOutlet weak var applianceStatusLabel: NSTextField!
    
    @IBOutlet weak var textModeButton: NSButton!
    @IBAction func textModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .text)
        insertTextToCycleRoutine()
    }
    @IBOutlet weak var textModeTextField: NSTextField!
    @IBAction func textModeTextFieldValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        insertTextToCycleRoutine()
    }
    @IBOutlet weak var textModeColorModePopUpButton: NSPopUpButton!
    @IBAction func textModeColorModePopUpButtonValueChanged(_ sender: Any) {
        suitTextCellColorWellEnabledState()
        setApplianceLabel(.notApplied)
        insertTextToCycleRoutine()
    }
    @IBOutlet weak var textModeColorWell: NSColorWell!
    @IBAction func textModeColorWellValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        insertTextToCycleRoutine()
    }
    @IBOutlet weak var textModeAnimationSegmentedControl: NSSegmentedControl!
    @IBAction func textModeAnimationSegmentedControlValueChanged(_ sender: Any) {
        suitTextCellAnimationControlsEnabledState()
        setApplianceLabel(.notApplied)
        insertTextToCycleRoutine()
    }
    @IBOutlet weak var textModeAnimationFadeButton: NSButton!
    @IBAction func textModeAnimationFadeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        insertTextToCycleRoutine()
    }
    @IBOutlet weak var textModeAnimationDelaySlider: NSSlider!
    @IBAction func textModeAnimationDelaySliderValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        updateTextModeAnimationDelayLabel()
        insertTextToCycleRoutine()
    }
    @IBOutlet weak var textModeAnimationDelayLabel: NSTextField!
    @IBOutlet weak var textModeCycleSwitch: NSSwitch!
    @IBAction func textModeCycleSwitchSwitched(_ sender: Any) {
        suitTextCellCycleElementsEnabledState()
        //insertTextToCycleRoutine(inserting: true)
    }
    @IBOutlet weak var textModeCycleProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var textModeCycleStepsLabel: NSTextField!
    @IBOutlet weak var textModeCycleStepsStepper: NSStepper!
    @IBAction func textModeCycleStepsStepperValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        updateTextModeCycleStepsLabel()
        applyTextCycleRoutineElement()
    }
    @IBOutlet weak var textModeCycleStepAddButton: NSButton!
    @IBAction func textModeCycleStepAddButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        textModeCycleStepsStepper.maxValue += 1
        textModeCycleStepsStepper.integerValue += 1
        updateTextModeCycleStepsLabel()
        insertTextToCycleRoutine(inserting: true)
    }
    @IBOutlet weak var textModeCycleStepRemoveButton: NSButton!
    @IBAction func textModeCycleStepRemoveButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        currentRoutineIndex = 0
        routine.remove(at: textModeCycleStepsStepper.integerValue)
        textModeCycleStepsStepper.maxValue -= 1
        textModeCycleStepsStepper.integerValue -= 1
        updateTextModeCycleStepsLabel()
    }
    @IBOutlet weak var textModeCycleStepsClearButton: NSButton!
    @IBAction func textModeCycleStepsClearButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        currentRoutineIndex = 0
        textModeCycleStepsStepper.maxValue = 0
        textModeCycleStepsStepper.integerValue = 0
        updateTextModeCycleStepsLabel()
        insertTextToCycleRoutine(clearing: true)
    }
    @IBOutlet weak var textModeCycleDelayTextField: NSTextField!
    @IBAction func textModeCycleDelayTextFieldValueChanged(_ sender: NSTextField) {
        setApplianceLabel(.notApplied)
        textModeCycleDelayStepper.stringValue = textModeCycleDelayTextField.stringValue
    }
    @IBOutlet weak var textModeCycleDelayStepper: NSStepper!
    @IBAction func textModeCycleDelayStepperValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        textModeCycleDelayTextField.stringValue = textModeCycleDelayStepper.stringValue
    }
    
    @IBOutlet weak var keyTraceModeButton: NSButton!
    @IBAction func keyTraceModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .keyTrace)
    }
    @IBOutlet weak var keyTraceModeColorModePopUpButton: NSPopUpButton!
    @IBAction func keyTraceModeColorModePopUpButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        suitKeyTraceCellColorWellEnabledState()
    }
    @IBOutlet weak var keyTraceModeColorWell: NSColorWell!
    @IBAction func keyTraceModeColorWellValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
    }
    
    @IBOutlet weak var CCPSModeButton: NSButton!
    @IBAction func CCPSModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .CCPS)
    }
    @IBOutlet weak var CCPSModeSequenceTextField: NSTextField!
    @IBOutlet weak var timerModeButton: NSButton!
    @IBAction func timerModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .timer)
    }
    @IBOutlet weak var timerModeTextField: NSTextField!
    @IBAction func timerModeTextFieldValueChanged(_ sender: NSTextField) {
        setApplianceLabel(.notApplied)
        timerModeStepper.stringValue = timerModeTextField.stringValue
        timerModeSlider.stringValue = timerModeTextField.stringValue
    }
    @IBOutlet weak var timerModeStepper: NSStepper!
    @IBAction func timerModeStepperValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        timerModeTextField.stringValue = timerModeStepper.stringValue
        timerModeSlider.stringValue = timerModeStepper.stringValue
    }
    @IBOutlet weak var timerModeSlider: NSSlider!
    @IBAction func timerModeSliderValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        timerModeTextField.stringValue = timerModeSlider.stringValue
        timerModeStepper.stringValue = timerModeSlider.stringValue
    }
    @IBOutlet weak var timerModeProgressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var pomodoroModeButton: NSButton!
    @IBAction func pomodoroModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .pomodoro)
    }
    @IBOutlet weak var pomodoroModeWorkTextField: NSTextField!
    @IBAction func pomodoroModeWorkTextFieldValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        pomodoroModeWorkStepper.stringValue = pomodoroModeWorkTextField.stringValue
    }
    @IBOutlet weak var pomodoroModeWorkStepper: NSStepper!
    @IBAction func pomodoroModeWorkStepperValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        pomodoroModeWorkTextField.stringValue = pomodoroModeWorkStepper.stringValue
    }
    @IBOutlet weak var pomodoroModeWorkProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var pomodoroModeRestTextField: NSTextField!
    @IBAction func pomodoroModeRestTextFieldValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        pomodoroModeRestStepper.stringValue = pomodoroModeRestTextField.stringValue
    }
    @IBOutlet weak var pomodoroModeRestStepper: NSStepper!
    @IBAction func pomodoroModeRestStepperValueChanged(_ sender: Any) {
        setApplianceLabel(.notApplied)
        pomodoroModeRestTextField.stringValue = pomodoroModeRestStepper.stringValue
    }
    @IBOutlet weak var pomodoroModeRestProgressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var clockModeButton: NSButton!
    @IBAction func clockModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .clock)
    }
    
    @IBOutlet weak var nowPlayingModeButton: NSButton!
    @IBAction func nowPlayingModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .nowPlaying)
    }
    
    @IBOutlet weak var offModeButton: NSButton!
    @IBAction func offModeButtonPressed(_ sender: Any) {
        setApplianceLabel(.notApplied)
        setMode(to: .off)
    }
    
    @IBAction func quitButtonPressed(_ sender: Any) {
        MenuViewController.keylogger.stop()
        exit(0)
    }
    @IBOutlet weak var customCommandButton: NSButton!
    @IBAction func setupButtonPressed(_ sender: Any) {
        let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "SetupWindowController") as! NSWindowController
        controller.showWindow(self)
    }
    @IBOutlet weak var applyButton: NSButton!
    @IBAction func applyButtonPressed(_ sender: Any) {
        composeAndExecuteCommand()
    }
    
    //*********************************************************************
    // MARK: VARS & CONSTS
    //*********************************************************************
    @objc private static var serialPort: ORSSerialPort!
    private static var player = AVAudioPlayer()
    public static var connectionState = SystemProperties.ConnectionState.disconnected
    public static var keylogger = Keylogger()
    public static var keyTraceColor: String?
    public static var systemCurrentMode = SystemProperties.Mode.off
    var systemTargetMode = SystemProperties.Mode.off
    var modeApplied = true
    var routineTimer: Timer?
    var routine: [RoutineStep] = []
    var currentRoutineIndex = 0
    var CCPSCustomPath: URL!
    
    var cycleValid: Bool {
        get {
            for i in routine {
                switch i {
                case .Clock: break
                case .Text(let textStep):
                    if textStep.text == "" { return false }
                }
            }
            return true
        }
    }
    //*********************************************************************
    // MARK: MAIN FUNCTIONS
    //*********************************************************************
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CCPSCustomPath = FileManager().homeDirectoryForCurrentUser.appendingPathComponent("Documents/Noonecares")
        insertTextToCycleRoutine(inserting: true)
    }
    
    override func viewDidAppear() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        maintainConnection()
    }
    
//    TODO: Receive errors from device
//    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
//        let string = String(data: data, encoding: .utf8)
//        print("Got \(string) from the serial port!")
//    }
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        setConnectionState(to: .disconnected)
    }
    
    /// Send a command to the device via serial port
    /// - Parameter command: Command to send to the device
    public static func sendCommand(_ command: String) {
        guard let d = command.data(using: .utf8) else {
            SystemMethods.log("No data to send")
            return
        }
        MenuViewController.serialPort.send(d)
    }
    
    /// Send key to the device
    /// - Parameter key: Key, received from keylogger
    public static func registerKeyloggerEvent(_ key: String) {
        guard let color = keyTraceColor, systemCurrentMode == .keyTrace else { return }
        MenuViewController.sendCommand("ACH<h\(key)<c\(color)/")
    }
    
    /// Do routine task
    @objc
    func performRoutine() {
        switch routine[currentRoutineIndex] {
        case .Text:
            composeAndExecuteCommand(from: routine[currentRoutineIndex])
        case .Clock:
            MenuViewController.sendCommand("CLK<t\(Calendar.current.currentTimeAsString())/")
        }
        if currentRoutineIndex < routine.count - 1 {
            currentRoutineIndex += 1
        } else {
            currentRoutineIndex = 0
        }
    }
    
    /// Connect to the device and set the state
    func maintainConnection() {
        if MenuViewController.connectionState == .connected {
            if !MenuViewController.serialPort.isOpen {
                setConnectionState(to: .disconnected)
            }
            return
        }
        guard let s = ORSSerialPort(path: NSUserDefaultsController.shared.defaults.string(forKey: "port") ?? "") else {
            setConnectionState(to: .disconnected)
            return
        }
        s.delegate = self
        s.baudRate = 115200
        MenuViewController.serialPort = s
        setConnectionState(to: .connected)
        MenuViewController.serialPort.open()
    }
    
    /// Create from cycle step and send a command to the matix
    /// - Parameter from: Cycle step to use
    func composeAndExecuteCommand(from: RoutineStep) {
        let command: String!
        switch from {
        case .Text(let textStep):
            let colorCompoment: String!
            if let s = textStep.color.0 {
                colorCompoment = s
            } else if let s = textStep.color.1 {
                colorCompoment = s.asString()
            } else {
                fatalError("Color error")
            }
            let animationComponent: String!
            if let s = textStep.animation {
                animationComponent = "\(s.0)<e\(s.1)"
            } else {
                animationComponent = ""
            }
            command = "RTX<t\(textStep.text)<c\(colorCompoment + (textStep.fade ? "<i" : "") + animationComponent)/"
        case .Clock:
            command = "CLK<t\(Calendar.current.currentTimeAsString())/"
        }
        MenuViewController.sendCommand(command)
        setApplianceLabel(.applied)
    }
    
    /// Create from UI and send a command to the matix
    func composeAndExecuteCommand() {
        stopAllAction()
        let command: String!
        switch systemTargetMode {
        case .text:
            guard textModeTextField.stringValue != "" else { setApplianceLabel(.corruptedParameters); return }
            if textModeCycleSwitch.state == .on && textModeCycleSwitch.isEnabled {
                guard cycleValid else { setApplianceLabel(.corruptedParameters); return }
                insertTextToCycleRoutine()
                routineTimer = Timer.scheduledTimer(
                    timeInterval: Double(textModeCycleDelayStepper.integerValue),
                    target: self,
                    selector: #selector(self.performRoutine), userInfo: nil, repeats: true)
                textModeCycleProgressIndicator.startAnimation(nil)
                return
            }
            let fadeComponent = (textModeAnimationFadeButton.state == .on && textModeAnimationFadeButton.isEnabled) ? "<i" : ""
            command = "RTX<t\(textModeTextField.stringValue)<c\(getColor(forMode: .text) + fadeComponent + (getTextAnimation(withDelay: true) ?? ""))/"
        case .keyTrace:
            MenuViewController.keyTraceColor = getColor(forMode: .keyTrace)
            MenuViewController.keylogger.start()
            command = "CLR/"
        case .CCPS:
            guard CCPSModeSequenceTextField.stringValue != "" else { setApplianceLabel(.corruptedParameters); return }
            let b = CCPSCustomPath.appendingPathComponent(CCPSModeSequenceTextField.stringValue + ".ccps")
            let fm = FileManager()
            if fm.fileExists(atPath: b.path) {
                do {
                    command = "CPS<s\(try String(contentsOf: b))/"
                } catch {
                    setApplianceLabel(.corruptedParameters)
                    return
                }
                let a = CCPSCustomPath.appendingPathComponent(CCPSModeSequenceTextField.stringValue + ".mp3")
                if fm.fileExists(atPath: a.path) {
                    MenuViewController.player = try! AVAudioPlayer(contentsOf: a)
                    MenuViewController.player.volume = 1.0
                    MenuViewController.player.play()
                }
            } else {
                command = "CPS<s\(CCPSModeSequenceTextField.stringValue)/"
            }
        case .clock:
            routineTimer = Timer.scheduledTimer(
                timeInterval: 30.0,
                target: self,
                selector: #selector(self.performRoutine), userInfo: nil, repeats: true)
            routine = [RoutineStep.Clock]
            command = "CLK<t\(Calendar.current.currentTimeAsString())/"
        case .off:
            command = "CLR/"
        default:
            setApplianceLabel("Not supported", NSColor.red)
            return
        }
        SystemMethods.log("Sending \(command!)...")
        MenuViewController.sendCommand(command)
        setApplianceLabel(.applied)
        MenuViewController.systemCurrentMode = systemTargetMode
    }
    
    /// Stops all recurring actions such as routine
    func stopAllAction() {
        if MenuViewController.systemCurrentMode == .keyTrace && systemTargetMode != .keyTrace {
            MenuViewController.keylogger.stop()
        }
        textModeCycleProgressIndicator?.stopAnimation(nil)
        routineTimer?.invalidate()
    }
    
    /// Insert current text cell parameters to routine array
    /// - Parameters:
    ///   - inserting: Whether to insert item in place
    ///   - clearing: Whether to clean the routine pre-add
    func insertTextToCycleRoutine(inserting: Bool = false, clearing: Bool = false) {
        if routine == [RoutineStep.Clock] { routine = []; currentRoutineIndex = 0 }
        var animationOut: (String, Int)? = nil
        if let animation = getTextAnimation(withDelay: false) {
            animationOut = (animation, textModeAnimationDelaySlider.integerValue)
        }
        let element = RoutineStep.Text(RoutineStep.TextCycleStep(text: textModeTextField.stringValue, color: getColor(forMode: .text), animation: animationOut, fade: (textModeAnimationFadeButton.isEnabled && textModeAnimationFadeButton.state == .on)))
        if inserting {
            routine.insert(element, at: textModeCycleStepsStepper.integerValue)
        } else if clearing {
            routine = [element]
        } else {
            routine[textModeCycleStepsStepper.integerValue] = element
        }
    }
    
    /// Apply current routine element's data to the UI
    func applyTextCycleRoutineElement() {
        guard case .Text(let textStep) = routine[textModeCycleStepsStepper.integerValue] else { return }
        textModeTextField.stringValue = textStep.text
        var itemIndex = 0
        if let s = textStep.color.0 {
            switch s {
            case "%RND%":
                itemIndex = 1
            case "%CHRND%":
                itemIndex = 2
            case "%TLL%":
                itemIndex = 3
            default: ()
            }
        }
        textModeColorModePopUpButton.selectItem(at: itemIndex)
        if let c = textStep.color.1 {
            textModeColorWell.color = c
        }
        textModeAnimationFadeButton.state = textStep.fade ? .on : .off
        if let a = textStep.animation {
            textModeAnimationDelaySlider.integerValue = a.1
            updateTextModeAnimationDelayLabel()
            var segmentIndex = 0
            switch a.0 {
            case "<a%BLI%":
                segmentIndex = 1
            case "<a%SCR%":
                segmentIndex = 2
            default: ()
            }
            textModeAnimationSegmentedControl.setSelected(true, forSegment: segmentIndex)
        } else {
            textModeAnimationSegmentedControl.setSelected(true, forSegment: 0)
        }
        suitTextCellColorWellEnabledState()
        suitTextCellAnimationControlsEnabledState()
    }
    
    /// Update text mode cell's cycle steps label according to current routine state
    func updateTextModeCycleStepsLabel() {
        textModeCycleStepsLabel.stringValue = "\(textModeCycleStepsStepper.integerValue + 1)/\(Int(textModeCycleStepsStepper.maxValue + 1))"
    }
    
    /// Update text mode cell's animation delay label according to delay slider value
    func updateTextModeAnimationDelayLabel() {
        textModeAnimationDelayLabel.stringValue = textModeAnimationDelaySlider.stringValue
    }
    
    /// Get text animation instance for the routine
    /// - Returns: Animation keyword, if exists, nil otherwise
    /// - Parameter withDelay: true if delay value should be appended to string
    func getTextAnimation(withDelay: Bool) -> String? {
        switch textModeAnimationSegmentedControl.indexOfSelectedItem {
        case 1:
            return withDelay ? "<a%BLI%<e\(textModeAnimationDelaySlider.stringValue)" : "<a%BLI%"
        case 2:
            return withDelay ? "<a%SCR%<e\(textModeAnimationDelaySlider.stringValue)" : "<a%SCR%"
        default:
            return nil
        }
    }
    
    /// Get color string for sending to the device
    /// - Returns: Color-respresenting string for the device
    /// - Parameter forMode: Cell to get data from. Only supports .text and .keyTrace
    func getColor(forMode: SystemProperties.Mode) -> String {
        let index = forMode == .text ? textModeColorModePopUpButton.indexOfSelectedItem : keyTraceModeColorModePopUpButton.indexOfSelectedItem
        switch index {
        case 1:
            return "%RND%"
        case 2:
            return "%CHRND%"
        case 3:
            return "%TLL%"
        default:
            let color = forMode == .text ? textModeColorWell.color.asString() : keyTraceModeColorWell.color.asString()
            return color
        }
    }
    
    /// Get color instance for the routine
    /// - Returns: String or NSColor packed in a tuple
    /// - Parameter forMode: Cell to get data from. Only supports .text and .keyTrace
    func getColor(forMode: SystemProperties.Mode) -> (String?, NSColor?) {
        let index = forMode == .text ? textModeColorModePopUpButton.indexOfSelectedItem : keyTraceModeColorModePopUpButton.indexOfSelectedItem
        switch index {
        case 1:
            return ("%RND%", nil)
        case 2:
            return ("%CHRND%", nil)
        case 3:
            return ("%TLL%", nil)
        default:
            let color = forMode == .text ? textModeColorWell.color : keyTraceModeColorWell.color
            return (nil, color)
        }
    }
    
    func getClippedCCPS(from: String) -> [String] {
        let skipMarkers = ["N"]
        var r = [""]
        var index = 0
        var counter = 0
        for i in from {
            counter += 1
            if counter >= 32 {
                counter = 0
                index += 1
            }
            r[index].append(i)
        }
        return r
    }
    
    /// Set system mode
    /// - Parameters:
    ///   - to: Mode to switch to
    ///   - forceModeButton: Whether to explicitly order the corresponding mode button to set its state to 'on'
    func setMode(to: SystemProperties.Mode, forceModeButton: Bool = false) {
        MenuViewController.player.stop()
        systemTargetMode = to
        setModeButtonsState(to: .off, except: to.rawValue, force: forceModeButton)
        setCellsEnabledState(to: false, except: to.rawValue, revert: true)
    }
    
    /// Set serial connection state
    /// - Parameter to: current connection state
    func setConnectionState(to: SystemProperties.ConnectionState) {
        MenuViewController.connectionState = to
        switch to {
        case .connected:
            connectionStatusLabel.stringValue = "Connected"
            connectionStatusLabel.textColor = NSColor.systemGreen
            connectionStatusImageView.image = NSImage(named: "NSStatusAvailable")
            applyButton.isEnabled = true
            connectionStatusRefreshButton.isHidden = true
        case .disconnected:
            connectionStatusLabel.stringValue = "Disconnected"
            connectionStatusLabel.textColor = NSColor.systemGray
            connectionStatusImageView.image = NSImage(named: "NSStatusNone")
            applyButton.isEnabled = false
            connectionStatusRefreshButton.isHidden = false
        }
    }
    
    /// Set appliance label to default state
    /// - Parameter isApplied: Whether to set the label to Applied state
    func setApplianceLabel(_ to: SystemProperties.ApplianceState) {
        switch to {
        case .applied:
            applianceStatusLabel.stringValue = ""
            applianceStatusLabel.textColor = NSColor.white
        case .notApplied:
            applianceStatusLabel.stringValue = "Not Applied"
            applianceStatusLabel.textColor = NSColor.white
        case .corruptedParameters:
            applianceStatusLabel.stringValue = "Check options"
            applianceStatusLabel.textColor = NSColor.systemRed
        }
    }
    
    /// Set appliance label to a specific string value and color
    /// - Parameters:
    ///   - to: String value to set the label to
    ///   - color: Color to paint the label in
    func setApplianceLabel(_ to: String, _ color: NSColor) {
        applianceStatusLabel.stringValue = to
        applianceStatusLabel.textColor = color
    }
    
    /// Set all mode buttons to a specific state
    /// - Parameters:
    ///   - to: State to set buttons to
    ///   - except: Index of the button to skip
    ///   - force: Explicitly set skipped button to the opposite state
    private func setModeButtonsState(to: NSControl.StateValue, except: Int? = nil, force: Bool = false) {
        let allModeButtons = [
            textModeButton,
            keyTraceModeButton,
            CCPSModeButton,
            timerModeButton,
            pomodoroModeButton,
            clockModeButton,
            nowPlayingModeButton,
            offModeButton
        ]
        for i in 0...allModeButtons.count - 1 {
            if let a = except, i == a { if force { allModeButtons[i]?.state = (to == .on ? .off : .on) }; continue }
            allModeButtons[i]?.state = to
        }
    }
    
    /// Set all mode cells to a specific enabled/disabled state
    /// - Parameters:
    ///   - to: Whether to enable the cells
    ///   - except: Index of the cell to skip
    ///   - revert: Explicitly set skipped cell to the opposite state
    private func setCellsEnabledState(to: Bool, except: Int? = nil, revert: Bool = false) {
        let allCells = [
            [
                textModeTextField,
                textModeColorWell,
                textModeAnimationSegmentedControl,
                textModeAnimationFadeButton,
                textModeCycleSwitch,
                textModeAnimationDelaySlider,
                textModeColorModePopUpButton,
                textModeCycleStepsStepper,
                textModeCycleStepAddButton,
                textModeCycleStepRemoveButton,
                textModeCycleStepsClearButton,
                textModeCycleDelayTextField,
                textModeCycleDelayStepper
            ],
            [
                keyTraceModeColorModePopUpButton
            ],
            [
                CCPSModeSequenceTextField
            ],
            [
                timerModeTextField,
                timerModeStepper,
                timerModeSlider
            ],
            [
                pomodoroModeWorkTextField,
                pomodoroModeWorkStepper,
                pomodoroModeRestTextField,
                pomodoroModeRestStepper,
            ]
        ]
        for i in 0...allCells.count - 1 {
            if let a = except, i == a {
                if revert {
                    for j in 0...allCells[i].count - 1 {
                        allCells[i][j]?.isEnabled = !to
                        if i == 0 && j == 6 {  // Animation Delay Slider and elements of the Cycle Cell must be set in a specific way
                            suitTextCellCycleElementsEnabledState()
                            suitTextCellAnimationControlsEnabledState()
                            suitTextCellColorWellEnabledState()
                            break
                        } else if i == 1 {  // So must be KeyTrace cell's Color Well
                            suitKeyTraceCellColorWellEnabledState()
                        }
                    }
                }
                continue
            }
            for j in allCells[i] {
                j?.isEnabled = to
            }
        }
    }
    
    /// Set Cycle Cell elements to a corresponding state
    private func suitTextCellCycleElementsEnabledState() {
        let allElements = [
            textModeCycleStepsStepper,
            textModeCycleStepAddButton,
            textModeCycleStepRemoveButton,
            textModeCycleStepsClearButton,
            textModeCycleDelayTextField,
            textModeCycleDelayStepper
        ]
        switch textModeCycleSwitch.state {
        case .off:
            for i in allElements {
                i?.isEnabled = false
            }
        case.on:
            for i in allElements {
                i?.isEnabled = true
            }
        default: ()
        }
    }
    
    /// Set Delay Slider and Fade Button to a corresponding state
    private func suitTextCellAnimationControlsEnabledState() {
        let b = textModeAnimationSegmentedControl.indexOfSelectedItem != 0
        textModeAnimationDelaySlider.isEnabled = b
        textModeAnimationFadeButton.isEnabled = !b
    }
    
    /// Set Text cell's Color Well to a corresponding state
    private func suitTextCellColorWellEnabledState() {
        textModeColorWell.isEnabled = textModeColorModePopUpButton.indexOfSelectedItem == 0
    }
    
    /// Set KeyTrace cell's Color Well to a corresponding state
    private func suitKeyTraceCellColorWellEnabledState() {
        keyTraceModeColorWell.isEnabled = keyTraceModeColorModePopUpButton.indexOfSelectedItem == 0
    }
    
}

//*********************************************************************
// MARK: EXTENSIONS
//*********************************************************************
extension MenuViewController {
    /// Receive a functional instance of the Menu View Controller
    /// - Returns: Functional instance of the Menu View Controller
    static func freshController() -> MenuViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("MenuViewController")
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? MenuViewController else {
            fatalError("No controller found")
    }
        return viewController
    }
}

extension NSColor {
    /// Get command-formatted string representing specific color
    /// - Returns: Command-formatted string
    func asString() -> String {
        return "\(Int(self.redComponent * 255)),\(Int(self.greenComponent * 255)),\(Int(self.blueComponent * 255))"
    }
}

extension Calendar {
    /// Get command-formatted string representing current date and time
    /// - Returns: Command-formatted string
    func currentTimeAsString() -> String {
        let date = Date()
        let hour = self.component(.hour, from: date)
        let minute = self.component(.minute, from: date)
        let second = self.component(.second, from: date)
        let day = self.component(.day, from: date)
        let month = self.component(.month, from: date)
        let year = self.component(.year, from: date)
        return "\(hour),\(minute),\(second),\(day),\(month),\(year)"
    }
}
