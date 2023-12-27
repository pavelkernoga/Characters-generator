//
//  CharactersListView.swift
//  TestCombine+RestAPI
//
//  Created by pavel on 21.11.23.
//

import Foundation
import UIKit
import Combine

class CharactersListView: UIViewController {
    
    @IBOutlet weak var getCharactersButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusPicker: UIPickerView!
    @IBOutlet weak var charactersTableView: UITableView!
    
    private let viewModel = CharactersViewModel()
    private var charactersNames = ["rick", "morty"]
    private var genderArray = ["female", "male", "genderless", "unknown"]
    private var statusArray = ["alive", "dead", "unknown"]
    private var receivedCharacters: [String]?
    
    @Published var characterName: String = ""
    
    private var validatedName: AnyPublisher<String?, Never> {
        return $characterName
            .receive(on: RunLoop.main)
            .map { name in
                if !self.charactersNames.filter({ $0 == name }).isEmpty {
                    return name
                }
                return nil
            }
            .eraseToAnyPublisher()
    }
    
    private var nameSubscriber: AnyCancellable?
    private var charactersSubscriber = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupDelegates()
        // binding
        setupSubscriptions()
    }
    
    private func configureUI() {
        nameLabel.text = "Name(rick or morty):"
        nameLabel.font = .systemFont(ofSize: 20)
        nameLabel.textAlignment = .center
        
        genderLabel.text = "Gender:"
        genderLabel.font = .systemFont(ofSize: 20)
        genderLabel.textAlignment = .center
        
        statusLabel.text = "Status:"
        statusLabel.font = .systemFont(ofSize: 20)
        statusLabel.textAlignment = .center
        
        charactersTableView.backgroundColor = .systemGray6
        charactersTableView.layer.cornerRadius = 10
        
        getCharactersButton.layer.cornerRadius = 10
        getCharactersButton.setTitle("Get characters", for: .normal)
    }
    
    private func setupDelegates() {
        nameTextField.delegate = self
        genderPicker.delegate = self
        genderPicker.dataSource = self
        statusPicker.delegate = self
        statusPicker.dataSource = self
        charactersTableView.delegate = self
        charactersTableView.dataSource = self
    }
    
    private func setupSubscriptions() {
        // validate "Get characters" button
        nameSubscriber = validatedName
            .map { $0 != nil }
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: getCharactersButton)
        
        // update table view with received names
        viewModel.$names
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] names in
                if names.count != .zero && names != self?.receivedCharacters {
                    self?.receivedCharacters = names
                    UIView.animate(withDuration: 1) {
                        self?.charactersTableView.reloadData()
                    }
                }
            }
            .store(in: &charactersSubscriber)
    }
    
    @IBAction func getCharactersButtonTapped(_ sender: Any) {
        receivedCharacters?.removeAll()
        viewModel.getCharactersData(
            name: characterName,
            gender: genderArray[genderPicker.selectedRow(inComponent: 0)],
            status: statusArray[statusPicker.selectedRow(inComponent: 0)]
        )
    }
}

extension CharactersListView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText = textField.text ?? ""
        let text = (textFieldText as NSString).replacingCharacters(in: range, with: string)
        
        if textField == nameTextField {
            characterName = text
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
}

extension CharactersListView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == genderPicker ? genderArray.count : statusArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == genderPicker ? genderArray[row] : statusArray[row]
    }
}

extension CharactersListView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfRow = receivedCharacters?.count else { return .zero }
        return numberOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        if let characters = receivedCharacters {
            cell.textLabel?.text = characters[indexPath.row]
        }
        return cell
    }
}
