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

import { WebView } from "react-native-webview";

import TitleBar from '../../../widget/TitleBar';


export default class OurServiceActivity extends Component {

  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
    }
  }

  render() {

    const { navigation } = this.props;

    return(

      <View style = {styles.bg}>

        <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

        <SafeAreaView style = {styles.afearea} >

            <TitleBar
              title = {'Service'} 
              navigation={navigation}
              hideLeftArrow = {true}
              hideRightArrow = {false}
              extraData={this.state}/>


            <View style = {styles.view_content}>

                 <WebView
                    source={{uri: 'http://info.chienchitow.com/services/'}}
                    style={{flex: 1}}/>



            </View>
              
        </SafeAreaView>

        <SafeAreaView style = {styles.afearea_foot} />     

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
    flex:1,
    backgroundColor:'#FFFFFF'
  }
});

