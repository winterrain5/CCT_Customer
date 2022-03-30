import React, {
  Component
} from 'react';
import {
  KeyboardAvoidingView,
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

export default class AccountManagementActivity extends Component {

  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       login_password:undefined,
       send_specific_email:undefined,
       edit_type:0, // 当前修改类型   0;phone 1 : Email 2: Password,
       new_phone:undefined,
       new_email:undefined,
       code:undefined,
       keyboard:false,
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
    });


     DeviceStorage.get('login_password').then((login_password) => {

      this.setState({
          login_password: login_password,
      });

    });

  }


   componentDidMount(){

    var temporary = this;
      
    this.emit =  DeviceEventEmitter.addListener('update_user',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
        DeviceStorage.get('UserBean').then((user_bean) => {
          this.setState({
              userBean: user_bean,
          });  
        });
     });

    this.emit =  DeviceEventEmitter.addListener('update_user_password',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
         DeviceStorage.get('login_password').then((login_password) => {
            this.setState({
                login_password: login_password,
            });
          });
     });

    

  }

  componentWillUnmount(){

      this.emit.remove();
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
            temporary.sendSmsForEmail(json.data.send_specific_email);
        }    
    });

}




  clickEditPhone(edit_type){


    this.setState({
      edit_type:edit_type,
    });

     this.coverLayer.showWithContent(
              ()=> {
                  return (

                
                      <View style={styles.view_popup_bg}>


                        <Text style = {styles.text_popup_title}>Verify</Text>


                        <Text style = {[styles.text_popup_terms_content,{marginTop:32}]}>Before making changes, please verify by entering your password</Text>


                        <Text style = {[styles.text_item_title,{width:'100%',marginTop:24}]}>Password</Text>



                       <TextInput 
                          style = {styles.text_input}
                          placeholder='Enter Password'
                          multiline = {false}
                          secureTextEntry = {true}
                          value = {this.state.password} 
                          onBlur={() => {
                              this.setState({
                                keyboard:false,
                              })
                          }}
                          onFocus={() => {
                              this.setState({
                                keyboard:true,
                              })
                          }}
                          onChangeText={(text) => {
                             this.setState({
                                password:text,
                             });
                    
                          }}/>


                        <View style = {[styles.view_line,{marginTop:7}]}/>   


                         <TouchableOpacity
                               style = {{marginTop:32,marginBottom:32}}    
                               activeOpacity = {0.8}
                               onPress={this.clickForgotPassword.bind(this)}>


                                <Text style = {styles.text_forgot}>Forgot Password?</Text>



                         </TouchableOpacity>      


                       

                         <View style = {styles.xpop_cancel_confim}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={this.clickPopCancel.bind(this)}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Cancel</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickPopConfirm.bind(this)}>

                                <View style = {[styles.xpop_item,{backgroundColor:'#C44729'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#fff'}]}>Confirm</Text>

                              </View>

                            </TouchableOpacity>   

                                                   
                          </View> 


                          <View style = {{width:'100%',height:this.state.keyboard ? 250 : 0,}}/>                    
                     
                               
                      </View>

                  )
              },
          ()=>this.hidePopup(),
          CoverLayer.popupMode.bottom);

  }

  hidePopup(){
    this.coverLayer.hide();
    this.setState({
      keyboard:false,
    });
  }




  clickForgotPassword(){



  }


  clickPopCancel(){

    this.hidePopup();

  }


  clickPopConfirm(){


    if (!this.state.password) {
      toastShort('Enter Password!');
      return;
    }

    if (this.state.login_password != this.state.password) {
      toastShort('The Password is incorrect!');
      return;
    }
    this.hidePopup();


    if (this.state.edit_type == 0) {
      // phone 
      this.editNewPhoneOrEmailPopup(0);

    }else if (this.state.edit_type == 1){

      //email
      this.editNewPhoneOrEmailPopup(1);

    }else {

      //password
      const { navigation } = this.props;
      if (navigation) {
        navigation.navigate('ChangePasswordActivity');
      }

    }

  }


  editNewPhoneOrEmailPopup(type){


     this.coverLayer.showWithContent(
              ()=> {
                  return (
                      <View style={styles.view_popup_bg}>


                        <Text style = {styles.text_popup_title}>{type == 0 ? 'Edit phone number' : 'Edit email'}</Text>



                        <Text style = {[styles.text_item_title,{width:'100%',marginTop:24}]}>{type == 0 ? 'Phone Number' : 'Email'}</Text>



                       <View style = {styles.view_newphone}>

                        {type == 0 ?  (<Text style = {styles.text_quhao}>+65</Text>) : (<View/>)}

                          <TextInput 
                            style = {[styles.text_input,{flex:1}]}
                            placeholder={ type == 0 ? 'Edit phone number' : 'Edit Email'}
                            multiline = {type == 0 ? false : true}
                            value = {type == 0 ? this.state.new_phone : this.state.new_email}
                            onBlur={() => {
                              this.setState({
                                keyboard:false,
                              })
                             }}
                            onFocus={() => {
                                this.setState({
                                  keyboard:true,
                                })
                            }} 
                            onChangeText={(text) => {

                              if (type == 0) {
                                this.setState({
                                  new_phone:text,
                               });
                              }else {
                                this.setState({
                                  new_email:text,
                               });
                              }
                               
                      
                            }}/>
                              


                       </View>   


                    
                        <View style = {[styles.view_line,{marginTop:7}]}/>   


                       

      
                         <View style = {[styles.xpop_cancel_confim,{marginTop:32}]}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={this.clickPopCancel.bind(this)}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Cancel</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickEditPhoneConfirm.bind(this,type)}>

                                <View style = {[styles.xpop_item,{backgroundColor:'#C44729'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#fff'}]}>Confirm</Text>

                              </View>

                            </TouchableOpacity>   

                                                   
                          </View> 


                          <View style = {{width:'100%',height:this.state.keyboard ? 280 : 0,}}/>                       
                     
                               
                      </View>
                  )
              },
          ()=>this.hidePopup(),
          CoverLayer.popupMode.bottom);

  }


  clickEditPhoneConfirm(){


    if (type == 0) {
       if (!this.state.new_phone) {
          toastShort('Edit phone number');
          return;
        } 

        //检验手机号是否存在
        this.userMobileExists();

    }else {

      if (!this.state.new_email) {
          toastShort('Edit Email');
          return;
        }  

        this.userEmailExists();

    }
   
    // this.coverLayer.hide();

  }


  userEmailExists(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:userEmailExists id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<email i:type="d:string">'+ this.state.new_email +'</email>'+
    '</n0:userEmailExists></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('client','userEmailExistsResponse',data, function(json) {


        if (json && json.success == 0 ) {
            
          //邮箱不存在 可以进行修改  
           temporary.getTSystemConfig();
        }else {

          // 邮箱已存在，不可进行修改
          Loading.hidden();
          toastShort('Email already exists!');

        }

    });


  }

  sendSmsForEmail(send_specific_email){


  var code = DateUtil.randomCode();

   this.setState({
      code: code,
   });


  var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:sendSmsForEmail id="o0" c:root="1" xmlns:n0="http://terra.systems/"><params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
  '<item><key i:type="d:string">company_id</key><value i:type="d:string">'+ this.state.head_company_id + '</value></item>'+
  '<item><key i:type="d:string">email</key><value i:type="d:string">'+ this.state.new_email +'</value></item>'+
  '<item><key i:type="d:string">from_email</key><value i:type="d:string">'+ send_specific_email + '</value></item>'+
  '<item><key i:type="d:string">message</key><value i:type="d:string">Your OTP is '+ code +'. Please enter the OTP within 2 minutes</value></item>'+
  '<item><key i:type="d:string">title</key><value i:type="d:string">[Chien Chi Tow] Edit Email</value></item>'+
  '<item><key i:type="d:string">client_id</key><value i:type="d:string">'+ this.state.userBean +'</value></item>'+
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




  userMobileExists(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:userMobileExists id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<mobile i:type="d:string">'+this.state.new_phone +'</mobile>'+
    '</n0:userMobileExists></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('client','userMobileExistsResponse',data, function(json) {


        Loading.hidden();
        if (json && json.success == 1 ) {
            
          //手机号不存在 可以进行修改  
           temporary.toEditLoginTypeActivity();
        }else {
          toastShort('Request was aborted!');

        }

    });


  }


  sendSmsForMobile(){


    var code = DateUtil.randomCode();

     this.setState({
        code: code,
     });

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:sendSmsForMobile id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">company_id</key><value i:type="d:string">'+ this.state.head_company_id +'</value></item>'+
    '<item><key i:type="d:string">mobile</key><value i:type="d:string">'+ this.state.new_phone +'</value></item>'+
    '<item><key i:type="d:string">message</key><value i:type="d:string">Your OTP is '+ code +'. Please enter the OTP within 2 minutes</value></item>'+
    '<item><key i:type="d:string">title</key><value i:type="d:string">Edit phone number</value></item>'+
    '</params></n0:sendSmsForMobile></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('sms','sendSmsForMobileResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1 ) {
            
          //手机号不存在 可以进行修改  
           temporary.toEditLoginTypeActivity();
        }else {
          toastShort('Request was aborted!');

        }

    });


  }


  toEditLoginTypeActivity(){

     this.hidePopup();;

    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('EditLoginTypeActivity',{
        'edit_type':this.state.edit_type,
        'edit_data':(this.state.edit_type == 0 ? this.state.new_phone : this.state.new_email),
        'code':this.state.code,
      });
    }

  }






  clickEditIdentification(){


         // 根据传入的方法渲染并弹出

    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}>Locked Information</Text>


                          <Text style = {[styles.text_popup_terms_content,{marginTop:32}]}>For security reasons, you will not be able to make changes to your Identification Number.</Text>


                          <Text style = {[styles.text_popup_terms_content,{marginBottom:32}]}>Please contact our staff or visit our nearby Chien Chi Tow outlet should you want to make any changes to this information</Text>


                       
                                 
                        </View>
                    )
                },
            ()=> this.hidePopup(),
            CoverLayer.popupMode.bottom);



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

                <Text style = {styles.text_title}>Account Management</Text>

                <View style = {[styles.view_item,{marginTop:32}]}>


                    <Text style = {styles.text_item_title}>Phone Number</Text>

                    <View style = {styles.view_item_item}>

                        <Text style = {styles.text_item_content}>{'+65 ' + (this.state.userBean ? this.state.userBean.mobile : '') }</Text>


                        <TouchableOpacity 
                            activeOpacity = {0.8}
                            onPress={this.clickEditPhone.bind(this,0)}>

                            <Image style = {{width:15,height:15}} 
                                    resizeMode = 'contain' 
                                    source={require('../../../../images/pencilxxxhdpi.png')}/>


                        </TouchableOpacity>    



                       
                    </View>


                    <View style = {styles.view_line}/>


                </View>


                <View style = {[styles.view_item,{marginTop:16}]}>


                    <Text style = {styles.text_item_title}>Email</Text>

                    <View style = {styles.view_item_item}>

                        <Text style = {styles.text_item_content}>{this.state.userBean ? this.state.userBean.email : ''}</Text>


                        <TouchableOpacity 
                            activeOpacity = {0.8}
                            onPress={this.clickEditPhone.bind(this,1)}>


                            <Image style = {{width:15,height:15}} 
                                    resizeMode = 'contain' 
                                    source={require('../../../../images/pencilxxxhdpi.png')}/>


                        </TouchableOpacity>    


                         


                    </View>


                    <View style = {styles.view_line}/>


                </View>


                <View style = {[styles.view_item,{marginTop:16}]}>


                    <Text style = {styles.text_item_title}>Identification No.</Text>

                    <View style = {styles.view_item_item}>

                        <Text style = {styles.text_item_content}>{this.state.userBean ? StringUtils.hideNRIC(this.state.userBean.card_number) : ''}</Text>



                        <TouchableOpacity 
                            activeOpacity = {0.8}
                            onPress={this.clickEditIdentification.bind(this)}>

                             <Image style = {{width:15,height:15}} 
                                resizeMode = 'contain' 
                                source={require('../../../../images/lockxxxhdpi.png')}/>


                        </TouchableOpacity>    

                        

                    </View>


                    <View style = {styles.view_line}/>


                </View>


                 <TouchableOpacity
                    style = {{width:'100%',marginTop:16}} 
                    activeOpacity = {0.8}
                    onPress={this.clickEditPhone.bind(this,2)}>



                    <View style = {[styles.view_item,]}>


                        <Text style = {styles.text_item_title}></Text>

                        <View style = {styles.view_item_item}>

                            <Text style = {styles.text_item_content}>Change Password</Text>


                           
                             <Image style = {{width:5,height:8.5,marginTop:8}} 
                                        resizeMode = 'contain' 
                                        source={require('../../../../images/you.png')}/>


                        </View>

                    </View>    



                </TouchableOpacity>    

                <View style = {[styles.view_line,{marginTop:11}]}/>


              
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
  view_item:{
    width:'100%',
  },
  text_item_title:{
    fontSize:14,
    fontWeight: 'bold',
    color: '#333333',
  },
  view_item_item:{
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  text_item_content:{
    fontSize:16,
    color: '#333333',
  },
  view_line:{
    marginTop:5,
    backgroundColor:'#e0e0e0',
    width:'100%',
    height: 1,
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
  text_popup_terms_content:{
    width:'100%',
    marginTop:16,
    fontSize:16,
    color:'#333333',
  },
  text_input:{
    marginTop:5,
    width:'100%',
    color:'#333333',
    fontSize:14,
  },
  text_forgot:{
    color:'#C44729',
    fontSize:14,
    fontWeight: 'bold',
  },
   xpop_cancel_confim:{
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
  view_newphone:{
    width:'100%',
    flexDirection: 'row',
  },
  text_quhao:{
    marginRight:8,
    marginTop:5,
    color:'#333333',
    fontSize:14,
  }

});
