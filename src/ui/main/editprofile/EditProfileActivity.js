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
  KeyboardAvoidingView,
  Dimensions,
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

import {RadioGroup, RadioButton} from 'react-native-flexi-radio-button'



export default class EditProfileActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       first_name:undefined,
       gender:'1',
       cct_or_mp:undefined,
       birthday:undefined,
      post_code:undefined,
      street_name:undefined,
      building_block_num:undefined,
      unit_num:undefined,
      city:undefined,
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


      if (user_bean) {
        this.setState({
          userBean: user_bean,
          first_name:user_bean.first_name,
          last_name:user_bean.last_name,
          gender:user_bean.gender,
          birthday:user_bean.birthday,
          post_code:user_bean.post_code,
          street_name:user_bean.street_name,
          building_block_num:user_bean.building_block_num,
          unit_num:user_bean.unit_num,
          city:user_bean.city,
          cct_or_mp:user_bean.cct_or_mp,
        });

      }
     
    });

  }


  clickBirth(){


     // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title,]}>Locked Information</Text>

                          
                          <Text style = {styles.text_popup_data_cotent}>For security reasons, you will not be able to make changes to your Date of Birth.</Text>


                          <Text style = {[styles.text_popup_data_cotent,{marginBottom:32}]}>Please contact our staff or visit our nearby Chien Chi Tow outlet should you want to make any changes to this information</Text>
                        

                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);


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


  clickNext(){

    if (!this.state.first_name) {
      toastShort('Please fill in the First Name');
      return;
    }

    if (!this.state.last_name) {
      toastShort('Please fill in the Last Name');
      return;
    }

    if (!this.state.post_code) {
      toastShort('Please fill in the Post Code');
      return;
    }

    if (!StringUtils.isPostCode(this.state.post_code)) {

      toastShort('Post Code entered is invalid');
      return;

    }

    if (!this.state.street_name) {
      toastShort('Please fill in the Street Name');
      return;
    }

    if (!this.state.building_block_num) {
      toastShort('Please fill in the Building/Block Number');
      return;
    }

    if (!this.state.unit_num) {
      toastShort('Please fill in the Unit Number');
      return;
    }

    if (!this.state.city) {
      toastShort('Please fill in the City');
      return;
    }


    this.changeClientInfo();

  }

  changeClientInfo(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
    '<n0:changeClientInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">last_name</key><value i:type="d:string">'+ this.state.last_name +'</value></item>'+
    '<item><key i:type="d:string">cct_or_mp</key><value i:type="d:string">'+ this.state.cct_or_mp +'</value></item>'+
    '<item><key i:type="d:string">first_name</key><value i:type="d:string">'+ this.state.first_name  +'</value></item>'+
    '<item><key i:type="d:string">unit_num</key><value i:type="d:string">'+ this.state.unit_num +'</value></item>'+
    '<item><key i:type="d:string">gender</key><value i:type="d:string">'+ this.state.gender +'</value></item>'+
    '<item><key i:type="d:string">street_name</key><value i:type="d:string">'+ this.state.street_name +'</value></item>'+
    '<item><key i:type="d:string">birthday</key><value i:type="d:string">'+ this.state.birthday +'</value></item>'+
    '<item><key i:type="d:string">source</key><value i:type="d:string">1</value></item>'+
    '<item><key i:type="d:string">building_block_num</key><value i:type="d:string">'+ this.state.building_block_num +'</value></item>'+
    '<item><key i:type="d:string">post_code</key><value i:type="d:string">'+ this.state.post_code +'</value></item>'+
    '<item><key i:type="d:string">id</key><value i:type="d:string">'+ this.state.userBean.id +'</value></item>'+
    '</data></n0:changeClientInfo></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('client','changeClientInfoResponse',data, function(json) {

        if (json && json.success == 1 ) {
           
            temporary.getTClientPartInfo();
        }else {
           Loading.hidden();
           toastShort('Network request failed！');
        }

    });
  }


  getTClientPartInfo(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTClientPartInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
    '</n0:getTClientPartInfo></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('client','getTClientPartInfoResponse',data, function(json) {
         Loading.hidden();
        if (json && json.success == 1 && json.data ) {
             toastShort('Edit Profile SuccessFully!');
            temporary.upAppClitent(json.data);

        }else {
          toastShort('Network request failed！');
        }

    });

  }


  upAppClitent(newUser){
   
    DeviceStorage.update('UserBean', newUser);  
    DeviceEventEmitter.emit('user_update',JSON.stringify(newUser));
    this.props.navigation.goBack();
  }




  render() {

    const { navigation } = this.props;

     return(

        <View style = {styles.bg}>

          <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

          <SafeAreaView style = {styles.afearea} >

             <TitleBar
                title = {'Edit Profile'} 
                navigation={navigation}
                hideLeftArrow = {true}
                hideRightArrow = {false}
                extraData={this.state}/>


            <View style = {styles.view_content}>


              <KeyboardAvoidingView behavior={Platform.OS == "ios" ? "padding" : "height"} style = {{flex:1}}>

                 <ScrollView 
                    style = {styles.scrollview}
                    showsVerticalScrollIndicator = {false}
                    contentOffset={{x: 0, y: 0}}
                    onScroll={this.changeScroll}>


                    <Text style = {styles.text_title}>Edit Profile</Text>


                    <View style = {styles.view_name}>

                        <Text style = {styles.text_item_title}>Name</Text>


                       <View style = {styles.view_iparinput}>
                            <IparInput
                                valueText = {this.state.first_name} 
                                placeholderText={'First Name'}
                                onChangeText={(text) => {                                  
                                  this.setState({first_name:text})
                                }}/>
                        </View>


                        <View style = {styles.view_iparinput}>
                            <IparInput
                                valueText = {this.state.last_name} 
                                placeholderText={'Last Name'}
                                onChangeText={(text) => {                                  
                                  this.setState({last_name:text})
                                }}/>
                        </View>


                    </View>


                    <Text style = {styles.text_item_title}>Gender</Text>


                    <RadioGroup style = {styles.radio_group}
                        color='#C44729'  
                        selectedIndex={parseInt(this.state.gender) - 1}
                        onSelect={(index, value) => this.setState({gender:value})}>

                        <RadioButton style={styles.radio_button} value={'1'} >
                            <Text style={styles.radio_text}>Male</Text>
                        </RadioButton>


                        <RadioButton style={styles.radio_button} value={'2'} >
                            <Text style={styles.radio_text}>Female</Text>
                        </RadioButton>

                    </RadioGroup>



                     <Text style = {styles.text_item_title}>Date of Birth</Text>


                     <TouchableOpacity 
                          activeOpacity = {0.8}
                          onPress={this.clickBirth.bind(this)}>


                       <View style = {styles.view_birth}>

                        <Text style = {[styles.text_birth,{color:'#333'}]}>{this.state.birthday}</Text>

                        <Image style = {styles.image_birth} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/lockxxxhdpi.png')}/>

                      </View>


                      <View style = {styles.view_line}/>


                    </TouchableOpacity>


                     <Text style = {styles.text_item_title}>Address</Text>


                      <View style = {styles.view_iparinput}>
                        <IparInput
                            valueText = {this.state.post_code} 
                            placeholderText={'Post Code*'}
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
                            placeholderText={'Unit Number*'}
                            onChangeText={(text) => {
                                 
                              this.setState({unit_num:text})
                            }}/>

                    </View>


                    <View style = {styles.view_iparinput}>
                        <IparInput 
                            valueText = {this.state.city}
                            placeholderText={'city'}
                            onChangeText={(text) => {
                                 
                              this.setState({city:text})
                            }}/>

                    </View>



                    <Text style = {styles.text_item_title}>Madam Partum Customer</Text>


                    <RadioGroup style = {styles.radio_group}
                        color='#C44729'  
                        selectedIndex={parseInt(this.state.cct_or_mp) - 1}
                        onSelect={(index, value) => this.setState({cct_or_mp:value})}>

                        <RadioButton style={styles.radio_button} value={'1'} >
                            <Text style={styles.radio_text}>Yes</Text>
                        </RadioButton>


                        <RadioButton style={styles.radio_button} value={'2'} >
                            <Text style={styles.radio_text}>No</Text>
                        </RadioButton>

                    </RadioGroup>


                </ScrollView>


              </KeyboardAvoidingView>      


                 <View style = {styles.next_view}>

                    <TouchableOpacity style = {[styles.next_layout]}  
                          activeOpacity = {0.8}
                          onPress={this.clickNext.bind(this)}>


                      <Text style = {styles.next_text}>Save</Text>

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
    backgroundColor:'#FFFFFF'
  },
   scrollview:{
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  text_title:{
    fontSize:24,
    fontWeight:'bold',
    color:'#145A7C',
  },
  view_name:{
     width:'100%',
  },
  text_item_title:{
     marginTop:32,
     width:'100%',
     fontSize:14,
     fontWeight:'bold',
     color:'#333333',
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
  view_line:{
    marginTop:10,
    width:'100%',
    height:1,
    backgroundColor:'#e0e0e0'
  },
  next_layout:{
    marginTop:32,
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
    marginBottom:32,
    width:'100%',
    height:44,

  },
  text_error: {
    fontSize:12,
    color:'#C44729',
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
  text_popup_data_cotent : {
    width:'100%',
    marginTop:32,
    fontSize:16,
    color:'#333'
  },
   text_popup_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:16,
    textAlign :'center',
    fontWeight: 'bold',
  },
});


