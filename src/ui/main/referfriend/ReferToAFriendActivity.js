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
  Dimensions,
  Linking,
  Share,
} from 'react-native';

import Clipboard from '@react-native-community/clipboard';


import TitleBar from '../../../widget/TitleBar';

import ProgressBar from '../../../widget/ProgressBar';

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import { Loading } from '../../../widget/Loading';

import { toastError, toastShort, toastSuccess } from '../../../uitl/ToastUtils';

import DateUtil from '../../../uitl/DateUtil';

import DeviceStorage from '../../../uitl/DeviceStorage';

import IparInput from '../../../widget/IparInput';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import CheckBox from 'react-native-check-box'

import StringUtils from '../../../uitl/StringUtils';

import {Card} from 'react-native-shadow-cards';

export default class ReferToAFriendActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
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
  }


  clickTCApply(){


  }




  clickShare(type){

    var url = 'sms:';

   if (type == '0') {
      url ='whatsapp:'
   }else if (type == '1') {
      url = 'telegram:'
   } else if (type == '2') {
      url = 'sms:';
   } else if (type == '3') {
      url = 'mailto:';
   } 

    Linking.canOpenURL(url)
      .then(supported => {
        if (!supported) {
            toastError('The phone does not support dialing function!');
        }
        return Linking.openURL(url);
      })
      .catch(err => toastError('The phone does not support dialing function!'));

  }


  clickOtherShare(){

    Share.share({
      message: this.state.userBean.referral_code,
    })
      .then()
      .catch((error) => {});
    
  }


  clickCopyCode(){

    toastSuccess('Copy Success');

    Clipboard.setString(this.state.userBean.referral_code);
    
  }




  render() {

    const { navigation } = this.props;

    return (

       <View style = {styles.bg}>

          <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />


          <SafeAreaView style = {styles.afearea} >

             <TitleBar
              title = {''} 
              navigation={navigation}
              hideLeftArrow = {true}
              hideRightArrow = {false}
              extraData={this.state}/>


              <View style = {styles.view_referral}>


                  <Text style = {styles.text_referral}>{this.state.userBean ? this.state.userBean.referral_code : ''}</Text>


                   <TouchableOpacity 
                      onPress={this.clickCopyCode.bind(this,'0')}
                      activeOpacity = {0.8 }>

                      <Text style = {styles.text_copy}>Copy referral code</Text>

                  </TouchableOpacity>  


              

              </View>


              <Text style = {styles.text_referral_title}>Invite your friends to use the Chien Chi Tow App. </Text>


                <TouchableOpacity 
                    onPress={this.clickTCApply.bind(this,'0')}
                    activeOpacity = {0.8 }>

                    <Text style = {styles.text_referral_hint}>Receive CCT $10 each when they create an account with your code. <Text style = {styles.text_referral_tc_apply}>T&C apply</Text></Text> 

                </TouchableOpacity>    



              <View style = {styles.view_content}>


                  <View style = {styles.view_share}>

                      <TouchableOpacity 

                          onPress={this.clickShare.bind(this,'0')}
                          activeOpacity = {0.8 }>

                          <View style = {styles.view_share_item}>

                               <View style = {styles.view_share_item_image}>

                                 <Image 
                                    style={{width:24,height:24,}}
                                    source={require('../../../../images/lv_dianhua.png')}
                                    resizeMode = 'contain' />

                               </View>


                               <Text style = {styles.text_share}>Whatsapp</Text>

                          </View>

                        
                      </TouchableOpacity>    


                      <TouchableOpacity 

                          onPress={this.clickShare.bind(this,'1')}
                          activeOpacity = {0.8 }>

                          <View style = {styles.view_share_item}>

                               <View style = {styles.view_share_item_image}>


                                <View style = {styles.view_lan_share}>

                                   <Image 
                                    style={{width:12,height:12,marginRight:3}}
                                    source={require('../../../../images/feiji.png')}
                                    resizeMode = 'contain' />

                                </View>

                              
                               </View>


                               <Text style = {styles.text_share}>Telegram</Text>

                          </View>

                        
                      </TouchableOpacity>    



                      <TouchableOpacity 

                          onPress={this.clickShare.bind(this,'2')}
                          activeOpacity = {0.8 }>

                          <View style = {styles.view_share_item}>

                               <View style = {styles.view_share_item_image}>


                                 <View style = {[styles.view_lan_share,{backgroundColor:'#01E13F',borderRadius:4}]}>

                                    <Image 
                                        style={{width:12,height:12,}}
                                        source={require('../../../../images/weixin_message.png')}
                                        resizeMode = 'contain' />


                                 </View>

                                 
                               </View>


                               <Text style = {styles.text_share}>Messages</Text>

                          </View>

                        
                      </TouchableOpacity>    



                      <TouchableOpacity 
                          onPress={this.clickShare.bind(this,'3')}
                          activeOpacity = {0.8 }>

                          <View style = {styles.view_share_item}>

                               <View style = {styles.view_share_item_image}>


        
                                 <View style = {[styles.view_lan_share,{backgroundColor:'#6EE3FF',borderRadius:4}]}>

                                      <Image 
                                          style={{width:12,height:12,}}
                                          source={require('../../../../images/youjian.png')}
                                          resizeMode = 'contain' />


                                   </View>

                                 
                          
                               </View>


                               <Text style = {styles.text_share}>Email</Text>

                          </View>

                        
                      </TouchableOpacity>    




                  </View>


                  <TouchableOpacity 
                      onPress={this.clickOtherShare.bind(this)}
                      activeOpacity = {0.8 }>


                      <Text style = {styles.text_other_share}>Other sharing options</Text>

                  </TouchableOpacity>    



                   


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
    marginTop:5,
    flex:1,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16
  },
  view_referral:{
    marginTop:16,
    marginLeft:48,
    marginRight:48,
    marginBottom:16,
    height:132,
    backgroundColor:'#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_referral:{
    color:'#145A7C',
    fontSize:36,
  },
  text_copy:{
    marginTop:15,
    fontSize:16,
    fontWeight:'bold',
    color:'#C44729',
  },
  text_referral_title:{
    marginTop:16,
    marginBottom:16,
    marginLeft:24,
    marginRight:24,
    fontSize:24,
    fontWeight:'bold',
    color:'#FFFFFF',
  },
  text_referral_hint:{
    marginBottom:16,
    marginLeft:24,
    marginRight:24,
    fontSize:16,
    color:'#FFFFFF',
    opacity: 0.7
  },
  text_referral_tc_apply:{
    marginBottom:16,
    marginLeft:24,
    marginRight:24,
    fontSize:16,
    fontWeight: 'bold',
    color:'#FFFFFF'
  },
  view_share:{
    marginTop:8,
    width:'100%',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  view_share_item_image:{
    width:44,
    height:44,
    backgroundColor:'#F2f2f2',
    borderRadius:50,
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_share_item:{
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_share:{
    marginTop:18,
    fontSize:12,
    color:'#333333',
  },
  view_lan_share:{
    width:24,
    height:24,
    backgroundColor:'#229ACC',
    borderRadius:50,
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_other_share:{

    width:'100%',
    marginTop:32,
    fontSize:14,
    fontWeight:'bold',
    color:'#C44729',
    textAlign :'center',
  }
});



