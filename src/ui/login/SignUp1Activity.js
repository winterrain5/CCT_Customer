import React, {
  Component
} from 'react';
import {
  SafeAreaView,
  Platform,
  StyleSheet,
  Modal,
  Text,
  Linking,
  View,
  ImageBackground,
  Image,
  TextInput,
  Button,
  TouchableOpacity,
  TouchableHighlight,
  ScrollView,
  StatusBar,
  AsyncStorage,
  StackAction,
  NavigationActions,
  DeviceEventEmitter,
  NativeModules
} from 'react-native';


import TitleBar from '../../widget/TitleBar';

import WebserviceUtil from '../../uitl/WebserviceUtil';

import { Loading } from '../../widget/Loading';

import { toastShort } from '../../uitl/ToastUtils';

import DateUtil from '../../uitl/DateUtil';

import DeviceStorage from '../../uitl/DeviceStorage';

import CoverLayer from '../../widget/xpop/CoverLayer';

const { StatusBarManager } = NativeModules;



export default class SignUp1Activity extends Component {

  constructor(props) {
    super(props);
    this.state = {
      head_company_id:'97',
      number:undefined,
      code:undefined,
      userBean:undefined,
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

    })

  }



clickSend(){

  if (this.state.number) {

    this.refs['input'].blur();
    // this.userMobileExists();
    //this.toSignUp2Activity();
    this.getClientsByPhone();
  }

}


showErrorConfirmPopup(type){

  var title = '';
  var content = '';
  var confirm = '';


  if (type == 0) {

    title = 'You seem to have a duplicate mobile no.';
    content = 'Unable to proceed with registration, please approach our counter staff or call 62933933';
    confirm = 'Call now';

  }else if (type == 1) {

    title = 'This mobile number is registered, please confirm your details to start using the Chien Chi Tow App.';
    content = undefined;
    confirm = 'Confirm';


  }else if (type == 2) {

    title = ' This mobile number is registered, please login with your login ID.';
    content = undefined;
    confirm = 'Login';

   

  }





    // 根据传入的方法渲染并弹出

    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}>{title}</Text>


                          <Text style = {[styles.text_popup_content,{marginTop:content ? 32 : 0}]}>{content}</Text>


                           <View style = {styles.view_popup_next}>

                             <TouchableOpacity style = {[styles.next_layout,{backgroundColor:'#C44729'}]}  
                                activeOpacity = { 0.8}
                                onPress={this.clickPopupConfirm.bind(this,type)}>


                                <Text style = {styles.next_text}>{confirm}</Text>

                             </TouchableOpacity>


                           </View>                     
              
                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);




}



clickPopupConfirm(type){


  this.coverLayer.hide();

  if (type == 0) {
    this.callMerchant();
  }else if (type == 2) {

    this.toLoginActivity();
  }
}

toLoginActivity(){

  const { navigation } = this.props;
    
    if (navigation) {
      navigation.replace('SignIn1Activity');
    }
}  




callMerchant = () => {
    this.call('62933933');
  };



/**
   *  拨打电话
   * @param {string} phone 版本号
   * @example
   * call('')
   */
  call = phone => {
    const url = `tel:${phone}`;
    Linking.canOpenURL(url)
      .then(supported => {
        if (!supported) {
          toastShort('call phone error');
        }
        return Linking.openURL(url);
      })
      .catch(err => toastShort('call phone error'));
  };
 
  








getClientsByPhone(){


  this.setState({
      userBean:undefined
  });


  var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getClientsByPhone id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
  '<mobile i:type="d:string">'+this.state.number +'</mobile></n0:getClientsByPhone></v:Body></v:Envelope>';

  Loading.show();

  var temporary = this;


  WebserviceUtil.getQueryDataResponse('client','getClientsByPhoneResponse',data, function(json) {
        

      

        if (json && json.success == 1) {

            if (json.data && json.data.length == 0) {
                //未注册
                temporary.sendSmsForMobile();

            }else if (json && json.data.length == 1) {

                // 有一个已注册用户

                if (json.data[0].source == '0') {
                  // 电脑端注册用户   进行数据补全
                  temporary.setState({
                    userBean:json.data[0],
                  });
                  temporary.sendSmsForMobile();

                }else {

                    // 手机端用户提示已存在
                     Loading.hidden();
                    temporary.showErrorConfirmPopup(2);

                }
            }else if (json && json.data.length > 1) {

                  // 存在多个用户，提示  
                   Loading.hidden();
                   temporary.showErrorConfirmPopup(0);


            }else {

               // 请求失败
              Loading.hidden();
              toastShort('Network request failed！');

            }


        }else {

            // 请求失败
            Loading.hidden();
         }



    });




}





userMobileExists(){

  var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:userMobileExists id="o0" c:root="1" xmlns:n0="http://terra.systems/">' +
   '<mobile i:type="d:string">'+this.state.number +'</mobile>'+
   '</n0:userMobileExists></v:Body></v:Envelope>';

  Loading.show();

  var temporary = this;


  WebserviceUtil.getQueryDataResponse('client','userMobileExistsResponse',data, function(json) {

        if (json) {
          if (json.success == 0) {
              temporary.sendSmsForMobile();
          }else {
            Loading.hidden();
            toastShort('This mobile number is registered,Would you like to Log In to Your account!')

          }

        }else {
          Loading.hidden();
          toastShort('Network request failed！');
        } 


    });


}



sendSmsForMobile(){


  this.setState({
      code: DateUtil.randomCode(),
  });


  var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:sendSmsForMobile id="o0" c:root="1" xmlns:n0="http://terra.systems/"><params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
  '<item><key i:type="d:string">company_id</key><value i:type="d:string">97</value></item><item>'+
  '<key i:type="d:string">mobile</key><value i:type="d:string">'+this.state.number + '</value></item>'+
  '<item><key i:type="d:string">message</key><value i:type="d:string">Your OTP is '+ this.state.code + '. Please enter the OTP within 2 minutes</value></item>'+
  '<item><key i:type="d:string">title</key><value i:type="d:string">Sign Up</value></item></params></n0:sendSmsForMobile></v:Body></v:Envelope>';
  var temporary = this;




  WebserviceUtil.getQueryDataResponse('sms','sendSmsForMobileResponse',data, function(json) {

        Loading.hidden();

        if (json && json.success == 1) {
            temporary.toSignUp2Activity();
        }else {
          toastShort('Network request failed！');
        } 


    });


}


toSignUp2Activity(){
    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('SignUp2Activity',{
        'number':this.state.number,
        'userBean':this.state.userBean,
        'code':this.state.code,
      });
    }
}





clickTerms(){
     // 根据传入的方法渲染并弹出

    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}>Terms & conditions</Text>


                          <Text style = {[styles.text_popup_terms_content,{marginTop:32}]}>You can invite your friends by sending them your unique referral link provided by this feature in the Chien Chi Tow app via email, SMS, WhatsApp or other messaging platforms.</Text>


                          <Text style = {[styles.text_popup_terms_content]}>Your friends must use the link you send them to install the app and sign-up to receive their $10.00 CCT voucher, which will be automatically added to your app wallet.</Text>


                          <Text style = {[styles.text_popup_terms_content]}>When you utilises your friend's referral credit, they will receive $10.00 CCT voucher that will be automatically added in their app wallet.</Text>


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


    return (

        <View style = {styles.bg}>

          <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />


            <SafeAreaView style = {[styles.afearea,{marginTop:this.state.statusbarHeight}]} >


              <TitleBar
                title = {""} 
                navigation={navigation}
                hideLeftArrow = {true}
                hideRightArrow = {false}
                extraData={this.state}/>

              <View style = {styles.view_title} >


                <Text style = {styles.text_title}>Enter with your mobile number</Text>


                <Text style = {styles.text_content}>We will need to verify your registration by sending a one time password (OTP) via SMS!</Text>
              


              </View> 




              <View style = {styles.view_content}>



                  <View style = {styles.view_phone}>


                        <View>


                            <View style = {styles.view_quyu}>

                                <Text style = {styles.text_quhao}>+65</Text>

                                <Image style = {styles.image_more} 
                                   resizeMode = 'contain' 
                                   source={require('../../../images/xia.png')}/>


                            </View>


                            <View style = {styles.view_line1}/>





                        </View>


                        <View style = {styles.view_jiange}>

                            <View style = {styles.view_input}>

                              <View style = {styles.view_quyu}>


                                <TextInput style = {styles.text_input}
                                    ref='input'
                                    placeholder='Enter Number'
                                    multiline = {false}
                                    keyboardType='numeric'
                                    onChangeText={(text) => {
                                      const newText = text.replace(/[^\d]+/, '');
                                      this.setState({number:newText});
   
                                    }}
                                    />


                              </View>

                            </View>


                            <View style = {styles.view_line2}/>

                        </View>

                       


                  </View>



                   <View style = {styles.next_view}>

                      <TouchableOpacity style = {[styles.next_layout,{backgroundColor:this.state.number ? '#C44729':'#BDBDBD'}]}  
                          activeOpacity = {this.state.number ? 0.8: 1}
                          onPress={this.clickSend.bind(this)}>


                      <Text style = {styles.next_text}>Send OTP</Text>



                      </TouchableOpacity>


                  </View> 


                  <View style = {[styles.bg,{backgroundColor:'#FFFFFF'}]}/>


                  <View style = {styles.view_foot}>

                      <Text style = {styles.text_foot_content}>By registering with us, you are agreeing to our</Text>


                      <TouchableOpacity   
                          style = {styles.toach_title}
                          activeOpacity = {0.8}
                          onPress={this.clickTerms.bind(this)}>


                          <Text style = {styles.text_foot_title}>Terms of Service and conditions</Text>



                      </TouchableOpacity>



                      <View style = {styles.view_foot2}>

                          <Text style = {styles.text_foot_content}>View our </Text>



                           <TouchableOpacity   
                          
                              activeOpacity = {0.8}
                              onPress={this.clickTerms.bind(this)}>


                            <Text style = {styles.text_foot_title}>Privacy Policy</Text>



                          </TouchableOpacity>

                        


                      </View>

                      

                  </View>



              </View>


            </SafeAreaView>


             <SafeAreaView style = {styles.afearea_foot} />


            <CoverLayer ref={ref => this.coverLayer = ref}/>


        </View>

      )
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
  view_content:{
    marginTop:32,
    padding:24,
    flex:1,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16

  },
  view_phone :{
    marginTop:20,
    width:'100%',
    flexDirection: 'row',
  },
  view_quyu :{
    flexDirection: 'row',
    justifyContent: 'center',
  },
  text_quhao:{
    fontSize:16,
    color:'#333333'

  },
  image_more:{
    marginTop:7,
    marginLeft:34,
    width:6,
    height:3,

  },
  view_line1:{
    marginTop:11,
    width:75,
    height:1,
    borderRadius: 50,
    backgroundColor:'#E0E0E0',
  },
  view_input:{
    flex:1,
  },
  text_input:{
  
    flex:1,
    height:24,
    fontSize:16,
    color:'#333333'
  },
  view_jiange:{
    flex:1,
    marginLeft:13
  },
  view_line2:{
    width:'100%',
    height:1,
    borderRadius: 50,
    backgroundColor:'#E0E0E0',
  },
  next_view:{
      marginTop:36,
      width:'100%',

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
  view_foot:{
    marginBottom:44,
    alignItems: 'center',
    justifyContent: 'center',
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
  toach_title:{
    marginTop:5    
  },
  view_foot2:{
    marginTop:5 ,
    alignItems: 'center',
    flexDirection: 'row',
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
  text_popup_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:16,
    textAlign :'center',
    fontWeight: 'bold',
  },
  text_popup_content:{
    width:'100%',
    marginTop:32,
    fontSize:16,
    color:'#333333',
    textAlign :'center',
  },
   view_popup_next:{
      marginTop:33,
      width:'100%',
      marginBottom:30,
  },
  text_popup_terms_content:{
    width:'100%',
    marginTop:16,
    fontSize:16,
    color:'#333333',


  }


});