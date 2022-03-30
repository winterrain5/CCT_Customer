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
  NativeModules,
} from 'react-native';

import TitleBar from '../../../widget/TitleBar';

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import { Loading } from '../../../widget/Loading';

import { toastShort } from '../../../uitl/ToastUtils';

import DateUtil from '../../../uitl/DateUtil';

import DeviceStorage from '../../../uitl/DeviceStorage';

import IparInput from '../../../widget/IparInput';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import CheckBox from 'react-native-check-box'

import StringUtils from '../../../uitl/StringUtils';

import {CommonActions,useNavigation} from '@react-navigation/native';


export default class CheckInConfirmBookActivity extends Component {



  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       service:undefined,
       userBean:undefined,
    }
  }


  UNSAFE_componentWillMount(){

  
    DeviceStorage.get('head_company_id').then((ompany_id) => {


      if (ompany_id) {
        this.setState({
            head_company_id: ompany_id,
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
    });

    if (this.props.route.params) {

      this.setState({
        service:this.props.route.params.service,
      
      });
    }


  }

  clickNRICPopup(){


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

                              <Text style = {styles.text_popup_data_cotent}>g.complying with any applicable laws, regulations, codes of practice, guidelines, or rules, or to assist in law enforcement and investigations conducted by any governmental and/or regulatory authority;\</Text>

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


  clickConfim(){


    const { navigation } = this.props;


    if (this.state.service && navigation) {

      console.log(this.state.service);
      // 1.保健 2.治疗 3.产前 4. 产后       
        if (this.state.service.health_declaration_form_type == '1') {

            navigation.navigate('TreatmentDevlarationActivity',{
              'service':this.state.service,
              'gender':this.state.userBean.gender,
              'well_treatment':0,
            });

        }else if (this.state.service.health_declaration_form_type == '2') {

            navigation.navigate('TreatmentDevlarationActivity',{
              'service':this.state.service,
              'gender':this.state.userBean.gender,
              'well_treatment':1,
            });

        }else if (this.state.service.health_declaration_form_type == '3') {

            navigation.navigate('PreConceptionDevlarationActivity',{
              'service':this.state.service,
              'gender':this.state.userBean.gender,
            });

        }else if (this.state.service.health_declaration_form_type == '4') {

          navigation.navigate('PostPartumDevlarationActivity',{
              'service':this.state.service,
              'gender':this.state.userBean.gender,
            });

        }

    }

  }


  _therapistView(){


    if (this.state.service  &&  this.state.service.staff_is_random == '2') {

      var name = '';

      console.error(this.state.service);


      if (this.state.service.business_namne != undefined) {

        name = this.state.service.business_namne;

      }else if (this.state.service.staff_name != undefined) {

        name = this.state.service.staff_name;
      }




      return (

        <View style = {styles.view_item_item}>


          <Image style = {styles.image_item} 
            resizeMode = 'contain' 
            source={require('../../../../images/person_0217.png')}/>


          <Text style = {styles.text_item_content}>{name}</Text>

        </View>

      );


    }else {

      return (<View/>);
    }



  }





  render() {

    const { navigation } = this.props;

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

                  <Text style = {styles.text_title}>Confirm your session</Text>


                  <View style = {[styles.view_item,{marginTop:32}]}>


                      <Text style = {styles.text_title}>{this.state.service  ? this.state.service.alias_name : ''}</Text>


                      <View style = {styles.view_item_item}>


                        <Image style = {styles.image_item} 
                          resizeMode = 'contain' 
                          source={require('../../../../images/time.png')}/>


                        <Text style = {styles.text_item_content}>{this.state.service ? DateUtil.getShowHMTime2(this.state.service.therapy_start_date) : ''}</Text>




                      </View>



                      <View style = {styles.view_item_item}>


                        <Image style = {styles.image_item} 
                          resizeMode = 'contain' 
                          source={require('../../../../images/date_xiao.png')}/>


                        <Text style = {styles.text_item_content}>{this.state.service ? DateUtil.getShowTimeFromDate3(this.state.service.therapy_start_date) : ''}</Text>


                      </View>



                      <View style = {styles.view_item_item}>


                        <Image style = {styles.image_item} 
                          resizeMode = 'contain' 
                          source={require('../../../../images/location.png')}/>


                        <Text style = {styles.text_item_content}>{this.state.service ? this.state.service.location_name : ''}</Text>

                      </View>



                      {this._therapistView()}


                  </View>


                  <View style = {[styles.view_item,{marginTop:16}]}>


                     <Text style = {styles.text_title}>Patient's Information</Text>


                    <View style = {[styles.view_item_item,{marginTop:16}]}>

                      <Text style = {[styles.text_item_content,{color:'#828282'}]}>Name</Text>

                       <Text style = {styles.text_item_content}>{this.state.userBean ? (this.state.userBean.first_name + ' ' + this.state.userBean.last_name) : ''}</Text>


                    </View>


                    <View style = {[styles.view_item_item]}>


                      <View style ={styles.view_item_image}>
                        <Text style = {[styles.text_image,{color:'#828282'}]}>NRIC/Passport</Text>


                        <TouchableOpacity                      
                          activeOpacity = {0.8}
                          onPress={this.clickNRICPopup.bind(this)}>


                          <Image style = {styles.image_item} 
                            resizeMode = 'contain' 
                            source={require('../../../../images/vector_1015.png')}/>


                        </TouchableOpacity>  

                      </View>

              
                      <Text style = {styles.text_item_content}>{this.state.userBean ? StringUtils.hideNRIC(this.state.userBean.card_number) : ''}</Text>


                    </View>


                    <View style = {[styles.view_item_item]}>

                      <Text style = {[styles.text_item_content,{color:'#828282'}]}>Gender</Text>

                       <Text style = {styles.text_item_content}>{this.state.userBean ? (this.state.userBean.gender == '1' ? 'Male' : 'Female') : ''}</Text>


                    </View>


                    <View style = {[styles.view_item_item]}>

                      <Text style = {[styles.text_item_content,{color:'#828282'}]}>Date of Birth</Text>

                       <Text style = {styles.text_item_content}>{this.state.userBean ? DateUtil.getShowTimeFromDate1(this.state.userBean.birthday) : ''}</Text>


                    </View>




                  </View>


                <View style = {styles.bg}/>



                 <View style = {styles.next_view}>

                  <TouchableOpacity style = {[styles.next_layout,{backgroundColor:'#C44729'}]}  
                      activeOpacity = {0.8 }
                      onPress={this.clickConfim.bind(this)}>


                    <Text style = {styles.next_text}>Confirm</Text>

                  </TouchableOpacity>

                </View>



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
    padding:24,
    flex:1,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16
  },
  scrollview:{
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  text_title : {
    marginTop:8,
    color:'#145A7C',
    fontSize: 24,
    fontWeight: 'bold',
  },
  scrollview:{
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  text_title : {
    marginTop:8,
    color:'#145A7C',
    fontSize: 24,
    fontWeight: 'bold',
  },
  view_item:{
    marginTop:16,
    padding:16,
    borderRadius:16,
    backgroundColor:'#FAF3EB',
    width:'100%',
  },
  text_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:18,
    fontWeight: 'bold',
  },
  view_item_item:{
    marginTop:8,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center'
  },
  image_item:{
    width:15,
    height:15
  },
  text_item_content:{
    marginLeft:6,
    flex:1,
    color:'#333',
    fontSize:14,
  },
  view_item_image:{
     flexDirection: 'row',
    flex:1,
  },
  text_image:{
    marginLeft:6,
    color:'#828282',
    fontSize:14,
  },
   next_layout:{
      width:'100%',
      height:44,
      borderRadius: 50,
      justifyContent: 'center',
      alignItems: 'center'
  },
  next_text :{
      fontSize: 14,
      color: '#FFFFFF',
      fontWeight: 'bold',
  },
  next_view:{
    marginTop:32
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
   flat_popup:{
    marginTop:24,
    width:'100%'
  },
  text_popup_content:{
    width:'100%',
    marginTop:16,
    marginBottom:16,
    fontSize:16,
    color:'#333333'
  },
  view_item_line:{
    backgroundColor: "#E0E0E0",
    width: '100%',
    height: 1
  },
  scrollview: {
    width:'100%',
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




