import UIKit
import CoreBluetooth

class ScanViewController: UIViewController {
  @IBOutlet weak var scanButton: UIBarButtonItem!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var advertiseButton: UIBarButtonItem!
  
  var peripherals = [CBPeripheral]()
  
  let centralManager = CBCentralManager()
  let peripheralManager = CBPeripheralManager()
  var service = CBMutableService(type: CBUUID(string: "88888888-4444-4444-4444-121212121212"), primary: true)
  var characteristic: CBMutableCharacteristic?
  var serviceUUID = CBUUID(string: "88888888-4444-4444-4444-121212121212")
  var characteristicUUID = CBUUID(string: "88888888-4444-4444-4444-121212121213")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    peripheralManager.delegate = self
    centralManager.delegate = self
  }
  
  @IBAction func didTapScanButton(_ sender: Any) {
    if centralManager.isScanning {
      centralManager.stopScan()
      scanButton.title = "Scan"
    } else {
      centralManager.scanForPeripherals(withServices: [], options: [:])
      scanButton.title = "Stop Scan"
    }
  }
  
  @IBAction func didTapAdvertiseButton(_ sender: Any) {
    if peripheralManager.isAdvertising {
      peripheralManager.stopAdvertising()
      advertiseButton.title = "Advertise"
    } else {
      let advertisementData: [String: Any] = [
        CBAdvertisementDataLocalNameKey: "LETHINH",
        CBAdvertisementDataServiceUUIDsKey : [service.uuid],
      ]
      peripheralManager.startAdvertising(advertisementData)
      advertiseButton.title = "Stop Advertise"
    }
  }
}

extension ScanViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return peripherals.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    let peripheral = peripherals[indexPath.row]
    cell.textLabel?.text = peripheral.name ?? "Unknown"
    cell.detailTextLabel?.text = "\(peripheral.state)"
    return cell
  }
}

extension ScanViewController: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
    case .poweredOff:
      print("central.state is .poweredOff")
    case .unknown:
      print("central.state is .unknown")
    case .resetting:
      print("central.state is .resetting")
    case .unsupported:
      print("central.state is .unsupported")
    case .unauthorized:
      print("central.state is .unauthorized")
    case .poweredOn:
      print("central.state is .poweredOn")
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    if !peripherals.contains(where: { $0.identifier == peripheral.identifier }) {
      print("===========================")
      for (key, value) in advertisementData {
        print("\(key): \(value)")
      }
      let indexPath = IndexPath(row: peripherals.count, section: 0)
      peripherals.append(peripheral)
      tableView.insertRows(at: [indexPath], with: .automatic)
    }
  }
}

extension ScanViewController: CBPeripheralManagerDelegate {
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    switch peripheral.state {
    case .poweredOff:
      print("peripheral.state is .poweredOff")
    case .unknown:
      print("peripheral.state is .unknown")
    case .resetting:
      print("peripheral.state is .resetting")
    case .unsupported:
      print("peripheral.state is .unsupported")
    case .unauthorized:
      print("peripheral.state is .unauthorized")
    case .poweredOn:
      print("peripheral.state is .poweredOn")
      let data = "LeThinh".data(using: .utf8, allowLossyConversion: false)
      let chrateristic = CBMutableCharacteristic(type: characteristicUUID, properties: .read, value: data, permissions: .readable)
      service.characteristics = [chrateristic] as [CBCharacteristic]
      peripheralManager.add(service)
    }
  }
  
  func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
      if let error = error {
          print("PerformerUtility.publishServices() returned error: \(error.localizedDescription)")
        print("Providing the reason for failure: \(error.localizedFailureReason ?? "")")
      }
  }
  
  func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
    if let error = error {
      print(error.localizedDescription)
      peripheral.stopAdvertising()
      advertiseButton.title = "Advertise"
    } else {
      print("Did start advertising")
    }
  }
}
