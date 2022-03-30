import React, {
  Component
} from 'react';
import {
  SafeAreaView,
  Platform,
  StyleSheet,
  Text,
  View,
  ImageBackground,
  Image,
  TextInput,
  FlatList,
  Button,
  TouchableOpacity,
  TouchableHighlight,
  ScrollView,
  StatusBar,
  AsyncStorage,
  StackAction,
  NavigationActions,
  DeviceEventEmitter,
  Dimensions
} from 'react-native';

import TitleBar from '../../../widget/TitleBar';

import ProgressBar from '../../../widget/ProgressBar';

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import { Loading } from '../../../widget/Loading';

import { toastShort } from '../../../uitl/ToastUtils';

import DateUtil from '../../../uitl/DateUtil';

import DeviceStorage from '../../../uitl/DeviceStorage';

import IparInput from '../../../widget/IparInput';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import CheckBox from 'react-native-check-box'

import StringUtils from '../../../uitl/StringUtils';

import {Card} from 'react-native-shadow-cards';




export default class SettingActivity extends Component {

  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       client_settings:undefined,
       categories:undefined,
    }
  }


  UNSAFE_componentWillMount(){

    DeviceStorage.get('head_company_id').then((company_id) => {

      if (company_id) {
        this.setState({
            head_company_id: company_id,
          });
      }else {
        this.setState({
            head_company_id: '97',
          });

      }
    });

    DeviceStorage.get('UserBean').then((user_bean) => {

      this.setState({
          userBean: user_bean,
      });

      this.getClientSettings(user_bean);
    });


    this.getCategories();

  }


  getCategories(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getCategories id="o0" c:root="1" xmlns:n0="http://terra.systems/" /></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('blog','getCategoriesResponse',data, function(json) {


        if (json && json.success == 1 ) {
           
            temporary.setState({

              categories:json.data,

            });
        }

    });


  }


getClientSettings(userBean){


   var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
   '<v:Header />'+
   '<v:Body><n0:getClientSettings id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
   '<clientId i:type="d:string">'+ userBean.id + '</clientId>'+
   '</n0:getClientSettings></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('client','getClientSettingsResponse',data, function(json) {


        if (json && json.success == 1 ) {
           
            temporary.setState({

              client_settings:json.data,

            });
        }

    });


}


changeClientPartInfo(client_settings){

  var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
  '<v:Header />'+
  '<v:Body><n0:changeClientPartInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
  '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
  '<item><key i:type="d:string">inbox_content</key><value i:type="d:string">'+ (this.state.client_settings && this.state.client_settings.inbox_content ? this.state.client_settings.inbox_content : '[]') +'</value></item>'+
  '<item><key i:type="d:string">sync_phone_calendar</key><value i:type="d:string">'+ (this.state.client_settings && this.state.client_settings.sync_phone_calendar == '1' ? '1' : '0') +'</value></item>'+
  '<item><key i:type="d:string">send_notification_by</key><value i:type="d:string">'+ (this.state.client_settings && this.state.client_settings.send_notification_by == '2' ? '2' : '0') +'</value></item>'+
  '<item><key i:type="d:string">blog_content</key><value i:type="d:string">'+  (this.state.client_settings && this.state.client_settings.blog_content ? this.state.client_settings.blog_content : '[]') +'</value></item>'+
  '<item><key i:type="d:string">send_notification_by_en</key><value i:type="d:string">'+ (this.state.client_settings && this.state.client_settings.send_notification_by_en == '1' ? '1' : '0') +'</value></item>'+
  '</data>'+
  '<logData i:type="n2:Map" xmlns:n2="http://xml.apache.org/xml-soap">'+
  '<item><key i:type="d:string">ip</key><value i:type="d:string"></value></item>'+
  '<item><key i:type="d:string">create_uid</key><value i:type="d:string">23855</value></item>'+
  '</logData>'+
  '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
  '</n0:changeClientPartInfo></v:Body></v:Envelope>';
  var temporary = this;
  WebserviceUtil.getQueryDataResponse('client','changeClientPartInfoResponse',data, function(json) {


  });

}  




clickLanguage(){


  // 根据传入的方法渲染并弹出
  this.coverLayer.showWithContent(
              ()=> {
                  return (
                      <View style={styles.view_popup_bg}>


                        <Text style = {styles.text_popup_title}>Select Language</Text>




                        <TouchableOpacity 
                            style = {{width:'100%'}}  
                            activeOpacity = {0.8}
                            onPress={this.clickLanguageEnglish.bind(this)}>


                             <View style = {[styles.view_language,{marginTop:24}]}>


                                  <Text style = {styles.text_language_title}>English</Text>


                                   <Image style = {{width:20,height:20,marginTop:5}} 
                                          resizeMode = 'contain' 
                                          source={this.state.client_settings && this.state.client_settings.send_notification_by_en == '1' ? require('../../../../images/selected_526.png') : undefined}/>


                              </View>

                       </TouchableOpacity>     


                        <TouchableOpacity 
                            style = {{width:'100%'}}  
                            activeOpacity = {0.8}
                            onPress={this.clickLanguageChinese.bind(this)}>


                             <View style = {styles.view_language}>

                                  <Text style = {styles.text_language_title}>Chinese</Text>

                                  <Image style = {{width:20,height:20,marginTop:5}} 
                                          resizeMode = 'contain' 
                                          source={this.state.client_settings && this.state.client_settings.send_notification_by_en != '1' ? require('../../../../images/selected_526.png') : undefined}/>

                              </View>

                        </TouchableOpacity>     

                      </View>
                  )
              },
          ()=>this.coverLayer.hide(),
          CoverLayer.popupMode.bottom);



}


clickLanguageEnglish(){


  this.coverLayer.hide();

  var client_settings = this.state.client_settings;

  client_settings.send_notification_by_en = '1';


  this.setState({
    client_settings:client_settings,
  });

  this.changeClientPartInfo(client_settings);
}

clickLanguageChinese(){

  this.coverLayer.hide();

  var client_settings = this.state.client_settings;

  client_settings.send_notification_by_en = '0';


  this.setState({
    client_settings:client_settings,
  });

   this.changeClientPartInfo(client_settings);

}


clickNotification(){


  if (this.state.client_settings && this.state.client_settings.send_notification_by) {


     var client_settings = this.state.client_settings;

    if (client_settings.send_notification_by == '2') {

      client_settings.send_notification_by = '0';

    }else {

      client_settings.send_notification_by = '2';
    }

    this.setState({
      client_settings:client_settings,
    });

    this.changeClientPartInfo(client_settings);


  }

}


clickCalendar(){

  if (this.state.client_settings && this.state.client_settings.sync_phone_calendar) {


    var client_settings = this.state.client_settings;

    if (client_settings.sync_phone_calendar == '1') {

      client_settings.sync_phone_calendar = '0';

    }else {

      client_settings.sync_phone_calendar = '1';
    }

    this.setState({
      client_settings:client_settings,
    });

    this.changeClientPartInfo(client_settings);

  }


} 


clickInbox(){

  // 根据传入的方法渲染并弹出
  this.coverLayer.showWithContent(
              ()=> {
                  return (
                      <View style={styles.view_popup_bg}>


                        <Text style = {styles.text_popup_title}>Filter Inbox</Text>


                        <View style = {[styles.view_language,{marginTop:24}]}>


                            <Text style = {styles.text_language_title}>Articles</Text>


                            <TouchableOpacity 
                        
                              activeOpacity = {0.8}
                              onPress={this.clickInboxItem.bind(this,'1')}>


                              <Image style = {{width:30,height:19,marginTop:5}} 
                                  resizeMode = 'contain' 
                                  source={this.isInBox('1') ? require('../../../../images/switch_on.png') : require('../../../../images/switch_off.png')}/>


                             </TouchableOpacity>     
                    
                         </View>



                        <View style = {[styles.view_language,{marginTop:0}]}>


                            <Text style = {styles.text_language_title}>News Events</Text>


                            <TouchableOpacity 
                        
                              activeOpacity = {0.8}
                              onPress={this.clickInboxItem.bind(this,'2')}>


                              <Image style = {{width:30,height:19,marginTop:5}} 
                                  resizeMode = 'contain' 
                                  source={this.isInBox('2') ? require('../../../../images/switch_on.png') : require('../../../../images/switch_off.png')}/>


                             </TouchableOpacity>     
                    
                         </View>


                         <View style = {[styles.view_language,{marginTop:0}]}>


                            <Text style = {styles.text_language_title}>Promotions</Text>


                            <TouchableOpacity 
                        
                              activeOpacity = {0.8}
                              onPress={this.clickInboxItem.bind(this,'3')}>


                              <Image style = {{width:30,height:19,marginTop:5}} 
                                  resizeMode = 'contain' 
                                  source={this.isInBox('3') ? require('../../../../images/switch_on.png') : require('../../../../images/switch_off.png')}/>


                             </TouchableOpacity>     
                    
                         </View>


                         <View style = {[styles.view_language,{marginTop:0}]}>


                            <Text style = {styles.text_language_title}>Madam Partum</Text>


                            <TouchableOpacity 
                        
                              activeOpacity = {0.8}
                              onPress={this.clickInboxItem.bind(this,'4')}>


                              <Image style = {{width:30,height:19,marginTop:5}} 
                                  resizeMode = 'contain' 
                                  source={this.isInBox('4') ? require('../../../../images/switch_on.png') : require('../../../../images/switch_off.png')}/>


                             </TouchableOpacity>     
                    
                         </View>


                         

                        
                            
                      </View>
                  )
              },
          ()=>this.coverLayer.hide(),
          CoverLayer.popupMode.bottom);

}


isInBox(id){


  var isInbox = false;

  if (this.state.client_settings && this.state.client_settings.inbox_content) {

     var inbox_content = JSON.parse(this.state.client_settings.inbox_content,'utf-8')

     for (var i = 0; i < inbox_content.length; i++) {
        var box_id = inbox_content[i];

        if (id == box_id) {

          isInbox = true;

          break;

        }

    }

  }


  return isInbox;


} 



clickInboxItem(id){


  if (this.state.client_settings && this.state.client_settings.inbox_content) {

     var client_settings = this.state.client_settings;
     var inbox_content = JSON.parse(this.state.client_settings.inbox_content,'utf-8');

    if (this.isInBox(id)) {

      for (var i = 0; i < inbox_content.length; i++) {
        if (inbox_content[i] == id ) {
          inbox_content.splice(i,1);
          break;
        }
      }
    }else {

       inbox_content.push(id);
    }

     client_settings.inbox_content = JSON.stringify(inbox_content);

     this.setState({
      client_settings:client_settings,
     });

      this.changeClientPartInfo(client_settings);

  }

} 




clickBlog(){

  // 根据传入的方法渲染并弹出
  this.coverLayer.showWithContent(
              ()=> {
                  return (
                      <View style={styles.view_popup_bg}>


                        <Text style = {styles.text_popup_title}>Blog Content</Text>

                         <FlatList
                            style = {styles.flat_popup}
                            ref = {(flatList) => this._flatList = flatList}
                            renderItem = {this._blog_renderItem}
                            onEndReachedThreshold={0}
                            keyExtractor={(item, index) => index.toString()}
                            data={this.state.categories}/>

                               
                      </View>
                  )
              },
          ()=>this.coverLayer.hide(),
          CoverLayer.popupMode.bottom);
}



_blog_renderItem = (item) => {

  return (

      <View style = {{width:'100%'}}>

           <View style = {[styles.view_language,{marginTop:0,width:'100%',paddingTop:0}]}>


              <Text style = {[styles.text_language_title]}>{item.item.key_word}</Text>


              <TouchableOpacity 
              
                activeOpacity = {0.8}
                onPress={this.clickBlogItem.bind(this,item)}>


                <Image style = {{width:30,height:19,marginTop:15}} 
                    resizeMode = 'contain' 
                    source={this.isInBlog(item) ? require('../../../../images/switch_on.png') : require('../../../../images/switch_off.png')}/>


               </TouchableOpacity>     
      
           </View>



          <View style = {[styles.view_line,{marginTop:0}]} />    



      </View>


  );

}


isInBlog(item){

  var isInblog = false;

  if (this.state.client_settings && this.state.client_settings.blog_content) {

     var blog_content = JSON.parse(this.state.client_settings.blog_content,'utf-8');

     for (var i = 0; i < blog_content.length; i++) {
       if (blog_content[i] == item.item.id) {
          isInblog = true;
          break;
       }
     }


  }


  return isInblog;


}


clickBlogItem(item){

  if (this.state.client_settings && this.state.client_settings.blog_content) {

     var client_settings = this.state.client_settings;
     var blog_content = JSON.parse(this.state.client_settings.blog_content,'utf-8');

    if (this.isInBlog(item)) {

      for (var i = 0; i < blog_content.length; i++) {
        if (blog_content[i] == item.item.id ) {
          blog_content.splice(i,1);
          break;
        }
      }
    }else {

       blog_content.push(item.item.id);
    }

     client_settings.blog_content = JSON.stringify(blog_content);

     this.setState({
      client_settings:client_settings,
     });


    this.changeClientPartInfo(client_settings);

  }

}



clickPrivacy(){

     // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title,{marginBottom:32}]}>Data Protection Notice</Text>

                          
                          <ScrollView style = {styles.scrollview}
                            showsVerticalScrollIndicator = {false}
                            contentOffset={{x: 0, y: 0}}
                            onScroll={this.changeScroll}>

                            <View style = {styles.scrollview}>

                              <Text style = {[styles.text_popup_data_title]}>COLLECTION, USE AND DISCLOSURE OF PERSONAL DATA</Text>

                              <Text style = {styles.text_popup_data_cotent}>1.That I give permission to Chien Chi Tow Healthcare Pte Ltd (CCT) to collect, use, disclose or otherwise process said personal data in accordance with the Personal Data Protection Act (PDPA). By signing this consent form, I acknowledge that these terms apply to all my personal data currently in possession by CCT.</Text>

                              <Text style = {styles.text_popup_data_cotent}>2.That CCT shall seek my consent before collecting any additional personal data and before using my personal data for a purpose which I have not been notified to (except where permitted or authorised by law).</Text>

                              <Text style = {styles.text_popup_data_cotent}>3.That CCT may from time to time use my personal data for (but not confined to) the following purposes:</Text>

                              <Text style = {styles.text_popup_data_cotent}>a.performing obligations in the  course of/or  in connection with our provision of the goods and/or services requested by myself;</Text>

                              <Text style = {styles.text_popup_data_cotent}>b.verifying my identity;</Text>

                              <Text style = {styles.text_popup_data_cotent}>c.responding to, handling, and processing queries, requests, applications, complaints, and feedback from myself;</Text>

                              <Text style = {styles.text_popup_data_cotent}>d.managing my relationship with CCT;</Text>

                              <Text style = {styles.text_popup_data_cotent}>e.processing payment or credit transactions;</Text>

                              <Text style = {styles.text_popup_data_cotent}>f.sending information about CCT’s activities/Membership Rewards/events/news;</Text>

                              <Text style = {styles.text_popup_data_cotent}>g.complying with any applicable laws, regulations, codes of practice, guidelines, or rules, or to assist in law enforcement and investigations conducted by any governmental and/or regulatory authority;</Text>

                              <Text style = {styles.text_popup_data_cotent}>h.any other purposes for which I have provided the information;</Text>

                              <Text style = {styles.text_popup_data_cotent}>i.transmitting to any unaffiliated third parties including our third-party service providers and agents, and relevant governmental and/or regulatory authorities, whether in Singapore or abroad, for the aforementioned purposes; and</Text>

                              <Text style = {styles.text_popup_data_cotent}>j.any other incidental business purposes related to or in connection with the above.</Text>

                              <Text style = {styles.text_popup_data_cotent}>4. CCT may disclose my personal data:a) where such disclosure is required for performing obligations in the course of or in connection with CCT’s provision of the goods or services requested by myself; or b)to third party service providers, agents and other organisations CCT have engaged to perform any of the functions listed above for me.</Text>

                              <Text style = {styles.text_popup_data_title}>WITHDRAWAL OF CONSENT</Text>

                              <Text style = {styles.text_popup_data_cotent}>5.I acknowledge that I have the right to withdraw my consent for use of any personal data that falls outside said Membership matters. My request will be processed within ten (10) business days of CCT receiving a written request made out to enquiry@chienchitow.com the Withdrawal of Consent Form.</Text>

                              <Text style = {styles.text_popup_data_cotent}>6.I understand that depending on the nature and scope of my request, CCT may not be in a position to continue providing its goods or services to me and they shall, in such circumstances, notify me before completing the processing of said request. Should I decide to cancel my withdrawal of consent, I will do so in writing in the manner described in clause 5 above</Text>

                              <Text style = {styles.text_popup_data_cotent}>7.I acknowledge that withdrawal of consent does not affect CCT’s right to continue to collecting, using and disclosing personal data where such collection, use and disclosure without consent is permitted or required under applicable laws.</Text>

                              <Text style = {styles.text_popup_data_title}>ACCESS TO AND CORRECTION OF PERSONAL DATA</Text>

                              <Text style = {styles.text_popup_data_cotent}>8.I may make...</Text>

                              <Text style = {styles.text_popup_data_cotent}>(a) an access request for access to a copy of the persona data which CCT holds of me, or information about the ways in which CCT uses or discloses my personal data, or</Text>

                              <Text style = {styles.text_popup_data_cotent}>(b) a correction request to correct or update any of my personal data which CCT holds about me. I can do so by submitting a request in writing or via email using the Access Request Form or the Personal Particulars Update Form to CCT at the contact details provided in this document.</Text>

                              <Text style = {styles.text_popup_data_cotent}>9.CCT will respond to my request as soon as reasonably possible. Should CCT not be able to respond within thirty (30) days after receiving my request, they shall inform me in writing within said thirty (30) days period. If CCT is unable to provide me with any personal data or to make a correction requested by myself, they shall generally inform me of the reasons why said request was unable to be processed (except where they are not required to under the PDPA). I understand that this access/correction process may incur a reasonable fee, of which CCT will inform me before processing the request.</Text>

                              <Text style = {styles.text_popup_data_cotent}>10. I acknowledge that it is important to keep my personal data as current, complete and accurate as possible, and will ensure to update CCT if and when there are changes to my personal data through the relevant Particulars Update form.</Text>

                              <Text style = {styles.text_popup_data_title}>PROTECTION OF PERSONAL DATA</Text>

                              <Text style = {styles.text_popup_data_cotent}>11. CCT holds the security of my personal data at utmost importance and has set in place safeguards to prevent unauthorised access, collection, use, disclosure, copying, modification, disposal or similar risks. CCT has introduced appropriate administrative, physical and technical measures such as up-to-date antivirus protection, encryption and the use of privacy filters to secure all storage and transmission of personal data by us, and disclosing personal data both internally and to our authorised third-party service providers and agents only on a need-to-know basis. All hardcopy personal data is stored securely. Data files are stored in locked cabinets at all time, unless being accessed by authorised staff for processing purposes</Text>

                              <Text style = {styles.text_popup_data_cotent}>12. I am aware, however, that no method of transmission over the Internet or method of electronic storage is completely secure. While security cannot be guaranteed, CCT strives to protect the security of my information and is constantly reviewing and enhancing its information security measures.</Text>

                              <Text style = {styles.text_popup_data_title}>RETENTION OF PERSONAL DATA</Text>

                              <Text style = {styles.text_popup_data_cotent}>13.CCT will retain my personal information for as long as it is necessary to my membership with the Company. Upon the termination or transfer of my Membership, I acknowledge that CCT will keep my records on file for a further 5 calendar years for auditing and tracing purposes. After which, said documents will be destroyed in accordance with PDPA regulations.</Text>

                              <Text style = {styles.text_popup_data_title}>TRANSFER OF PERSONAL DATA OUTSIDE OF SINGAPORE</Text>

                              <Text style = {styles.text_popup_data_cotent}>14. CCT generally does not transfer personal data to 3rd parties outside of Singapore. However, from time to time (in line with certain activities or reciprocal arrangements) the Company may require sharing of my data, but will ensure to obtain my consent before said data is shared. CCT will take steps to ensure that my personal data received the standard of protection comparable to that provided under the PDPA.</Text>

                              <Text style = {styles.text_popup_data_title}>EFFECT OF NOTICE AND CHANGES TO NOTICE</Text>

                              <Text style = {styles.text_popup_data_cotent}>15.This Notice applies in conjunction with any other notices, contractual clauses and consent clauses that apply in relation to the collection, use and disclosure of my personal data by CCT.</Text>

                              <Text style = {styles.text_popup_data_cotent}>16. CCT may revise this Notice from time to time without any notice.</Text>

                              <Text style = {styles.text_popup_data_title}>DATA PROTECTION OFFICER</Text>

                              <Text style = {styles.text_popup_data_cotent}>ou may contact our Data Protection Officer if you have any enquiries or feedback on our personal data protection policies and procedures, or if you wish to make any request, in the following manner:</Text>

                              <Text style = {[styles.text_popup_data_cotent]}>Hotline: 62933 933</Text>

                              <Text style = {[styles.text_popup_data_cotent,{marginTop:16,marginBottom:56}]}>Email: enquiry@chienchitow.com</Text>


                            </View>


                            </ScrollView>

                        

                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);
 

} 


clickTerms(){

   // 根据传入的方法渲染并弹出

  this.coverLayer.showWithContent(
              ()=> {
                  return (
                      <View style={styles.view_popup_bg}>


                        <Text style = {styles.text_popup_title}>Terms & conditions</Text>


                        <Text style = {[styles.text_popup_terms_content,{marginTop:32}]}>You can invite your friends by sending them your unique referral link provided by this feature in the Chien Chi Tow app via email, SMS, WhatsApp or other messaging platforms.</Text>


                        <Text style = {[styles.text_popup_terms_content]}>Your friends must use the link you send them to install the app and sign-up to receive their $5.00 CCT voucher, which will be automatically added to your app wallet.</Text>


                        <Text style = {[styles.text_popup_terms_content]}>When you utilises your friend's referral credit, they will receive $5.00 CCT voucher that will be automatically added in their app wallet.</Text>


                        <Text style = {[styles.text_popup_terms_content]}>Voucher can be utilised without minimum spend restrictions.</Text>

                        
                        <Text style = {[styles.text_popup_terms_content]}>Voucher cannot be used in conjunction with any other offers or vouchers.</Text>

                        <Text style = {[styles.text_popup_terms_content]}>Vouchers will expire 31 days after they are issued to you.</Text>


                        <Text style = {[styles.text_popup_terms_content]}>You will receive vouchers for up to 10 people you invite and who successfully utilises their credits.</Text>


                        <Text style = {[styles.text_popup_terms_content]}>You can view all vouchers you’ve accumulated in "My Wallet"</Text>


                        <Text style = {[styles.text_popup_terms_content,{marginBottom:32}]}>Chien Chi Tow reserves the right to update these terms and conditions with effect for the future at any time.</Text>


                                 
            
                      </View>
                  )
              },
          ()=>this.coverLayer.hide(),
          CoverLayer.popupMode.bottom);

}




render() {

    const { navigation } = this.props;



    var inbox_nams = '';

    if (this.state.client_settings && this.state.client_settings.inbox_content) {


      var inbox_content = JSON.parse(this.state.client_settings.inbox_content,'utf-8');


      for (var i = 0; i < inbox_content.length; i++) {
        var box_id = inbox_content[i];

        var box_name = '123';

        if (box_id == '1') {
          box_name = 'Articles';
        }else if (box_id == '2') {
          box_name = 'News Events';
        }else if (box_id == '3') {
          box_name = 'Promotions';
        }else if (box_id == '4') {
          box_name = "Madam Partum";
        }
        if (inbox_nams == '') {
          inbox_nams += box_name;
        }else {

          inbox_nams += (',' + box_name);

        }

      }

    }


    var categories = '';


    if (this.state.client_settings && this.state.client_settings.blog_content && this.state.categories) {

      var blog_content = JSON.parse(this.state.client_settings.blog_content,'utf-8');

      for (var i = 0; i < blog_content.length; i++) {
        var blog_id = blog_content[i];

        for (var j = 0; j < this.state.categories.length; j++) {
          var categorie = this.state.categories[j];

          if (blog_id == categorie.id) {

            if (categories == '') {

              categories += categorie.key_word;

            }else {

              categories += (',' + categorie.key_word);

            }

          }

        }

      }

    }

    return(

      <View style = {styles.bg}>

        <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

        <SafeAreaView style = {styles.afearea} >

           <TitleBar
              title = {''} 
              navigation={navigation}
              hideLeftArrow = {true}
              hideRightArrow = {false}
              extraData={this.state}/>


          <View style = {styles.view_content}>


            <ScrollView style = {styles.scrollview}
              contentOffset={{x: 0, y: 0}}>


              <Text style = {styles.text_title}>Settings</Text>


              <View style = {styles.view_line} />



              <TouchableOpacity 
                  style = {{width:'100%'}}  
                  activeOpacity = {0.8}
                  onPress={this.clickLanguage.bind(this)}>


                   <View style = {styles.view_item}>

                        <View style = {styles.view_item_head}>

                            <Text style = {styles.text_item_title}>Language</Text>


                            <Image style = {{width:8,height:13,marginTop:5}} 
                                    resizeMode = 'contain' 
                                    source={require('../../../../images/you.png')}/>

                        </View>

                        <Text style = {styles.text_item_content}>{this.state.client_settings && this.state.client_settings.send_notification_by_en == '1' ? 'English' : 'Chinese' }</Text>

                    </View>


              </TouchableOpacity>    

             



               <View style = {[styles.view_line,{marginTop:0}]} />



              <View style = {styles.view_item}>


                  <View style = {styles.view_item_head}>

                      <Text style = {styles.text_item_title}>Notification</Text>


                      <TouchableOpacity 
                        activeOpacity = {0.8}
                        onPress={this.clickNotification.bind(this)}>

                          <Image style = {{width:30,height:19,marginTop:5}} 
                              resizeMode = 'contain' 
                              source={this.state.client_settings && this.state.client_settings.send_notification_by == '2' ? require('../../../../images/switch_on.png') : require('../../../../images/switch_off.png')}/>


                      </TouchableOpacity>  


                    

                  </View>


                  <Text style = {styles.text_item_content}>{this.state.client_settings && this.state.client_settings.send_notification_by == '2' ? 'Notification alerts is turned on' : 'Notification alerts is turned off'}</Text>



              </View>



              <View style = {[styles.view_line,{marginTop:0}]} />



              <View style = {styles.view_item}>


                  <View style = {styles.view_item_head}>

                      <Text style = {styles.text_item_title}>Sync Phone Calendar</Text>



                      <TouchableOpacity 
                        activeOpacity = {0.8}
                        onPress={this.clickCalendar.bind(this)}>


                         <Image style = {{width:30,height:19,marginTop:5}} 
                              resizeMode = 'contain' 
                              source={this.state.client_settings && this.state.client_settings.sync_phone_calendar == '1' ? require('../../../../images/switch_on.png') : require('../../../../images/switch_off.png')}/>



                      </TouchableOpacity>   


                  </View>


                  <Text style = {styles.text_item_content}>{this.state.client_settings && this.state.client_settings.sync_phone_calendar == '1' ? 'App is currently in sync' : 'App is not currently in sync'}</Text>



              </View>



              <View style = {[styles.view_line,{marginTop:0}]} />



               <TouchableOpacity 
                  style = {{width:'100%'}}
                  activeOpacity = {0.8}
                  onPress={this.clickInbox.bind(this)}>


                   <View style = {styles.view_item}>


                      <View style = {styles.view_item_head}>

                          <Text style = {styles.text_item_title}>Inbox Content</Text>


                          <Image style = {{width:8,height:13,marginTop:5}} 
                                  resizeMode = 'contain' 
                                  source={require('../../../../images/you.png')}/>

                      </View>

                      <Text style = {styles.text_item_content}>{inbox_nams}</Text>

                  </View>


              </TouchableOpacity>    



              <View style = {[styles.view_line,{marginTop:0}]} />



               <TouchableOpacity 
                  style = {{width:'100%'}}
                  activeOpacity = {0.8}
                  onPress={this.clickBlog.bind(this)}>


                  <View style = {styles.view_item}>


                      <View style = {styles.view_item_head}>

                          <Text style = {styles.text_item_title}>Blog Content</Text>


                          <Image style = {{width:8,height:13,marginTop:5}} 
                                  resizeMode = 'contain' 
                                  source={require('../../../../images/you.png')}/>

                      </View>

                      <Text style = {styles.text_item_content}>{categories}</Text>

                  </View>


              </TouchableOpacity>    


              <View style = {[styles.view_line,{marginTop:0}]} />


               <TouchableOpacity 
                  style = {{width:'100%'}}
                  activeOpacity = {0.8}
                  onPress={this.clickPrivacy.bind(this)}>


                    <View style = {styles.view_item}>

                        <View style = {styles.view_item_head}>

                            <Text style = {styles.text_item_title}>Privacy Policy</Text>

                            <Image style = {{width:8,height:13,marginTop:5}} 
                                    resizeMode = 'contain' 
                                    source={require('../../../../images/you.png')}/>

                        </View>

                    </View>


              </TouchableOpacity>    


              <View style = {[styles.view_line,{marginTop:0}]} />


              <TouchableOpacity 
                  style = {{width:'100%'}}
                  activeOpacity = {0.8}
                  onPress={this.clickTerms.bind(this)}>


                   <View style = {styles.view_item}>

                      <View style = {styles.view_item_head}>

                          <Text style = {styles.text_item_title}>Terms and Conditions</Text>


                          <Image style = {{width:8,height:13,marginTop:5}} 
                                  resizeMode = 'contain' 
                                  source={require('../../../../images/you.png')}/>


                      </View>

                  </View>

              </TouchableOpacity>    


              <View style = {styles.view_version}>


                  <Text style = {styles.text_version}>Version 23.1.30-21</Text>

                  <Text style = {[styles.text_version,{marginTop:4}]}>Chien Chi Tow Healthcare Pte Ltd</Text>



              </View>


            </ScrollView>  


          </View>   


        </SafeAreaView>


        <SafeAreaView style = {styles.afearea_foot} />


       <CoverLayer ref={ref => this.coverLayer = ref}/>



      </View>


    );

  }

}


const styles = StyleSheet.create({
  bg: {
    flex:1,
    backgroundColor:'#FFFFFF'
  },
   afearea:{
    flex:1,
    backgroundColor:'#145A7C'
  },
  afearea_foot:{
    flex:0,
    backgroundColor:'#FFFFFF'
  },
   view_content:{
    flex:1,
    backgroundColor:'#FFFFFF',
    paddingTop:24,
    paddingBottom:24,
  },
  text_title:{
    marginLeft:24,
    fontSize:24,
    fontWeight: 'bold',
    color: '#145A7C',
  },
  view_line:{
    backgroundColor:'#e0e0e0',
    width:'100%',
    height: 1,
    marginTop:24,
  },
  view_item:{
    width:'100%',
    paddingTop:16,
    paddingBottom:16,
    paddingLeft:24,
    paddingRight:24,
  },
  view_item_head:{
     width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  text_item_title:{
    fontSize:16,
    fontWeight: 'bold',
    color: '#333333',
  },
  text_item_content:{
    marginTop:4,
     fontSize:14,
     color: '#828282',
  },
  view_version:{
    width:'100%',
    justifyContent: 'center',
    alignItems: 'center',
    paddingTop:40,
    paddingBottom:53,
  },
  text_version:{
    fontSize:14,
     color: '#828282',
  },
  text_popup_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:16,
    textAlign :'center',
    fontWeight: 'bold',
  },
    view_popup_bg :{
    width:'100%',
    padding:24,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16,
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_language:{
    paddingTop:16,
    paddingBottom:16,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  text_language_title:{
     color:'#333',
    fontSize:14,
  },
  flat_popup:{
    marginTop:24,
    width:'100%',
  },
  text_popup_terms_content:{
    width:'100%',
    marginTop:16,
    fontSize:16,
    color:'#333333',
  },
  text_popup_data_title : {
    marginTop:32,
    fontSize:16,
    color:'#000000',
    fontWeight: 'bold',
  },
  text_popup_data_cotent : {
    marginTop:32,
    fontSize:16,
    color:'#333'
  }

});
