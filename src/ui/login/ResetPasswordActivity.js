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

import CoverLayer from '../../widget/xpop/CoverLayer';

import StringUtils from '../../uitl/StringUtils';

import { toastShort } from '../../uitl/ToastUtils';

import MD5 from "react-native-md5";



export default class ResetPasswordActivity extends Component {



  constructor(props) {
      super(props);
      this.state = {
        head_company_id:'97',
        reset_email:undefined,
        uuid:undefined,
        client_id:undefined,
        new_password:undefined,
        re_new_password:undefined,
        send_specific_email:undefined,
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

    DeviceStorage.get('login_client_id').then((client_id) => {

      if (client_id) {
        this.setState({
            client_id: client_id,
          });
      }else {
        this.setState({
            client_id: '0',
          });
      }

    });

    if (this.props.route.params) {

      this.setState({
        reset_email:this.props.route.params.reset_email,
        uuid:this.props.route.params.uuid,
      });
    }

      // 获取当前发送邮箱
    this.getSystemConfig();

  }

  clickNext(){


    if (this.state.new_password && this.state.re_new_password) {

      if (StringUtils.isPassword(this.state.new_password) && StringUtils.isPassword(this.state.re_new_password)) {

        if (this.state.new_password  == this.state.re_new_password) {
                
          // UUID确认是否点击了
          this.getFindPasswordUUID();

        }else {
          toastShort('The password and confirmation password should be consistent!')
        }

      }else {
        toastShort('Password format error!');
      }

    }
  }

  getFindPasswordUUID(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getFindPasswordUUID id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<uuid i:type="d:string">'+ this.state.uuid+'</uuid>'+
    '<clientId i:type="d:string">'+ this.state.client_id + '</clientId></n0:getFindPasswordUUID></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();

    WebserviceUtil.getQueryDataResponse('user','getFindPasswordUUIDResponse',data, function(json) {
     
        if (json && json.success == 1 && json.data && json.data.status == '2') {
          // 判断UUID点击了
          temporary.changeClientUserInfo();
        }else {
            // 判断UUID没有点击了
          Loading.hidden();
          toastShort('Please go to email to confirm the link！');
         
        }       
    });

  }


  changeClientUserInfo(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:changeClientUserInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/"><data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">password</key><value i:type="d:string">'+ MD5.hex_md5(this.state.new_password)+'</value></item>'+
    '<item><key i:type="d:string">id</key><value i:type="d:string">'+ this.state.client_id +'</value></item></data></n0:changeClientUserInfo></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('client','changeClientUserInfoResponse',data, function(json) {
        //Loading.hidden();
        if (json && json.success == 1) {
          // 修改成功
          //temporary.showEditSuccessPopup();

          //发送邮件
          temporary.endSmsForEmail();

        }else {
            // 修改失败
            Loading.hidden();
           toastShort('Network request failed！');
         
        }       
    });


  }


  endSmsForEmail(){

    var message = 'You have successfully changed your login password on ' + DateUtil.formatDateTime();

    message += 'If you did not authorise this action, please contact us immediately at 62 933 933.';


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:sendSmsForEmail id="o0" c:root="1" xmlns:n0="http://terra.systems/"><params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">company_id</key><value i:type="d:string">'+ this.state.head_company_id + '</value></item>'+
    '<item><key i:type="d:string">email</key><value i:type="d:string">'+ this.state.reset_email +'</value></item>'+
    '<item><key i:type="d:string">from_email</key><value i:type="d:string">'+ this.state.send_specific_email + '</value></item>'+
    '<item><key i:type="d:string">message</key><value i:type="d:string">'+ message  +'</value></item>'+
    '<item><key i:type="d:string">title</key><value i:type="d:string">[Chien Chi Tow]</value></item>'+
    '<item><key i:type="d:string">client_id</key><value i:type="d:string">'+ this.state.client_id  +'</value></item>'+
    '</params></n0:sendSmsForEmail></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('sms','sendSmsForEmailResponse',data, function(json) {
          
          Loading.hidden();
          temporary.showEditSuccessPopup();
          
      });
  }



  showEditSuccessPopup(){

    DeviceStorage.save('login_password', this.state.password);
    NativeModules.NativeBridge.setLoginPwd(this.state.password);

    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>

                          <Text style = {styles.text_popup_content}>You have succesfully changed your password!</Text>
               
                        </View>
                       
                    )
                },
            ()=>this.back(),
            CoverLayer.popupMode.bottom);


  }


  back(){

    this.props.navigation.goBack();
  }




    render() {

      const { navigation } = this.props;

       return(

        <View style = {styles.bg}>

          <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />


          <SafeAreaView style = {styles.afearea} >

              <TitleBar
                title = {"Reset Password"} 
                navigation={navigation}
                hideLeftArrow = {true}
                hideRightArrow = {false}
                extraData={this.state}/>


               <View style = {styles.view_content}>


                  <Text style = {styles.text_title}>Reset Password</Text>



                  <View style = {[styles.view_iparinput,{marginTop:44}]}>
                      <IparInput
                          isPassword = {true}                             
                          placeholderText={'Enter New Password*'}
                          onChangeText={(text) => {
                         
                              this.setState({new_password:text})
                      }} />

                  </View>


                   <View style = {styles.view_iparinput}>
                      <IparInput  
                          isPassword = {true}                      
                          placeholderText={'Re-Enter New Password*'}
                          onChangeText={(text) => {
                         
                              this.setState({re_new_password:text})
                      }} />

                  </View>



                 <View style = {styles.view_eamil_error} >

                  <Text style = {styles.text_error}>・Passwords need to be at least 6 characters</Text>

                  <Text style = {styles.text_error}>・At least one lowercase character</Text>

                  <Text style = {styles.text_error}>・At lease one uppercase character</Text>

                  <Text style = {styles.text_error}>・Must have numerical number</Text>

                 </View>   


                 <View style = {styles.bg}/>


                 <View style = {styles.next_view}>

                    <TouchableOpacity style = {[styles.next_layout,{backgroundColor:(this.state.new_password && this.state.re_new_password) ? '#C44729':'#BDBDBD'}]}  
                        activeOpacity = {(this.state.new_password && this.state.re_new_password)  ? 0.8: 1}
                        onPress={this.clickNext.bind(this)}>


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
  view_title : {
    marginLeft:24,
    paddingRight:24,
    marginTop:8,
    width:'100%',
  },
  text_title :{
    color:'#145A7C',
    fontSize: 24,
    fontWeight: 'bold',

  },
  view_content:{
    padding:24,
    flex:1,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16
  },
   view_iparinput:{
    width:'100%',
  },
  view_eamil_error : {

    marginTop:32

  },
  text_error:{
    color:'#333',
    fontSize:14
  },
  next_view:{
    paddingTop:10,
    paddingBottom:74,
    width:'100%',
    backgroundColor:'#FFFFFF'
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
});



