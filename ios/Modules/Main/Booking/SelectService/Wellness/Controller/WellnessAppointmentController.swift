//
//  WellnessAppointmentController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/20.
//

import UIKit

class ServiceFormModel {
  enum FormType {
    case Select
    case TextInput
  }
  var placeHolder:String = ""
  var title:String = ""
  var rightImage:UIImage?
  var type:FormType = .Select
  var sel:String = ""
  
  init(placeHolder:String,rightImage:UIImage?,sel:String,title:String = "",type:FormType = .Select) {
    self.placeHolder = placeHolder
    self.title = title
    self.rightImage = rightImage
    self.type = type
    self.sel = sel
    
  }
}

class WellnessAppointmentController: BaseTableController {
  enum WellnessType {
    case DateTime
    case Therapist
  }
  
  var headLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size: 24)
  }
  var headView = UIView().then { view in
    view.backgroundColor = .white
  }
  var footView = BookingServiceFormFooterView.loadViewFromNib()
  var type:WellnessType = .DateTime
  
  var models:[ServiceFormModel] = []
  
  var companyModels:[CompanyModel] = []
  var selectCompany:CompanyModel?
  
  var serviceModels:[BookingServiceModel] = []
  var selectedService:BookingServiceModel?
  
  var dutyDateModels:[BookingDutyDateModel] = []
  var selectedDate:BookingDutyDateModel?
  
  convenience init(type: WellnessType) {
    self.init()
    self.type = type
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = R.color.theamBlue()
    headView.addSubview(headLabel)
    headLabel.text = type == .DateTime ? "Select By Preferred Slot" : "Select By Preferred Therapist"
    headLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.top.equalToSuperview().offset(32)
    }
    
    if type == .DateTime {
      models = [
        ServiceFormModel(placeHolder: "Select Outlet", rightImage: R.image.booking_form_dropdown(), sel: "selectOutlet"),
        ServiceFormModel(placeHolder: "Select Service", rightImage: R.image.booking_form_dropdown(), sel: "selectService"),
        ServiceFormModel(placeHolder: "Select Date", rightImage: R.image.booking_form_calendar(), sel: "selectDate"),
        ServiceFormModel(placeHolder: "Select Time Slot", rightImage: R.image.booking_form_dropdown(), sel: "selectTimeSlot"),
        ServiceFormModel(placeHolder: "Additional Note", rightImage: nil, sel: "additionalNote"),
      ]
    }else {
      models = [
        ServiceFormModel(placeHolder: "Select Outlet", rightImage: R.image.booking_form_dropdown(), sel: "selectOutlet"),
        ServiceFormModel(placeHolder: "Select Service", rightImage: R.image.booking_form_dropdown(), sel: "selectService"),
        ServiceFormModel(placeHolder: "Select Therapist", rightImage: R.image.booking_form_dropdown(), sel: "selectTherapist"),
        ServiceFormModel(placeHolder: "Select Date", rightImage: R.image.booking_form_calendar(), sel: "selectDate"),
        ServiceFormModel(placeHolder: "Select Time Slot", rightImage: R.image.booking_form_dropdown(), sel: "selectTimeSlot"),
        ServiceFormModel(placeHolder: "Additional Note", rightImage: nil, sel: "additionalNote"),
      ]
    }
  }
  
  override func createListView() {
    super.createListView()
    
    tableView?.separatorColor = R.color.line()
    tableView?.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    tableView?.separatorStyle = .singleLine
    
    tableView?.tableHeaderView = headView
    headView.size = CGSize(width: kScreenWidth, height: 84)
    
    tableView?.tableFooterView = footView
    footView.size = CGSize(width: kScreenWidth, height: 188)
    
    tableView?.register(cellWithClass: BookingServiceFormCell.self)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView?.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    models.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    63
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: BookingServiceFormCell.self)
    cell.model = models[indexPath.row]
    cell.selectionStyle = .none
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let model = models[indexPath.row]
    if model.type == .TextInput { return }
    let sel = NSSelectorFromString(model.sel)
    if self.responds(to: sel) {
      self.perform(sel)
    }
  }
  
  
}

extension WellnessAppointmentController {
  @objc func selectOutlet() {
    
    if companyModels.count > 0 {
      showCompanySheetView()
    }else {
      getCanOnlineBookingLocation()
    }
    
  }
  @objc func selectService() {
    if selectCompany == nil {
      Toast.showMessage("Please Select a outlet")
      return
    }
    getServiceByLocation()
  }
  @objc func selectTherapist() {
    
  }
  @objc func selectDate() {
    if selectCompany == nil {
      Toast.showMessage("Please Select a outlet")
      return
    }
    if selectedService == nil {
      Toast.showMessage("Please Select a therapist")
      return
    }
    
  }
  @objc func selectTimeSlot() {
    
  }
  @objc func additionalNote() {
    
  }
  
  func getCanOnlineBookingLocation() {
    
    Toast.showLoading()
    
    let params = SOAPParams(action: .Company, path: .getCanOnlineBookingLocations)
    params.set(key: "pId", value: Defaults.shared.get(for: .companyId) ?? "")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(CompanyModel.self, from: data) {
        self.companyModels = models
        self.showCompanySheetView()
      }
      Toast.dismiss()
    } errorHandler: { e in
      Toast.dismiss()
    }

  }
  
  func showCompanySheetView() {
    let strs = self.companyModels.map({ $0.alias_name.isEmpty ? $0.name : $0.alias_name })
    BookingServiceFormSheetView.show(dataArray: strs, type: .Outlet) { index in
      self.selectCompany = self.companyModels[index]
      self.models[0].title = self.companyModels[index].alias_name
      self.tableView?.reloadData()
    }
  }
  
  func getServiceByLocation() {
    Toast.showLoading()
    let params = SOAPParams(action: .Schedule, path: .getServicesByLocation)
    params.set(key: "locationId", value: selectCompany?.id ?? "")
    params.set(key: "isWellness", value: "1")
    params.set(key: "gendar", value: Defaults.shared.get(for: .userModel)?.gender ?? "")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(BookingServiceModel.self, from: data) {
        self.serviceModels = models
        
        if self.serviceModels.count == 0 {
          Toast.showMessage("No siutable service")
          return
        }
        self.showServiceSheetView()
      }
      Toast.dismiss()
    } errorHandler: { e in
      Toast.dismiss()
    }

  }
  
  func showServiceSheetView() {
    
    if self.serviceModels.count == 1 {
      self.selectedService = self.serviceModels[0]
      self.models[1].title = self.selectedService?.alias_name ?? ""
      self.tableView?.reloadData()
      return
    }
    
    let strs = self.serviceModels.map({ $0.alias_name })
    BookingServiceFormSheetView.show(dataArray: strs, type: .Service) { index in
      self.selectedService = self.serviceModels[index]
      self.models[1].title = self.selectedService?.alias_name ?? ""
      self.tableView?.reloadData()
    }
  }
  
  func getDocSchedulesForService() {
    Toast.showLoading()
    let params = SOAPParams(action: .Schedule, path: .getDocSchedulesForService)
    params.set(key: "locationId", value: selectCompany?.id ?? "")
    params.set(key: "serviceId", value: selectedService?.id ?? "")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(BookingDutyDateModel.self, from: data) {
        self.dutyDateModels = models
        self.showDateSheetView()
      }
      Toast.dismiss()
    } errorHandler: { e in
      Toast.showMessage("There is no right date")
    }

  }
  
  func showDateSheetView() {
    
  }
}
