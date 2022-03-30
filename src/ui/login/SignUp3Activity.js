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


import DeviceStorage from '../../uitl/DeviceStorage';

import IparInput from '../../widget/IparInput';

import CheckBox from 'react-native-check-box'

import { toastShort } from '../../uitl/ToastUtils';

import WebserviceUtil from '../../uitl/WebserviceUtil';

import { Loading } from '../../widget/Loading';


import StringUtils from '../../uitl/StringUtils';

const { StatusBarManager } = NativeModules;



export default class SignUp3Activity extends Component {


  constructor(props) {
    super(props);
    this.state = {
      head_company_id:'97',
      number:undefined,
      email:undefined,
      password:undefined,
      re_password:undefined,
      card_number:undefined,
      isOneChecked:true,
      userBean:undefined,
      password_show:true,
      re_password_show:true,
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
        card_number:this.props.route.params.card_number,
        userBean:this.props.route.params.userBean,
        email:this.props.route.params.userBean ? this.props.route.params.userBean.email : undefined,
      });
    }



  }

 

  back(){

      this.props.navigation.goBack();
  }


  clickTerms(){



  }


  clickNext(){

    if (this.state.email && StringUtils.isPassword(this.state.password) && StringUtils.isPassword(this.state.re_password)) {

      if (this.state.password != this.state.re_password) {
          toastShort('Password is inconsistent with Re-enter Password');
      }else {

          if (this.state.userBean && this.state.userBean.email == this.state.email) {
              this.toSignUp4Activity();
          }else {
            this.userEmailExists();
          }


          

      } 
    }
  }


  userEmailExists(){

    var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:userEmailExists id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<email i:type="d:string">'+this.state.email+'</email>'+
    '</n0:userEmailExists></v:Body></v:Envelope>';

    Loading.show();


    var temporary = this;


    WebserviceUtil.getQueryDataResponse('client','userEmailExistsResponse',data, function(json) {

        Loading.hidden();
        if (json) {
          if (json.success == 1 && json.data == 0) {
               temporary.toSignUp4Activity();
          }else {
            toastShort('Email already exists')
          }

        }else {
          
          toastShort('Network request failed！');
        } 


    });

  }


  

 toSignUp4Activity(){

    const { navigation } = this.props;
    
    if (navigation) {
      navigation.navigate('SignUp4Activity',{
        'number':this.state.number,
        'email':this.state.email,
        'password':this.state.password,
        'card_number':this.state.card_number,
        'userBean':this.state.userBean,
      });
    }



 }


emailError(){


  if (!this.state.email || StringUtils.isEmail(this.state.email)) {


    return (<View></View>);


  }else {

    return (

        <View style = {styles.view_eamil_error} >

          <Text style = {styles.text_error}>・Email entered is invalid</Text>

        </View>

    );

  }

}

passwordError(){

  if (!this.state.password || StringUtils.isPassword(this.state.password)) {


       return (<View></View>)


  }else {

      return ( <View style = {styles.view_eamil_error} >

                  <Text style = {styles.text_error}>・Passwords need to be at least 6 characters</Text>

                  <Text style = {styles.text_error}>・At least one lowercase character</Text>

                  <Text style = {styles.text_error}>・At lease one uppercase character</Text>

                  <Text style = {styles.text_error}>・Must have numerical number</Text>

              </View>);

  }

}


clickPasswordShow(){

  this.setState({
    password_show : !this.state.password_show,
  });


}


clickRePasswordShow(){

  this.setState({
    re_password_show : !this.state.re_password_show,
  });


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
                <View style = {styles.view_progress_2}/>
                <View style = {styles.view_progress_2}/>
                <View style = {styles.view_progress_3}/>


              </View>


              <View style = {styles.zhanwei1}/>



            </View>



           <View style = {styles.view_title} >

              <Text style = {styles.text_title}>Register your Account</Text>

           </View>     


           <View style = {styles.view_content}>


             <View style = {styles.view_iparinput}>

                 <View style = {styles.view_input}>


                  <IparInput 
                     valueText = {this.state.email}
                     placeholderText={'Email Address*'}
                     onChangeText={(text) => {
                          
                        this.setState({email:text})
                    }}/>

                 </View>         

              </View>

              {this.emailError()}


            <View style = {styles.view_iparinput}>


                <View style = {styles.view_input}>


                  <IparInput
                     valueText = {this.state.password}
                     isPassword = {this.state.password_show} 
                     placeholderText={'Password*'}
                     onChangeText={(text) => {
                          
                        this.setState({password:text})
                    }}/>


                </View>


                <TouchableOpacity
                    activeOpacity = {0.8}
                    onPress={this.clickPasswordShow.bind(this)}>

                     <Image style = {styles.image_pass} 
                      resizeMode = 'contain' 
                      source={this.state.password_show ? require('../../../images/0114_biyan.png') : require('../../../images/0114_kaiyan.png')}/>


                 </TouchableOpacity>  

    
            </View>    


             {this.passwordError()}



            <View style = {styles.view_iparinput}>


                <View style = {styles.view_input} >

                   <IparInput
                     valueText = {this.state.re_password}  
                     isPassword = {this.state.re_password_show} 
                     placeholderText={'Re-enter password*'}
                     onChangeText={(text) => {
                          
                        this.setState({re_password:text})
                    }}/>

                </View>

                 <TouchableOpacity
                    activeOpacity = {0.8}
                    onPress={this.clickRePasswordShow.bind(this)}>

                     <Image style = {styles.image_pass} 
                      resizeMode = 'contain' 
                      source={this.state.re_password_show ? require('../../../images/0114_biyan.png') : require('../../../images/0114_kaiyan.png')}/>


                 </TouchableOpacity>


               


            </View>   

            

             <View style = {[styles.bg,{backgroundColor:'#FFFFFF'}]}/>



             <View style = {styles.next_view}>

                <TouchableOpacity style = {[styles.next_layout,{backgroundColor:(this.state.email && StringUtils.isPassword(this.state.password) && StringUtils.isPassword(this.state.re_password)) ? '#C44729':'#BDBDBD'}]}  
                    activeOpacity = {(this.state.email && StringUtils.isPassword(this.state.password) && StringUtils.isPassword(this.state.re_password))  ? 0.8: 1}
                    onPress={this.clickNext.bind(this)}>


                <Text style = {styles.next_text}>Next</Text>



                </TouchableOpacity>



            </View>


            

          </View>
             


          </SafeAreaView>



          <SafeAreaView style = {styles.afearea_foot} /> 


       </View>

    )

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
  view_content:{
    marginTop:32,
    padding:24,
    flex:1,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16
  },
  view_iparinput:{
    marginTop:16,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  view_input : {
    flex:1
  },
  image_pass: {
    marginTop:30,
    width:20,
    height:20
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
  view_eamil_error : {
    marginTop:16

  },

  text_error: {
      fontSize:12,
      color:'#C44729',
  }


});