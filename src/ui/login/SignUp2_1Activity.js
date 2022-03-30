import React, {
  Component
} from 'react';
import {
  SafeAreaView,
  Platform,
  StyleSheet,
  Modal,
  Text,
  View,
  ImageBackground,
  Image,
  TextInput,
  Button,
  TouchableOpacity,
  TouchableHighlight,
  ScrollView,
  StatusBar,
  FlatList,
  AsyncStorage,
  StackAction,
  NavigationActions,
  DeviceEventEmitter,
  NativeModules,
  Linking
} from 'react-native';


import TitleBar from '../../widget/TitleBar';

import WebserviceUtil from '../../uitl/WebserviceUtil';

import { Loading } from '../../widget/Loading';

import { toastShort } from '../../uitl/ToastUtils';

import DateUtil from '../../uitl/DateUtil';

import DeviceStorage from '../../uitl/DeviceStorage';

import IparInput from '../../widget/IparInput';

import CoverLayer from '../../widget/xpop/CoverLayer';

import CheckBox from 'react-native-check-box'

import StringUtils from '../../uitl/StringUtils';

const { StatusBarManager } = NativeModules;


export default class SignUp2_1Activity extends Component {


  constructor(props) {
    super(props);
    this.state = {
      head_company_id:'97',
      number:undefined,
      card_number:undefined,
      isOneChecked:true,
      userBean:undefined,
      id_type:'Singapore NRIC/FIN',
      showTypePop: false,
      idTypeData:['Singapore NRIC/FIN','Foreign ID'],
      statusbarHeight:0,
    }
  }



  UNSAFE_componentWillMount(){

    var temporary = this;
    if (Platform.OS === 'ios') {

      StatusBarManager.getHeight(height => {

        temporary.setState({
          statusbarHeight:height.height,
        });
      });

    }else {

      temporary.setState({
          statusbarHeight:StatusBar.currentHeight,
        });
    }


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


    if (this.props.route.params) {
      this.setState({
        number:this.props.route.params.number,
        userBean:this.props.route.params.userBean,
        card_number:this.props.route.params.userBean ? this.props.route.params.userBean.card_number : undefined,
      });
    }

  }


  clickTerms(){

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

  clickIdType(){

   // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}>Select ID Type</Text>

                          <FlatList
                              style = {styles.flat_popup}
                              ref = {(flatList) => this._flatList = flatList}
                              renderItem = {this._renderItem}
                              onEndReachedThreshold={0}
                              keyExtractor={(item, index) => index.toString()}
                              data={this.state.idTypeData}/>

                         


                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);
    

  }


  _renderItem = (item) => {


      return (

        <TouchableOpacity
          activeOpacity = {0.8}
          onPress = {this.clickIDItem.bind(this,item)}>

          <Text style = {styles.text_popup_content}>{item.item}</Text>


          <View style = {styles.view_item_line}/>


        </TouchableOpacity>  

      );

  }


  clickIDItem(item){
    this.coverLayer.hide();

    this.setState({
      id_type:item.item,
    });



  }



  clickNext(){


    if (this.state.card_number && this.state.isOneChecked) {


      //新加坡用户判断 IC 号是否正确
      if (this.state.id_type == 'Singapore NRIC/FIN') {

          // 新加坡用户

         

          if (StringUtils.isNRIC(this.state.card_number)) {

            // 是否是修改
            if (this.state.userBean && this.state.userBean.card_number && this.state.userBean.card_number.toLocaleUpperCase() == this.state.card_number.toLocaleUpperCase()) {
                //修改用户，IC用的是原来的
                  this.toSignUp3Activity();

            }else {
                // 验证IC是否重复
                this.userICExists();

            }



          }else {

              toastShort('Wrong ID number format.')
          }
            

      }else {

          // 是否是修改
            if (this.state.userBean && this.state.userBean.card_number && this.state.userBean.card_number == this.state.card_number) {
                //修改用户，IC用的是原来的
                  this.toSignUp3Activity();

            }else {
                // 验证IC是否重复
                this.userICExists();

            }

      }    
     }
          
  }


  


  userICExists(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:clientICExists id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<IcNO i:type="d:string">'+ this.state.card_number +'</IcNO></n0:clientICExists></v:Body></v:Envelope>';
    var temporary = this;

    Loading.show();

    WebserviceUtil.getQueryDataResponse('client','clientICExistsResponse',data, function(json) {

        Loading.hidden();

        if (json && json.success == 1) {
          if (json.data == 0) {
              temporary.toSignUp3Activity();
          }else {

            temporary.showIcExistsPopup();
            // toastShort('IC already exists')
          }
          
        }else {
          toastShort('Network request failed！');
        } 


    });
  }


  showIcExistsPopup(){


    // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}>You seem to have a  duplicate Identification No.</Text>

                          
                          <Text style = {styles.text_popup_content}>Unable to proceed with registration, please approach our counter staff or call 62933933.</Text>

                         

                           <View style = {[styles.next_view,{marginBottom:54}]}>

                              <TouchableOpacity style = {[styles.next_layout,{backgroundColor:'#C44729'}]}  
                                activeOpacity = {0.8}
                                onPress={this.clickCallPhone.bind(this)}>


                              <Text style = {styles.next_text}>Call now</Text>



                            </TouchableOpacity>

                          </View>




                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);


  }

clickCallPhone(){

  this.coverLayer.hide();

  const url = 'tel:62933933';
  Linking.canOpenURL(url)
    .then(supported => {
      if (!supported) {
          toastShort('The phone does not support dialing function!');
      }
      return Linking.openURL(url);
    })
    .catch(err => toastShort('The phone does not support dialing function!'));

}




  toSignUp3Activity(){

    const { navigation } = this.props;
    
    if (navigation) {
      navigation.navigate('SignUp3Activity',{
        'number':this.state.number,
        'card_number':this.state.card_number,
        'userBean':this.state.userBean,
      });
    }


 }  


  render() {


  const { navigation } = this.props;


    return (

        <View style = {styles.bg}>

          <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

          <SafeAreaView style = {[styles.afearea,{marginTop:this.state.statusbarHeight}]} >

        
              <TitleBar
                title = {''} 
                navigation={navigation}
                hideLeftArrow = {true}
                hideRightArrow = {false}
                extraData={this.state}/>



              <View style = {styles.view_title} >


                <Text style = {styles.text_title}>Your ID is a sensitive matter but...</Text>


                <Text style = {styles.text_content}>Our establishment is under the regulatory purview of Singapore Police Force, knowing your NRIC is mandatory. Please be assured your personal information is kept in strictest confidentiality.</Text>
              

              </View> 


               <View style = {styles.view_content}>



                <TouchableOpacity                      
                    activeOpacity = {0.8}
                    onPress={this.clickIdType.bind(this)}>


                  <View style = {styles.view_id_type}>


                    <Text style = {styles.text_id_type}>{this.state.id_type}</Text>


                    <Image style = {styles.image_id_more} 
                      resizeMode = 'contain' 
                      source={require('../../../images/xia.png')}/>


                  </View> 

                </TouchableOpacity>

                  <View style = {styles.view_line}/>

                  <View style = {styles.view_iparinput}>
                     <IparInput 
                      valueText = {this.state.card_number}
                      placeholderText={'Identification No*'}
                      onChangeText={(text) => {
                         
                        this.setState({card_number:(text != undefined ? text.toLocaleUpperCase() : text)})
                    }}/>

                  </View>



                  <View style = {styles.view_notic}>

                    <Text style = {styles.text_foot_content}>Click here to read the </Text>

                    <TouchableOpacity                      
                      activeOpacity = {0.8}
                      onPress={this.clickTerms.bind(this)}>


                      <Text style = {styles.text_foot_title}>Data Protection Notice</Text>

                    </TouchableOpacity>

                  </View>


                  <View style = {styles.view_notic}>


                   <View style = {styles.view_checkbox}>
                      <CheckBox 
                          style={styles.checkbox} 
                          rightText={''}
                          rightTextStyle = {styles.text_foot_content}
                          onClick={()=>{
                            this.setState({
                              isOneChecked:!this.state.isOneChecked})
                          }}
                          isChecked={this.state.isOneChecked}
                          checkedCheckBoxColor = "#C44729"
                          uncheckedCheckBoxColor = "#C44729"/>   

                  </View>


                    <Text style = {{flex:1}}>

                         <Text style = {styles.text_checkbox_content}>I acknowledge that i have read and understood the </Text>

                          <TouchableOpacity                      
                            activeOpacity = {0.8}
                            onPress={this.clickTerms.bind(this)}>

                            <Text style = {styles.text_foot_title}>Data Protection Notice</Text>

                          </TouchableOpacity>

                         <Text style = {styles.text_checkbox_content}>, and consent to the collection, use and disclosure of my personal data by Chien Chi Tow for the purpose set out in the Notice.</Text>


                    </Text>


                  
                 </View>



                <View style = {[styles.bg,{backgroundColor:'#FFFFFF'}]}/>


                <View style = {styles.next_view}>

                    <TouchableOpacity style = {[styles.next_layout,{backgroundColor:( this.state.card_number && this.state.isOneChecked) ? '#C44729':'#BDBDBD'}]}  
                      activeOpacity = {(this.state.card_number && this.state.isOneChecked)  ? 0.8: 1}
                      onPress={this.clickNext.bind(this)}>


                    <Text style = {styles.next_text}>Next</Text>



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
    backgroundColor:'#145A7C'
  },
  afearea:{
    flex:1,
    backgroundColor:'#145A7C'
  },
  afearea_foot:{
    flex:0,
    backgroundColor:'#FFFFFF'
  },
  view_title : {
    marginLeft:24,
    paddingRight:24,
    marginTop:8,
    width:'100%',
  },
  text_title :{
    color:'#FFFFFF',
    fontSize: 24,
    fontWeight: 'bold',

  },
  text_content :{
    marginTop:8,
    color:'#FFFFFF',
    fontSize: 16,
    lineHeight:25

  },
  text_popup_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:16,
    textAlign :'center',
    fontWeight: 'bold',
  },
  view_content:{
    marginTop:32,
    padding:24,
    flex:1,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16

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
  view_notic :{
      marginTop:32,
      flexDirection: 'row',
  },
  text_foot_content:{
    fontSize:14,
    color:'#333'
  },
  text_foot_title:{
    fontSize:14,
    color:'#C44729',
    fontWeight: 'bold',
  },
   view_checkbox:{
     marginRight:11,
  },
  text_checkbox_content:{
    fontSize:14,
    color:'#333',
    lineHeight:20
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
  view_id_type : {
    width:'100%',
    flexDirection: 'row',
  },
  text_id_type: {
    flex:1,
    fontSize:16,
    color:'#000000',
  },
  image_id_more : {
    width:15,
    height:15
  },
  view_line:{
    marginTop:11,
    backgroundColor: "#E0E0E0",
    width: '100%',
    height: 1
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
  },
  next_view:{
    width:'100%',
  },
  view_sate:{
   flex:1,
   flexDirection: 'row',
   flexWrap: 'wrap',
  }
});