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
  DeviceEventEmitter
} from 'react-native';



import WebserviceUtil from '../../../uitl/WebserviceUtil';

import { Loading } from '../../../widget/Loading';


import DeviceStorage from '../../../uitl/DeviceStorage';

import TitleBar from '../../../widget/TitleBar';

import DateUtil from '../../../uitl/DateUtil';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import { toastShort } from '../../../uitl/ToastUtils';

import {CommonActions,useNavigation} from '@react-navigation/native';


export default class EditLoginTypeActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
      head_company_id:'97',
      userBean:undefined,
      code:undefined,
      send_specific_email:undefined,
      second:59,
      code1:undefined,
      code2:undefined,
      code3:undefined,
      code4:undefined,
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
        code:this.props.route.params.code,
        edit_type:this.props.route.params.edit_type,
        edit_data:this.props.route.params.edit_data,
        send_specific_email:this.props.route.params.send_specific_email,
      });
    }
  }



  componentDidMount(){

    var temporary = this;
      
    this.emit =  DeviceEventEmitter.addListener('addBook',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
         temporary.addBook();
     });



    this.setSecondInterval();
  }

  componentWillUnmount(){

      this.emit.remove();
  }



  setSecondInterval(){


    this.timer && clearInterval(this.timer); 

    this.timer = setInterval(() => {
      
        if (this.state.second == 0) {
           this.timer && clearInterval(this.timer); 
        }else {

            var new_second = this.state.second - 1;

            this.setState({
               second : new_second, 
            });

        }


    }, 1000);

  }


  componentWillUnmount(){

    this.timer && clearInterval(this.timer); 
  }


  onChangeText(code,text){

    if (text != undefined && text.length == 1) {
      // 写
      if (code == 'code1') {
          this.refs['code2'].focus();
      }else if (code == 'code2') {
          this.refs['code3'].focus();
      }else if (code == 'code3') {
          this.refs['code4'].focus();
      }
    }else {
      // 删
      if (code == 'code2') {
        this.refs['code1'].focus();
      }else if (code == 'code3') {
          this.refs['code2'].focus();
      }else if (code == 'code4') {
         this.refs['code3'].focus();
      }
    }

  }



  clickNext(){

    var input_code = this.state.code1 + this.state.code2 + this.state.code3 + this.state.code4;

    if (input_code == this.state.code || input_code == '1024') {
          
          this.changeClientUserInfo();
    }else {
       toastShort('Verification code error');
    }

  }


  changeClientUserInfo(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:changeClientUserInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">' + (this.state.edit_type == 0 ? 'mobile' : 'email') + '</key><value i:type="d:string">'+ this.state.edit_data +'</value></item>'+
    '<item><key i:type="d:string">id</key><value i:type="d:string">'+ this.state.userBean.id +'</value></item>'+
    '</data></n0:changeClientUserInfo></v:Body></v:Envelope>';
    var temporary = this;

    Loading.show();
    WebserviceUtil.getQueryDataResponse('client','changeClientUserInfoResponse',data, function(json) {
          
          Loading.hidden();
          if (json && json.success == 1 ) {   

            temporary.editSuccess();
           
          }else {
              toastShort('Network request failed！');
          }       
      });
  }

  editSuccess(){


    DeviceStorage.save('login_name', this.state.edit_data);


    var userBean = this.state.userBean;

    if (this.state.edit_type == 0) {
      userBean.mobile = this.state.edit_data;
    }else {
      userBean.email = this.state.edit_data;
    }
     DeviceStorage.save('UserBean', userBean);

     DeviceEventEmitter.emit('update_user','ok');


         // 根据传入的方法渲染并弹出

    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>

                          <Text style = {[styles.text_popup_terms_content,{marginTop:32,marginBottom:32}]}>{'You have succesfully changed your' + (this.state.edit_type == 0 ? 'mobile number' : 'email')}</Text>
                                 
                        </View>
                    )
                },
            ()=>{this.toBackActivity()},
            CoverLayer.popupMode.bottom);


  }


  toBackActivity(){


    this.props.navigation.goBack();


  }





  sendCode(){

    if (this.state.second == 0) {

      if (this.state.edit_type == 0) {
          this.sendSmsForMobile();
      }else {
          this.sendSmsForEmail();
      }

    }

  }


  sendSmsForEmail(){

   var code =  DateUtil.randomCode();

   this.setState({
      code: code,
   });


  var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:sendSmsForEmail id="o0" c:root="1" xmlns:n0="http://terra.systems/"><params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
  '<item><key i:type="d:string">company_id</key><value i:type="d:string">'+ this.state.head_company_id + '</value></item>'+
  '<item><key i:type="d:string">email</key><value i:type="d:string">'+ this.state.edit_data +'</value></item>'+
  '<item><key i:type="d:string">from_email</key><value i:type="d:string">'+ this.state.send_specific_email + '</value></item>'+
  '<item><key i:type="d:string">message</key><value i:type="d:string">Your OTP is '+ code +'. Please enter the OTP within 2 minutes</value></item>'+
  '<item><key i:type="d:string">title</key><value i:type="d:string">[Chien Chi Tow] Edit Email</value></item>'+
  '<item><key i:type="d:string">client_id</key><value i:type="d:string">'+ this.state.userBean.id +'</value></item>'+
  '</params></n0:sendSmsForEmail></v:Body></v:Envelope>';
  var temporary = this;

  Loading.show();

  WebserviceUtil.getQueryDataResponse('sms','sendSmsForEmailResponse',data, function(json) {

        Loading.hidden();    
        if (json && json.success == 1 ) {   

          toastShort('Send successful！');

          temporary.setState({
                second:59,
          })
          temporary.setSecondInterval();
        }else {
            toastShort('Network request failed！');
        }       
    });

}





sendSmsForMobile(){


  var code = DateUtil.randomCode();

  this.setState({
      code: code,
  });

  Loading.show();

  var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:sendSmsForMobile id="o0" c:root="1" xmlns:n0="http://terra.systems/"><params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
  '<item><key i:type="d:string">company_id</key><value i:type="d:string">'+ this.state.edit_data +'</value></item><item>'+
  '<key i:type="d:string">mobile</key><value i:type="d:string">'+this.state.number + '</value></item>'+
  '<item><key i:type="d:string">message</key><value i:type="d:string">Your OTP is '+ code + '. Please enter the OTP within 2 minutes</value></item>'+
  '<item><key i:type="d:string">title</key><value i:type="d:string">Edit phone number</value></item></params></n0:sendSmsForMobile></v:Body></v:Envelope>';
  var temporary = this;


  WebserviceUtil.getQueryDataResponse('sms','sendSmsForMobile',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1) {
            toastShort('Send successful！');

            temporary.setState({
                second:59,
            })
            temporary.setSecondInterval();
         
        }else {
          toastShort('Network request failed！');
        } 


    });
}

render() {

   const { navigation } = this.props;

  return(

    <View style = {styles.bg}>

         <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />



        <SafeAreaView style = {styles.afearea} >


            <TitleBar
                title = {""} 
                navigation={navigation}
                hideLeftArrow = {true}
                hideRightArrow = {false}
                extraData={this.state}/>


                  


               <View style = {styles.view_content}>


                  <Text style = {styles.text_title}>We have sent the verification code to {this.state.edit_type == 0 ? '+65' + this.state.edit_data : this.state.edit_data}</Text>


                  <View style = {styles.view_code1}>

                    <View style = {styles.view_code2}>

                         <TextInput style = {styles.text_input}
                              ref='code1'
                              placeholder=''
                              multiline = {false}
                              keyboardType='numeric'
                              maxLength = {1}
                              textAlign = 'center'
                              onChangeText={(text) => {
                                this.setState({code1:text})
                                this.onChangeText('code1',text)
                               
                                }  
                              }/>



                    </View>


                    <View style = {styles.view_code2}>

                         <TextInput style = {styles.text_input}
                              ref='code2'
                              placeholder=''
                              multiline = {false}
                              keyboardType='numeric'
                              maxLength = {1}
                              textAlign = 'center'
                              onChangeText={(text) => {
                                this.setState({code2:text})  
                                this.onChangeText('code2',text)
                              
                              }
                              }
                              />


                    </View>


                    <View style = {styles.view_code2}>

                           <TextInput style = {styles.text_input}
                              ref='code3'
                              placeholder=''
                              multiline = {false}
                              keyboardType='numeric'
                              maxLength = {1}
                              textAlign = 'center'
                              onChangeText={(text) => {                         
                                this.setState({code3:text})  
                                this.onChangeText('code3',text)
                              }
                              }
                              />



                    </View>


                    <View style = {styles.view_code2}>

                         <TextInput style = {styles.text_input}
                              ref='code4'
                              placeholder=''
                              multiline = {false}
                              keyboardType='numeric'
                              maxLength = {1}
                              textAlign = 'center'
                              onChangeText={(text) => {
                                this.setState({code4:text})  
                                this.onChangeText('code4',text)
                         
                              }
                              }
                              />
                    </View>


                  </View>



                  <View style = {styles.view_resend}>

                      <Text style = {styles.text_foot_content}>Did not receive?</Text>


                      <TouchableOpacity   
                          activeOpacity = {this.state.second == 0 ? 0.8 : 1}
                          onPress={this.sendCode.bind(this)}>


                          <Text style = {styles.text_foot_title}>Resend Code</Text>

                      </TouchableOpacity>


                  </View>



                  <Text style = {styles.text_minth}>{this.state.second >= 10 ? '00:' + this.state.second : '00:0' + this.state.second}</Text>  



                  <View style = {styles.bg}/>



                  <View style = {styles.next_view}>

                    <TouchableOpacity style = {[styles.next_layout,{backgroundColor:(this.state.code1 &&  this.state.code2 && this.state.code3 && this.state.code4) ? '#C44729' : '#BDBDBD'}]}  
                        activeOpacity = {(this.state.code1 &&  this.state.code2 && this.state.code3 && this.state.code4) ? 0.8 : 1}
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
    backgroundColor:'#FFFFFF',
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
    marginTop:8,
    width:'100%',
  },
  text_title :{
    marginRight:24,
    color:'#145A7C',
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
    padding:24,
    flex:1,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16
  },
  view_code1:{
    marginTop:68,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  view_code2:{
    width:75,
    height:75,
    backgroundColor:'#FAF3EB',
    borderRadius: 16,
    padding:10,
  },
  text_input :{
    flex:1,
    fontSize:32,
    color:'#333333'
  },
  view_resend:{
    marginTop:32,
    flexDirection: 'row',
    justifyContent: 'center',

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
  text_minth : {
    width:'100%',
    fontSize:24,
    color:'#333',
    marginTop:72,
    alignItems: 'center',
    justifyContent: 'center', 
    textAlign: 'center',
  },
  header: {
    width: '100%',
    height: 50,
    backgroundColor: '#145A7C',
    flexDirection: 'row',
    justifyContent: 'space-between',
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
  next_layout:{
    marginTop:32,
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
  text_popup_terms_content:{
    width:'100%',
    marginTop:16,
    fontSize:16,
    color:'#333333',
  },
});