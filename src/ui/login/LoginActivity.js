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
import Toast from 'react-native-root-toast';

import { toastShort } from '../../uitl/ToastUtils';

import DeviceStorage from '../../uitl/DeviceStorage';

var nativeBridge = NativeModules.NativeBridge;


export default class LoginActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
    }
  }


   //注册通知
  componentDidMount(){

    var temporary = this;

    this.emit =  DeviceEventEmitter.addListener('login_qrcode',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
           

            var code_company = undefined;

            try{
              code_company = JSON.parse(params,'utf-8');
            }catch(e){

            }

            if (code_company != undefined && code_company.type != undefined && code_company.type == 'SignIn') {

                temporary.toSign1ActivityforCode(code_company);

            }else {

               toastShort("Please scan the correct QR Code !"); 

            } 
            
       });
  }

 componentWillUnmount(){

    this.emit.remove();

 }



  clickSignUp(){

    const { navigation } = this.props;
    if (navigation) {
      navigation.navigate('SignUp1Activity');
    }
  }


  clickLogin(){

    const { navigation } = this.props;
    
    if (navigation) {
      navigation.navigate('SignIn1Activity');
    }
  }

  clickCode(){

    const { navigation } = this.props;
     if (navigation) {

      //扫码页面
      navigation.navigate('ScanQRCodeActivity',{
        'service':undefined,
        'type':2,
      });

    }

  }

  toSign1ActivityforCode(code_company){

    DeviceStorage.save('code_company', code_company);

    const { navigation } = this.props;
    if (navigation) {
      //nativeBridge.openNativeVc('test');
      navigation.navigate('SignIn1Activity',{
        isFormQr:true,
      });
    }

  }




   render() {

    return (

      <View style = {styles.bg}>

         <SafeAreaView style = {styles.afearea_head} >

         </SafeAreaView>

         <ImageBackground style = {styles.image_background} source={require('../../../images/login_bg.jpg')}>

        <StatusBar barStyle="light-content" />

          <SafeAreaView style = {styles.afearea} >


                <ImageBackground 
                  resizeMode = 'stretch'  
                  style = {styles.image_background_icon} source={require('../../../images/bianyuan.png')}>

                    <Image style = {styles.image_icon} 
                      resizeMode = 'contain' 
                      source={require('../../../images/sign_icon.png')}/>


                </ImageBackground>


                <View style = {{flex:1}}/>


                <View style = {styles.view_title}>

                    <Text style = {styles.text_title}>Welcome to </Text>

                    <Text style = {styles.text_title}>Chien Chi Tow</Text>

                </View>



                <View style = {styles.view_content}>

                     <Text style = {styles.text_content}>A one stop service platform to manage your Chien Chi Tow and Madam Partum experience</Text>

                </View>


                

                <View style = {styles.view_button}>


                  <TouchableOpacity style = {[styles.next_layout,{backgroundColor:'#C44729'}]}  
                     activeOpacity = {0.8}
                     onPress={this.clickSignUp.bind(this)}>


                    <Text style = {[styles.next_text,{color:'#FFFFFF'}]}>Sign Up</Text>



                  </TouchableOpacity>


                  <TouchableOpacity style = {[styles.next_layout,{backgroundColor:'#FFFFFF'}]}  
                     activeOpacity = {0.8}
                     onPress={this.clickLogin.bind(this)}>


                    <Text style = {[styles.next_text,{color:'#C44729'}]}>Login</Text>



                  </TouchableOpacity>                  




                </View>




                <View style ={styles.view_title}>



                 <TouchableOpacity 
                      style = {styles.touch_code}  
                     activeOpacity = {0.8}
                     onPress={this.clickCode.bind(this)}>


                     <Image style = {styles.image_code} 
                      resizeMode = 'contain' 
                      source={require('../../../images/login_code.png')}/>


                    <Text style = {styles.text_session}>Check in Session</Text>



                  </TouchableOpacity>  



                

                </View>



                 <View style = {{flex:1}}/>





               






          </SafeAreaView>



            </ImageBackground> 

      
      </View>


    );
  }

}

const styles = StyleSheet.create({
  bg: {
    flex:1,
  },
  afearea: {
    flex:1,
  },
  afearea_head: {
    flex:0,
    backgroundColor:'#145A7C',
  },
  image_background:{
    flex:1,
  },
  image_background_icon:{
    width:'100%',
    height:300,
    justifyContent: 'center',
    alignItems: 'center'

  },
  image_icon:{
      width:200,
      height:200
  },
  view_title:{
    marginTop:16,
    width:'100%',
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_title:{
    fontSize: 32,
    color: '#FFFFFF',
    fontWeight: 'bold',
  },
  view_content:{
    marginLeft:32,
    paddingRight:32,
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_content:{
     marginTop:16,
    fontSize: 16,
    color: '#FFFFFF',
    justifyContent: 'center',
  },
  view_button:{
    marginLeft:32,
    paddingRight:32,
    flexDirection: 'row',
    justifyContent: 'space-between'
  },
  next_layout:{
    marginTop:48,
    width:'48%',
    height:44,
     borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center'

  },

  next_text:{
    fontSize: 14,
    fontWeight: 'bold',
  },
  image_code:{
      width:36,
      height:36

  },
  text_session:{
    marginTop:10,
    fontSize:14,
     fontWeight: 'bold',
     color:'#FFFFFF'
  },
  touch_code:{
    justifyContent: 'center',
    alignItems: 'center'
  }
  
});