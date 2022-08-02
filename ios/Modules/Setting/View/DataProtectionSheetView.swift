//
//  PrivacyPolicySheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/1.
//

import UIKit
import SwiftEntryKit
@objcMembers
class DataProtectionSheetView: UIView,UITableViewDelegate,UITableViewDataSource {
  private var titleLabel = UILabel().then { label in
    label.text = "Data Protection Notice"
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size:24)
    label.lineHeight = 36
  }
  private var tableView:UITableView?
  private var datas:[DataProtectionModel] = []
  private var headView = DataProtectionHeadView.loadViewFromNib()
  private var menuView = DataProtectionSectionMenuView()
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .white
    configTableview()
    addSubview(titleLabel)
    addSubview(headView)
    addSubview(menuView)
    menuView.alpha = 0
    headView.selectSectionHandler = { [weak self] (isShow) in
      guard let `self` = self else { return }
      if isShow {
        UIView.animate(withDuration: 0.2) {
          self.menuView.alpha = 1
        }
      }else {
        UIView.animate(withDuration: 0.2) {
          self.menuView.alpha = 0
        }
      }
    }
    menuView.menuSelectHandler = { [weak self] model in
      self?.headView.setTitle(model.title)
      self?.headView.setSelectStatus()
      let row = self?.datas.firstIndex(where: { $0.id == model.id }) ?? 0
      self?.tableView?.scrollToRow(at: IndexPath(row: row, section: 0), at: .top, animated: false)
      UIView.animate(withDuration: 0.2) {
        self?.menuView.alpha = 0
      }
    }
    
    
    let model1 = DataProtectionModel(title: "COLLECTION, USE AND DISCLOSURE OF PERSONAL DATA ",
                                     content: "1.That I give permission to Chien Chi Tow Healthcare Pte Ltd (CCT) to collect, use, disclose or otherwise process said personal data in accordance with the Personal Data Protection Act (PDPA). By signing this consent form, I acknowledge that these terms apply to all my personal data currently in possession by CCT.\n\n" +
                                      "2.That CCT shall seek my consent before collecting any additional personal data and before using my personal data for a purpose which I have not been notified to (except where permitted or authorised by law).\n\n" +
                                      "3.That CCT may from time to time use my personal data for (but not confined to) the following purposes:\n\n" +
                                      "a.performing obligations in the  course of/or  in connection with our provision of the goods and/or services requested by myself;\n" +
                                      "b.verifying my identity;\n" +
                                      "c.responding to, handling, and processing queries, requests, applications, complaints, and feedback from myself;\n" +
                                      "d.managing my relationship with CCT;\n" +
                                      "e.processing payment or credit transactions;\n" +
                                      "f.sending information about CCT’s activities/Membership Rewards/events/news;\n" +
                                      "g.complying with any applicable laws, regulations, codes of practice, guidelines, or rules, or to assist in law enforcement and investigations conducted by any governmental and/or regulatory authority;\n" +
                                      "h.any other purposes for which I have provided the information;\n" +
                                      "i.transmitting to any unaffiliated third parties including our third-party service providers and agents, and relevant governmental and/or regulatory authorities, whether in Singapore or abroad, for the aforementioned purposes; \n" +
                                      "j.any other incidental business purposes related to or in connection with the above.\n\n" +
                                      "4. CCT may disclose my personal data:a) where such disclosure is required for performing obligations in the course of or in connection with CCT’s provision of the goods or services requested by myself; or b)to third party service providers, agents and other organisations CCT have engaged to perform any of the functions listed above for me.",
                                     id: 1)
    let model2 = DataProtectionModel(title: "WITHDRAWAL OF CONSENT ",
                                     content: "5.I acknowledge that I have the right to withdraw my consent for use of any personal data that falls outside said Membership matters. My request will be processed within ten (10) business days of CCT receiving a written request made out to enquiry@chienchitow.com the Withdrawal of Consent Form.\n\n" +
                                      "6.I understand that depending on the nature and scope of my request, CCT may not be in a position to continue providing its goods or services to me and they shall, in such circumstances, notify me before completing the processing of said request. Should I decide to cancel my withdrawal of consent, I will do so in writing in the manner described in clause 5 above.\n\n" +
                                      "7.I acknowledge that withdrawal of consent does not affect CCT’s right to continue to collecting, using and disclosing personal data where such collection, use and disclosure without consent is permitted or required under applicable laws.",
                                     id: 2)
    let model3 = DataProtectionModel(title: "ACCESS TO AND CORRECTION OF PERSONAL DATA ",
                                     content: "8.I may make...\n" +
                                      " (a) an access request for access to a copy of the persona data which CCT holds of me, or information about the ways in which CCT uses or discloses my personal data, or\n" +
                                      " (b) a correction request to correct or update any of my personal data which CCT holds about me. I can do so by submitting a request in writing or via email using the Access Request Form or the Personal Particulars Update Form to CCT at the contact details provided in this document.\n\n" +
                                      "9.CCT will respond to my request as soon as reasonably possible. Should CCT not be able to respond within thirty (30) days after receiving my request, they shall inform me in writing within said thirty (30) days period. If CCT is unable to provide me with any personal data or to make a correction requested by myself, they shall generally inform me of the reasons why said request was unable to be processed (except where they are not required to under the PDPA). I understand that this access/correction process may incur a reasonable fee, of which CCT will inform me before processing the request.\n\n" +
                                      "10. I acknowledge that it is important to keep my personal data as current, complete and accurate as possible, and will ensure to update CCT if and when there are changes to my personal data through the relevant Particulars Update form.",
                                     id: 3)
    let model4 = DataProtectionModel(title: "PROTECTION OF PERSONAL DATA ",
                                     content: "11. CCT holds the security of my personal data at utmost importance and has set in place safeguards to prevent unauthorised access, collection, use, disclosure, copying, modification, disposal or similar risks. CCT has introduced appropriate administrative, physical and technical measures such as up-to-date antivirus protection, encryption and the use of privacy filters to secure all storage and transmission of personal data by us, and disclosing personal data both internally and to our authorised third-party service providers and agents only on a need-to-know basis. All hardcopy personal data is stored securely. Data files are stored in locked cabinets at all time, unless being accessed by authorised staff for processing purposes.\n\n" +
                                      "12. I am aware, however, that no method of transmission over the Internet or method of electronic storage is completely secure. While security cannot be guaranteed, CCT strives to protect the security of my information and is constantly reviewing and enhancing its information security measures.",
                                     id: 4)
    let model5 = DataProtectionModel(title: "RETENTION OF PERSONAL DATA ",
                                     content: "13.CCT will retain my personal information for as long as it is necessary to my membership with the Company. Upon the termination or transfer of my Membership, I acknowledge that CCT will keep my records on file for a further 5 calendar years for auditing and tracing purposes. After which, said documents will be destroyed in accordance with PDPA regulations.",
                                     id: 5)
    let model6 = DataProtectionModel(title: "TRANSFER OF PERSONAL DATA OUTSIDE OF SINGAPORE ",
                                     content: "14. CCT generally does not transfer personal data to 3rd parties outside of Singapore. However, from time to time (in line with certain activities or reciprocal arrangements) the Company may require sharing of my data, but will ensure to obtain my consent before said data is shared. CCT will take steps to ensure that my personal data received the standard of protection comparable to that provided under the PDPA.",
                                     id: 6)
    let model7 = DataProtectionModel(title: "EFFECT OF NOTICE AND CHANGES TO NOTICE ",
                                     content: "15.This Notice applies in conjunction with any other notices, contractual clauses and consent clauses that apply in relation to the collection, use and disclosure of my personal data by CCT.\n\n" +
                                      "16. CCT may revise this Notice from time to time without any notice",
                                     id: 7)
    let model8 = DataProtectionModel(title: "DATA PROTECTION OFFICER  ",
                                     content: "You may contact our Data Protection Officer if you have any enquiries or feedback on our personal data protection policies and procedures, or if you wish to make any request, in the following manner:\n\n" +
                                      "Hotline: 62933 933\n" + "Email: enquiry@chienchitow.com" ,
                                     id: 8)
    
    datas.append(model1)
    datas.append(model2)
    datas.append(model3)
    datas.append(model4)
    datas.append(model5)
    datas.append(model6)
    datas.append(model7)
    datas.append(model8)
    
    tableView?.reloadData()
    menuView.datas = datas
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    corner(byRoundingCorners:  [.topLeft,.topRight], radii: 16)
    titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(24)
    }
    headView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(32)
      make.left.right.equalToSuperview()
      make.height.equalTo(46)
    }
    menuView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(headView.snp.bottom)
    }
    tableView?.snp.makeConstraints({ make in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(headView.snp.bottom).offset(32)
    })
  }
  
  func configTableview() {
    
    tableView = UITableView.init(frame: .zero, style: .plain)
    
    tableView?.delegate = self
    tableView?.dataSource = self
    
    tableView?.separatorStyle = .none
    tableView?.backgroundColor = .white
    tableView?.showsHorizontalScrollIndicator = false
    tableView?.showsVerticalScrollIndicator = false
    tableView?.tableFooterView = UIView.init()
    
    //
    tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    
    
    addSubview(tableView!)
    
    tableView?.register(cellWithClass: DataProtectionCell.self)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    datas[indexPath.row].rowHeight
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return datas.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: DataProtectionCell.self)
    cell.selectionStyle = .none
    if datas.count > 0 {
      cell.model = datas[indexPath.row]
    }
    
    return cell
  }
  
  static func show() {
    let view = DataProtectionSheetView()
    let size = CGSize(width: kScreenWidth, height: kScreenHeight - kNavBarHeight * 1.5)
    SwiftEntryKit.displayView(asSheet: view, size: size)
  }
 
}

class DataProtectionCell: UITableViewCell {
  var model:DataProtectionModel! {
    didSet {
      titleLabel.text = model.title
      contentLabel.text = model.content
    }
  }
  var contentLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name:.AvenirNextRegular,size:16)
    label.lineHeight = 24
    label.numberOfLines = 0
  }
  var titleLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name: .AvenirNextDemiBold, size:16)
    label.lineHeight = 24
    label.numberOfLines = 0
  }
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(titleLabel)
    contentView.addSubview(contentLabel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.top.equalToSuperview().offset(16)
    }
    
    contentLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.bottom.greaterThanOrEqualToSuperview().offset(-16)
      make.top.equalTo(titleLabel.snp.bottom).offset(32)
    }
    contentLabel.setContentCompressionResistancePriority(751, for: .vertical)
  }
}


class DataProtectionSectionMenuView:UIView,UITableViewDelegate,UITableViewDataSource {
  private var tableView:UITableView?
  var menuSelectHandler:((DataProtectionModel)->())?
  var datas:[DataProtectionModel] = [] {
    didSet {
      tableView?.reloadData()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .white
    
    configTableview()
  
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    corner(byRoundingCorners:  [.topLeft,.topRight], radii: 16)
   
    tableView?.snp.makeConstraints({ make in
      make.left.right.bottom.equalToSuperview()
      make.top.equalToSuperview()
    })
  }
  
  func configTableview() {
    
    tableView = UITableView.init(frame: .zero, style: .plain)
    
    tableView?.delegate = self
    tableView?.dataSource = self
    
    tableView?.separatorStyle = .singleLine
    tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    tableView?.separatorColor = R.color.line()
    tableView?.backgroundColor = .white
    tableView?.showsHorizontalScrollIndicator = false
    tableView?.showsVerticalScrollIndicator = false
    tableView?.tableFooterView = UIView.init()
    
    tableView?.rowHeight = UITableView.automaticDimension
    tableView?.estimatedRowHeight = 40
    
    //
    tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    
    
    addSubview(tableView!)
    
    tableView?.register(cellWithClass: UITableViewCell.self)
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return datas.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
    cell.selectionStyle = .none
    cell.textLabel?.font = UIFont(name: .AvenirNextDemiBold, size:16)
    cell.textLabel?.numberOfLines = 0
    cell.textLabel?.textColor = R.color.black333()
    cell.textLabel?.text = datas[indexPath.row].title
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if datas.count == 0 { return }
    let model = datas[indexPath.row]
    menuSelectHandler?(model)
  }
 
}
