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
  FlatList,
  DeviceEventEmitter,
  KeyboardAvoidingView,
  NativeModules
} from 'react-native';


import DeviceStorage from '../../uitl/DeviceStorage';

import IparInput from '../../widget/IparInput';

import CheckBox from 'react-native-check-box'

import { toastShort } from '../../uitl/ToastUtils';

import WebserviceUtil from '../../uitl/WebserviceUtil';

import { Loading } from '../../widget/Loading';


import CoverLayer from '../../widget/xpop/CoverLayer';

import StringUtils from '../../uitl/StringUtils';

import DateUtil from '../../uitl/DateUtil';

import MD5 from "react-native-md5";


import {CommonActions,useNavigation} from '@react-navigation/native';

const { StatusBarManager } = NativeModules;



export default class SignUp5Activity extends Component {


  constructor(props) {
    super(props);
    this.state = {
      head_company_id:'97',
      number:undefined,
      email:undefined,
      password:undefined,
      card_number:undefined,
      first_name:undefined,
      last_name:undefined,
      gender:undefined,
      birthday:undefined,
      cct_or_mp:undefined,
      invite_code:undefined,
      post_code:undefined,
      street_name:undefined,
      building_block_num:undefined,
      unit_num:undefined,
      city:undefined,
      countryData:undefined,
      userBean:undefined,
      selectedCountry:undefined,
      present_reward_discount:undefined,
      present_cash_voucher:undefined,
      present_invite_cash_voucher:undefined,
      newUser:undefined,
      friend_id:undefined,
      send_specific_email:undefined,
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
        email:this.props.route.params.email,
        password:this.props.route.params.password,
        card_number:this.props.route.params.card_number,
        first_name:this.props.route.params.first_name,
        last_name:this.props.route.params.last_name,
        gender:this.props.route.params.gender,
        birthday:this.props.route.params.birthday,
        cct_or_mp:this.props.route.params.cct_or_mp,
        invite_code:this.props.route.params.invite_code,
        userBean:this.props.route.params.userBean,
        post_code:this.props.route.params.userBean ? this.props.route.params.userBean.post_code : undefined,
        street_name:this.props.route.params.userBean ? this.props.route.params.userBean.street_name : undefined,
        building_block_num:this.props.route.params.userBean ? this.props.route.params.userBean.building_block_num : undefined,
        unit_num:this.props.route.params.userBean ? this.props.route.params.userBean.unit_num : undefined,
        city:this.props.route.params.userBean ? this.props.route.params.userBean.city : undefined,
      });
    }

    this.getTCountries();

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




  getTCountries(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTCountries id="o0" c:root="1" xmlns:n0="http://terra.systems/" /></v:Body></v:Envelope>';
    Loading.show();
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('country','getTCountriesResponse',data, function(json) {

        Loading.hidden();
        if (json && json.data ) { 
          //可用
          temporary.setState({
            countryData:json.data,
          });


          for (var i = 0; i < json.data.length; i++ ){
            
            if (json.data[i].name == 'Singapore') {

              temporary.setState({
                selectedCountry:json.data[i]
              });

              break;
            }
          }


        }

    });   


  }


  back(){
    this.props.navigation.goBack();
   
  }

  clickNext(){

    if (this.state.post_code && this.state.street_name && this.state.building_block_num && this.state.selectedCountry) {

        if (this.state.userBean) {

          //更新数据
          Loading.show();
          this.save(undefined,undefined);

        }else {

          //注册数据

          //10%的折扣
          this.getDiscountForRegister();

        }
    }


  }


  getDiscountForRegister(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getDiscountForRegister id="o0" c:root="1" xmlns:n0="http://terra.systems/"><name i:type="d:string">New Client</name><value i:type="d:string">0.1</value></n0:getDiscountForRegister></v:Body></v:Envelope>';
    Loading.show();
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('reward-discounts','getDiscountForRegisterResponse',data, function(json) {


        if (json && json.success == 1 && json.data && json.data.id ) { 

          temporary.setState({
            present_reward_discount : json.data.id,
          })

          if (temporary.state.invite_code) {
              temporary.getFreeGiftByValue(json.data.id);
          }else {

            temporary.save(json.data.id,undefined);

          }

        }else {
          Loading.hidden();
          toastShort('Network request failed！');
        }

    });   


  }

  getFreeGiftByValue(present_reward_discount){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header /><v:Body><n0:getFixedDiscount id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<value i:type="d:string">5</value>'+
    '</n0:getFixedDiscount></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('reward-discounts','getFixedDiscountResponse',data, function(json) {

        
        if (json && json.success == 1 && json.data && json.data.id ) { 

          temporary.setState({
             present_cash_voucher:json.data.id,
             present_invite_cash_voucher:json.data.id,
          })
          temporary.save(present_reward_discount,json.data.id);
        }else {
          Loading.hidden();
          toastShort('Network request failed！');
        }


    });   

  }




  save(present_reward_discount,present_cash_voucher){


    var id_item = '';

    if (this.state.userBean != undefined) {

      id_item = '<item><key i:type="d:string">id</key><value i:type="d:string">' + this.state.userBean.id +  '</value></item>';

    }

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header />'+
    '<v:Body><n0:saveTClient id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap"><item><key i:type="d:string">Client_Info</key><value i:type="n1:Map"> '+
    id_item + 
    '<item><key i:type="d:string">building_block_num</key><value i:type="d:string">' + this.state.building_block_num + '</value></item>'+
    '<item><key i:type="d:string">create_time</key><value i:type="d:string">' + DateUtil.formatDateTime() + '</value></item>'+
    '<item><key i:type="d:string">first_name</key><value i:type="d:string">' + this.state.first_name + '</value></item>'+
    '<item><key i:type="d:string">mobile</key><value i:type="d:string">' + this.state.number + '</value></item>'+
    '<item><key i:type="d:string">phone</key><value i:type="d:string">' + this.state.number + '</value></item>'+
    '<item><key i:type="d:string">present_invite_cash_voucher</key><value i:type="d:string">' + (this.state.invite_code ? this.state.present_invite_cash_voucher : '' ) + '</value></item>'+
    '<item><key i:type="d:string">cct_or_mp</key><value i:type="d:string">'+ this.state.cct_or_mp +'</value></item>'+
    '<item><key i:type="d:string">present_cash_voucher</key><value i:type="d:string">'+ (present_cash_voucher != undefined  ? present_cash_voucher : '')  +'</value></item>'+
    '<item><key i:type="d:string">is_display_on_all_booking</key><value i:type="d:string">1</value></item>'+
    '<item><key i:type="d:string">birthday</key><value i:type="d:string">'+ this.state.birthday +'</value></item>'+
    '<item><key i:type="d:string">card_number</key><value i:type="d:string">'+ this.state.card_number +'</value></item>'+
    '<item><key i:type="d:string">present_reward_discount</key><value i:type="d:string">'+ (present_reward_discount != undefined ? present_reward_discount : '') +'</value></item>'+
    '<item><key i:type="d:string">gender</key><value i:type="d:string">'+ this.state.gender +'</value></item>'+
    '<item><key i:type="d:string">street_name</key><value i:type="d:string">'+ this.state.street_name +'</value></item>'+
    '<item><key i:type="d:string">is_vip</key><value i:type="d:string">1</value></item>'+
    '<item><key i:type="d:string">is_delete</key><value i:type="d:string">0</value></item>'+
    '<item><key i:type="d:string">email</key><value i:type="d:string">'+ this.state.email + '</value></item>'+
    '<item><key i:type="d:string">source</key><value i:type="d:string">2</value></item>'+
    '<item><key i:type="d:string">sync_phone_calendar</key><value i:type="d:string">1</value></item>'+
    '<item><key i:type="d:string">city</key><value i:type="d:string">'+ (this.state.city != undefined ? this.state.city : '') +'</value></item>'+
    '<item><key i:type="d:string">unit_num</key><value i:type="d:string">'+ (this.state.unit_num != undefined ? this.state.unit_num : '') + '</value></item>'+
    '<item><key i:type="d:string">post_code</key><value i:type="d:string">'+ this.state.post_code + '</value></item>'+
    '<item><key i:type="d:string">last_name</key><value i:type="d:string">'+ this.state.last_name +'</value></item>'+
    '<item><key i:type="d:string">invite_code</key><value i:type="d:string">'+ (this.state.invite_code ?  this.state.invite_code : '') + '</value></item>'+
    '<item><key i:type="d:string">company_id</key><value i:type="d:string">'+ this.state.head_company_id +'</value></item>'+
    '<item><key i:type="d:string">country_id</key><value i:type="d:string">'+ this.state.selectedCountry.id + '</value></item>'+
    '</value></item><item><key i:type="d:string">User_Info</key><value i:type="n1:Map">'+
    '<item><key i:type="d:string">password</key><value i:type="d:string">'+ MD5.hex_md5(this.state.password) +'</value></item>'+
    '</value></item></data><logData i:type="n2:Map" xmlns:n2="http://xml.apache.org/xml-soap"><item><key i:type="d:string">ip</key><value i:type="d:string"></value></item><item><key i:type="d:string">create_uid</key><value i:type="d:string">0</value></item></logData></n0:saveTClient></v:Body></v:Envelope>';
    
    var temporary = this;
  

    WebserviceUtil.getQueryDataResponse('client','saveTClientResponse',data, function(json) {

        if (json && json.success == 1 && json.data) { 


          temporary.setState({
            newUser:json.data,
          });

          temporary.welcomeNote();
         
        }else {
          Loading.hidden();
          toastShort('Network request failed！');
        }

    });   


  }



  welcomeNote(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:welcomeNote id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+  this.state.newUser.client_id +'</clientId>'+
    '</n0:welcomeNote></v:Body></v:Envelope>';

     var temporary = this;
    
    WebserviceUtil.getQueryDataResponse('notifications','welcomeNoteResponse',data, function(json) {

        
        if (temporary.invite_code) {
          //
          temporary.getIdByReferralCode();
        }else {
         // temporary.nextActivity();
         temporary.sendSmsForEmail();
        }
        
     });
  }


  getIdByReferralCode(){


    var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getIdByReferralCode id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<code i:type="d:string">'+ this.state.invite_code +'</code></n0:getIdByReferralCode></v:Body></v:Envelope>';

    var temporary = this;

    WebserviceUtil.getQueryDataResponse('client','getIdByReferralCodeResponse',data, function(json) {

        
        if (json && json.success == 1 && json.data) {

            temporary.setState({
              friend_id:json.data,
            })
            temporary.friendUseReferral();
        }else {
          //temporary.nextActivity();
          temporary.sendSmsForEmail();
        }       
    });
  }

  friendUseReferral(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:friendUseReferral id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<friendId i:type="d:string">'+ this.state.friend_id +'</friendId>'+
    '<clientId i:type="d:string">'+ this.state.newUser.client_id +'</clientId>'+
    '</n0:friendUseReferral></v:Body></v:Envelope>';

    var temporary = this;

    WebserviceUtil.getQueryDataResponse('notifications','friendUseReferralResponse',data, function(json) {

        
         // temporary.nextActivity();
         temporary.sendSmsForEmail();
         
    });   


  }


sendSmsForEmail(){

  var message = 'You have successfully registered for your personal Chien Chi Tow App account.';

  message += 'Welcome to Chien Chi Tow App, your personal health or wellness companion. Be rewarded and enjoy exclusive deals when you use the App. Check your CCT points that you have collected from your purchases. Use the App to make an appointment with us now!';


  var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:sendSmsForEmail id="o0" c:root="1" xmlns:n0="http://terra.systems/"><params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
  '<item><key i:type="d:string">company_id</key><value i:type="d:string">'+ this.state.head_company_id + '</value></item>'+
  '<item><key i:type="d:string">email</key><value i:type="d:string">'+ this.state.email +'</value></item>'+
  '<item><key i:type="d:string">from_email</key><value i:type="d:string">'+ this.state.send_specific_email + '</value></item>'+
  '<item><key i:type="d:string">message</key><value i:type="d:string">'+ message  +'</value></item>'+
  '<item><key i:type="d:string">title</key><value i:type="d:string">[Chien Chi Tow]</value></item>'+
  '<item><key i:type="d:string">client_id</key><value i:type="d:string">'+ this.state.newUser.client_id +'</value></item>'+
  '</params></n0:sendSmsForEmail></v:Body></v:Envelope>';

  var temporary = this;

  
  WebserviceUtil.getQueryDataResponse('sms','sendSmsForEmailResponse',data, function(json) {
 
      

        temporary.nextActivity();
        
    });
}


  nextActivity(){

    Loading.hidden();
   
    // if (this.state.userBean) {
    //   toastShort('welcome Back!');
    // }else {
    //   toastShort('Sign up was successfull!');
    // }

    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>

                          <Text style = {styles.text_popup_content}>Your have successfully registered your account!</Text>
               
                        </View>
                       
                    )
                },
            ()=>this.getTClientPartInfo(),
            CoverLayer.popupMode.bottom);



    // const { navigation } = this.props;
    
    // if (navigation) {

    //     navigation.dispatch(
    //       CommonActions.reset({
    //         index: 0,
    //         routes: [
    //           { name: 'LoginActivity' },
    //         ],
    //      })
    //     );

    // }

  }



  getTClientPartInfo(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTClientPartInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ this.state.newUser.client_id+'</clientId>'+
    '</n0:getTClientPartInfo></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('client','getTClientPartInfoResponse',data, function(json) {

       
         Loading.hidden();
        if (json && json.success == 1 && json.data ) {

            temporary.toMainActivity(json.data);

        }else {
         
            temporary.toLoginActivity();
        }

    });


  }


toMainActivity(userBean){


  DeviceStorage.save('login_name', this.state.number);
  DeviceStorage.save('login_password', this.state.password);

  DeviceStorage.save('login_client_id', this.state.newUser.client_id); 
  DeviceStorage.save('UserBean', userBean);  

  NativeModules.NativeBridge.setLoginPwd(this.state.password);
  NativeModules.NativeBridge.setClientId(this.state.newUser.client_id.toString());
  NativeModules.NativeBridge.setUserId(userBean.user_id.toString());

  const { navigation } = this.props;
   if (navigation) {
      // navigation.replace('MainActivity');
      navigation.dispatch(
        CommonActions.reset({
          index: 0,
          routes: [
            { name: 'MainActivity' },
          ],
       })
      );
    }


}





  toLoginActivity(){

    const { navigation } = this.props;
    
    if (navigation) {

        navigation.dispatch(
          CommonActions.reset({
            index: 0,
            routes: [
              { name: 'LoginActivity' },
            ],
         })
        );

    }

  }






  clickCountry(){

    // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}>Select Country</Text>

                          <FlatList
                              style = {styles.flat_popup}
                              ref = {(flatList) => this._flatList = flatList}
                              renderItem = {this._renderItem}
                              onEndReachedThreshold={0}
                              keyExtractor={(item, index) => index.toString()}
                              data={this.state.countryData}/>

                         


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
          onPress = {this.clickCountryItem.bind(this,item)}>

          <Text style = {styles.text_popup_content}>{item.item.name}</Text>


          <View style = {styles.view_item_line}/>


        </TouchableOpacity>  

      );

  }


  clickCountryItem(item){
    this.coverLayer.hide();

    this.setState({
      selectedCountry:item.item,
    });

  }


  postCodeError(){

    if (!this.state.post_code || StringUtils.isPostCode(this.state.post_code)) {


    return (<View></View>);


    }else {

    return (

        <View style = {styles.view_eamil_error} >

          <Text style = {styles.text_error}>・Postal Code entered is invalid</Text>

        </View>);

    }


  }






  render() {


    return(
         <View style = {styles.bg}>
            <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

            <SafeAreaView style = {[styles.afearea,{marginTop:this.state.statusbarHeight}]} >

              <View style = {styles.header}>

                <TouchableOpacity  
                  onPress={this.back.bind(this)}>
                  <View style ={styles.rightView} >
                      <Image
                        style={{width:8,height:12}}
                        source={require('../../../images/left_0909.png')}
                        resizeMode = 'contain' />
                  </View>
                </TouchableOpacity>


              <View style = {styles.view_progress}>

                <View style = {styles.view_progress_1}/>
                <View style = {styles.view_progress_4}/>
                <View style = {styles.view_progress_4}/>
                <View style = {styles.view_progress_3}/>


              </View>


              <View style = {styles.zhanwei1}/>

            </View>


        <KeyboardAvoidingView behavior={Platform.OS == "ios" ? "padding" : "height"} style = {styles.keyboar}>


          <ScrollView style = {styles.scrollview}
              contentOffset={{x: 0, y: 0}}
              onScroll={this.changeScroll}>


            <View style = {styles.view_title} >

              <Text style = {styles.text_title}>Where do you reside</Text>

            </View>



            <View style = {styles.view_content}>


            <View style = {styles.view_iparinput}>
                <IparInput
                    valueText = {this.state.post_code} 
                    placeholderText={'Postal Code*'}
                    onChangeText={(text) => {
                         
                      this.setState({post_code:text})
                    }}/>

            </View>


            {this.postCodeError()}


            <View style = {styles.view_iparinput}>
                <IparInput 
                    valueText = {this.state.street_name} 
                    placeholderText={'Street Name*'}
                    onChangeText={(text) => {
                         
                      this.setState({street_name:text})
                    }}/>

            </View>



            <View style = {styles.view_iparinput}>
                <IparInput
                    valueText = {this.state.building_block_num} 
                    placeholderText={'Building/Block Number*'}
                    onChangeText={(text) => {
                         
                      this.setState({building_block_num:text})
                    }}/>

            </View>


            <View style = {styles.view_iparinput}>
                <IparInput 
                    valueText = {this.state.unit_num}
                    placeholderText={'Unit Number'}
                    onChangeText={(text) => {
                         
                      this.setState({unit_num:text})
                    }}/>

            </View>


            <View style = {styles.view_iparinput}>
                <IparInput 
                    valueText = {this.state.city}
                    placeholderText={'City'}
                    onChangeText={(text) => {
                         
                      this.setState({city:text})
                    }}/>

            </View>



            <TouchableOpacity                      
                activeOpacity = {0.8}
                onPress={this.clickCountry.bind(this)}>

                <View style = {styles.view_id_type}>

                    <Text style = {[styles.text_id_type,{color:(this.state.selectedCountry) ? '#333' : '#828282'}]}>{this.state.selectedCountry ? this.state.selectedCountry.name : 'Country*'}</Text>

                    <Image style = {styles.image_id_more} 
                      resizeMode = 'contain' 
                      source={require('../../../images/xia.png')}/>


                  </View> 

              </TouchableOpacity>



              <View style = {[styles.view_item_line,{marginTop:16}]} />

           

            <View style = {[styles.bg,{backgroundColor:'#FFFFFF'}]}/>








             <View style = {styles.next_view}>

              <TouchableOpacity style = {[styles.next_layout,{backgroundColor:(this.state.post_code &&  StringUtils.isPostCode(this.state.post_code) && this.state.street_name && this.state.building_block_num  && this.state.selectedCountry) ? '#C44729' : '#BDBDBD'}]}  
                    activeOpacity = {(this.state.post_code &&  StringUtils.isPostCode(this.state.post_code) && this.state.street_name && this.state.building_block_num  && this.state.selectedCountry) ? 0.8 : 1}
                    onPress={this.clickNext.bind(this)}>


                <Text style = {styles.next_text}>Done</Text>



              </TouchableOpacity>



            </View>

          </View>


          </ScrollView>


       </KeyboardAvoidingView>        



          

          </SafeAreaView>


          <CoverLayer ref={ref => this.coverLayer = ref}/>

          <SafeAreaView style = {styles.afearea_foot} />



         </View>


    );
  }

}


const styles = StyleSheet.create({

  bg: {
    flex:1,
    backgroundColor:'#145A7C',
  },
  afearea:{
    flex:1,
    backgroundColor:'#145A7C'
  },
  afearea_foot:{
    flex:0,
    backgroundColor:'#FFFFFF'
  },
  header: {
    width: '100%',
    height: 50,
    backgroundColor: '#145A7C',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  rightView: {
    width: 50,
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  view_progress:{
    flex:1,
    flexDirection: 'row',
    justifyContent: 'center',
     alignItems: 'center',
  },
  zhanwei1 :{

    width: 50,
    height: '100%',

  },
  view_progress_1 :{
    width:48,
    height:4,
    borderTopLeftRadius:50,
    borderBottomLeftRadius:50,
    backgroundColor:'#FFFFFF'

  },
  view_progress_2 :{
    marginLeft:2,
    width:48,
    height:4,
    backgroundColor:'#BDBDBD'
  },
   view_progress_3 :{
    marginLeft:2,
    width:48,
    height:4,
    borderBottomRightRadius:50,
    borderTopRightRadius:50,
    backgroundColor:'#BDBDBD'

  },
  view_progress_4 :{
    marginLeft:2,
    width:48,
    height:4,
    backgroundColor:'#FFFFFF'
  },
  view_title : {
    paddingTop:8,
    paddingLeft:24,
    paddingBottom:48,
    backgroundColor:'#145A7C',
    width:'100%',
  },
  text_title :{
    marginRight:24,
    color:'#FFFFFF',
    fontSize: 24,
    fontWeight: 'bold',

  },
  view_content:{
    marginTop:-16,
    padding:24,
    flex:1,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16
  },
  view_iparinput:{
     marginTop:16,
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
  skip_text:{
    fontSize:16,
    color:'#333'
  },
  view_skip:{
    width:'100%',
    justifyContent: 'center',
    alignItems: 'center',  
  },

  view_id_type : {
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
  },
  text_id_type: {
    flex:1,
    fontSize:16,
    color:'#000000',
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
   view_eamil_error : {
    marginTop:16

  },
  text_error: {
      fontSize:12,
      color:'#C44729',
  },
  keyboar:{
    flex:1,
  },
  scrollview:{
    flex:1,
    backgroundColor:'#FFFFFF'
  },
image_id_more:{
  marginTop:8,
  width:12,
  height:6,
}
});