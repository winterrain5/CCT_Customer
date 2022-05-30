//
//  EditProfileViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/1.
//

import UIKit
import IQKeyboardManagerSwift
class EditProfileViewController: BaseViewController {

  private var container = EditProfileContainer.loadViewFromNib()
  private var scrollView = UIScrollView()
  
  private var saveButton = LoadingButton().then { btn in
    btn.cornerRadius = 22
    btn.backgroundColor = R.color.theamRed()
    btn.titleColorForNormal = .white
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    btn.titleForNormal = "Save"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    self.view.addSubview(scrollView)
    scrollView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    scrollView.contentSize = CGSize(width: kScreenWidth, height: 774)
    scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 96 + kBottomsafeAreaMargin, right: 0)
    
    scrollView.addSubview(container)
    container.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 774)
    
    self.view.addSubview(saveButton)
    saveButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.height.equalTo(44)
      make.bottom.equalToSuperview().inset(32 + kBottomsafeAreaMargin)
    }
    
    saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
    
    IQKeyboardManager.shared.enableAutoToolbar = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    IQKeyboardManager.shared.enableAutoToolbar = false
    
  }

  @objc func saveButtonAction() {
    let model = container.editModel
    
    if model.firstName.isEmpty {
      Toast.showMessage("Please input First Name")
      return
    }
    
    if model.lastName.isEmpty {
      Toast.showMessage("Please input Last Name")
      return
    }
    
    if model.postCode.isEmpty {
      Toast.showMessage("Please fill in the Postal Code")
      return
    }
    
    if model.streetName.isEmpty {
      Toast.showMessage("Please fill in the Street Name")
      return
    }
    
    if model.buildingNum.isEmpty {
      Toast.showMessage("Please fill in the Building/Block Number")
      return
    }
    
    
    let params = SOAPParams(action: .Client, path: .changeClientInfo)
    let data = SOAPDictionary()
    data.set(key: "id", value: Defaults.shared.get(for: .clientId) ?? "")
    data.set(key: "first_name", value: model.firstName)
    data.set(key: "last_name", value: model.lastName)
    data.set(key: "gender", value: model.gender)
    data.set(key: "birthday", value: model.birthday)
    data.set(key: "post_code", value: model.postCode)
    data.set(key: "street_name", value: model.streetName)
    data.set(key: "building_block_num", value: model.buildingNum)
    data.set(key: "unit_num", value: model.unitNum)
    data.set(key: "city", value: model.city)
    data.set(key: "cct_or_mp", value: model.isCustomer)
    data.set(key: "source", value: "1")
    
    params.set(key: "data", value: data.result,type: .map(1))
    
    saveButton.startAnimation()
    NetworkManager().request(params: params) { data in
      NotificationCenter.default.post(name: .nativeNotification, object: nil ,userInfo: ["type":"UserDataChanged"])
      Toast.showSuccess(withStatus: "Edit Profile successfully")
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.navigationController?.popViewController()
      }
      self.saveButton.stopAnimation()
    } errorHandler: { e in
      self.saveButton.stopAnimation()
    }

  }

}
