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


import WebserviceUtil from '../../uitl/WebserviceUtil';

import { Loading } from '../../widget/Loading';


import DeviceStorage from '../../uitl/DeviceStorage';

import IparInput from '../../widget/IparInput';

import TitleBar from '../../widget/TitleBar';

import MD5 from "react-native-md5";

import CoverLayer from '../../widget/xpop/CoverLayer';

import DateUtil from '../../uitl/DateUtil';

import { toastShort } from '../../uitl/ToastUtils';

import StringUtils from '../../uitl/StringUtils';


const { StatusBarManager } = NativeModules;


export default class SignIn1Activity extends Component {


   constructor(props) {
      super(props);
      this.state = {
        head_company_id:'97',
        number:undefined,
        password:undefined,
        user_id:undefined,
        client_id:undefined,
        send_specific_email:undefined,
        code:undefined,
        login_type:1, //登录方式   1；手机 2：邮箱
        reset_email:undefined,
        uuid:undefined,
        email_type:1, // 短信类型  1 : 登录  2 ：修改密码
        isFormQr:false, // 是否是从扫码来的 默认不是,
        code_company:undefined,
        statusbarHeight:0,
      }
    }


  UNSAFE_componentWillMount(){

    var temporary = this;
    var statusbarHeight;

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

     DeviceStorage.get('code_company').then((code_company) => {

      this.setState({
          code_company: code_company,
      });
    });

    if (this.props && this.props.route && this.props.route.params) {
        this.setState({
          isFormQr:this.props.route.params.isFormQr,
        });
      }

  }


  clickForgot(){


    NativeModules.NativeBridge.showForgetPwdView();

    // if (this.state.isFormQr == false) {
    //    NativeModules.NativeBridge.showForgetPwdView();
    //  }else {

    //   const { navigation } = this.props;
    //   if (navigation) {
    //     navigation.navigate('SignUp1Activity');
    //   }

    //  }

   
  }


  clickRegisterNew(){

      const { navigation } = this.props;
      if (navigation) {
        navigation.navigate('SignUp1Activity');
      }

  }



  clickPopCancel(){
    this.coverLayer.hide();

  }


  clickPopConfirm(){



    if (this.state.reset_email && !StringUtils.isEmail(this.state.reset_email)) {

        toastShort('Please fill in the correct email address');
    }else {
       this.coverLayer.hide();

       //通过email获取client_id

        this.getIdByEmail(); 

       //this.saveFindPasswordUUID();
    }
  }


  getIdByEmail(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getIdByEmail id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<email i:type="d:string">'+ this.state.reset_email+'</email>'+
    '</n0:getIdByEmail></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('client','getIdByEmailResponse',data, function(json) {

        if (json && json.success == 1) {
          
            DeviceStorage.save('login_client_id', json.data);
      
            temporary.saveFindPasswordUUID(json.data);
        }else {

           Loading.hidden();
          toastShort('Network request failed！');
         
        }       
    });


  }




  saveFindPasswordUUID(client_id){


    this.setState({
      uuid:DateUtil.randomUUID(),
    });

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:saveFindPasswordUUID id="o0" c:root="1" xmlns:n0="http://terra.systems/"><params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap"><item><key i:type="d:string">status</key><value i:type="d:string">1</value></item>'+
    '<item><key i:type="d:string">uuid</key><value i:type="d:string">'+ this.state.uuid +'</value></item>'+
    '<item><key i:type="d:string">client_id</key><value i:type="d:string">'+ client_id +'</value></item></params></n0:saveFindPasswordUUID></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('user','saveFindPasswordUUIDResponse',data, function(json) {

       
        if (json && json.success == 1) {
          //UUID 传给后台成功，进行短信发送

            temporary.setState({
              email_type : 2,
            });
            temporary.getSystemConfig();
        }else {

           Loading.hidden();
          toastShort('Network request failed！');
         
        }       
    });




  }






  clickNext(){

    // 首先进行 手机号登陆
    this.numberLogin();
  }


  numberLogin(){

    var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getQueryData id="o0" c:root="1" xmlns:n0="http://terra.systems/"><statement i:null="true" /><select i:type="d:string">u.id,u.password,u.mobile,u.email</select><from i:type="d:string">t_user u</from><type i:type="d:string">1</type><where i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">u.mobile</key><value i:type="d:string">'+ this.state.number +'</value>'+
    '</item><item><key i:type="d:string">u.role_id</key><value i:type="d:string">11</value></item><item><key i:type="d:string">u.is_delete</key><value i:type="d:string">0</value></item></where></n0:getQueryData></v:Body></v:Envelope>';
    var temporary = this;

    Loading.show();

    WebserviceUtil.getQueryDataResponse('query','getQueryDataResponse',data, function(json) {

        
        if (json && json.success == 1 && json.data && json.data.length > 0) {


            if (json.data[0].password == MD5.hex_md5(temporary.state.password)) {


              temporary.setState({
                user_id:json.data[0].id,
              });


              if (temporary.state.isFormQr == false) {
                  //手机号登录成功，发送短息
                  temporary.sendSmsForMoile();

              }else {
                   temporary.loginUserData(json.data[0].id);
              }

              

            }else {

              // 密码错误
              Loading.hidden();
              temporary.showErrorPopup();

            }
                 
        }else {

            // 手机登录失败，进行邮箱登录
            temporary.emailLogin();
         
        }       
    });



  }

  sendSmsForMoile(){


    this.setState({
      code: DateUtil.randomCode(),
   });



    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:sendSmsForMobile id="o0" c:root="1" xmlns:n0="http://terra.systems/"><params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap"><item><key i:type="d:string">company_id</key><value i:type="d:string">97</value></item>'+
    '<item><key i:type="d:string">mobile</key><value i:type="d:string">'+ this.state.user_id +'</value></item>'+
    '<item><key i:type="d:string">message</key><value i:type="d:string">Your OTP is '+ this.state.code +'. Please enter the OTP within 2 minutes</value></item>'+
    '<item><key i:type="d:string">title</key><value i:type="d:string">Sign Up</value></item></params></n0:sendSmsForMobile></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('sms','sendSmsForMobileResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1) {


            temporary.setState({
              login_type:1,
            });


            temporary.toSignIn2Activity();
    
        }else {
          toastShort('Network request failed！');
         
        }       
    });

  }


  toSignIn2Activity(){

    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('SignIn2Activity',{
        'number':this.state.number,
        'password':this.state.password,
        'user_id':this.state.user_id,
        'code':this.state.code,
        'login_type':this.state.login_type,
        'send_specific_email':this.state.send_specific_email,
        'client_id':this.state.client_id,
      });
    }



  }




  showErrorPopup(){

     // 根据传入的方法渲染并弹出

    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>

                          <Text style = {styles.text_popup_content}>The mobile / email / password is invalid. Please try again.</Text>
               
                        </View>
                       
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);



  }

  emailLogin(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getQueryData id="o0" c:root="1" xmlns:n0="http://terra.systems/"><statement i:null="true" /><select i:type="d:string">u.id,u.password,u.mobile,u.email</select><from i:type="d:string">t_user u</from><type i:type="d:string">1</type><where i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap"><item><key i:type="d:string">u.role_id</key><value i:type="d:string">11</value></item>'+
    '<item><key i:type="d:string">u.email</key><value i:type="d:string">'+ this.state.number +'</value></item>'+
    '<item><key i:type="d:string">u.is_delete</key><value i:type="d:string">0</value></item></where></n0:getQueryData></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('query','getQueryDataResponse',data, function(json) {

        
        if (json && json.success == 1 && json.data && json.data.length > 0 && json.data[0].password == MD5.hex_md5(temporary.state.password)) {

            // 邮箱登录成功，进行邮箱信息发送
            temporary.setState({
                user_id:json.data[0].id,
                 email_type : 1,
              });

            temporary.loginUserData(json.data[0].id);

        }else {

            Loading.hidden();
            temporary.showErrorPopup();
         
        }       
    });


  }


  loginUserData(user_id){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTClientByUserId id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<userId i:type="d:string">'+ user_id +'</userId></n0:getTClientByUserId></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('client','getTClientByUserIdResponse',data, function(json) {

        if (json && json.success == 1 && json.data) {

            // 邮箱登录成功，进行邮箱信息发送
            temporary.setState({
                client_id:json.data.id,
              });

              if (temporary.state.isFormQr == false) {
                 temporary.getSystemConfig();
              }else {

                temporary.getClientLocationBookedServices(json.data.id);

              }
        }else {

            Loading.hidden();
            temporary.showErrorPopup();
         
        }       
    });
  }


  // 扫码登陆时，获取当天有没有预约
  getClientLocationBookedServices(client_id){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header /><v:Body>'+
    '<n0:getClientLocationBookedServices id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<date i:type="d:string">'+ DateUtil.formatDateTime1() +'</date>'+
    '<clientId i:type="d:string">'+ client_id +'</clientId>'+
    '<locationId i:type="d:string">'+ (this.state.code_company ? this.state.code_company.id : '99')+'</locationId>'+
    '</n0:getClientLocationBookedServices></v:Body></v:Envelope>';
    var temporary = this;


    WebserviceUtil.getQueryDataResponse('booking-order','getClientLocationBookedServicesResponse',data, function(json) {

        Loading.hidden();

  
        if (json && json.success == 1 && json.data && json.data.length > 0) {

            temporary.toToadyBookServicesActivity();  
              
        }else {
              
            temporary.toSelectedBookServicesActivity();

        }       
    });

  }


  toToadyBookServicesActivity(){


     DeviceStorage.save('login_name', this.state.number);
     DeviceStorage.save('login_password', this.state.password);
     DeviceStorage.save('login_user_id', this.state.user_id);
     DeviceStorage.save('login_client_id', this.state.client_id);

    NativeModules.NativeBridge.setLoginPwd(this.state.password);
    NativeModules.NativeBridge.setClientId(this.state.client_id.toString());
    NativeModules.NativeBridge.setUserId(this.state.user_id.toString());
    const { navigation } = this.props;
  
    if (navigation) {
      navigation.navigate('ToadyBookServicesActivity',{
        'client_id':this.state.client_id,
      });
    }




  }

  toSelectedBookServicesActivity(){

     DeviceStorage.save('login_name', this.state.number);
     DeviceStorage.save('login_password', this.state.password);
     DeviceStorage.save('login_user_id', this.state.user_id);
     DeviceStorage.save('login_client_id', this.state.client_id);
     NativeModules.NativeBridge.setLoginPwd(this.state.password);
     NativeModules.NativeBridge.setClientId(this.state.client_id.toString());
     NativeModules.NativeBridge.setUserId(this.state.user_id.toString());
    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('SelectedBookServicesActivity',{
        'client_id':this.state.client_id,
      });
    }

  }





getSystemConfig(){

  var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTSystemConfig id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
  '<companyId i:type="d:string">' + this.state.head_company_id + '</companyId><columns i:type="d:string">send_specific_email</columns></n0:getTSystemConfig></v:Body></v:Envelope>';
  var temporary = this;
  WebserviceUtil.getQueryDataResponse('system-config','getTSystemConfigResponse',data, function(json) {


    
        if (json && json.success == 1 && json.data && json.data.send_specific_email) {

            // 邮箱登录成功，进行邮箱信息发送
            temporary.setState({
                send_specific_email:json.data.send_specific_email,
              });



              if (temporary.state.email_type == 1) {
                  temporary.sendSmsForEmail();
              }else {
                  temporary.sendForgotPasswordEmail();
              }

              
             
        }else {

            Loading.hidden();
           temporary.showErrorPopup();
         
        }       
    });

}

sendSmsForEmail(){


  var code = DateUtil.randomCode();

   this.setState({
      code: code,
   });


  var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:sendSmsForEmail id="o0" c:root="1" xmlns:n0="http://terra.systems/"><params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
  '<item><key i:type="d:string">company_id</key><value i:type="d:string">'+ this.state.head_company_id + '</value></item>'+
  '<item><key i:type="d:string">email</key><value i:type="d:string">'+ this.state.number +'</value></item>'+
  '<item><key i:type="d:string">from_email</key><value i:type="d:string">'+ this.state.send_specific_email + '</value></item>'+
  '<item><key i:type="d:string">message</key><value i:type="d:string">Your OTP is '+ code +'. Please enter the OTP within 2 minutes</value></item>'+
  '<item><key i:type="d:string">title</key><value i:type="d:string">[Chien Chi Tow] App login</value></item>'+
  '<item><key i:type="d:string">client_id</key><value i:type="d:string">'+ this.state.client_id +'</value></item>'+
  '</params></n0:sendSmsForEmail></v:Body></v:Envelope>';
  var temporary = this;
  WebserviceUtil.getQueryDataResponse('sms','sendSmsForEmailResponse',data, function(json) {

        
        if (json && json.success == 1 ) {   

          temporary.setState({
              login_type:2,
          });

          Loading.hidden();
          temporary.toSignIn2Activity();
        }else {

           Loading.hidden();
           temporary.showErrorPopup();
         
        }       
    });
}


sendForgotPasswordEmail(){


  var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:sendSmsForEmail id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
  '<params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
  '<item><key i:type="d:string">company_id</key><value i:type="d:string">' + this.state.head_company_id + '</value></item>'+
  '<item><key i:type="d:string">email</key><value i:type="d:string">'+ this.state.reset_email + '</value></item>'+
  '<item><key i:type="d:string">from_email</key><value i:type="d:string">'+ this.state.send_specific_email + '</value></item>'+
  '<item><key i:type="d:string">message</key><value i:type="d:string">&lt;p&gt;Hi,&lt;/p&gt;&lt;p&gt;We have received your request to reset your password for Chien Chi Tow App. Please follow the link below to reset your password:&lt;/p&gt;&lt;p&gt;&lt;a target="_blank" href="http://cctuat.performsoftware.biz/index.php?r=user-manager/change-find-pwd-status&amp;uuid='+ this.state.uuid + '"&gt;http://cctuat.performsoftware.biz/index.php?r=user-manager/change-find-pwd-status&amp;uuid='+ this.state.uuid +'&lt;/a&gt;&lt;/p&gt;&lt;p&gt;If you have not requested to have your password reset, please ignore this email.&lt;/p&gt;&lt;p&gt;Thanks,&lt;/p&gt;&lt;p&gt;Chien Chi Tow&lt;/p&gt;</value></item>'+
  '<item><key i:type="d:string">title</key><value i:type="d:string">[Chien Chi Tow] Forgot Password</value></item>'+
  '<item><key i:type="d:string">client_id</key><value i:type="d:string">0</value></item></params></n0:sendSmsForEmail></v:Body></v:Envelope>';
  var temporary = this;


  WebserviceUtil.getQueryDataResponse('sms','sendSmsForEmailResponse',data, function(json) {

        Loading.hidden();
      
        if (json && json.success == 1 ) {   
          temporary.toResetPasswordActivity();

          
        }else {
           toastShort('Network request failed！');
         
        }       
    });


}


toResetPasswordActivity(){

    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('ResetPasswordActivity',{
        'reset_email':this.state.reset_email,
        'uuid':this.state.uuid,
      });
    }



}







 render() {

    const { navigation } = this.props;

    return(

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

                <Text style = {styles.text_title}>Login to your Account</Text>

              </View>


              <View style = {styles.view_content}>

                <View style = {styles.view_iparinput}>
                  <IparInput
                    valueText = {this.state.number}  
                    placeholderText={'Email/Phone Number'}
                    onChangeText={(text) => {
                         
                      this.setState({number:text})
                  }}/>

                </View>


                <View style = {styles.view_iparinput}>
                  <IparInput
                    valueText = {this.state.password}   
                    isPassword = {true} 
                    placeholderText={'Enter Password'}
                    onChangeText={(text) => {
                         
                      this.setState({password:text})
                  }}/>

                </View>


                


                 <View style = {[styles.view_forgot,{marginTop:30}]}>

                  <TouchableOpacity 
                    activeOpacity = {0.8}
                    onPress={this.clickForgot.bind(this)}>

                    <Text style = {styles.forgot_text}>Forgot Your Password</Text>

                  </TouchableOpacity>


                 </View>   


                  <View style = {styles.bg_white}/>



                <View style = {styles.next_layout}>

                  <TouchableOpacity style = {[styles.next_layout,{backgroundColor:(this.state.number && this.state.password) ? '#C44729':'#E0E0E0'}]}  
                      activeOpacity = {(this.state.number && this.state.password)  ? 0.8: 1}
                      onPress={this.clickNext.bind(this)}>


                    <Text style = {styles.next_text}>Login</Text>

                  </TouchableOpacity>

                </View>


                {this.state.isFormQr == true ? 

                   <View style = {[styles.next_layout,{marginTop:10}]}>

                      <TouchableOpacity style = {[styles.next_layout,{backgroundColor: '#E0E0E0'}]}  
                          activeOpacity = {0.8}
                          onPress={this.clickRegisterNew.bind(this)}>

                        <Text style = {[styles.next_text,{color:'#333333'}]}>Register New</Text>

                      </TouchableOpacity>

                    </View>
                  :  

                  <View/>
                }

               




          


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
  bg_white: {
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
  view_content:{
    marginTop:32,
    padding:24,
    flex:1,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16
  },
   view_iparinput:{
    width:'100%',
  },
  forgot_text:{
    fontSize:14,
    color:'#C44729',
    fontWeight: 'bold',
  },
  view_forgot:{
    width:'100%',
    justifyContent: 'center',
    alignItems: 'center',

  },
  next_layout:{
      marginTop:28,
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
  view_popup_bg :{
    width:'100%',
    padding:24,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16,
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_popup_content:{
    marginBottom:50,
    width:'100%',
    marginTop:32,
    fontSize:16,
    color:'#333333',
    textAlign :'center',
  },
  xpop_cancel_confim:{
    marginTop:32,
    marginBottom:50,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom:74,
  },
  xpop_item:{
    borderRadius: 50,
    height:44,
   
    justifyContent: 'center',
    alignItems: 'center',
  },
  xpop_text: {
    fontSize:14,
    textAlign :'center',
    fontWeight: 'bold',
  },
  xpop_touch:{
     width:'48%',

  },
  text_popup_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:16,
    textAlign :'center',
    fontWeight: 'bold',
  },
});

