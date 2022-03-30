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
  KeyboardAvoidingView,
  NativeModules
} from 'react-native';



import DeviceStorage from '../../uitl/DeviceStorage';

import IparInput from '../../widget/IparInput';

import CheckBox from 'react-native-check-box'

import { toastShort } from '../../uitl/ToastUtils';

import WebserviceUtil from '../../uitl/WebserviceUtil';

import DateUtil from '../../uitl/DateUtil';



import { Loading } from '../../widget/Loading';

import {RadioGroup, RadioButton} from 'react-native-flexi-radio-button'

import CoverLayer from '../../widget/xpop/CoverLayer';

import DateTimePicker from '@react-native-community/datetimepicker'

import {DatePicker} from "react-native-common-date-picker";

const { StatusBarManager } = NativeModules;


export default class SignUp4Activity extends Component {


  constructor(props) {
    super(props);
    this.state = {
      head_company_id:'97',
      number:undefined,
      email:undefined,
      password:undefined,
      card_number:undefined,
      isOneChecked:true,
      first_name:undefined,
      last_name:undefined,
      gender:1,
      birthday:undefined,
      show_birth_day:undefined,
      cct_or_mp:2,
      invite_code:undefined,
      userBean:undefined,
      y:0,
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


     if (this.props.route.params) {

      this.setState({
        number:this.props.route.params.number,
        email:this.props.route.params.email,
        password:this.props.route.params.password,
        card_number:this.props.route.params.card_number,
        userBean:this.props.route.params.userBean,
        first_name:this.props.route.params.userBean ? this.props.route.params.userBean.first_name : undefined,
        last_name:this.props.route.params.userBean ? this.props.route.params.userBean.last_name : undefined,
        gender:this.props.route.params.userBean ? this.props.route.params.userBean.gender : 1,
        birthday:this.props.route.params.userBean ? this.props.route.params.userBean.birthday : undefined,
        cct_or_mp:this.props.route.params.userBean ? this.props.route.params.userBean.cct_or_mp : 2,

      });
    }


  }



  toSignUp5Activity(){

    const { navigation } = this.props;
    
    if (navigation) {
      navigation.navigate('SignUp5Activity',{
        'number':this.state.number,
        'email':this.state.email,
        'password':this.state.password,
        'card_number':this.state.card_number,
        'userBean':this.state.userBean,
        'first_name':this.state.first_name,
        'last_name':this.state.last_name,
        'gender':this.state.gender,
        'birthday':this.state.birthday,
        'cct_or_mp':this.state.cct_or_mp,
        'invite_code':this.state.invite_code,

      });
    }
 }


  back(){

    this.props.navigation.goBack();

  }

  clickNext(){

    if (this.state.first_name && this.state.last_name && this.state.birthday && this.state.isOneChecked) {

       //是否有邀请码
      if (this.state.invite_code) {
        //验证邀请码
        this.checkReferralCodeExists();

       }else {
        // 下一界面
        this.toSignUp5Activity();
      }


    }



   

  }


  clickPopCancel(){
     this.coverLayer.hide();

  }


  clickPopConfirm(){
     this.coverLayer.hide();

      this.setState({
        birthday:this.state.show_birth_day,
     });

  }


  checkReferralCodeExists(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:checkReferralCodeExists id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
      '<code i:type="d:string">'+ this.state.invite_code + '</code></n0:checkReferralCodeExists></v:Body></v:Envelope>';


    Loading.show();


    var temporary = this;

    WebserviceUtil.getQueryDataResponse('client','checkReferralCodeExistsResponse',data, function(json) {


        Loading.hidden();
        if (json && json.success == 1 && json.data == 1) {
          
          //可用
          temporary.toSignUp5Activity();

        }else {

          //不可用
          temporary.showErrorPopup();

        }

    });   

  }


  showErrorPopup(){


       // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_xpopup_error}>The current invitation code is incorrect, please check !</Text>




                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);



  }








  clickBirth(){

    var defaultDate ;

    if (this.state.birthday == undefined) {
        this.setState({
          show_birth_day:DateUtil.formatDateTime1(),
        });

        defaultDate = DateUtil.formatDateTime1();

    }else {

       this.setState({
          show_birth_day:this.state.birthday,
        });

       defaultDate = this.state.birthday;

    }

      // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>

                          <Text style = {styles.text_popup_title}></Text>

                          <DatePicker
                              style = {styles.date_picker}
                              defaultDate = {defaultDate}
                              type = {'DD-MM-YYYY'}
                              minDate = {'1900-01-01'}
                              maxDate = {DateUtil.formatDateTime1()}
                              monthDisplayMode = {'en-short'}
                              showToolBar = {false}
                              onValueChange={(selectedIndex) => {
                                 this.setState({
                                  show_birth_day:selectedIndex,
                                });
                              }}
                          />


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
                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);
  }



changeScroll = (e) => {
    this.setState({y: e.nativeEvent.contentOffset.y});
  };


  enterReferralCode(){


      if (!this.state.userBean) {

        return (<View style = {styles.view_iparinput_referral}>
                  <IparInput
                    valueText = {this.state.invite_code}   
                     placeholderText={'Enter Referral Code,if any'}
                     onChangeText={(text) => {
                         
                        this.setState({invite_code:text})
                    }}

                     />

                </View>);

      }else {


        <View/>

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
                <View style = {styles.view_progress_2}/>
                <View style = {styles.view_progress_3}/>


              </View>


              <View style = {styles.zhanwei1}/>

            </View>



          <KeyboardAvoidingView behavior={Platform.OS == "ios" ? "padding" : "height"} style = {styles.keyboar}>


            <ScrollView style = {styles.scrollview}
              contentOffset={{x: 0, y: 0}}
              onScroll={this.changeScroll}>

              <View style = {styles.view_title} >

                <Text style = {styles.text_title}>General information</Text>

              </View>



               <View style = {styles.view_content}>

                <View style = {styles.view_iparinput}>
                  <IparInput
                     valueText = {this.state.first_name} 
                     placeholderText={'First name*'}
                     onChangeText={(text) => {
                         
                        this.setState({first_name:text})
                    }}

                     />

                </View>


                <View style = {styles.view_iparinput}>
                  <IparInput 
                     valueText = {this.state.last_name} 
                     placeholderText={'Last name*'}
                     onChangeText={(text) => {
                         
                        this.setState({last_name:text})
                    }}

                     />

                </View>


              <Text style = {styles.text_gender_title}>Gender</Text>


              <RadioGroup style = {styles.radio_group}
                  color='#C44729'  
                  selectedIndex={0}
                  onSelect={(index, value) => this.setState({gender:value})}>

                  <RadioButton style={styles.radio_button} value={'1'} >
                      <Text style={styles.radio_text}>Male</Text>
                  </RadioButton>


                  <RadioButton style={styles.radio_button} value={'2'} >
                      <Text style={styles.radio_text}>Female</Text>
                  </RadioButton>

              </RadioGroup>


              <TouchableOpacity 
                    activeOpacity = {0.8}
                    onPress={this.clickBirth.bind(this)}>


                 <View style = {styles.view_birth}>

                  <Text style = {[styles.text_birth,{color:this.state.birthday ? '#333' : '#828282'}]}>{this.state.birthday ? this.state.birthday : 'Date of Birth*' }</Text>

                  <Image style = {styles.image_birth} 
                        resizeMode = 'contain' 
                        source={require('../../../images/rili.png')}/>

                </View>


                <View style = {styles.line}/>


              </TouchableOpacity>

              

              <Text style = {styles.text_gender_title}>Are you a Madam Partum Customer</Text>


              <RadioGroup style = {styles.radio_group}
                  color='#C44729'  
                  selectedIndex={this.state.cct_or_mp == '2' ? 0 : 1}
                  onSelect={(index, value) => this.setState({cct_or_mp:value})}>

                  <RadioButton style={styles.radio_button} value={'2'} >
                      <Text style={styles.radio_text}>Yes</Text>
                  </RadioButton>


                  <RadioButton style={styles.radio_button} value={'1'} >
                      <Text style={styles.radio_text}>No</Text>
                  </RadioButton>

              </RadioGroup>



               {this.enterReferralCode()} 


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

                <Text style = {styles.text_checkbox_content}>Keep me updated with the latest health tips and promotions from Chien Chi Tow.</Text>
             </View>
 

            <View style = {[styles.bg,{backgroundColor:'#FFFFFF'}]}/>

            </View>


            </ScrollView>


          </KeyboardAvoidingView>



            
          <View style = {styles.next_view}>

                <TouchableOpacity style = {[styles.next_layout,{backgroundColor:(this.state.first_name && this.state.last_name && this.state.birthday && this.state.isOneChecked) ? '#C44729':'#BDBDBD'}]}  
                    activeOpacity = {(this.state.first_name && this.state.last_name && this.state.birthday && this.state.isOneChecked)  ? 0.8: 1}
                    onPress={this.clickNext.bind(this)}>


                <Text style = {styles.next_text}>Next</Text>



                </TouchableOpacity>



            </View>

          

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
  keyboar:{
    flex:1,
  },
  scrollview:{
    flex:1,
    backgroundColor:'#FFFFFF'
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
    paddingBottom:42,
    backgroundColor: '#145A7C',
    width:'100%',
  },
  text_title :{
    marginRight:24,
    color:'#FFFFFF',
    fontSize: 24,
    fontWeight: 'bold',

  },
    view_content:{
    marginTop:-10,
    padding:24,
    flex:1,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16
  },
  view_iparinput:{
     marginTop:16,
  },
  text_gender_title:{
    marginTop:16,
    color:'#333',
    fontSize: 14,
    fontWeight: 'bold',
  },
  radio_group:{
    marginTop:8,
    width:'100%',
    flexDirection: 'row',

  },
  radio_button :{
    width:180
   
  },
  radio_text:{
    flex:1,
    color:'#000',
    fontSize:16
  },
  view_birth :{
    marginTop:28,
    width:'100%',
    flexDirection: 'row',
  },
  text_birth:{
    flex:1,
    fontSize:16
  },
  image_birth : {
    width:13.5,
    height:13.5,
    marginTop:5
  },
  line : {
    marginTop:11,
    height:1,
    backgroundColor:'#e0e0e0',
    width:'100%'
  },
  view_iparinput_referral:{
    marginTop:0,
  },
  view_checkbox:{
     marginRight:11,
  },
  text_checkbox_content:{
    flex:1,
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
  checkbox:{
    justifyContent: 'center'
  },
  next_view:{
    paddingLeft:24,
    paddingRight:24,
    paddingTop:10,
    paddingBottom:74,
    width:'100%',
    backgroundColor:'#FFFFFF'
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
  date_picker:{
    width:'100%',
    height:220,
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
  text_xpopup_error : {
    marginBottom:50,
    width:'100%',
    fontSize:16,
    color:'#333'
  }
});


