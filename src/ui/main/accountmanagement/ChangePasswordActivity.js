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


import WebserviceUtil from '../../../uitl/WebserviceUtil';

import { Loading } from '../../../widget/Loading';

import IparInput from '../../../widget/IparInput';


import DeviceStorage from '../../../uitl/DeviceStorage';

import TitleBar from '../../../widget/TitleBar';

import DateUtil from '../../../uitl/DateUtil';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import { toastShort } from '../../../uitl/ToastUtils';

import StringUtils from '../../../uitl/StringUtils';

import {CommonActions,useNavigation} from '@react-navigation/native';

import MD5 from "react-native-md5";


export default class ChangePasswordActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
      head_company_id:'97',
      userBean:undefined,
      password:undefined,
      re_password:undefined,
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

    DeviceStorage.get('UserBean').then((user_bean) => {

      this.setState({
          userBean: user_bean,
      });  
    });

      // 获取当前发送邮箱
    this.getSystemConfig();


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

          }   
      });

}



  clickNext(){


    if (this.state.password && this.state.re_password) {


      if (!StringUtils.isPassword(this.state.password)) {
        toastShort('The password format does not meet the requirements');
        return;
      }


      if (this.state.password != this.state.re_password) {
        toastShort('The password and confirmation password should be consistent');
        return;
      }

      this.changeClientUserInfo();

    }


  }


  changeClientUserInfo(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:changeClientUserInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">password</key><value i:type="d:string">'+ MD5.hex_md5(this.state.password) + '</value></item>'+
    '<item><key i:type="d:string">id</key><value i:type="d:string">'+ this.state.userBean.id +'</value></item>'+
    '</data></n0:changeClientUserInfo></v:Body></v:Envelope>';
    var temporary = this;

    Loading.show();
    WebserviceUtil.getQueryDataResponse('client','changeClientUserInfoResponse',data, function(json) {
          
          //Loading.hidden();
          if (json && json.success == 1 ) {   

            //temporary.editSuccess();

            //修改完成发送邮件

            temporary.endSmsForEmail();

           
          }else {
              toastShort('Network request failed！');
          }       
      });
  }

  endSmsForEmail(){

    var message = 'You have successfully changed your login password on ' + DateUtil.formatDateTime();

    message += 'If you did not authorise this action, please contact us immediately at 62 933 933.';


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:sendSmsForEmail id="o0" c:root="1" xmlns:n0="http://terra.systems/"><params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">company_id</key><value i:type="d:string">'+ this.state.head_company_id + '</value></item>'+
    '<item><key i:type="d:string">email</key><value i:type="d:string">'+ this.state.userBean.email +'</value></item>'+
    '<item><key i:type="d:string">from_email</key><value i:type="d:string">'+ this.state.send_specific_email + '</value></item>'+
    '<item><key i:type="d:string">message</key><value i:type="d:string">'+ message  +'</value></item>'+
    '<item><key i:type="d:string">title</key><value i:type="d:string">[Chien Chi Tow]</value></item>'+
    '<item><key i:type="d:string">client_id</key><value i:type="d:string">'+ this.state.userBean.id  +'</value></item>'+
    '</params></n0:sendSmsForEmail></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('sms','sendSmsForEmailResponse',data, function(json) {
          
          Loading.hidden();
          temporary.editSuccess();
          
      });
  }





  editSuccess(){


    DeviceStorage.save('login_password', this.state.password);
    NativeModules.NativeBridge.setLoginPwd(this.state.password);

    DeviceEventEmitter.emit('update_user_password','ok');

         // 根据传入的方法渲染并弹出

    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>

                          <Text style = {[styles.text_popup_terms_content,{marginTop:32,marginBottom:32}]}>You have succesfully changed your password</Text>
                                 
                        </View>
                    )
                },
            ()=>{this.toBackActivity()},
            CoverLayer.popupMode.bottom);


  }


  toBackActivity(){


    this.props.navigation.goBack();


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

                <Text style = {styles.text_title}>Change Password</Text>


                 <View style = {[styles.view_iparinput,{marginTop:24}]}>
                    <IparInput
                        isPassword = {true}  
                        valueText = {this.state.password} 
                        placeholderText={'Enter Password'}
                        onChangeText={(text) => {
                             
                          this.setState({password:text})
                        }}/>

                </View>


                <View style = {[styles.view_iparinput,{marginTop:0}]}>
                    <IparInput
                        isPassword = {true} 
                        valueText = {this.state.re_password} 
                        placeholderText={'Re-Password'}
                        onChangeText={(text) => {
                             
                          this.setState({re_password:text})
                        }}/>

                </View>


                <Text style = {[styles.text_content,{marginTop:24}]}>・At least one lowercase character</Text>

                <Text style = {[styles.text_content,{marginTop:8}]}>・At lease one uppercase character</Text>

                <Text style = {[styles.text_content,{marginTop:8}]}>・Must have numerical number</Text>




             </View>  



              <View style = {styles.next_view}>

                    <TouchableOpacity style = {[styles.next_layout,{backgroundColor:(this.state.password != undefined && this.state.re_password != undefined) ? '#C44729' : "#E0e0e0"}]}  
                          activeOpacity = {(this.state.password != undefined && this.state.re_password != undefined) ? 0.8 : 1}
                          onPress={this.clickNext.bind(this)}>


                      <Text style = {styles.next_text}>Confirm</Text>

                    </TouchableOpacity>


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
    padding:24,
  },
  text_title:{
    fontSize:24,
    fontWeight: 'bold',
    color: '#145A7C',
  },
  view_iparinput:{
    width:'100%',
  },
  text_content:{
    fontSize:14,
    color: '#333333',
  },
   next_layout:{
  
    width:'100%',
    height:44,
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor:'#C44729'
  },
  next_text :{
    fontSize: 14,
    color: '#FFFFFF',
    fontWeight: 'bold',
  },
  next_view:{
    padding:24,
    backgroundColor:'#FFFFFF',
    width:'100%',
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
});
