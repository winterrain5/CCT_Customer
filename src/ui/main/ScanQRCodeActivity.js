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
  Dimensions,
  NativeModules
} from 'react-native';

import { QRScannerView } from 'react-native-qrcode-scanner-view';

import CoverLayer from '../../widget/xpop/CoverLayer';

import TitleBar from '../../widget/TitleBar';


export default class ScanQRCodeActivity extends Component {

    constructor(props) {
      super(props);
      this.state = { 
         service:undefined,
         type:0, // 0 : check in  1: 首页 : 2 : 登陆页
         scanFinish:0
      }
    }

    UNSAFE_componentWillMount(){


      if (this.props.route && this.props.route.params) {
        this.setState({
          service:this.props.route.params.service,
          type:this.props.route.params.type,
        });
      }

  }


  renderTitleBar() {

      return (

          <Text style={{color:'white',textAlign:'center',padding:16,marginTop:50, fontSize:24,fontWeight:'bold',}} >Scan the QR Code</Text>

        );

  }


    renderMenu(){

      return (

          <View style = {styles.view_menu}>


               <Image style = {styles.image_tier} 
                      resizeMode = 'contain' 
                      source={require('../../../images/bai_gantan.png')}/>    


                <TouchableOpacity   
                  activeOpacity = {0.8 }
                  onPress={this.clickShowPopup.bind(this)}>


                   <Text style = {styles.text_code}>Where's the QR Code?</Text>
                  

                </TouchableOpacity>      

              
            
          </View>

          

        );

    }


    clickShowPopup(){

         // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                            <Text style = {[styles.text_popup_title]}>Where's the QR Code?</Text>


                              <View style = {styles.view_popup_item}>


                                <Image style = {{width:80,height:80}} 
                                      resizeMode = 'contain' 
                                      source={require('../../../images/qecode2.png')}/> 



                                 <Text style = {styles.text_service_title}>Reception Desk</Text>

                

                              <Text style = {styles.text_service_content}>QR code is located on top of our Reception Desk where our staff is to welcome you</Text>                        

                           </View>  



                          <View style = {styles.view_popup_item}>


                                <Image style = {{width:80,height:80}} 
                                      resizeMode = 'contain' 
                                      source={require('../../../images/qrcode1.png')}/> 



                                 <Text style = {styles.text_service_title}>Waiting Area</Text>


                          

                              <Text style = {styles.text_service_content}>QR code is located on the wall at the waiting area where seats are made available for waiting</Text>                        

                           </View>    

                          

                   </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);


    }


  
  
    barcodeReceived = (event) => { 

      if (this.state.scanFinish == 1) {
        this.setState({
          scanFinish:0
        });
        return;
      }
      var url = event.data;

      if (url) {
        const { navigation } = this.props;
        
        if (navigation) {
          this.setState({
            scanFinish:1
          });
          navigation.goBack();
        }
        
        NativeModules.NativeBridge.log(url);
        NativeModules.NativeBridge.log("type"+JSON.stringify(this.state.type));
        if (this.state.type == 0) {

          var service = this.state.service;
          service.code_url = url;
          DeviceEventEmitter.emit('service_check_in',JSON.stringify(service));

        }else if (this.state.type == 1) {

          DeviceEventEmitter.emit('ohter_qrcode',url);

        }else if (this.state.type == 2) {

          DeviceEventEmitter.emit('login_qrcode',url);

        }
        

      }
    };



    render() {

      const { navigation } = this.props;

      return (

        <View style = {styles.bg}>


          <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

          <SafeAreaView style = {styles.afearea}>


             <TitleBar
                title = {''} 
                navigation={navigation}
                hideLeftArrow = {true}
                hideRightArrow = {false}
                extraData={this.state}/>


              <QRScannerView
                  hintText = {''}
                  onScanResult={ this.barcodeReceived }
                  renderHeaderView={ this.renderTitleBar.bind(this) }
                  renderFooterView={ this.renderMenu.bind(this)  }
                  scanBarAnimateReverse={ true }/>

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
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16
  },
  view_head:{
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_menu:{
    height:200,
    width:'100%',
    justifyContent: 'center',
    alignItems: 'center',
    flexDirection: 'row',
  },
  image_tier:{
    marginTop:1,
    marginLeft:8,
    width:15,
    height:15,
  },
  text_code:{
    marginLeft:5,
    color:'#FFFFFF',
    fontSize:14,
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
    fontSize:18,
    textAlign :'center',
    fontWeight: 'bold',
  },
  view_popup_item:{
    marginTop:16,
    padding:16,
    borderRadius:16,
    backgroundColor:'#FAF3EB',
    width:'100%',
     justifyContent: 'center',
    alignItems: 'center'
  },
  popup_service_more_head:{

    flexDirection: 'row',
  

  },
  popup_service_more:{
    borderRadius:8,
    width:24,
    height:24,
    backgroundColor:'#EE8F7B',
    justifyContent: 'center',
    alignItems: 'center',
  },
  text_service_title:{
    marginTop:16,
     color:'#145A7C',
     fontSize:18,
     fontWeight:'bold',
  },
  text_service_content:{
    marginTop:16,
    marginBottom:10,
     color:'#333333',
     fontSize:14,
     textAlign :'center',
  }
 
});


