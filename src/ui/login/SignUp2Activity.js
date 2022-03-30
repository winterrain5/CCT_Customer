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


import DeviceStorage from '../../uitl/DeviceStorage';

import TitleBar from '../../widget/TitleBar';

import { Loading } from '../../widget/Loading';

import DateUtil from '../../uitl/DateUtil';

import CoverLayer from '../../widget/xpop/CoverLayer';

import { toastShort } from '../../uitl/ToastUtils';

const { StatusBarManager } = NativeModules;



export default class SignUp2Activity extends Component {

  constructor(props) {
    super(props);
    this.state = {
      head_company_id:'97',
      userBean:undefined,
      number:undefined,
      code:undefined,
      second:59,
      code1:undefined,
      code2:undefined,
      code3:undefined,
      code4:undefined,
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

  componentDidMount(){


    if (this.props.route.params) {

      this.setState({
        number:this.props.route.params.number,
        code:this.props.route.params.code,
        userBean:this.props.route.params.userBean,
      });
    }



    this.setSecondInterval();

    

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

      var new_code;

      if (code == 'code1') {
         
         new_code = text + this.state.code2 + this.state.code3 + this.state.code4 ; 
      }else if (code == 'code2') {
         
         new_code = this.state.code1 + text + this.state.code3 + this.state.code4 ; 
      }else if (code == 'code3') {

        new_code = this.state.code1 + this.state.code2 + text + this.state.code4 ; 
          
      }else if (code == 'code4') {

        new_code = this.state.code1 + this.state.code2 + this.state.code3 + text ; 
      }



    if (new_code == this.state.code || new_code == '1024') {

        this.toSignUp2_1Activity();

    }


} 


toSignUp2_1Activity(){


  const { navigation } = this.props;
    
    if (navigation) {

      if (this.state.userBean) {

        navigation.navigate('WelcomeBackActivity',{
          'number':this.state.number,
          'userBean':this.state.userBean,
        });

      }else {
        navigation.navigate('SignUp2_1Activity',{
          'number':this.state.number,
          'userBean':this.state.userBean,
        });
        
      }


      
    }


} 


clickTerms(){
  NativeModules.NativeBridge.showTermsConditionsView();
}

clickPrivacyPolicy() {
  NativeModules.NativeBridge.showPrivacyPolicyView();
}


clickSend(){

  if (this.state.second == 0) {
    this.sendSmsForMobile();
  }

}


sendSmsForMobile(){


  this.setState({
      code: DateUtil.randomCode(),
  });

  Loading.show();

  var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:sendSmsForMobile id="o0" c:root="1" xmlns:n0="http://terra.systems/"><params i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
  '<item><key i:type="d:string">company_id</key><value i:type="d:string">97</value></item><item>'+
  '<key i:type="d:string">mobile</key><value i:type="d:string">'+this.state.number + '</value></item>'+
  '<item><key i:type="d:string">message</key><value i:type="d:string">Your OTP is '+ this.state.code + '. Please enter the OTP within 2 minutes</value></item>'+
  '<item><key i:type="d:string">title</key><value i:type="d:string">Sign Up</value></item></params></n0:sendSmsForMobile></v:Body></v:Envelope>';
  var temporary = this;


  WebserviceUtil.getQueryDataResponse('sms','sendSmsForMobileResponse',data, function(json) {

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


 clickCode(code){
   this.showOTPPopup();
 }


 showOTPPopup(){

    // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_otp_bg}>


                          <View style = {styles.view_otp_line}>



                             <TouchableHighlight
                              underlayColor = {'#90AFBD'}
                              onPress={this.clickNumber.bind(this,'1')}
                              style = {styles.view_otp_item}>

                                <View style = {styles.view_otp_item_2}>

                                  <Text style = {styles.text_opt}>1</Text>

                                 </View>

                             </TouchableHighlight> 



                            


                            <TouchableHighlight
                              underlayColor = {'#90AFBD'}
                              onPress={this.clickNumber.bind(this,'2')}
                              style = {styles.view_otp_item}>

                                <View style = {styles.view_otp_item_2}>

                                  <Text style = {styles.text_opt}>2</Text>

                                 </View>

                             </TouchableHighlight> 


                             <TouchableHighlight
                              underlayColor = {'#90AFBD'}
                              onPress={this.clickNumber.bind(this,'3')}
                              style = {styles.view_otp_item}>

                                <View style = {styles.view_otp_item_2}>

                                  <Text style = {styles.text_opt}>3</Text>

                                 </View>

                             </TouchableHighlight> 


                          </View>


                          <View style = {styles.view_otp_line}>


                             <TouchableHighlight
                              underlayColor = {'#90AFBD'}
                              onPress={this.clickNumber.bind(this,'4')}
                              style = {styles.view_otp_item}>

                                <View style = {styles.view_otp_item_2}>

                                  <Text style = {styles.text_opt}>4</Text>

                                 </View>

                             </TouchableHighlight> 


                             <TouchableHighlight
                              underlayColor = {'#90AFBD'}
                              onPress={this.clickNumber.bind(this,'5')}
                              style = {styles.view_otp_item}>

                                <View style = {styles.view_otp_item_2}>

                                  <Text style = {styles.text_opt}>5</Text>

                                 </View>

                             </TouchableHighlight> 


                             <TouchableHighlight
                              underlayColor = {'#90AFBD'}
                              onPress={this.clickNumber.bind(this,'6')}
                              style = {styles.view_otp_item}>

                                <View style = {styles.view_otp_item_2}>

                                  <Text style = {styles.text_opt}>6</Text>

                                 </View>

                             </TouchableHighlight> 


                          </View>


                          <View style = {styles.view_otp_line}>


                              <TouchableHighlight
                              underlayColor = {'#90AFBD'}
                              onPress={this.clickNumber.bind(this,'7')}
                              style = {styles.view_otp_item}>

                                <View style = {styles.view_otp_item_2}>

                                  <Text style = {styles.text_opt}>7</Text>

                                 </View>

                             </TouchableHighlight> 


                              <TouchableHighlight
                              underlayColor = {'#90AFBD'}
                              onPress={this.clickNumber.bind(this,'8')}
                              style = {styles.view_otp_item}>

                                <View style = {styles.view_otp_item_2}>

                                  <Text style = {styles.text_opt}>8</Text>

                                 </View>

                             </TouchableHighlight> 



                             <TouchableHighlight
                              underlayColor = {'#90AFBD'}
                              onPress={this.clickNumber.bind(this,'9')}
                              style = {styles.view_otp_item}>

                                <View style = {styles.view_otp_item_2}>

                                  <Text style = {styles.text_opt}>9</Text>

                                 </View>

                             </TouchableHighlight> 


                          </View>


                          <View style = {[styles.view_otp_line,{marginBottom:40}]}>


                              <View style = {[styles.view_otp_item,{backgroundColor:'#BDBDBD'}]}>


                                

                              </View>


                              <TouchableHighlight
                              underlayColor = {'#90AFBD'}
                              onPress={this.clickNumber.bind(this,'0')}
                              style = {styles.view_otp_item}>

                                <View style = {styles.view_otp_item_2}>

                                  <Text style = {styles.text_opt}>0</Text>

                                 </View>

                             </TouchableHighlight> 



                             <TouchableOpacity
                              onPress={this.clickNumber.bind(this,'-1')}
                              style = {[styles.view_otp_item,{backgroundColor:'#BDBDBD'}]}>


                                 <View style = {[styles.view_otp_item_2]}>

                                  <Image style = {{width:46,height:34}} 
                                      resizeMode = 'contain' 
                                      source={require('../../../images/delete_03_22.png')}/>

                                  
                              </View>



                             </TouchableOpacity>
                              



                             

                          </View>


                      
                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);


  } 


  clickNumber(str_number){

    if (str_number == '-1') {

      //删

       if (this.state.code4 != undefined) {
          this.setState({
            code4:undefined,
          });
        
        }else if (this.state.code3 != undefined) {

          this.setState({
            code3:undefined,
          });


        }else if (this.state.code2 != undefined) {

          this.setState({
            code2:undefined,
          }); 
          
        }else if (this.state.code1 != undefined) {

          this.setState({
            code1:undefined,
          }); 
          
        }



    }else {

      //增

       if (this.state.code1 == undefined) {
          this.setState({
            code1:str_number,
      
          });
         
        }else if (this.state.code2 == undefined) {
          this.setState({
            code2:str_number,

          });
       
        }else if (this.state.code3 == undefined) {
          this.setState({
            code3:str_number,
         
          });
         
        }else if (this.state.code4 == undefined) {
          this.setState({
            code4:str_number,
          });

          // var  new_code = this.state.code1 + this.state.code2 + this.state.code3 + str_number ; 


          // if (new_code == this.state.code || new_code == '1024') {

          //    this.toSignUp2_1Activity();

          // }


        }
    }

  }


  clickNext(){

    if (this.state.code1 &&  this.state.code2 && this.state.code3 && this.state.code4 ) {

      var  new_code = this.state.code1 + this.state.code2 + this.state.code3 + this.state.code4  ; 

       if (new_code == this.state.code || new_code == '1024') {

             this.toSignUp2_1Activity();

      }else {

         toastShort('Verification code error');
      }


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

                <Text style = {styles.text_title}>We have sent the verification code to {this.state.number}</Text>

              </View>     


               <View style = {styles.view_content}>


                  <View style = {styles.view_code1}>

                    <TouchableOpacity
                      style = {styles.view_code2}
                      activeOpacity = {1}
                      onPress={this.clickCode.bind(this,'cdode1')}>

                      <View style = {[styles.view_code2,{padding:0}]}>

                        <Text style = {styles.text_input}>{this.state.code1 != undefined ? this.state.code1 : ''}</Text>

                      </View>

                    </TouchableOpacity>


                     <TouchableOpacity
                      style = {styles.view_code2}
                      activeOpacity = {1}
                      onPress={this.clickCode.bind(this,'cdode2')}>

                      <View style = {[styles.view_code2,{padding:0}]}>

                        <Text style = {styles.text_input}>{this.state.code2 != undefined ? this.state.code2 : ''}</Text>

                      </View>


                    </TouchableOpacity>


                    <TouchableOpacity
                      style = {styles.view_code2}
                      activeOpacity = {1}
                      onPress={this.clickCode.bind(this,'cdode3')}>

                      <View style = {[styles.view_code2,{padding:0}]}>

                        <Text style = {styles.text_input}>{this.state.code3 != undefined ? this.state.code3 : ''}</Text>

                      </View>


                    </TouchableOpacity>




                    <TouchableOpacity
                      style = {styles.view_code2}
                      activeOpacity = {1}
                      onPress={this.clickCode.bind(this,'cdode4')}>

                      <View style = {[styles.view_code2,{padding:0}]}>

                        <Text style = {styles.text_input}>{this.state.code4 != undefined ? this.state.code4 : ''}</Text>

                      </View>


                    </TouchableOpacity>

                  </View>



                  <View style = {styles.view_resend}>

                      <Text style = {styles.text_foot_content}>Did not receive?</Text>


                      <TouchableOpacity   
                          activeOpacity = {this.state.second == 0 ? 0.8 : 1}
                          onPress={this.clickSend.bind(this)}>


                          <Text style = {styles.text_foot_title}>Resend Code</Text>

                      </TouchableOpacity>


                  </View>



                  <Text style = {styles.text_minth}>{this.state.second >= 10 ? '00:' + this.state.second : '00:0' + this.state.second}</Text>  



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
                              onPress={this.clickPrivacyPolicy.bind(this)}>


                            <Text style = {styles.text_foot_title}>Privacy Policy</Text>



                          </TouchableOpacity>

                        


                      </View>

                      

                  </View>



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


        <CoverLayer
                 coverLayerColor = {'rgba(0,0,0,0.0)'}
                ref={ref => this.coverLayer = ref}/>





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
  view_title : {
    marginLeft:24,
    marginTop:8,
    width:'100%',
  },
  text_title :{
    marginRight:24,
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
  view_code1:{
    marginTop:8,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  view_code2:{
    width:75,
    height:75,
    backgroundColor:'#FAF3EB',
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  text_input :{
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
  view_otp_bg:{
    width:'100%',
    backgroundColor:'#BDBDBD',
    padding:10,
  },
  view_otp_line:{
    width:'100%',
    flexDirection: 'row',
    height:55,
  },
  view_otp_item:{
    flex:1,
    margin:2,
    borderRadius:4,
    backgroundColor:'#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_otp_item_2:{
     flex:1,
     borderRadius:4,
     justifyContent: 'center',
     alignItems: 'center'
  },
  text_opt:{
    color:'#000',
    fontWeight:'bold',
    fontSize:20
  }
});




