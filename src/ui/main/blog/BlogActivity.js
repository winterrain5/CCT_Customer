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


export default class BlogActivity extends Component {


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

      if (user_bean) {
        this.setState({
          userBean: user_bean,
        });

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
                  title = {'Blog'} 
                  navigation={navigation}
                  hideLeftArrow = {true}
                  hideRightArrow = {false}
                  extraData={this.state}/>

               <View style = {styles.view_content}>
               

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
});


