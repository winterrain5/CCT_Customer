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


import { Loading } from '../../widget/Loading';


import DeviceStorage from '../../uitl/DeviceStorage';


import WebserviceUtil from '../../uitl/WebserviceUtil';


import MD5 from "react-native-md5";


import {CommonActions,useNavigation} from '@react-navigation/native';

let nativeBridge = NativeModules.NativeBridge;

export default class FristActivity extends Component {

	constructor(props) {
    super(props);
    this.state = {
    	isFirst:true,
    	login_name:undefined,
    	login_password:undefined,
      user_id:undefined,
      client_id:undefined,
    }
  }


  //
  UNSAFE_componentWillMount(){


  	DeviceStorage.get('isFirst').then((isFirst) => {


  		if (isFirst) {
  			this.setState({
        		isFirst: true,
      		});
  		}else {
  			this.setState({
        		isFirst: false,
      		});

  		}

    });

    DeviceStorage.get('login_name').then((login_name) => {


      this.setState({
          login_name: login_name,
      });

    });

    DeviceStorage.get('login_password').then((login_password) => {


      this.setState({
          login_password: login_password,
      });

    });

  }


componentDidMount(){

 	this.getParentCompanyBySysName();

}





getParentCompanyBySysName(){


	var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getParentCompanyBySysName id="o0" c:root="1" xmlns:n0="http://terra.systems/"><systemName i:type="d:string">TCM</systemName></n0:getParentCompanyBySysName></v:Body></v:Envelope>';


  Loading.show();
	var temporary = this;
	WebserviceUtil.getQueryDataResponse('company','getParentCompanyBySysNameResponse',data, function(json) {


		    Loading.hidden();

        if (json && json.success == 1 && json.data.length > 0) {

        	DeviceStorage.save('head_company_id', json.data);
          nativeBridge.setCompanyId(json.data);
        }else {

        	DeviceStorage.save('head_company_id', '97');
          nativeBridge.setCompanyId('97');
        } 

        temporary.toLoginOrOnboarding();


    });

}


toLoginOrOnboarding(){

	if (!this.state.isFirst) {

		const { navigation } = this.props;
    
       Loading.hidden();
    	if (navigation) {
      		 navigation.replace('OnboardingActivity');
    	}
	}else {

		if (this.state.login_name && this.state.login_password) {

			 this.tonNmberLogin();
		}else {
      Loading.hidden();
			this.toLogin();
		}	



	}
}

tonNmberLogin(){

  // 进行手机号登录
   this.numberLogin();

}


 numberLogin(){

    var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getQueryData id="o0" c:root="1" xmlns:n0="http://terra.systems/"><statement i:null="true" /><select i:type="d:string">u.id,u.password,u.mobile,u.email</select><from i:type="d:string">t_user u</from><type i:type="d:string">1</type><where i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">u.mobile</key><value i:type="d:string">'+ this.state.login_name +'</value>'+
    '</item><item><key i:type="d:string">u.role_id</key><value i:type="d:string">11</value></item><item><key i:type="d:string">u.is_delete</key><value i:type="d:string">0</value></item></where></n0:getQueryData></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('query','getQueryDataResponse',data, function(json) {

        
        if (json && json.success == 1 && json.data && json.data.length > 0) {


            if (json.data[0].password == MD5.hex_md5(temporary.state.login_password)) {


              temporary.setState({
                user_id:json.data[0].id,
              });

              temporary.loginUserData();
            }else {
              
               temporary.emailLogin();  

            }    
        }else {
         
          temporary.emailLogin();  
         
        }       
    });

  }


 emailLogin(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getQueryData id="o0" c:root="1" xmlns:n0="http://terra.systems/"><statement i:null="true" /><select i:type="d:string">u.id,u.password,u.mobile,u.email</select><from i:type="d:string">t_user u</from><type i:type="d:string">1</type><where i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap"><item><key i:type="d:string">u.role_id</key><value i:type="d:string">11</value></item>'+
    '<item><key i:type="d:string">u.email</key><value i:type="d:string">'+ this.state.login_name +'</value></item>'+
    '<item><key i:type="d:string">u.is_delete</key><value i:type="d:string">0</value></item></where></n0:getQueryData></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('query','getQueryDataResponse',data, function(json) {

        
        if (json && json.success == 1 && json.data && json.data.length > 0 && json.data[0].password == MD5.hex_md5(temporary.state.login_password)) {

            // 邮箱登录成功，进行邮箱信息发送
            temporary.setState({
                user_id:json.data[0].id,
              });

            temporary.loginUserData();

        }else {
          Loading.hidden();
          temporary.toLogin(); 
           
         
        }       
    });


  }


loginUserData(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTClientByUserId id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<userId i:type="d:string">'+ this.state.user_id +'</userId></n0:getTClientByUserId></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('client','getTClientByUserIdResponse',data, function(json) {
        if (json && json.success == 1 && json.data) {

            // 邮箱登录成功，进行邮箱信息发送
            temporary.setState({
                client_id:json.data.id,
              });

            temporary.getTClientPartInfo(json.data.id); 
             
        }else {
            temporary.toLogin();
         
        }       
    });

  }


  getTClientPartInfo(client_id){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTClientPartInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ client_id+'</clientId>'+
    '</n0:getTClientPartInfo></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('client','getTClientPartInfoResponse',data, function(json) {

       
         Loading.hidden();
        if (json && json.success == 1 && json.data ) {

            temporary.toMainActivity(json.data);

        }else {
         
           toastShort('Login failed！')
        }

    });


  }


toLogin(){

   const { navigation } = this.props;
   if (navigation) {
      // navigation.replace('LoginActivity');
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


toMainActivity(userBean){


  
  DeviceStorage.save('login_user_id', this.state.user_id);
  DeviceStorage.save('login_client_id', this.state.client_id); 
  DeviceStorage.save('UserBean', userBean); 
  
  nativeBridge.setClientId(this.state.client_id.toString());
  nativeBridge.setUserId(this.state.user_id.toString());

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

  
 render() {

    return (

    	<View style = {styles.bg}>
    	  <StatusBar barStyle="light-content" hidden = {true}/>

          <SafeAreaView>


          </SafeAreaView>

    	
    	</View>


    );
}
}

const styles = StyleSheet.create({
  bg: {
  	flex:1,
  	backgroundColor:'#FAF3E8'
  },
  engine: {
    position: 'absolute',
    right: 0,
  },
});
